//
//  RingToneMakerApp.swift
//  RingToneMaker
//
//  Created on 1/18/26.
//

import SwiftUI
import AVFoundation
import MediaPlayer

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@main
struct RingToneMakerApp: App {
    @State private var purchaseManager = PurchaseManager()
    
    init() {
        #if canImport(GoogleMobileAds)
        // Initialize Google Mobile Ads SDK
        GADMobileAds.sharedInstance().start(completionHandler: { status in
            print("✅ Google Mobile Ads SDK initialized")
            
            // Log initialization status for each adapter
            for (adapterName, adapterStatus) in status.adapterStatusesByClassName {
                let state = adapterStatus.state.rawValue
                let description = adapterStatus.description
                print("  - \(adapterName): State \(state) - \(description)")
            }
        })
        
        // Configure test devices (optional - for testing)
        #if DEBUG
        print("📱 Using AdMob test ad units for DEBUG builds")
        #endif
        #else
        print("⚠️ AdMob SDK not installed - using debug simulation")
        print("💡 To add AdMob: File > Add Package Dependencies")
        print("   URL: https://github.com/googleads/swift-package-manager-google-mobile-ads.git")
        #endif
        
        // Configure audio session for playback and recording
        configureAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(purchaseManager: purchaseManager)
        }
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
}
