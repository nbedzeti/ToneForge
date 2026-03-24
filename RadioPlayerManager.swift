//
//  RadioPlayerManager.swift
//  RingToneMaker
//
//  Handles radio streaming via AVPlayer
//

import Foundation
import AVFoundation

@MainActor
@Observable
class RadioPlayerManager {
    
    var isPlaying = false
    var currentStation: RadioStation?
    var isBuffering = false
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var statusObserver: NSKeyValueObservation?
    
    func play(station: RadioStation) {
        guard let url = station.streamURL else { return }
        
        stop()
        currentStation = station
        isBuffering = true
        
        // Configure audio session
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("❌ Audio session error: \(error)")
        }
        
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Observe buffering state
        statusObserver = playerItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                guard let self = self else { return }
                switch item.status {
                case .readyToPlay:
                    self.isBuffering = false
                    self.isPlaying = true
                case .failed:
                    self.isBuffering = false
                    self.isPlaying = false
                    print("❌ Player failed: \(item.error?.localizedDescription ?? "unknown")")
                default:
                    break
                }
            }
        }
        
        player?.play()
    }
    
    func stop() {
        player?.pause()
        player = nil
        playerItem = nil
        statusObserver?.invalidate()
        statusObserver = nil
        isPlaying = false
        isBuffering = false
    }
    
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else if currentStation != nil {
            player?.play()
            isPlaying = true
        }
    }
    
    nonisolated deinit {
        // Cleanup handled by ARC
    }
}
