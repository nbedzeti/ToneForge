# Monetization Testing Checklist

Complete testing guide for RingToneMaker's hybrid monetization system (free tier + rewarded ads + subscriptions/lifetime).

---

## Table of Contents

1. [Local StoreKit Configuration Testing](#1-local-storekit-configuration-testing)
2. [Sandbox Testing](#2-sandbox-testing)
3. [Free Tier & Limits Testing](#3-free-tier--limits-testing)
4. [Rewarded Ads Testing](#4-rewarded-ads-testing)
5. [UI/UX Testing](#5-uiux-testing)
6. [Edge Cases & Persistence](#6-edge-cases--persistence)
7. [App Store Compliance](#7-app-store-compliance)
8. [Analytics Integration](#8-analytics-integration)
9. [Pre-Submission Checklist](#9-pre-submission-checklist)

---

## 1. Local StoreKit Configuration Testing

### Setup StoreKit Configuration File

- [ ] Create `Configuration.storekit` in Xcode
- [ ] Add products:
  - [ ] Monthly: `com.yourapp.ringtonemaker.monthly` - $4.99 - Auto-renewable (1 month)
  - [ ] Yearly: `com.yourapp.ringtonemaker.yearly` - $25.00 - Auto-renewable (1 year)
  - [ ] Lifetime: `com.yourapp.ringtonemaker.lifetime` - $35.00 - Non-consumable
- [ ] Set subscription group for monthly/yearly
- [ ] Enable StoreKit configuration in scheme

### Purchase Flow Testing

#### Monthly Subscription
- [ ] Product loads correctly
- [ ] Price displays as "$4.99"
- [ ] Display name shows correctly
- [ ] Purchase completes successfully
- [ ] `isPremium` becomes `true`
- [ ] Export button shows "Unlimited"
- [ ] No ads shown after purchase
- [ ] Transaction appears in StoreKit transaction manager

#### Yearly Subscription
- [ ] Product loads correctly
- [ ] Price displays as "$25.00"
- [ ] Savings badge shows "Save 58%"
- [ ] Purchase completes successfully
- [ ] `isPremium` becomes `true`
- [ ] All premium features unlock

#### Lifetime Purchase
- [ ] Product loads correctly
- [ ] Price displays as "$35.00"
- [ ] Badge shows "MOST POPULAR"
- [ ] Purchase completes successfully
- [ ] `isPremium` becomes `true`
- [ ] Persists across app restarts
- [ ] No expiration

### Restore Purchases

- [ ] Tap "Restore Purchases" button
- [ ] Previous purchases restore correctly
- [ ] `isPremium` updates to `true`
- [ ] Success message appears
- [ ] Works after deleting and reinstalling app (with same StoreKit config)

### Subscription Expiration Simulation

- [ ] In StoreKit configuration, set renewal rate to "2 minutes"
- [ ] Purchase monthly subscription
- [ ] Wait for expiration
- [ ] Verify `isPremium` becomes `false`
- [ ] Verify ads reappear
- [ ] Verify free tier limits apply again

### Error Handling

- [ ] Cancel purchase → No charge, `isPremium` stays `false`
- [ ] Network error simulation → Shows error message
- [ ] Invalid product ID → Graceful error handling
- [ ] Purchase pending → Shows pending state

---

## 2. Sandbox Testing

### Setup Sandbox Accounts

- [ ] Create 3+ sandbox accounts in App Store Connect
- [ ] Use different email addresses
- [ ] Note: Use format `test+1@example.com`, `test+2@example.com`

### Sandbox Purchase Testing

#### Monthly Subscription
- [ ] Sign in with sandbox account
- [ ] Purchase monthly subscription
- [ ] Verify charge in sandbox account
- [ ] Check subscription status in Settings > Apple ID > Subscriptions
- [ ] Verify auto-renewal (accelerated: 5 minutes = 1 month)
- [ ] Test 6 renewals (sandbox limit)
- [ ] Verify subscription expires after 6 renewals

#### Yearly Subscription
- [ ] Purchase yearly subscription
- [ ] Verify accelerated renewal (1 hour = 1 year in sandbox)
- [ ] Test multiple renewals
- [ ] Verify expiration after 6 renewals

#### Lifetime Purchase
- [ ] Purchase lifetime
- [ ] Verify no expiration
- [ ] Delete app and reinstall
- [ ] Restore purchases
- [ ] Verify lifetime still active

### Billing Grace Period

- [ ] Simulate payment failure (use declined test card)
- [ ] Verify app shows grace period status
- [ ] Verify user retains premium access during grace
- [ ] Update payment method
- [ ] Verify subscription resumes

### Subscription Management

- [ ] Cancel subscription in Settings
- [ ] Verify access continues until period end
- [ ] Verify `isPremium` becomes `false` after expiration
- [ ] Resubscribe
- [ ] Verify immediate access restoration

### Cross-Device Testing

- [ ] Purchase on iPhone
- [ ] Restore on iPad (same Apple ID)
- [ ] Verify premium status syncs
- [ ] Test with different iOS versions (15.0+)

---

## 3. Free Tier & Limits Testing

### First Launch Experience

- [ ] Fresh install (delete app, reinstall)
- [ ] Verify `freeCreationsUsed` = 0
- [ ] Verify `remainingFreeCreations` = 3
- [ ] Export button shows "Export Ringtone (3 free left)"
- [ ] No ads or upgrade prompts yet
- [ ] Banner shows "3 free ringtones remaining"

### Using Free Creations

#### First Creation
- [ ] Select song, adjust times
- [ ] Tap "Export Ringtone (3 free left)"
- [ ] Ringtone exports successfully
- [ ] `freeCreationsUsed` increments to 1
- [ ] Button updates to "Export Ringtone (2 free left)"
- [ ] Banner updates to "2 free ringtones remaining"

#### Second Creation
- [ ] Export another ringtone
- [ ] `freeCreationsUsed` = 2
- [ ] Button shows "Export Ringtone (1 free left)"
- [ ] Banner shows "1 free ringtone remaining"

#### Third Creation
- [ ] Export third ringtone
- [ ] `freeCreationsUsed` = 3
- [ ] Button shows "Upgrade or Watch Ads" (orange)
- [ ] Banner disappears
- [ ] "Watch Ads" button appears

### After Free Limit Reached

- [ ] Tap "Upgrade or Watch Ads" button
- [ ] Alert appears: "Limit Reached"
- [ ] Message: "You've used your 3 free ringtone creations..."
- [ ] Three options visible:
  - [ ] "Watch Ads" button
  - [ ] "Go Premium" button
  - [ ] "Cancel" button
- [ ] Tap "Cancel" → Alert dismisses, no action
- [ ] Tap "Go Premium" → Paywall appears
- [ ] Tap "Watch Ads" → Ad loads and shows

### Persistence Testing

- [ ] Use 2 free creations
- [ ] Force quit app
- [ ] Relaunch app
- [ ] Verify `freeCreationsUsed` = 2 (persisted)
- [ ] Verify button shows "1 free left"

---

## 4. Rewarded Ads Testing

### Ad Loading

- [ ] App launches
- [ ] Check console: "📺 Loading rewarded ad..."
- [ ] Check console: "✅ Ad loaded successfully"
- [ ] Verify `isAdReady` = `true`
- [ ] Verify no errors in console

### Ad Showing - Success Flow

#### First Ad
- [ ] Reach free limit (3 creations used)
- [ ] Tap "Watch Ad to Unlock Ringtone"
- [ ] Ad appears (test ad in DEBUG)
- [ ] Watch full ad (15-30 seconds)
- [ ] Ad dismisses
- [ ] Success toast appears: "✅ Ad watched! 1/3 complete."
- [ ] Toast auto-hides after 3 seconds
- [ ] `adsWatchedForNextUnlock` = 1
- [ ] Progress bar shows 33% (1/3)
- [ ] Alert shows: "Great! You've watched 1/3 ads..."

#### Second Ad
- [ ] Tap "Watch Ad" again
- [ ] Watch full ad
- [ ] Success toast: "✅ Ad watched! 2/3 complete."
- [ ] `adsWatchedForNextUnlock` = 2
- [ ] Progress bar shows 66% (2/3)

#### Third Ad (Unlock)
- [ ] Tap "Watch Ad" again
- [ ] Watch full ad
- [ ] Success toast: "🎉 Unlocked 1 ringtone! You now have 1 available."
- [ ] `adsWatchedForNextUnlock` resets to 0
- [ ] `extraCreationsAvailable` = 1
- [ ] Export button shows "Export Ringtone (1 unlocked)"
- [ ] Banner shows "1 ad-unlocked ringtones available"
- [ ] Progress bar disappears

### Using Ad-Unlocked Creation

- [ ] Export a ringtone
- [ ] `extraCreationsAvailable` decrements to 0
- [ ] Button returns to "Upgrade or Watch Ads"
- [ ] Can watch 3 more ads to unlock another

### Ad Accumulation

- [ ] Watch 3 ads → Unlock 1 ringtone
- [ ] Don't use it yet
- [ ] Watch 3 more ads → Unlock another ringtone
- [ ] Verify `extraCreationsAvailable` = 2
- [ ] Export 2 ringtones
- [ ] Verify both are consumed

### Ad Failure Handling

#### No Internet
- [ ] Turn off WiFi/cellular
- [ ] Tap "Watch Ad"
- [ ] Alert appears: "Ad Not Available"
- [ ] Message: "Unable to load ad. Please try again later..."
- [ ] Tap OK
- [ ] Turn on internet
- [ ] Verify ad loads automatically

#### Ad Load Failure
- [ ] Simulate ad load failure (if possible)
- [ ] Error message appears
- [ ] User can retry
- [ ] No infinite loading state

#### User Closes Ad Early
- [ ] Tap "Watch Ad"
- [ ] Close ad before completion (if possible)
- [ ] No reward given
- [ ] `adsWatchedForNextUnlock` doesn't increment
- [ ] User can try again

### No Infinite Loop

- [ ] Verify ad doesn't auto-play
- [ ] Verify user must tap button to watch
- [ ] Verify ad doesn't loop after completion
- [ ] Verify new ad loads for next time
- [ ] Verify no forced ads

### Premium User - No Ads

- [ ] Purchase premium subscription
- [ ] Verify "Watch Ads" button disappears
- [ ] Verify no ad prompts
- [ ] Verify `showRewardedAd()` returns early for premium users
- [ ] Export unlimited ringtones without ads

---

## 5. UI/UX Testing

### Paywall Design & Messaging

#### Value Proposition
- [ ] Headline: "Unlock Unlimited Ringtones"
- [ ] Subheadline: "Create as many custom ringtones as you want with no ads"
- [ ] Clear, not deceptive
- [ ] No false urgency ("Limited time!" etc.)
- [ ] No fake scarcity ("Only 3 spots left!")

#### Product Cards
- [ ] Monthly: $4.99/month - Clear pricing
- [ ] Yearly: $25/year - Shows "Save 58%" badge
- [ ] Lifetime: $35 - Shows "MOST POPULAR" badge
- [ ] All prices visible before purchase
- [ ] No hidden fees mentioned

#### Features List
- [ ] "Unlimited Ringtones" - Clear benefit
- [ ] "No Ads" - Clear benefit
- [ ] "All Features" - Not misleading
- [ ] "Support Development" - Honest
- [ ] Icons match features

#### Legal & Transparency
- [ ] "Restore Purchases" button visible
- [ ] Subscription auto-renewal notice visible
- [ ] "Manage subscriptions in App Store settings" visible
- [ ] Terms of Service link (placeholder OK for now)
- [ ] Privacy Policy link (placeholder OK for now)

### Free Tier Messaging

- [ ] "3 free ringtones remaining" - Clear
- [ ] "You've used your 3 free creations" - Clear
- [ ] "Watch 3 ads to unlock 1 more" - Clear value exchange
- [ ] "or upgrade to Premium" - Clear alternative
- [ ] No guilt-tripping or dark patterns

### Button States

#### Export Button
- [ ] Premium: "Export Ringtone (Unlimited)" - Green
- [ ] Free (2 left): "Export Ringtone (2 free left)" - Green
- [ ] Free (0 left, 1 unlocked): "Export Ringtone (1 unlocked)" - Green
- [ ] Free (0 left, 0 unlocked): "Upgrade or Watch Ads" - Orange
- [ ] Disabled state: Gray, not clickable

#### Watch Ads Button
- [ ] Shows when needed
- [ ] Hides for premium users
- [ ] Clear text: "Watch Ad to Unlock Ringtone"
- [ ] Shows progress: "2/3 ads watched"
- [ ] Blue background, white text

#### Upgrade Button
- [ ] Always visible for free users
- [ ] Gradient background (purple to blue)
- [ ] Crown icon
- [ ] Text: "Upgrade to Premium"

### Success Feedback

- [ ] Toast appears at top
- [ ] Green background
- [ ] Checkmark icon
- [ ] Clear message
- [ ] Smooth slide-in animation
- [ ] Auto-hides after 3 seconds
- [ ] Doesn't block UI

### Error Messages

- [ ] Clear, not technical
- [ ] Actionable (what user should do)
- [ ] Not blaming user
- [ ] Consistent tone

---

## 6. Edge Cases & Persistence

### Reinstall Scenarios

#### Without Purchases
- [ ] Install app
- [ ] Use 2 free creations
- [ ] Delete app
- [ ] Reinstall app
- [ ] **Expected:** Counter resets to 0 (UserDefaults cleared)
- [ ] **Note:** This is acceptable behavior for free tier

#### With Purchases
- [ ] Purchase lifetime
- [ ] Delete app
- [ ] Reinstall app
- [ ] Tap "Restore Purchases"
- [ ] Verify lifetime purchase restores
- [ ] Verify `isPremium` = `true`

### Keychain Persistence (Optional Enhancement)

**Note:** Current implementation uses UserDefaults. Consider Keychain for cross-reinstall persistence.

- [ ] Document current behavior in App Store description
- [ ] Consider adding Keychain backup in future update
- [ ] Test iCloud Keychain sync if implemented

### Family Sharing

#### Setup
- [ ] Enable Family Sharing in App Store Connect
- [ ] Purchase subscription with family organizer account
- [ ] Sign in with family member account

#### Testing
- [ ] Verify family member has premium access
- [ ] Verify `isPremium` = `true` for family member
- [ ] Verify no ads shown
- [ ] Verify unlimited exports
- [ ] Test with multiple family members

### App Updates

- [ ] Install v1.0
- [ ] Use 1 free creation
- [ ] Update to v1.1 (simulated)
- [ ] Verify counter persists
- [ ] Verify purchases persist

### Background/Foreground

- [ ] Use 2 free creations
- [ ] Background app (home button)
- [ ] Wait 5 minutes
- [ ] Foreground app
- [ ] Verify counter still shows 2
- [ ] Verify no reset

### Airplane Mode

- [ ] Turn on airplane mode
- [ ] Launch app
- [ ] Verify free tier works offline
- [ ] Verify export works offline
- [ ] Verify ads don't load (expected)
- [ ] Turn off airplane mode
- [ ] Verify ads load

### Low Storage

- [ ] Fill device storage to <100MB
- [ ] Try to export ringtone
- [ ] Verify graceful error handling
- [ ] Verify no crash

### iOS Version Compatibility

- [ ] Test on iOS 15.0 (minimum)
- [ ] Test on iOS 16.x
- [ ] Test on iOS 17.x
- [ ] Test on latest iOS 18.x
- [ ] Verify StoreKit 2 works on all versions

---

## 7. App Store Compliance

### App Store Review Guidelines

#### 3.1.1 - In-App Purchase
- [ ] All digital content uses IAP (not external payment)
- [ ] No links to external purchase pages
- [ ] No mention of prices outside App Store
- [ ] Restore purchases button visible

#### 3.1.2 - Subscriptions
- [ ] Clear description of what user gets
- [ ] Subscription terms visible before purchase
- [ ] Auto-renewal clearly stated
- [ ] Cancellation instructions provided
- [ ] Free trial (if any) clearly marked

#### 3.1.3(b) - Multiplatform Services
- [ ] Not applicable (app is iOS-only)

#### 2.3.8 - Metadata
- [ ] App description matches functionality
- [ ] Screenshots show actual app
- [ ] No misleading claims

### App Description Compliance

#### Required Elements
- [ ] "Free: 3 ringtone creations"
- [ ] "Watch ads to unlock more (optional)"
- [ ] "Upgrade to Premium for unlimited creations"
- [ ] Pricing clearly stated
- [ ] No forced purchases for core functionality

#### Example Description:
```
RingToneMaker - Create Custom Ringtones

FREE FEATURES:
• 3 free ringtone creations
• Select any song from your library
• Trim to perfect 30-second clip
• Visual waveform editor
• Export as M4R format

UNLOCK MORE:
• Watch 3 ads to unlock 1 additional ringtone (optional)
• Or upgrade to Premium for unlimited creations

PREMIUM FEATURES:
• Unlimited ringtone creations
• No ads
• All current and future features
• Support indie development

PRICING:
• Monthly: $4.99/month
• Yearly: $25/year (save 58%)
• Lifetime: $35 (one-time purchase)

Subscriptions auto-renew unless cancelled 24 hours before period end.
Manage subscriptions in Settings > Apple ID > Subscriptions.
```

### Rewarded Ads Compliance

- [ ] Ads are optional, not forced
- [ ] User initiates ad viewing
- [ ] Clear value exchange (3 ads = 1 ringtone)
- [ ] Can use app without watching ads (via purchase)
- [ ] No deceptive ad placement
- [ ] Ads don't interrupt core functionality

### No Forced IAP

- [ ] Core functionality works without purchase
- [ ] 3 free creations provided
- [ ] Alternative (ads) available
- [ ] No artificial limitations to force purchase
- [ ] No "pay to remove bugs"

### Restore Purchases

- [ ] Button visible in paywall
- [ ] Button visible in settings (if settings screen exists)
- [ ] Works correctly
- [ ] No charge for restore
- [ ] Restores all purchases

### Privacy & Data

- [ ] Privacy policy link in app
- [ ] Privacy policy link in App Store Connect
- [ ] Data collection disclosed
- [ ] ATT permission (if tracking)
- [ ] Privacy manifest included

---

## 8. Analytics Integration

### Firebase Analytics Setup

#### Installation
- [ ] Add Firebase SDK via SPM or CocoaPods
- [ ] Add `GoogleService-Info.plist`
- [ ] Initialize Firebase in app launch
- [ ] Test connection in Firebase console

#### Key Events to Track

##### User Journey
```swift
// App launch
Analytics.logEvent("app_launch", parameters: nil)

// First time user
Analytics.logEvent("first_launch", parameters: nil)

// Song selected
Analytics.logEvent("song_selected", parameters: [
    "song_title": songTitle,
    "duration": duration
])
```

##### Free Tier
```swift
// Free creation used
Analytics.logEvent("free_creation_used", parameters: [
    "remaining": remainingFreeCreations,
    "total_used": freeCreationsUsed
])

// Free limit reached
Analytics.logEvent("free_limit_reached", parameters: [
    "time_since_install": timeSinceInstall
])
```

##### Rewarded Ads
```swift
// Ad requested
Analytics.logEvent("ad_requested", parameters: [
    "ad_type": "rewarded",
    "trigger": "free_limit_reached"
])

// Ad loaded
Analytics.logEvent("ad_loaded", parameters: [
    "ad_type": "rewarded",
    "load_time": loadTime
])

// Ad shown
Analytics.logEvent("ad_impression", parameters: [
    "ad_type": "rewarded",
    "ad_unit_id": adUnitID
])

// Ad completed
Analytics.logEvent("ad_reward_earned", parameters: [
    "ad_type": "rewarded",
    "ads_watched": adsWatchedForNextUnlock,
    "unlocked": extraCreationsAvailable > 0
])

// Ad failed
Analytics.logEvent("ad_failed", parameters: [
    "ad_type": "rewarded",
    "error": errorMessage
])
```

##### Purchases
```swift
// Paywall viewed
Analytics.logEvent("paywall_viewed", parameters: [
    "trigger": "free_limit_reached" // or "upgrade_button"
])

// Product selected
Analytics.logEvent("product_selected", parameters: [
    "product_id": productID,
    "price": price
])

// Purchase initiated
Analytics.logEvent("begin_checkout", parameters: [
    "product_id": productID,
    "value": price,
    "currency": "USD"
])

// Purchase completed
Analytics.logEvent("purchase", parameters: [
    "product_id": productID,
    "value": price,
    "currency": "USD",
    "transaction_id": transactionID
])

// Purchase failed
Analytics.logEvent("purchase_failed", parameters: [
    "product_id": productID,
    "error": errorMessage
])

// Restore purchases
Analytics.logEvent("restore_purchases", parameters: [
    "success": success
])
```

##### Conversions
```swift
// Free to ad watcher
Analytics.logEvent("conversion_free_to_ad", parameters: [
    "time_since_limit": timeSinceLimit
])

// Free to premium
Analytics.logEvent("conversion_free_to_premium", parameters: [
    "product_id": productID,
    "time_since_install": timeSinceInstall,
    "free_creations_used": freeCreationsUsed
])

// Ad watcher to premium
Analytics.logEvent("conversion_ad_to_premium", parameters: [
    "product_id": productID,
    "total_ads_watched": totalAdsWatched,
    "ad_unlocked_used": adUnlockedUsed
])
```

### Conversion Funnel Analysis

#### Free User Funnel
```
Install (100%)
  ↓
First Creation (X%)
  ↓
Second Creation (X%)
  ↓
Third Creation (X%)
  ↓
Limit Reached (X%)
  ↓
├─ Watch Ads (X%)
│  ↓
│  Ad Completed (X%)
│  ↓
│  Use Ad-Unlocked (X%)
│
└─ Go Premium (X%)
   ↓
   Purchase (X%)
```

#### Metrics to Track
- [ ] Install to first creation rate
- [ ] First to third creation rate
- [ ] Limit reached to ad watch rate
- [ ] Ad watch to completion rate
- [ ] Ad completion to premium conversion rate
- [ ] Limit reached to premium conversion rate
- [ ] Average time to conversion
- [ ] Lifetime value (LTV) by cohort

### A/B Testing Ideas

- [ ] Paywall design variations
- [ ] Pricing variations ($4.99 vs $3.99 monthly)
- [ ] Free tier limits (3 vs 5 free creations)
- [ ] Ad frequency (3 ads vs 2 ads per unlock)
- [ ] Button copy variations
- [ ] Badge variations ("BEST VALUE" vs "SAVE 58%")

---

## 9. Pre-Submission Checklist

### Code & Build

- [ ] All code compiles without errors
- [ ] No warnings in Xcode
- [ ] All diagnostics pass
- [ ] Archive builds successfully
- [ ] App runs on physical device
- [ ] No crashes in testing

### StoreKit Configuration

- [ ] Products created in App Store Connect
- [ ] Product IDs match code exactly
- [ ] Prices set correctly
- [ ] Subscription group configured
- [ ] Products submitted for review
- [ ] Products approved

### AdMob Configuration

- [ ] AdMob account created
- [ ] App added to AdMob
- [ ] Rewarded ad unit created
- [ ] App ID in Info.plist (production)
- [ ] Ad Unit ID in AdManager.swift (production)
- [ ] Test ads work in DEBUG
- [ ] Real ads work in Release
- [ ] Payment info completed in AdMob

### Privacy & Compliance

- [ ] Privacy policy created and hosted
- [ ] Terms of service created and hosted
- [ ] Privacy manifest included (PrivacyInfo.xcprivacy)
- [ ] ATT permission implemented (if tracking)
- [ ] Data collection disclosed
- [ ] GDPR/CCPA compliant

### App Store Connect

- [ ] App created in App Store Connect
- [ ] Bundle ID matches
- [ ] Version number set
- [ ] Build uploaded
- [ ] Screenshots added (all required sizes)
- [ ] App description written
- [ ] Keywords added
- [ ] Support URL provided
- [ ] Privacy policy URL provided
- [ ] Age rating set correctly

### Testing

- [ ] All items in this checklist completed
- [ ] TestFlight beta testing completed
- [ ] Feedback addressed
- [ ] No critical bugs
- [ ] Performance acceptable
- [ ] Battery usage acceptable

### Documentation

- [ ] README updated
- [ ] CHANGELOG created
- [ ] User guide available (SET_RINGTONE_GUIDE.md)
- [ ] Support email set up
- [ ] FAQ prepared

---

## Testing Summary

### Critical Path Tests (Must Pass)

1. **Free Tier**
   - [ ] 3 free creations work
   - [ ] Limit enforced after 3
   - [ ] Counter persists

2. **Rewarded Ads**
   - [ ] Ads load and show
   - [ ] Rewards granted correctly
   - [ ] 3 ads = 1 ringtone

3. **Purchases**
   - [ ] All products purchase successfully
   - [ ] Premium status activates
   - [ ] Restore works

4. **UI/UX**
   - [ ] No deceptive patterns
   - [ ] Clear messaging
   - [ ] Restore button visible

5. **Compliance**
   - [ ] No forced IAP
   - [ ] Ads optional
   - [ ] Terms visible

### Recommended Testing Order

1. **Day 1:** Local StoreKit testing
2. **Day 2:** Sandbox testing
3. **Day 3:** Free tier & ads testing
4. **Day 4:** Edge cases & persistence
5. **Day 5:** UI/UX & compliance review
6. **Day 6:** Analytics integration
7. **Day 7:** TestFlight beta
8. **Day 8-14:** Beta feedback & fixes
9. **Day 15:** Final review & submission

---

## Test Devices

### Minimum Test Matrix

- [ ] iPhone SE (small screen)
- [ ] iPhone 14 Pro (notch)
- [ ] iPhone 15 Pro Max (large screen)
- [ ] iPad (if supporting)
- [ ] iOS 15.0 (minimum version)
- [ ] iOS 17.x (current)
- [ ] iOS 18.x (latest)

---

## Bug Tracking Template

```markdown
### Bug Report

**Title:** [Brief description]

**Severity:** Critical / High / Medium / Low

**Steps to Reproduce:**
1. 
2. 
3. 

**Expected Result:**

**Actual Result:**

**Device:** iPhone 14 Pro, iOS 17.2

**Build:** 1.0 (1)

**Screenshots:** [Attach if applicable]

**Console Logs:** [Paste relevant logs]

**Frequency:** Always / Sometimes / Rare
```

---

## Success Criteria

### Before Submission

- [ ] 100% of critical path tests pass
- [ ] 95%+ of all tests pass
- [ ] No critical or high severity bugs
- [ ] Beta testers report positive experience
- [ ] Conversion funnel tracked in analytics
- [ ] Revenue projections validated

### Post-Launch (Week 1)

- [ ] No crashes reported
- [ ] No 1-star reviews mentioning bugs
- [ ] Conversion rate > 2%
- [ ] Ad fill rate > 80%
- [ ] Purchase completion rate > 70%

---

## Resources

- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [StoreKit Testing Guide](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_with_sandbox)
- [AdMob Policy](https://support.google.com/admob/answer/6128543)
- [Firebase Analytics](https://firebase.google.com/docs/analytics/get-started?platform=ios)

---

**Last Updated:** January 18, 2026  
**Version:** 1.0  
**Status:** Ready for Testing

---

**🧪 Happy Testing! 🚀**
