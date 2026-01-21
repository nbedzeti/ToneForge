# Google AdMob Integration Guide for RingToneMaker

## ✅ Status: READY TO INTEGRATE

All code is prepared and ready. Just add the SDK and update your Ad Unit IDs!

---

## Overview

This guide walks you through integrating Google AdMob rewarded video ads into RingToneMaker. The integration is **already coded** - you just need to add the SDK and configure your ad units.

---

## Step 1: Add Google Mobile Ads SDK

### Option A: Swift Package Manager (Recommended for 2026)

1. Open your Xcode project
2. Go to **File > Add Package Dependencies**
3. Enter the URL:
   ```
   https://github.com/googleads/swift-package-manager-google-mobile-ads.git
   ```
4. Select version: **11.0.0** or later
5. Click **Add Package**
6. Select **GoogleMobileAds** and click **Add Package**

### Option B: CocoaPods

1. Create a `Podfile` in your project root (if you don't have one):
   ```ruby
   platform :ios, '15.0'
   use_frameworks!

   target 'RingToneMaker' do
     pod 'Google-Mobile-Ads-SDK', '~> 11.0'
   end
   ```

2. Install:
   ```bash
   cd RingToneMaker
   pod install
   ```

3. Open `RingToneMaker.xcworkspace` (not .xcodeproj)

---

## Step 2: Create AdMob Account & App

### 2.1 Sign Up for AdMob

1. Go to [https://admob.google.com](https://admob.google.com)
2. Sign in with your Google account
3. Click **Get Started**

### 2.2 Add Your App

1. Click **Apps** in the sidebar
2. Click **Add App**
3. Select **iOS**
4. Enter app name: **RingToneMaker**
5. Click **Add**
6. Copy your **App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`)

### 2.3 Create Rewarded Ad Unit

1. Click **Ad units** in the sidebar
2. Click **Add Ad Unit**
3. Select **Rewarded**
4. Enter ad unit name: **Ringtone Unlock Reward**
5. Click **Create Ad Unit**
6. Copy your **Ad Unit ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY`)

---

## Step 3: Update Info.plist (Already Done!)

✅ **Already configured** with test IDs and SKAdNetwork identifiers.

**What's included:**
- `GADApplicationIdentifier` - Test App ID (replace with yours)
- `SKAdNetworkItems` - 48 SKAdNetwork IDs for ad attribution
- `NSUserTrackingUsageDescription` - ATT permission message

**Action Required:**
Replace the test App ID with your real App ID from AdMob:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

---

## Step 4: Update Ad Unit IDs in Code

### 4.1 Update AdManager.swift

Open `RingToneMaker/RingToneMaker/AdManager.swift` and replace:

```swift
private let productionAdUnitID = "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"
```

With your **Rewarded Ad Unit ID** from AdMob console.

### 4.2 Test vs Production

The code automatically uses test ads in DEBUG builds:

```swift
private var currentAdUnitID: String {
    #if DEBUG
    return testAdUnitID  // Google's test ID
    #else
    return productionAdUnitID  // Your real ID
    #endif
}
```

---

## Step 5: Test Integration

### 5.1 Build and Run

1. Build the project (Cmd+B)
2. Run on simulator or device (Cmd+R)
3. Check console for initialization:
   ```
   ✅ Google Mobile Ads SDK initialized
   📺 Loading rewarded ad from AdMob...
   ✅ Ad loaded successfully
   ```

### 5.2 Test Ad Flow

1. Use your 3 free ringtone creations
2. Tap **"Watch Ad to Unlock Ringtone"**
3. Ad should load and play (test ad in DEBUG)
4. After watching, you should see:
   - Success toast: "🎉 Unlocked 1 ringtone!"
   - Progress updates: "1/3 ads watched"
5. Export a ringtone with unlocked creation

### 5.3 Test Device IDs (Optional)

To see test ads on a real device:

1. Run the app on your device
2. Check Xcode console for your device ID
3. Add to `RingToneMakerApp.swift`:
   ```swift
   #if DEBUG
   GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [
       "YOUR_DEVICE_ID_HERE"
   ]
   #endif
   ```

---

## Step 6: Handle App Tracking Transparency (ATT)

### 6.1 Request Tracking Permission

AdMob works better with ATT permission. Add this to `ContentView.swift` or `RingToneMakerApp.swift`:

```swift
import AppTrackingTransparency
import AdSupport

func requestTrackingPermission() {
    if #available(iOS 14, *) {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                print("✅ Tracking authorized")
            case .denied:
                print("❌ Tracking denied")
            case .notDetermined:
                print("⏳ Tracking not determined")
            case .restricted:
                print("🚫 Tracking restricted")
            @unknown default:
                break
            }
        }
    }
}
```

Call this after app launch (optional but recommended for better ad targeting).

---

## Step 7: Privacy Manifest (iOS 17+)

### 7.1 Create PrivacyInfo.xcprivacy

Create `RingToneMaker/RingToneMaker/PrivacyInfo.xcprivacy`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <true/>
    <key>NSPrivacyTrackingDomains</key>
    <array>
        <string>googleadservices.com</string>
        <string>google-analytics.com</string>
        <string>googlesyndication.com</string>
        <string>doubleclick.net</string>
    </array>
    <key>NSPrivacyCollectedDataTypes</key>
    <array>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeDeviceID</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <false/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <true/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string>
                <string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
            </array>
        </dict>
        <dict>
            <key>NSPrivacyCollectedDataType</key>
            <string>NSPrivacyCollectedDataTypeProductInteraction</string>
            <key>NSPrivacyCollectedDataTypeLinked</key>
            <false/>
            <key>NSPrivacyCollectedDataTypeTracking</key>
            <true/>
            <key>NSPrivacyCollectedDataTypePurposes</key>
            <array>
                <string>NSPrivacyCollectedDataTypePurposeAnalytics</string>
            </array>
        </dict>
    </array>
    <key>NSPrivacyAccessedAPITypes</key>
    <array>
        <dict>
            <key>NSPrivacyAccessedAPIType</key>
            <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
            <key>NSPrivacyAccessedAPITypeReasons</key>
            <array>
                <string>CA92.1</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

---

## Code Architecture

### Files Modified

1. **RingToneMakerApp.swift**
   - ✅ Imports GoogleMobileAds
   - ✅ Initializes SDK on app launch
   - ✅ Logs initialization status

2. **AdManager.swift**
   - ✅ Full GADRewardedAd implementation
   - ✅ Load/show with delegate callbacks
   - ✅ Error handling with lastAdError
   - ✅ Auto-reload after showing
   - ✅ Test/production ad unit switching

3. **PurchaseManager.swift**
   - ✅ Uses AdManager for rewarded ads
   - ✅ Tracks ad watch progress
   - ✅ Increments extraCreationsAvailable
   - ✅ Handles rewards

4. **ContentView.swift**
   - ✅ Watch ads button
   - ✅ Success toast animation
   - ✅ Error handling with alerts
   - ✅ Progress tracking UI

5. **Info.plist**
   - ✅ GADApplicationIdentifier
   - ✅ SKAdNetworkItems (48 networks)
   - ✅ NSUserTrackingUsageDescription

---

## Ad Flow Diagram

```
User taps "Watch Ad to Unlock Ringtone"
    ↓
ContentView.watchRewardedAd()
    ↓
PurchaseManager.showRewardedAd()
    ↓
AdManager.showRewardedAdForExtraCreation()
    ↓
GADRewardedAd.present()
    ↓
[User watches 15-30 second video]
    ↓
GADFullScreenContentDelegate.adDidDismissFullScreenContent()
    ↓
PurchaseManager.rewardedAdWatched()
    ↓
Increment adsWatchedForNextUnlock
    ↓
If 3 ads watched → extraCreationsAvailable += 1
    ↓
ContentView shows success toast
    ↓
User can export 1 ringtone
```

---

## Testing Checklist

### Debug Mode (Test Ads)
- [ ] App builds without errors
- [ ] SDK initializes successfully
- [ ] Test ad loads (check console)
- [ ] Ad shows when tapping "Watch Ad"
- [ ] Ad plays full video
- [ ] Success toast appears after ad
- [ ] Progress updates (1/3, 2/3, 3/3)
- [ ] After 3 ads, 1 creation unlocked
- [ ] Can export ringtone with unlocked creation
- [ ] New ad loads automatically

### Production Mode (Real Ads)
- [ ] Replace test App ID with real ID
- [ ] Replace test Ad Unit ID with real ID
- [ ] Build in Release mode
- [ ] Real ads load and show
- [ ] Revenue appears in AdMob dashboard
- [ ] No crashes or errors

### Error Handling
- [ ] No internet → Shows "Ad not available" alert
- [ ] Ad fails to load → Shows error message
- [ ] User closes ad early → No reward given
- [ ] Premium user → No ads shown

---

## Troubleshooting

### "Ad failed to load"

**Possible causes:**
1. No internet connection
2. Ad inventory not available (rare with test ads)
3. Wrong Ad Unit ID
4. App ID not in Info.plist
5. SDK not initialized

**Solutions:**
- Check console for detailed error
- Verify Ad Unit ID is correct
- Ensure Info.plist has GADApplicationIdentifier
- Wait a few seconds and try again
- Check AdMob account is active

### "SDK not initialized"

**Solution:**
- Verify GoogleMobileAds is imported in RingToneMakerApp.swift
- Check GADMobileAds.sharedInstance().start() is called
- Look for initialization log in console

### "No ads showing in production"

**Possible causes:**
1. Using test Ad Unit ID in production
2. App not approved in AdMob
3. Payment info not set up in AdMob
4. Ad serving disabled

**Solutions:**
- Replace test IDs with production IDs
- Check AdMob dashboard for app status
- Complete payment setup in AdMob
- Ensure ad units are active

### "Ads showing but no revenue"

**Possible causes:**
1. Still using test ads
2. Invalid clicks/impressions
3. Payment threshold not reached

**Solutions:**
- Verify production Ad Unit IDs are used
- Don't click your own ads
- Check AdMob reports for earnings

---

## Revenue Optimization

### 1. Ad Placement
- ✅ Only show when user needs it (after free limit)
- ✅ Clear value proposition ("Watch 3 ads for 1 ringtone")
- ✅ Optional, not forced

### 2. Ad Frequency
- ✅ 3 ads per unlock (good balance)
- ✅ Can accumulate multiple unlocks
- ✅ No daily limits

### 3. User Experience
- ✅ Success toast for positive feedback
- ✅ Progress bar shows advancement
- ✅ Clear error messages
- ✅ Premium option always available

### 4. Mediation (Advanced)
Consider adding ad mediation for higher eCPM:
- AdMob Mediation
- ironSource
- AppLovin MAX
- Unity Ads

---

## Expected Revenue

### Assumptions
- 1,000 DAU (Daily Active Users)
- 30% watch ads (300 users)
- 3 ads per user = 900 ad impressions/day
- $5 eCPM (earnings per 1000 impressions)

### Calculation
```
Daily:   900 impressions × $5 / 1000 = $4.50/day
Monthly: $4.50 × 30 = $135/month
Yearly:  $135 × 12 = $1,620/year
```

### With Growth
```
10,000 DAU → $1,350/month → $16,200/year
50,000 DAU → $6,750/month → $81,000/year
```

**Note:** Actual eCPM varies by:
- Geography (US/EU higher than others)
- Time of year (Q4 highest)
- Ad quality score
- User engagement

---

## Production Checklist

Before submitting to App Store:

- [ ] Replace test App ID with production ID in Info.plist
- [ ] Replace test Ad Unit ID with production ID in AdManager.swift
- [ ] Remove test device IDs from code
- [ ] Test with real ads in Release build
- [ ] Verify privacy manifest is included
- [ ] Complete AdMob payment setup
- [ ] Enable ad serving in AdMob console
- [ ] Test ATT permission flow
- [ ] Verify SKAdNetwork IDs are up to date
- [ ] Test on multiple devices/iOS versions
- [ ] Check AdMob dashboard for impressions

---

## Support Resources

### Documentation
- [AdMob iOS Quick Start](https://developers.google.com/admob/ios/quick-start)
- [Rewarded Ads Guide](https://developers.google.com/admob/ios/rewarded)
- [Privacy & Messaging](https://developers.google.com/admob/ios/privacy)
- [SKAdNetwork](https://developers.google.com/admob/ios/ios14)

### AdMob Console
- [AdMob Dashboard](https://apps.admob.com)
- [Ad Units](https://apps.admob.com/v2/apps)
- [Reports](https://apps.admob.com/v2/reports)
- [Payment Settings](https://apps.admob.com/v2/payments)

### Code Files
- `RingToneMaker/RingToneMaker/AdManager.swift` - Ad loading/showing
- `RingToneMaker/RingToneMaker/PurchaseManager.swift` - Reward handling
- `RingToneMaker/RingToneMaker/ContentView.swift` - UI integration
- `RingToneMaker/RingToneMaker/Info.plist` - AdMob configuration

---

## Summary

✅ **Code is 100% ready** - Just add SDK and update IDs!

**What's done:**
- Full AdMob integration code
- Rewarded ad loading/showing
- Error handling
- Success feedback
- Progress tracking
- Info.plist configuration
- Privacy manifest template

**What you need to do:**
1. Add Google Mobile Ads SDK (5 minutes)
2. Create AdMob account & app (10 minutes)
3. Update App ID in Info.plist (1 minute)
4. Update Ad Unit ID in AdManager.swift (1 minute)
5. Test! (5 minutes)

**Total time: ~20 minutes** 🚀

---

**Last Updated:** January 18, 2026  
**AdMob SDK Version:** 11.0+  
**iOS Version:** 15.0+  
**Status:** Ready to Integrate

---

## Quick Start Commands

### Add SDK via SPM
```
File > Add Package Dependencies
https://github.com/googleads/swift-package-manager-google-mobile-ads.git
```

### Build & Run
```bash
cd RingToneMaker
open RingToneMaker.xcodeproj
# Press Cmd+R
```

### Check Console
```
✅ Google Mobile Ads SDK initialized
📺 Loading rewarded ad from AdMob...
✅ Ad loaded successfully
```

---

**🎉 You're ready to monetize with AdMob! 🚀**
