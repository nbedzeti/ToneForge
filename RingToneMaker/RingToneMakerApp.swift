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
        // Configure global appearance for system sheets
        configureAppearance()
        
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
    
    private func configureAppearance() {
        // Set global tint color to green
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
        
        // Configure navigation bar appearance globally
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        appearance.titleTextAttributes = [.foregroundColor: UIColor(red: 0, green: 1, blue: 0, alpha: 1)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(red: 0, green: 1, blue: 0, alpha: 1)]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
        
        // Configure toolbar appearance
        let toolbarAppearance = UIToolbarAppearance()
        toolbarAppearance.configureWithOpaqueBackground()
        toolbarAppearance.backgroundColor = UIColor.black
        
        UIToolbar.appearance().standardAppearance = toolbarAppearance
        UIToolbar.appearance().compactAppearance = toolbarAppearance
        UIToolbar.appearance().tintColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
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
