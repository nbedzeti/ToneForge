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
        var fadeInDuration: Double = 0.0      // 0-3 seconds
        var fadeOutDuration: Double = 0.0     // 0-3 seconds
        var volumeBoost: Float = 1.0          // 0.5-2.0 (50%-200%)
        var normalizeAudio: Bool = false      // Normalize volume levels
        var equalizerPreset: EqualizerPreset = .none
        
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
    
    // MARK: - Audio Analysis
    
    /// Analyze peak audio level in the specified time range
    private static func analyzePeakLevel(asset: AVAsset, timeRange: CMTimeRange) async throws -> Float {
        // Get audio track
        let audioTracks = try await asset.loadTracks(withMediaType: .audio)
        guard let audioTrack = audioTracks.first else {
            throw NSError(domain: "AudioProcessor", code: -5, userInfo: [NSLocalizedDescriptionKey: "No audio track found for analysis"])
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
            throw NSError(domain: "AudioProcessor", code: -6, userInfo: [NSLocalizedDescriptionKey: "Failed to start reading audio"])
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
    
    // MARK: - Audio Analysis (Legacy)
    
    /// Analyze audio to suggest optimal volume boost
    static func analyzeAudioLevels(asset: AVAsset) async throws -> Float {
        // This would analyze the audio and return a suggested volume multiplier
        // For now, return 1.0 (no boost)
        // In a full implementation, you'd analyze the waveform peaks
        return 1.0
    }
}
