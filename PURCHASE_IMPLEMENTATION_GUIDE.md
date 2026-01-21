# Purchase Implementation Guide

## Overview

This guide explains how to integrate the PurchaseManager into your RingToneMaker app.

---

## Files Created

1. **PurchaseManager.swift** - Core StoreKit 2 manager
2. **PurchaseView.swift** - Paywall UI

---

## Integration Steps

### Step 1: Initialize PurchaseManager

In `RingToneMakerApp.swift`:

```swift
import SwiftUI

@main
struct RingToneMakerApp: App {
    @StateObject private var purchaseManager = PurchaseManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(purchaseManager)
        }
    }
}
```

### Step 2: Update ContentView

Add PurchaseManager to ContentView:

```swift
struct ContentView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showingPurchaseView = false
    
    // ... existing code ...
    
    private func trimAndExportAudio() {
        // Check if user can create ringtone
        guard purchaseManager.canCreateRingtone else {
            showingPurchaseView = true
            return
        }
        
        // ... existing export code ...
        
        // After successful export, use a creation
        purchaseManager.useFreeCreation()
    }
}
```

### Step 3: Update Export Button

Replace the export button with:

```swift
Button(action: {
    if purchaseManager.canCreateRingtone {
        trimAndExportAudio()
    } else {
        showingPurchaseView = true
    }
}) {
    HStack {
        if isExporting {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            Text("Creating Ringtone...")
        } else {
            Image(systemName: "scissors")
            if purchaseManager.isPremium {
                Text("Export Ringtone")
            } else if purchaseManager.remainingFreeCreations > 0 {
                Text("Export Ringtone (\(purchaseManager.remainingFreeCreations) free left)")
            } else if purchaseManager.extraCreationsAvailable > 0 {
                Text("Export Ringtone (\(purchaseManager.extraCreationsAvailable) unlocked)")
            } else {
                Text("Watch Ads or Upgrade")
            }
        }
    }
    .font(.headline)
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .padding()
    .background(purchaseManager.canCreateRingtone && !isExporting ? Color.green : Color.gray)
    .cornerRadius(12)
}
.disabled(!purchaseManager.canCreateRingtone || isExporting)
.sheet(isPresented: $showingPurchaseView) {
    PurchaseView(purchaseManager: purchaseManager)
}
```

### Step 4: Add Rewarded Ad Button

If user needs to watch ads:

```swift
if purchaseManager.needsToWatchAdsOrUpgrade && !purchaseManager.isPremium {
    Button(action: {
        purchaseManager.showRewardedAd { success in
            if success {
                alertTitle = "Success"
                alertMessage = "You've unlocked 1 ringtone! (\(purchaseManager.extraCreationsAvailable) available)"
                showingAlert = true
            }
        }
    }) {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "play.rectangle.fill")
                Text("Watch Ad to Unlock")
            }
            .font(.headline)
            
            if purchaseManager.adsWatchedForNextUnlock > 0 {
                Text("\(purchaseManager.adsWatchedForNextUnlock)/3 ads watched")
                    .font(.caption)
            }
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .cornerRadius(12)
    }
    .padding(.horizontal, 20)
}
```

---

## App Store Connect Setup

### 1. Create Subscription Group

1. Go to App Store Connect
2. Select your app
3. Go to "Subscriptions"
4. Click "+" to create subscription group
5. Name: "Premium Access"

### 2. Add Products

#### Monthly Subscription
- **Product ID:** `com.yourapp.ringtonemaker.monthly`
- **Reference Name:** Monthly Premium
- **Duration:** 1 month
- **Price:** $4.99 (Tier 5)
- **Free Trial:** 7 days (optional)

#### Yearly Subscription
- **Product ID:** `com.yourapp.ringtonemaker.yearly`
- **Reference Name:** Yearly Premium
- **Duration:** 1 year
- **Price:** $25.00 (Tier 25)
- **Free Trial:** 7 days (optional)

#### Lifetime Purchase
- **Product ID:** `com.yourapp.ringtonemaker.lifetime`
- **Reference Name:** Lifetime Premium
- **Type:** Non-Consumable
- **Price:** $35.00 (Tier 35)

### 3. Add Localizations

For each product, add:
- **Display Name:** e.g., "Monthly Premium"
- **Description:** e.g., "Unlimited ringtones with no ads"

### 4. Submit for Review

Submit all products for review before app submission.

---

## Testing with Sandbox

### 1. Create Sandbox Tester

1. App Store Connect > Users and Access
2. Sandbox Testers
3. Add new tester with unique email
4. Use this account on test device

### 2. Test Purchases

```swift
// In debug builds, you can test without real purchases
#if DEBUG
// Products will show as sandbox
#endif
```

### 3. Test Scenarios

- [ ] Purchase monthly subscription
- [ ] Purchase yearly subscription
- [ ] Purchase lifetime
- [ ] Restore purchases
- [ ] Cancel subscription (in Settings)
- [ ] Resubscribe
- [ ] Test on multiple devices

---

## StoreKit Configuration File (Optional)

For local testing without App Store Connect:

1. File > New > File > StoreKit Configuration File
2. Add products manually
3. Select configuration in scheme

**Products.storekit:**
```json
{
  "identifier" : "Products",
  "nonRenewingSubscriptions" : [ ],
  "products" : [
    {
      "displayPrice" : "4.99",
      "familyShareable" : false,
      "internalID" : "monthly",
      "localizations" : [ ],
      "productID" : "com.yourapp.ringtonemaker.monthly",
      "referenceName" : "Monthly Premium",
      "type" : "AutoRenewable",
      "subscriptionDuration" : "P1M"
    },
    {
      "displayPrice" : "25.00",
      "familyShareable" : false,
      "internalID" : "yearly",
      "localizations" : [ ],
      "productID" : "com.yourapp.ringtonemaker.yearly",
      "referenceName" : "Yearly Premium",
      "type" : "AutoRenewable",
      "subscriptionDuration" : "P1Y"
    },
    {
      "displayPrice" : "35.00",
      "familyShareable" : true,
      "internalID" : "lifetime",
      "localizations" : [ ],
      "productID" : "com.yourapp.ringtonemaker.lifetime",
      "referenceName" : "Lifetime Premium",
      "type" : "NonConsumable"
    }
  ],
  "settings" : { },
  "subscriptionGroups" : [
    {
      "id" : "premium",
      "localizations" : [ ],
      "name" : "Premium Access",
      "subscriptions" : [
        {
          "adHocOffers" : [ ],
          "codeOffers" : [ ],
          "displayPrice" : "4.99",
          "familyShareable" : false,
          "groupNumber" : 1,
          "internalID" : "monthly",
          "introductoryOffer" : null,
          "localizations" : [ ],
          "productID" : "com.yourapp.ringtonemaker.monthly",
          "recurringSubscriptionPeriod" : "P1M",
          "referenceName" : "Monthly Premium",
          "subscriptionGroupID" : "premium",
          "type" : "RecurringSubscription"
        },
        {
          "adHocOffers" : [ ],
          "codeOffers" : [ ],
          "displayPrice" : "25.00",
          "familyShareable" : false,
          "groupNumber" : 1,
          "internalID" : "yearly",
          "introductoryOffer" : null,
          "localizations" : [ ],
          "productID" : "com.yourapp.ringtonemaker.yearly",
          "recurringSubscriptionPeriod" : "P1Y",
          "referenceName" : "Yearly Premium",
          "subscriptionGroupID" : "premium",
          "type" : "RecurringSubscription"
        }
      ]
    }
  ],
  "version" : {
    "major" : 2,
    "minor" : 0
  }
}
```

---

## Rewarded Ads Integration

### 1. Add Google AdMob

**Podfile:**
```ruby
pod 'Google-Mobile-Ads-SDK'
```

Or **Swift Package Manager:**
```
https://github.com/googleads/swift-package-manager-google-mobile-ads.git
```

### 2. Initialize AdMob

In `RingToneMakerApp.swift`:

```swift
import GoogleMobileAds

@main
struct RingToneMakerApp: App {
    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    // ... rest of code
}
```

### 3. Create AdManager

**AdManager.swift:**
```swift
import GoogleMobileAds

class AdManager: NSObject, ObservableObject {
    @Published var isAdReady = false
    private var rewardedAd: GADRewardedAd?
    
    // Test ad unit ID
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"
    
    func loadRewardedAd() {
        GADRewardedAd.load(withAdUnitID: adUnitID, request: GADRequest()) { [weak self] ad, error in
            if let error = error {
                print("Failed to load ad: \(error.localizedDescription)")
                self?.isAdReady = false
                return
            }
            
            self?.rewardedAd = ad
            self?.isAdReady = true
            print("Ad loaded successfully")
        }
    }
    
    func showRewardedAd(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        guard let ad = rewardedAd else {
            completion(false)
            return
        }
        
        ad.present(fromRootViewController: viewController) {
            let reward = ad.adReward
            print("User earned reward: \(reward.amount) \(reward.type)")
            completion(true)
        }
        
        // Load next ad
        loadRewardedAd()
    }
}
```

### 4. Update PurchaseManager

Replace the placeholder `showRewardedAd` method:

```swift
func showRewardedAd(completion: @escaping (Bool) -> Void) {
    // Get root view controller
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
        completion(false)
        return
    }
    
    // Show ad via AdManager
    adManager.showRewardedAd(from: rootViewController) { [weak self] success in
        if success {
            self?.rewardedAdWatched()
        }
        completion(success)
    }
}
```

---

## Usage Statistics

Display user stats in settings:

```swift
struct SettingsView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    var body: some View {
        List {
            Section("Usage") {
                let stats = purchaseManager.usageStats
                
                LabeledContent("Total Ringtones", value: "\(stats.totalCreations)")
                LabeledContent("Free Used", value: "\(stats.freeCreationsUsed)/3")
                LabeledContent("Ad Unlocked", value: "\(stats.extraCreationsAvailable)")
                LabeledContent("Ads Watched", value: "\(stats.totalAdsWatched)")
                LabeledContent("Member Since", value: stats.memberSince.formatted(date: .abbreviated, time: .omitted))
            }
            
            Section("Premium") {
                LabeledContent("Status", value: stats.isPremium ? "Premium" : "Free")
                LabeledContent("Plan", value: stats.subscriptionStatus.rawValue)
            }
        }
    }
}
```

---

## Error Handling

Handle common errors:

```swift
do {
    try await purchaseManager.purchase(product)
} catch PurchaseError.failedVerification {
    // Show verification error
} catch PurchaseError.productNotFound {
    // Show product not found error
} catch {
    // Show generic error
}
```

---

## Best Practices

### 1. Load Products Early
```swift
.onAppear {
    Task {
        await purchaseManager.loadProducts()
    }
}
```

### 2. Check Premium Status
```swift
if purchaseManager.isPremium {
    // Show premium features
} else {
    // Show upgrade prompt
}
```

### 3. Handle Restore
```swift
Button("Restore Purchases") {
    Task {
        await purchaseManager.restorePurchases()
    }
}
```

### 4. Monitor Transactions
```swift
// PurchaseManager automatically listens for transaction updates
// No additional code needed
```

---

## Debugging

### Enable Logging

```swift
// In PurchaseManager
private let debugMode = true

if debugMode {
    print("🔍 [Purchase] \(message)")
}
```

### Test Reset

```swift
#if DEBUG
Button("Reset Free Creations") {
    purchaseManager.resetFreeCreations()
}
#endif
```

---

## Checklist

- [ ] PurchaseManager integrated
- [ ] Products loaded from App Store
- [ ] Purchase flow works
- [ ] Restore purchases works
- [ ] Free tier tracking works
- [ ] Ad rewards work
- [ ] Premium status updates
- [ ] UI shows correct state
- [ ] Error handling implemented
- [ ] Tested with sandbox
- [ ] Products submitted to App Store Connect

---

## Support

For issues:
1. Check console logs
2. Verify product IDs match
3. Test with sandbox account
4. Check App Store Connect status
5. Review StoreKit documentation

---

**Ready to monetize! 💰**
