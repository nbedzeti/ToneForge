//
//  AdManager.swift
//  RingToneMaker
//
//  Created on 1/18/26.
//

import Foundation
import SwiftUI

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

/// Manages rewarded video ads using Google AdMob
@MainActor
class AdManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isAdReady = false
    @Published var isLoadingAd = false
    @Published var lastAdError: String?
    
    // MARK: - Private Properties
    
    #if canImport(GoogleMobileAds)
    private var rewardedAd: GADRewardedAd?
    #endif
    private var rewardCompletion: ((Bool) -> Void)?
    
    // Ad Unit IDs
    private let testAdUnitID = "ca-app-pub-3940256099942544/1712485313" // AdMob test rewarded ad ID
    private let productionAdUnitID = "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY" // Replace with your ID from AdMob console
    
    private var currentAdUnitID: String {
        #if DEBUG
        return testAdUnitID
        #else
        return productionAdUnitID
        #endif
    }
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        loadRewardedAd()
    }
    
    // MARK: - Ad Loading
    
    /// Load a rewarded ad
    func loadRewardedAd() {
        guard !isLoadingAd else { return }
        
        isLoadingAd = true
        lastAdError = nil
        
        print("📺 Loading rewarded ad...")
        
        #if canImport(GoogleMobileAds)
        let request = GADRequest()
        
        GADRewardedAd.load(withAdUnitID: currentAdUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.isLoadingAd = false
                
                if let error = error {
                    print("❌ Failed to load ad: \(error.localizedDescription)")
                    self.lastAdError = error.localizedDescription
                    self.isAdReady = false
                    return
                }
                
                self.rewardedAd = ad
                self.rewardedAd?.fullScreenContentDelegate = self
                self.isAdReady = true
                print("✅ Ad loaded successfully")
            }
        }
        #else
        // Simulate ad loading for testing without SDK
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isLoadingAd = false
            self?.isAdReady = true
            print("✅ [DEBUG] Simulated ad loaded (AdMob SDK not installed)")
        }
        #endif
    }
    
    // MARK: - Ad Presentation
    
    /// Show rewarded ad for extra ringtone creation
    /// - Parameter completion: Called with true if user earned reward, false otherwise
    func showRewardedAdForExtraCreation(completion: @escaping (Bool) -> Void) {
        // Store completion for later
        self.rewardCompletion = completion
        
        #if canImport(GoogleMobileAds)
        guard isAdReady, let ad = rewardedAd else {
            print("⚠️ Ad not ready")
            lastAdError = "Ad not available. Please try again in a moment."
            completion(false)
            
            // Try to load a new ad for next time
            if !isLoadingAd {
                loadRewardedAd()
            }
            return
        }
        
        guard let rootViewController = getRootViewController() else {
            print("❌ No root view controller")
            lastAdError = "Unable to show ad. Please try again."
            completion(false)
            return
        }
        
        print("📺 Showing rewarded ad...")
        
        // Present the ad
        ad.present(fromRootViewController: rootViewController) {
            // This closure is called when user earns the reward
            let reward = ad.adReward
            print("✅ User earned reward: \(reward.amount) \(reward.type)")
            
            Task { @MainActor in
                // Reward will be handled in adDidDismissFullScreenContent
                // to ensure proper timing
            }
        }
        #else
        // Simulate ad watching for testing without SDK
        guard isAdReady else {
            print("⚠️ Ad not ready")
            lastAdError = "Ad not available. Please try again in a moment."
            completion(false)
            
            if !isLoadingAd {
                loadRewardedAd()
            }
            return
        }
        
        print("📺 [DEBUG] Showing simulated ad...")
        
        // Simulate ad watching (2 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            print("✅ [DEBUG] Simulated ad watched")
            self?.isAdReady = false
            self?.rewardCompletion?(true)
            self?.rewardCompletion = nil
            self?.loadRewardedAd()
        }
        #endif
    }
    
    /// Show rewarded ad (generic version)
    /// - Parameter completion: Called with true if user earned reward, false otherwise
    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        showRewardedAdForExtraCreation(completion: completion)
    }
    
    // MARK: - Helper Methods
    
    /// Get root view controller for presenting ads
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        
        // Get the topmost view controller
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        return topController
    }
}

// MARK: - GADFullScreenContentDelegate

#if canImport(GoogleMobileAds)
extension AdManager: GADFullScreenContentDelegate {
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("📊 Ad recorded impression")
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("👆 Ad recorded click")
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Ad failed to present: \(error.localizedDescription)")
        
        Task { @MainActor in
            self.lastAdError = "Failed to show ad: \(error.localizedDescription)"
            self.isAdReady = false
            
            // Call completion with failure
            self.rewardCompletion?(false)
            self.rewardCompletion = nil
            
            // Load next ad
            self.loadRewardedAd()
        }
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("📺 Ad will present")
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("📺 Ad dismissed")
        
        Task { @MainActor in
            self.isAdReady = false
            
            // User watched the ad successfully - call completion with success
            // Note: This is called after the reward closure in present()
            self.rewardCompletion?(true)
            self.rewardCompletion = nil
            
            // Load next ad
            self.loadRewardedAd()
        }
    }
}
#endif
