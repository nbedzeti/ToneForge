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
        
        // Apply audio effects
        let audioMix = AVMutableAudioMix()
        let audioMixInputParameters = AVMutableAudioMixInputParameters(track: compositionTrack)
        
        // Apply volume boost
        audioMixInputParameters.setVolume(effects.volumeBoost, at: .zero)
        
        // Apply fade in
        if effects.fadeInDuration > 0 {
            audioMixInputParameters.setVolumeRamp(
                fromStartVolume: 0.0,
                toEndVolume: effects.volumeBoost,
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
                fromStartVolume: effects.volumeBoost,
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
    
    /// Analyze audio to suggest optimal volume boost
    static func analyzeAudioLevels(asset: AVAsset) async throws -> Float {
        // This would analyze the audio and return a suggested volume multiplier
        // For now, return 1.0 (no boost)
        // In a full implementation, you'd analyze the waveform peaks
        return 1.0
    }
}
