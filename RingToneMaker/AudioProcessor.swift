//
//  AudioProcessor.swift
//  RingToneMaker
//
//  Premium audio processing features
//

import Foundation
import AVFoundation

/// Handles premium audio processing features
class AudioProcessor {
    
    // MARK: - Audio Effects Settings
    
    struct AudioEffects {
        // Volume & Dynamics
        var fadeInDuration: Double = 0.0      // 0-3 seconds
        var fadeOutDuration: Double = 0.0     // 0-3 seconds
        var volumeBoost: Float = 1.0          // 0.5-2.0 (50%-200%)
        var normalizeAudio: Bool = false      // Normalize volume levels
        
        // Reverb
        var reverbEnabled: Bool = false
        var reverbPreset: ReverbPreset = .smallRoom
        var reverbMix: Float = 30.0           // 0-100%
        
        // Echo/Delay
        var echoEnabled: Bool = false
        var echoDelay: Double = 0.3           // 0.1-0.5 seconds
        var echoFeedback: Float = 40.0        // 0-80%
        var echoMix: Float = 30.0             // 0-100%
        
        // Equalizer
        var equalizerPreset: EqualizerPreset = .none
        
        enum ReverbPreset: String, CaseIterable {
            case smallRoom = "Small Room"
            case mediumRoom = "Medium Room"
            case largeRoom = "Large Room"
            case cathedral = "Cathedral"
            case plate = "Plate"
        }
        
        enum EqualizerPreset: String, CaseIterable {
            case none = "None"
            case bassBoost = "Bass Boost"
            case trebleBoost = "Treble Boost"
            case vocal = "Vocal Enhance"
            case balanced = "Balanced"
        }
    }
    
    // MARK: - Export with Effects
    
    /// Export ringtone with premium audio effects applied
    static func exportRingtoneWithEffects(
        asset: AVAsset,
        startTime: Double,
        endTime: Double,
        effects: AudioEffects
    ) async throws -> URL {
        
        // Check if we need advanced effects (Reverb, Echo, EQ)
        let needsAdvancedEffects = effects.reverbEnabled || effects.echoEnabled || effects.equalizerPreset != .none
        
        if needsAdvancedEffects {
            print("🎵 Applying advanced effects (Reverb/Echo/EQ)...")
            // Use two-pass approach: basic effects first, then advanced effects
            return try await exportWithAdvancedEffects(asset: asset, startTime: startTime, endTime: endTime, effects: effects)
        } else {
            // Use simple AVAudioMix for basic effects (faster)
            return try await exportWithBasicEffects(asset: asset, startTime: startTime, endTime: endTime, effects: effects)
        }
    }
    
    // MARK: - Basic Export
    
    /// Export with basic effects using AVAudioMix (fade, volume, normalize)
    private static func exportWithBasicEffects(
        asset: AVAsset,
        startTime: Double,
        endTime: Double,
        effects: AudioEffects
    ) async throws -> URL {
        
        let startCMTime = CMTime(seconds: startTime, preferredTimescale: 600)
        let endCMTime = CMTime(seconds: endTime, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: startCMTime, end: endCMTime)
        
        // Create composition
        let composition = AVMutableComposition()
        
        guard let compositionTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw NSError(domain: "AudioProcessor", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create composition track"])
        }
        
        // Add audio track
        let audioTracks = try await asset.loadTracks(withMediaType: .audio)
        guard let assetTrack = audioTracks.first else {
            throw NSError(domain: "AudioProcessor", code: -2, userInfo: [NSLocalizedDescriptionKey: "No audio track found"])
        }
        
        try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
        
        // Calculate final volume
        var finalVolume = effects.volumeBoost
        
        // If normalize is enabled, analyze and adjust volume
        if effects.normalizeAudio {
            print("🔊 Analyzing audio for normalization...")
            let peakLevel = try await analyzePeakLevel(asset: asset, timeRange: timeRange)
            let normalizeBoost = calculateNormalizeBoost(peakLevel: peakLevel)
            finalVolume *= normalizeBoost
            print("📊 Peak level: \(peakLevel)dB, Normalize boost: \(normalizeBoost)x, Final volume: \(finalVolume)x")
        }
        
        // Apply audio effects
        let audioMix = AVMutableAudioMix()
        let audioMixInputParameters = AVMutableAudioMixInputParameters(track: compositionTrack)
        
        // Apply volume (with normalization if enabled)
        audioMixInputParameters.setVolume(finalVolume, at: .zero)
        
        // Apply fade in
        if effects.fadeInDuration > 0 {
            audioMixInputParameters.setVolumeRamp(
                fromStartVolume: 0.0,
                toEndVolume: finalVolume,
                timeRange: CMTimeRange(
                    start: .zero,
                    duration: CMTime(seconds: effects.fadeInDuration, preferredTimescale: 600)
                )
            )
        }
        
        // Apply fade out
        if effects.fadeOutDuration > 0 {
            let duration = CMTimeGetSeconds(composition.duration)
            let fadeOutStart = duration - effects.fadeOutDuration
            
            audioMixInputParameters.setVolumeRamp(
                fromStartVolume: finalVolume,
                toEndVolume: 0.0,
                timeRange: CMTimeRange(
                    start: CMTime(seconds: fadeOutStart, preferredTimescale: 600),
                    duration: CMTime(seconds: effects.fadeOutDuration, preferredTimescale: 600)
                )
            )
        }
        
        audioMix.inputParameters = [audioMixInputParameters]
        
        // Export
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetAppleM4A
        ) else {
            throw NSError(domain: "AudioProcessor", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to create export session"])
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentsPath.appendingPathComponent("Ringtone_\(Date().timeIntervalSince1970).m4r")
        
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        exportSession.audioMix = audioMix
        
        await exportSession.export()
        
        if exportSession.status == .completed {
            return outputURL
        } else {
            throw exportSession.error ?? NSError(domain: "AudioProcessor", code: -4, userInfo: [NSLocalizedDescriptionKey: "Export failed"])
        }
    }
    
    // MARK: - Advanced Export
    
    /// Export with advanced effects (reverb, echo, EQ) - two-pass approach
    private static func exportWithAdvancedEffects(
        asset: AVAsset,
        startTime: Double,
        endTime: Double,
        effects: AudioEffects
    ) async throws -> URL {
        
        // Pass 1: Export with basic effects to temp file
        let tempURL = try await exportWithBasicEffects(asset: asset, startTime: startTime, endTime: endTime, effects: effects)
        
        // Pass 2: Apply advanced effects using AVAudioEngine
        let finalURL = try await applyAdvancedEffects(inputURL: tempURL, effects: effects)
        
        // Clean up temp file
        try? FileManager.default.removeItem(at: tempURL)
        
        return finalURL
    }
    
    /// Apply advanced effects (reverb, echo, EQ) to an audio file
    private static func applyAdvancedEffects(inputURL: URL, effects: AudioEffects) async throws -> URL {
        
        let audioFile = try AVAudioFile(forReading: inputURL)
        let format = audioFile.processingFormat
        
        // Read entire file into buffer
        let frameCount = AVAudioFrameCount(audioFile.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            throw NSError(domain: "AudioProcessor", code: -5, userInfo: [NSLocalizedDescriptionKey: "Failed to create buffer"])
        }
        
        try audioFile.read(into: buffer)
        
        // Setup audio engine
        let engine = AVAudioEngine()
        let playerNode = AVAudioPlayerNode()
        engine.attach(playerNode)
        
        var lastNode: AVAudioNode = playerNode
        
        // Add Reverb
        if effects.reverbEnabled {
            print("✨ Adding reverb: \(effects.reverbPreset.rawValue) at \(effects.reverbMix)%")
            let reverbNode = AVAudioUnitReverb()
            
            switch effects.reverbPreset {
            case .smallRoom:
                reverbNode.loadFactoryPreset(.smallRoom)
            case .mediumRoom:
                reverbNode.loadFactoryPreset(.mediumRoom)
            case .largeRoom:
                reverbNode.loadFactoryPreset(.largeRoom)
            case .cathedral:
                reverbNode.loadFactoryPreset(.cathedral)
            case .plate:
                reverbNode.loadFactoryPreset(.plate)
            }
            
            reverbNode.wetDryMix = effects.reverbMix
            engine.attach(reverbNode)
            engine.connect(lastNode, to: reverbNode, format: format)
            lastNode = reverbNode
        }
        
        // Add Echo/Delay
        if effects.echoEnabled {
            print("🔁 Adding echo: \(effects.echoDelay)s delay, \(effects.echoFeedback)% feedback")
            let delayNode = AVAudioUnitDelay()
            delayNode.delayTime = effects.echoDelay
            delayNode.feedback = effects.echoFeedback
            delayNode.wetDryMix = effects.echoMix
            engine.attach(delayNode)
            engine.connect(lastNode, to: delayNode, format: format)
            lastNode = delayNode
        }
        
        // Add EQ
        if effects.equalizerPreset != .none {
            print("🎚️ Adding EQ: \(effects.equalizerPreset.rawValue)")
            let eqNode = AVAudioUnitEQ(numberOfBands: 3)
            
            // Configure EQ bands
            let lowBand = eqNode.bands[0]
            lowBand.filterType = .lowShelf
            lowBand.frequency = 100
            lowBand.bandwidth = 1.0
            lowBand.bypass = false
            
            let midBand = eqNode.bands[1]
            midBand.filterType = .parametric
            midBand.frequency = 1000
            midBand.bandwidth = 1.0
            midBand.bypass = false
            
            let highBand = eqNode.bands[2]
            highBand.filterType = .highShelf
            highBand.frequency = 8000
            highBand.bandwidth = 1.0
            highBand.bypass = false
            
            // Apply preset
            switch effects.equalizerPreset {
            case .none:
                break
            case .bassBoost:
                lowBand.gain = 8.0
                midBand.gain = 0.0
                highBand.gain = -2.0
            case .trebleBoost:
                lowBand.gain = -2.0
                midBand.gain = 0.0
                highBand.gain = 8.0
            case .vocal:
                lowBand.gain = -3.0
                midBand.gain = 6.0
                highBand.gain = 2.0
            case .balanced:
                lowBand.gain = 3.0
                midBand.gain = 0.0
                highBand.gain = 3.0
            }
            
            engine.attach(eqNode)
            engine.connect(lastNode, to: eqNode, format: format)
            lastNode = eqNode
        }
        
        // Connect to output
        engine.connect(lastNode, to: engine.mainMixerNode, format: format)
        
        // Prepare output file
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentsPath.appendingPathComponent("Ringtone_\(Date().timeIntervalSince1970).m4r")
        
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try FileManager.default.removeItem(at: outputURL)
        }
        
        let outputFile = try AVAudioFile(forWriting: outputURL, settings: [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: format.sampleRate,
            AVNumberOfChannelsKey: format.channelCount,
            AVEncoderBitRateKey: 128000
        ])
        
        // Enable manual rendering mode
        engine.stop()
        try engine.enableManualRenderingMode(.offline, format: format, maximumFrameCount: 4096)
        
        // Start engine
        try engine.start()
        
        // Schedule buffer
        playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        playerNode.play()
        
        // Render audio
        let maxFrames: AVAudioFrameCount = 4096
        var isFinished = false
        
        while !isFinished {
            guard let renderBuffer = AVAudioPCMBuffer(pcmFormat: engine.manualRenderingFormat, frameCapacity: maxFrames) else {
                break
            }
            
            let framesToRender = min(maxFrames, AVAudioFrameCount(engine.manualRenderingSampleTime + Int64(maxFrames)))
            
            do {
                let status = try engine.renderOffline(framesToRender, to: renderBuffer)
                
                switch status {
                case .success:
                    if renderBuffer.frameLength > 0 {
                        try outputFile.write(from: renderBuffer)
                    }
                case .insufficientDataFromInputNode:
                    isFinished = true
                case .cannotDoInCurrentContext:
                    throw NSError(domain: "AudioProcessor", code: -6, userInfo: [NSLocalizedDescriptionKey: "Cannot render in current context"])
                case .error:
                    throw NSError(domain: "AudioProcessor", code: -7, userInfo: [NSLocalizedDescriptionKey: "Rendering error"])
                @unknown default:
                    throw NSError(domain: "AudioProcessor", code: -8, userInfo: [NSLocalizedDescriptionKey: "Unknown rendering status"])
                }
            } catch {
                print("❌ Rendering error: \(error)")
                throw error
            }
        }
        
        engine.stop()
        
        print("✅ Advanced effects applied successfully")
        
        return outputURL
    }
    
    // MARK: - Audio Analysis
    
    /// Analyze peak audio level in the specified time range
    private static func analyzePeakLevel(asset: AVAsset, timeRange: CMTimeRange) async throws -> Float {
        // Get audio track
        let audioTracks = try await asset.loadTracks(withMediaType: .audio)
        guard let audioTrack = audioTracks.first else {
            throw NSError(domain: "AudioProcessor", code: -9, userInfo: [NSLocalizedDescriptionKey: "No audio track found for analysis"])
        }
        
        // Create asset reader
        let assetReader = try AVAssetReader(asset: asset)
        
        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]
        
        let assetReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
        assetReaderOutput.audioTimePitchAlgorithm = .spectral
        
        assetReader.add(assetReaderOutput)
        assetReader.timeRange = timeRange
        
        guard assetReader.startReading() else {
            throw NSError(domain: "AudioProcessor", code: -10, userInfo: [NSLocalizedDescriptionKey: "Failed to start reading audio"])
        }
        
        var maxSample: Float = 0.0
        
        // Read audio samples and find peak
        while let sampleBuffer = assetReaderOutput.copyNextSampleBuffer() {
            guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else {
                continue
            }
            
            let length = CMBlockBufferGetDataLength(blockBuffer)
            var data = Data(count: length)
            
            data.withUnsafeMutableBytes { (bytes: UnsafeMutableRawBufferPointer) in
                CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: bytes.baseAddress!)
            }
            
            // Convert to Int16 samples and find peak
            data.withUnsafeBytes { (samples: UnsafeRawBufferPointer) in
                let int16Samples = samples.bindMemory(to: Int16.self)
                for sample in int16Samples {
                    let normalizedSample = abs(Float(sample)) / Float(Int16.max)
                    maxSample = max(maxSample, normalizedSample)
                }
            }
        }
        
        // Convert to dB
        let peakDB = maxSample > 0 ? 20 * log10(maxSample) : -96.0
        
        return peakDB
    }
    
    /// Calculate volume boost needed to normalize audio to target level
    private static func calculateNormalizeBoost(peakLevel: Float, targetLevel: Float = -1.0) -> Float {
        // If audio is already at or above target, don't boost
        guard peakLevel < targetLevel else {
            return 1.0
        }
        
        // Calculate boost needed in dB
        let boostDB = targetLevel - peakLevel
        
        // Convert dB to linear gain
        // Limit boost to reasonable range (max +12dB to avoid distortion)
        let limitedBoostDB = min(boostDB, 12.0)
        let linearGain = pow(10.0, limitedBoostDB / 20.0)
        
        return linearGain
    }
}
