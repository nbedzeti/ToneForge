# How the Ad System Works - Complete Explanation

## Overview

Your app uses a **"3 Ads = 1 Ringtone"** reward system. Users can watch rewarded video ads to unlock additional ringtone creations without paying.

---

## The Flow

### 1. User Gets 3 Free Ringtones
When user first installs the app:
- `freeCreationsUsed = 0`
- User can create 3 ringtones for free
- No ads required

### 2. After 3 Free Ringtones
Once user has created 3 ringtones:
- `freeCreationsUsed = 3`
- User sees a message: "Watch ads or upgrade to Premium"
- User has 2 options:
  - **Option A**: Watch ads to unlock more
  - **Option B**: Buy premium subscription

### 3. Watching Ads
User chooses to watch ads:
- Taps "Watch Ad" button
- AdMob shows a **rewarded video ad** (15-30 seconds)
- User must watch the entire ad
- After watching:
  - `adsWatchedForNextUnlock` increases by 1
  - `totalAdsWatched` increases by 1 (lifetime counter)

### 4. Progress Tracking
The app tracks progress towards the next unlock:
- **1st ad watched**: Progress = 1/3 (33%)
- **2nd ad watched**: Progress = 2/3 (67%)
- **3rd ad watched**: Progress = 3/3 (100%) → **UNLOCK!**

### 5. Unlocking a Ringtone
When user watches 3rd ad:
- `extraCreationsAvailable` increases by 1
- `adsWatchedForNextUnlock` resets to 0
- User can now create 1 more ringtone
- Progress bar resets

### 6. Using the Unlocked Ringtone
When user creates a ringtone:
- If `extraCreationsAvailable > 0`:
  - `extraCreationsAvailable` decreases by 1
  - Ringtone is created
- User must watch 3 more ads for next ringtone

---

## Code Implementation

### Key Variables (in PurchaseManager.swift)

```swift
// Free tier tracking
var freeCreationsUsed: Int = 0           // How many free ringtones used (0-3)

// Ad-based unlocks
var extraCreationsAvailable: Int = 0     // Ringtones unlocked by watching ads
var adsWatchedForNextUnlock: Int = 0     // Progress towards next unlock (0-2)
var totalAdsWatched: Int = 0             // Lifetime counter (for analytics)

// Premium status
var isPremium: Bool = false              // If user bought subscription
```

### Key Functions

#### 1. Can User Create Ringtone?
```swift
var canCreateRingtone: Bool {
    return isPremium ||                    // Premium = unlimited
           freeCreationsUsed < 3 ||        // Still have free ones
           extraCreationsAvailable > 0     // Have ad-unlocked ones
}
```

#### 2. Recording Ad Watch
```swift
func recordAdWatched() {
    totalAdsWatched += 1              // Lifetime counter
    adsWatchedForNextUnlock += 1      // Progress counter
    
    if adsWatchedForNextUnlock >= 3 {
        extraCreationsAvailable += 1   // Unlock 1 ringtone
        adsWatchedForNextUnlock = 0    // Reset progress
    }
}
```

#### 3. Using a Creation
```swift
func recordCreation() {
    if isPremium {
        // Premium users: unlimited, do nothing
    } else if extraCreationsAvailable > 0 {
        extraCreationsAvailable -= 1   // Use ad-unlocked creation
    } else if freeCreationsUsed < 3 {
        freeCreationsUsed += 1         // Use free creation
    }
}
```

---

## User Experience Examples

### Example 1: New User
```
Install app
├─ Create ringtone #1 → freeCreationsUsed = 1 ✅
├─ Create ringtone #2 → freeCreationsUsed = 2 ✅
├─ Create ringtone #3 → freeCreationsUsed = 3 ✅
└─ Try to create #4 → "Watch ads or upgrade" ⚠️
```

### Example 2: Watching Ads
```
User has used 3 free ringtones
├─ Watch ad #1 → adsWatchedForNextUnlock = 1 (33%)
├─ Watch ad #2 → adsWatchedForNextUnlock = 2 (67%)
├─ Watch ad #3 → adsWatchedForNextUnlock = 3 (100%)
│                 extraCreationsAvailable = 1 🎉
│                 adsWatchedForNextUnlock = 0 (reset)
├─ Create ringtone #4 → extraCreationsAvailable = 0 ✅
└─ Try to create #5 → "Watch ads or upgrade" ⚠️
```

### Example 3: Multiple Ad Sessions
```
User watches ads multiple times:
├─ Watch 3 ads → extraCreationsAvailable = 1
├─ Watch 3 more ads → extraCreationsAvailable = 2
├─ Watch 3 more ads → extraCreationsAvailable = 3
├─ Create ringtone → extraCreationsAvailable = 2
├─ Create ringtone → extraCreationsAvailable = 1
└─ Create ringtone → extraCreationsAvailable = 0
```

### Example 4: Premium User
```
User buys premium subscription
├─ isPremium = true
├─ Create ringtone #1 → Unlimited ✅
├─ Create ringtone #2 → Unlimited ✅
├─ Create ringtone #100 → Unlimited ✅
└─ No ads, no limits! 🎉
```

---

## UI Display

### Free Status Card (PurchaseView.swift)
Shows user's current status:

```swift
// If user has free creations left
"3 free ringtones remaining" (blue badge)

// If user has ad-unlocked creations
"2 ad-unlocked ringtones available" (green badge)

// If user is making progress
"Progress to next unlock"
Progress bar: 2/3 ads watched (orange badge)
```

---

## AdMob Integration

### How Ads Are Shown

1. **Ad Loading** (AdManager.swift)
   - App loads ad in background
   - Uses AdMob SDK
   - Ad is ready to show

2. **User Taps "Watch Ad"**
   - App checks if ad is ready
   - Shows full-screen video ad
   - User watches (15-30 seconds)

3. **Ad Completion**
   - AdMob confirms user watched entire ad
   - App calls `recordAdWatched()`
   - Progress updates
   - If 3 ads watched → unlock ringtone

4. **Next Ad Loads**
   - App automatically loads next ad
   - Ready for next time

### Ad Unit IDs

```swift
// Test mode (for development)
testAdUnitID = "ca-app-pub-3940256099942544/1712485313"

// Production mode (for real users)
productionAdUnitID = "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"
```

You need to replace the production ID with your real AdMob ID!

---

## Revenue Model

### How You Make Money

**From Ads:**
- User watches 3 ads = 1 ringtone
- You earn ~$0.01 - $0.05 per ad view
- 3 ads = ~$0.03 - $0.15 revenue
- If user creates 10 ringtones via ads = 30 ads = ~$0.90 - $4.50

**From Subscriptions:**
- Monthly: $2.99/month
- Yearly: $17.99/year
- Lifetime: $24.99 one-time

### User Conversion Funnel

```
100 users install app
├─ 100 users use 3 free ringtones (0 revenue)
├─ 50 users watch ads for more (ad revenue)
│   └─ Average: 10 ads per user = $0.50 revenue
├─ 5 users buy monthly ($2.99 × 5 = $14.95)
├─ 3 users buy yearly ($17.99 × 3 = $53.97)
└─ 2 users buy lifetime ($24.99 × 2 = $49.98)

Total revenue from 100 users: ~$143.90
```

---

## Data Persistence

All data is saved to UserDefaults:

```swift
UserDefaults.standard.set(freeCreationsUsed, forKey: "freeCreationsUsed")
UserDefaults.standard.set(extraCreationsAvailable, forKey: "extraCreationsAvailable")
UserDefaults.standard.set(adsWatchedForNextUnlock, forKey: "adsWatchedForNextUnlock")
UserDefaults.standard.set(totalAdsWatched, forKey: "totalAdsWatched")
```

**This means:**
- Data persists across app launches
- If user closes app after watching 2 ads, progress is saved
- If user deletes app, all data is lost (fresh start)

---

## Testing the System

### In Debug Mode (Simulator/Test Device)

The app uses **test ads** that don't generate real revenue:
- Ads load instantly
- No real money involved
- Can test unlimited times

### In Production (Real Users)

The app uses **real ads** that generate revenue:
- Ads load from real advertisers
- You earn money per view
- AdMob tracks everything

---

## Important Notes

### ⚠️ Before Launch

1. **Replace Production Ad Unit ID**
   - Go to AdMob console
   - Create rewarded ad unit
   - Copy the ID
   - Replace in `AdManager.swift`

2. **Test Thoroughly**
   - Test with 3 free ringtones
   - Test watching ads
   - Test progress tracking
   - Test premium bypass

3. **AdMob Account Setup**
   - Create AdMob account
   - Link to App Store app
   - Set up payment info
   - Wait for approval

### ✅ What's Already Working

- ✅ Ad loading system
- ✅ Progress tracking (3 ads = 1 ringtone)
- ✅ Data persistence
- ✅ Premium bypass
- ✅ UI displays
- ✅ Error handling

### ⚠️ What You Need to Do

- [ ] Create AdMob account
- [ ] Get production ad unit ID
- [ ] Replace ID in code
- [ ] Test with real ads
- [ ] Submit to App Store

---

## Summary

**The system works like this:**

1. User gets 3 free ringtones
2. After that, must watch 3 ads per ringtone
3. Or buy premium for unlimited
4. Progress is tracked and saved
5. You earn money from ads and subscriptions

**It's a fair model:**
- Users get value (free ringtones via ads)
- You get revenue (ads + subscriptions)
- Premium users get best experience (no ads)

---

**Questions?** The code is all in:
- `PurchaseManager.swift` - Tracking logic
- `AdManager.swift` - Ad loading/showing
- `PurchaseView.swift` - UI display

