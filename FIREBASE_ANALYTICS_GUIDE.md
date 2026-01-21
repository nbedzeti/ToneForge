# Firebase Analytics Integration Guide

Track user behavior, conversions, and revenue for RingToneMaker's monetization system.

---

## Why Firebase Analytics?

- **Free** - No cost for analytics
- **Unlimited Events** - Track everything
- **Real-time Dashboard** - See data instantly
- **Conversion Funnels** - Track free → ad → premium
- **Revenue Tracking** - Automatic IAP revenue tracking
- **Audience Segmentation** - Target specific user groups
- **Integration with AdMob** - Unified reporting

---

## Installation

### Option 1: Swift Package Manager (Recommended)

1. Open Xcode project
2. File > Add Package Dependencies
3. Enter URL:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
4. Select version 10.0.0+
5. Select packages:
   - FirebaseAnalytics
   - FirebaseAnalyticsSwift (for Swift-friendly API)

### Option 2: CocoaPods

Add to `Podfile`:
```ruby
pod 'Firebase/Analytics'
```

Run:
```bash
pod install
```

---

## Setup

### 1. Create Firebase Project

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: "RingToneMaker"
4. Enable Google Analytics
5. Choose or create Analytics account
6. Click "Create project"

### 2. Add iOS App

1. Click iOS icon
2. Enter Bundle ID: `com.yourcompany.ringtonemaker`
3. Enter App nickname: "RingToneMaker"
4. Download `GoogleService-Info.plist`
5. Add to Xcode project (drag into project navigator)
6. Ensure "Copy items if needed" is checked
7. Ensure target membership is checked

### 3. Initialize Firebase

Update `RingToneMakerApp.swift`:

```swift
import SwiftUI
import AVFoundation
import MediaPlayer
import GoogleMobileAds
import FirebaseCore
import FirebaseAnalytics

@main
struct RingToneMakerApp: App {
    @StateObject private var purchaseManager = PurchaseManager()
    
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured")
        
        // Initialize Google Mobile Ads SDK
        GADMobileAds.sharedInstance().start(completionHandler: { status in
            print("✅ Google Mobile Ads SDK initialized")
        })
        
        // Configure audio session
        configureAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(purchaseManager)
                .onAppear {
                    // Log app launch
                    Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
                }
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
```

---

## Analytics Events

### Create Analytics Helper

Create `RingToneMaker/RingToneMaker/AnalyticsManager.swift`:

```swift
//
//  AnalyticsManager.swift
//  RingToneMaker
//
//  Created on 1/18/26.
//

import Foundation
import FirebaseAnalytics

/// Centralized analytics tracking
class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    
    private init() {}
    
    // MARK: - App Events
    
    func logAppLaunch() {
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }
    
    func logFirstLaunch() {
        Analytics.logEvent("first_launch", parameters: nil)
    }
    
    // MARK: - Song Selection
    
    func logSongSelected(title: String, duration: TimeInterval) {
        Analytics.logEvent("song_selected", parameters: [
            "song_title": title,
            "duration": duration
        ])
    }
    
    // MARK: - Free Tier Events
    
    func logFreeCreationUsed(remaining: Int, totalUsed: Int) {
        Analytics.logEvent("free_creation_used", parameters: [
            "remaining": remaining,
            "total_used": totalUsed
        ])
    }
    
    func logFreeLimitReached(timeSinceInstall: TimeInterval) {
        Analytics.logEvent("free_limit_reached", parameters: [
            "time_since_install_hours": timeSinceInstall / 3600
        ])
    }
    
    // MARK: - Rewarded Ads Events
    
    func logAdRequested(trigger: String) {
        Analytics.logEvent("ad_requested", parameters: [
            "ad_type": "rewarded",
            "trigger": trigger
        ])
    }
    
    func logAdLoaded(loadTime: TimeInterval) {
        Analytics.logEvent("ad_loaded", parameters: [
            "ad_type": "rewarded",
            "load_time_ms": loadTime * 1000
        ])
    }
    
    func logAdShown(adUnitID: String) {
        Analytics.logEvent(AnalyticsEventAdImpression, parameters: [
            "ad_type": "rewarded",
            "ad_unit_id": adUnitID
        ])
    }
    
    func logAdRewardEarned(adsWatched: Int, unlocked: Bool) {
        Analytics.logEvent("ad_reward_earned", parameters: [
            "ad_type": "rewarded",
            "ads_watched": adsWatched,
            "unlocked": unlocked
        ])
    }
    
    func logAdFailed(error: String) {
        Analytics.logEvent("ad_failed", parameters: [
            "ad_type": "rewarded",
            "error": error
        ])
    }
    
    // MARK: - Purchase Events
    
    func logPaywallViewed(trigger: String) {
        Analytics.logEvent("paywall_viewed", parameters: [
            "trigger": trigger
        ])
    }
    
    func logProductSelected(productID: String, price: Decimal) {
        Analytics.logEvent("product_selected", parameters: [
            "product_id": productID,
            "price": NSDecimalNumber(decimal: price).doubleValue
        ])
    }
    
    func logPurchaseInitiated(productID: String, price: Decimal) {
        Analytics.logEvent(AnalyticsEventBeginCheckout, parameters: [
            AnalyticsParameterItemID: productID,
            AnalyticsParameterValue: NSDecimalNumber(decimal: price).doubleValue,
            AnalyticsParameterCurrency: "USD"
        ])
    }
    
    func logPurchaseCompleted(productID: String, price: Decimal, transactionID: String) {
        Analytics.logEvent(AnalyticsEventPurchase, parameters: [
            AnalyticsParameterItemID: productID,
            AnalyticsParameterValue: NSDecimalNumber(decimal: price).doubleValue,
            AnalyticsParameterCurrency: "USD",
            AnalyticsParameterTransactionID: transactionID
        ])
    }
    
    func logPurchaseFailed(productID: String, error: String) {
        Analytics.logEvent("purchase_failed", parameters: [
            "product_id": productID,
            "error": error
        ])
    }
    
    func logRestorePurchases(success: Bool) {
        Analytics.logEvent("restore_purchases", parameters: [
            "success": success
        ])
    }
    
    // MARK: - Conversion Events
    
    func logConversionFreeToAd(timeSinceLimit: TimeInterval) {
        Analytics.logEvent("conversion_free_to_ad", parameters: [
            "time_since_limit_minutes": timeSinceLimit / 60
        ])
    }
    
    func logConversionFreeToPremium(productID: String, timeSinceInstall: TimeInterval, freeCreationsUsed: Int) {
        Analytics.logEvent("conversion_free_to_premium", parameters: [
            "product_id": productID,
            "time_since_install_hours": timeSinceInstall / 3600,
            "free_creations_used": freeCreationsUsed
        ])
    }
    
    func logConversionAdToPremium(productID: String, totalAdsWatched: Int, adUnlockedUsed: Int) {
        Analytics.logEvent("conversion_ad_to_premium", parameters: [
            "product_id": productID,
            "total_ads_watched": totalAdsWatched,
            "ad_unlocked_used": adUnlockedUsed
        ])
    }
    
    // MARK: - User Properties
    
    func setUserProperty(isPremium: Bool) {
        Analytics.setUserProperty(isPremium ? "premium" : "free", forName: "user_type")
    }
    
    func setUserProperty(subscriptionType: String) {
        Analytics.setUserProperty(subscriptionType, forName: "subscription_type")
    }
}
```

---

## Integration Points

### 1. ContentView.swift

Add analytics to export flow:

```swift
private func trimAndExportAudio() {
    // ... existing code ...
    
    // Log free creation used
    if !purchaseManager.isPremium && purchaseManager.remainingFreeCreations > 0 {
        AnalyticsManager.shared.logFreeCreationUsed(
            remaining: purchaseManager.remainingFreeCreations - 1,
            totalUsed: purchaseManager.freeCreationsUsed + 1
        )
    }
    
    // ... rest of export code ...
}

private func handleExportAction() {
    guard purchaseManager.canCreateRingtone else {
        // Log limit reached
        let timeSinceInstall = Date().timeIntervalSince(
            UserDefaults.standard.object(forKey: "firstLaunchDate") as? Date ?? Date()
        )
        AnalyticsManager.shared.logFreeLimitReached(timeSinceInstall: timeSinceInstall)
        
        showingLimitAlert = true
        return
    }
    
    trimAndExportAudio()
}

private func watchRewardedAd() {
    // Log ad requested
    AnalyticsManager.shared.logAdRequested(trigger: "free_limit_reached")
    
    purchaseManager.showRewardedAd { [self] success in
        if success {
            // Log conversion
            if purchaseManager.adsWatchedForNextUnlock == 1 {
                let timeSinceLimit = Date().timeIntervalSince(limitReachedDate)
                AnalyticsManager.shared.logConversionFreeToAd(timeSinceLimit: timeSinceLimit)
            }
            
            // ... existing success code ...
        } else {
            // ... existing error code ...
        }
    }
}
```

### 2. PurchaseManager.swift

Add analytics to purchase flow:

```swift
func purchase(_ product: Product) async throws -> Transaction? {
    // Log purchase initiated
    AnalyticsManager.shared.logPurchaseInitiated(
        productID: product.id,
        price: product.price
    )
    
    isLoading = true
    errorMessage = nil
    
    do {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            // Log purchase completed
            AnalyticsManager.shared.logPurchaseCompleted(
                productID: product.id,
                price: product.price,
                transactionID: String(transaction.id)
            )
            
            // Log conversion
            let timeSinceInstall = Date().timeIntervalSince(
                UserDefaults.standard.object(forKey: "firstLaunchDate") as? Date ?? Date()
            )
            
            if totalAdsWatched > 0 {
                AnalyticsManager.shared.logConversionAdToPremium(
                    productID: product.id,
                    totalAdsWatched: totalAdsWatched,
                    adUnlockedUsed: extraCreationsAvailable
                )
            } else {
                AnalyticsManager.shared.logConversionFreeToPremium(
                    productID: product.id,
                    timeSinceInstall: timeSinceInstall,
                    freeCreationsUsed: freeCreationsUsed
                )
            }
            
            // Update user property
            AnalyticsManager.shared.setUserProperty(isPremium: true)
            AnalyticsManager.shared.setUserProperty(subscriptionType: product.id)
            
            await updatePurchasedProducts()
            await transaction.finish()
            
            return transaction
            
        case .userCancelled:
            return nil
            
        case .pending:
            return nil
            
        @unknown default:
            return nil
        }
        
    } catch {
        // Log purchase failed
        AnalyticsManager.shared.logPurchaseFailed(
            productID: product.id,
            error: error.localizedDescription
        )
        
        errorMessage = "Purchase failed: \(error.localizedDescription)"
        throw error
    }
    
    isLoading = false
}

func restorePurchases() async {
    // Log restore attempt
    isLoading = true
    errorMessage = nil
    
    do {
        try await AppStore.sync()
        await updatePurchasedProducts()
        
        // Log restore success
        AnalyticsManager.shared.logRestorePurchases(success: true)
        
    } catch {
        // Log restore failure
        AnalyticsManager.shared.logRestorePurchases(success: false)
        
        errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
    }
    
    isLoading = false
}
```

### 3. AdManager.swift

Add analytics to ad flow:

```swift
func loadRewardedAd() {
    guard !isLoadingAd else { return }
    
    isLoadingAd = true
    lastAdError = nil
    
    let startTime = Date()
    
    GADRewardedAd.load(withAdUnitID: currentAdUnitID, request: request) { [weak self] ad, error in
        guard let self = self else { return }
        
        Task { @MainActor in
            self.isLoadingAd = false
            
            if let error = error {
                // Log ad failed
                AnalyticsManager.shared.logAdFailed(error: error.localizedDescription)
                
                self.lastAdError = error.localizedDescription
                self.isAdReady = false
                return
            }
            
            // Log ad loaded
            let loadTime = Date().timeIntervalSince(startTime)
            AnalyticsManager.shared.logAdLoaded(loadTime: loadTime)
            
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            self.isAdReady = true
        }
    }
}

func showRewardedAdForExtraCreation(completion: @escaping (Bool) -> Void) {
    self.rewardCompletion = completion
    
    guard isAdReady, let ad = rewardedAd else {
        AnalyticsManager.shared.logAdFailed(error: "Ad not ready")
        completion(false)
        return
    }
    
    guard let rootViewController = getRootViewController() else {
        AnalyticsManager.shared.logAdFailed(error: "No root view controller")
        completion(false)
        return
    }
    
    // Log ad shown
    AnalyticsManager.shared.logAdShown(adUnitID: currentAdUnitID)
    
    ad.present(fromRootViewController: rootViewController) {
        let reward = ad.adReward
        print("✅ User earned reward: \(reward.amount) \(reward.type)")
    }
}

// In GADFullScreenContentDelegate
func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    Task { @MainActor in
        self.isAdReady = false
        
        // User watched ad successfully
        self.rewardCompletion?(true)
        self.rewardCompletion = nil
        
        // Load next ad
        self.loadRewardedAd()
    }
}
```

### 4. PurchaseView.swift

Add analytics to paywall:

```swift
var body: some View {
    NavigationView {
        ScrollView {
            // ... existing UI ...
        }
        .onAppear {
            // Log paywall viewed
            AnalyticsManager.shared.logPaywallViewed(trigger: "user_initiated")
        }
    }
}

private func purchaseProduct(_ product: Product) async {
    // Log product selected
    AnalyticsManager.shared.logProductSelected(
        productID: product.id,
        price: product.price
    )
    
    isPurchasing = true
    
    do {
        let transaction = try await purchaseManager.purchase(product)
        
        if transaction != nil {
            dismiss()
        }
    } catch {
        showingError = true
    }
    
    isPurchasing = false
}
```

---

## Dashboard Setup

### 1. Enable Debug View

For testing, enable debug view:

```swift
#if DEBUG
// In RingToneMakerApp.swift init()
Analytics.setAnalyticsCollectionEnabled(true)
print("📊 Analytics enabled for DEBUG")
#endif
```

Run app with `-FIRDebugEnabled` argument:
1. Edit Scheme > Run > Arguments
2. Add: `-FIRDebugEnabled`

### 2. View Events in Firebase Console

1. Go to Firebase Console
2. Select your project
3. Click "Analytics" > "DebugView"
4. Run app on device/simulator
5. See events in real-time

### 3. Create Custom Dashboards

#### Conversion Funnel
1. Analytics > Events
2. Create funnel:
   - Step 1: `app_open`
   - Step 2: `free_creation_used`
   - Step 3: `free_limit_reached`
   - Step 4: `ad_requested` OR `paywall_viewed`
   - Step 5: `purchase`

#### Revenue Dashboard
1. Analytics > Revenue
2. View automatic IAP tracking
3. Filter by product ID
4. Compare monthly vs yearly vs lifetime

---

## Key Metrics to Monitor

### User Acquisition
- **DAU** (Daily Active Users)
- **MAU** (Monthly Active Users)
- **New Users** per day
- **Retention** (D1, D7, D30)

### Engagement
- **Free Creations Used** per user
- **Time to Limit** (install → 3rd creation)
- **Session Length**
- **Sessions per User**

### Monetization
- **Conversion Rate** (free → premium)
- **Ad Watch Rate** (limit reached → ad watched)
- **Ad Completion Rate** (ad started → ad completed)
- **ARPU** (Average Revenue Per User)
- **ARPPU** (Average Revenue Per Paying User)
- **LTV** (Lifetime Value)

### Revenue
- **Daily Revenue** (ads + IAP)
- **Monthly Recurring Revenue** (MRR)
- **Churn Rate** (subscription cancellations)
- **Revenue by Product** (monthly vs yearly vs lifetime)

---

## A/B Testing with Firebase

### Setup Remote Config

1. Firebase Console > Remote Config
2. Add parameters:
   - `free_tier_limit` (default: 3)
   - `ads_per_unlock` (default: 3)
   - `monthly_price` (default: 4.99)
   - `show_yearly_badge` (default: true)

### Implement in Code

```swift
import FirebaseRemoteConfig

class ConfigManager {
    static let shared = ConfigManager()
    private let remoteConfig = RemoteConfig.remoteConfig()
    
    func fetchConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // 1 hour
        remoteConfig.configSettings = settings
        
        remoteConfig.fetch { status, error in
            if status == .success {
                self.remoteConfig.activate()
                print("✅ Remote config fetched")
            }
        }
    }
    
    var freeTierLimit: Int {
        return remoteConfig["free_tier_limit"].numberValue.intValue
    }
    
    var adsPerUnlock: Int {
        return remoteConfig["ads_per_unlock"].numberValue.intValue
    }
}
```

---

## Privacy Compliance

### Update Privacy Manifest

Add to `PrivacyInfo.xcprivacy`:

```xml
<dict>
    <key>NSPrivacyCollectedDataType</key>
    <string>NSPrivacyCollectedDataTypeProductInteraction</string>
    <key>NSPrivacyCollectedDataTypeLinked</key>
    <false/>
    <key>NSPrivacyCollectedDataTypeTracking</key>
    <false/>
    <key>NSPrivacyCollectedDataTypePurposes</key>
    <array>
        <string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
    </array>
</dict>
```

### Disable Analytics for Users Who Opt Out

```swift
// If user opts out of analytics
Analytics.setAnalyticsCollectionEnabled(false)
```

---

## Testing Checklist

- [ ] Firebase SDK installed
- [ ] GoogleService-Info.plist added
- [ ] Firebase initialized in app launch
- [ ] AnalyticsManager created
- [ ] Events integrated in all key flows
- [ ] Debug view shows events in real-time
- [ ] Events appear in Firebase Console
- [ ] User properties set correctly
- [ ] Revenue tracking works
- [ ] Conversion funnels created

---

## Expected Results

### Week 1 Data
- Install to first creation: ~80%
- First to third creation: ~60%
- Limit reached to ad watch: ~30%
- Limit reached to premium: ~5%
- Ad watch to completion: ~70%

### Month 1 Targets
- 1,000+ installs
- 500+ active users
- 50+ premium conversions
- $200+ revenue

---

## Resources

- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [Firebase Analytics](https://firebase.google.com/docs/analytics/get-started?platform=ios)
- [Firebase Remote Config](https://firebase.google.com/docs/remote-config/get-started?platform=ios)
- [Firebase A/B Testing](https://firebase.google.com/docs/ab-testing)

---

**Last Updated:** January 18, 2026  
**Version:** 1.0  
**Status:** Ready to Integrate

---

**📊 Track everything, optimize everything! 🚀**
