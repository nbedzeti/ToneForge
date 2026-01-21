# How to Test RingToneMaker - Step by Step

Simple guide to test your app in 30 minutes.

---

## Prerequisites

- Mac with Xcode installed
- iPhone/iPad (physical device recommended) OR Simulator
- Music in your Apple Music library (for testing song selection)

---

## Part 1: Setup (5 minutes)

### Step 1: Add Google Mobile Ads SDK

**Option A: Swift Package Manager (Recommended)**

1. Open `RingToneMaker.xcodeproj` in Xcode
2. Click on the project in the left sidebar
3. Go to menu: **File > Add Package Dependencies**
4. In the search box, paste:
   ```
   https://github.com/googleads/swift-package-manager-google-mobile-ads.git
   ```
5. Click **Add Package**
6. Select **GoogleMobileAds** from the list
7. Click **Add Package** again
8. Wait for download to complete

**Option B: Skip for Now (Test Without Ads)**

If you want to test without ads first:
1. The app will work in DEBUG mode with simulated ads
2. You can add the SDK later

### Step 2: Setup StoreKit Configuration (Optional)

To test purchases locally without App Store:

1. In Xcode, click **File > New > File**
2. Search for "StoreKit Configuration File"
3. Name it: `Configuration.storekit`
4. Click **Create**
5. Copy the contents from `RingToneMaker/Configuration.storekit` (already created for you)
6. Go to **Product > Scheme > Edit Scheme**
7. Select **Run** on the left
8. Go to **Options** tab
9. Under **StoreKit Configuration**, select `Configuration.storekit`
10. Click **Close**

---

## Part 2: Build and Run (2 minutes)

### Step 3: Build the App

1. In Xcode, select a target device:
   - For simulator: Choose **iPhone 15 Pro** (or any iPhone)
   - For real device: Connect your iPhone and select it
2. Press **Cmd+B** to build
3. Wait for build to complete (should be no errors)
4. Check the console for any warnings

### Step 4: Run the App

1. Press **Cmd+R** to run
2. App should launch on your device/simulator
3. Check console output:
   ```
   ✅ Google Mobile Ads SDK initialized
   📺 Loading rewarded ad from AdMob...
   ✅ Ad loaded successfully
   ```
   (If you didn't add AdMob SDK, you'll see debug simulation messages)

---

## Part 3: Test Free Tier (10 minutes)

### Step 5: First Launch Experience

**What to check:**
- [ ] App launches without crashing
- [ ] Main screen shows "RingTone Maker" title
- [ ] "Select Song from Library" button is visible
- [ ] Banner shows "3 free ringtones remaining"

**Screenshot:** Take a screenshot of the initial screen

### Step 6: Select a Song

1. Tap **"Select Song from Library"**
2. If prompted for permission:
   - Tap **"OK"** to allow access
   - If denied, go to Settings > Privacy > Media & Apple Music
3. Music library picker should appear
4. Select any song from your library
5. Wait for song to load

**What to check:**
- [ ] Song title and artist appear
- [ ] Waveform displays
- [ ] Start time shows "0"
- [ ] End time shows "30" (or song duration if shorter)
- [ ] "Export Ringtone (3 free left)" button is green

### Step 7: Create First Ringtone

1. Adjust start/end times if desired (optional)
   - Use sliders, text fields, or steppers
   - Try the preview button to hear the selection
2. Tap **"Export Ringtone (3 free left)"**
3. Wait for export to complete (5-10 seconds)

**What to check:**
- [ ] Export button shows loading state
- [ ] Success alert appears: "Ringtone created successfully!"
- [ ] File info shows: "M4R Format"
- [ ] "Share as Ringtone" button appears
- [ ] Export button now shows "Export Ringtone (2 free left)"
- [ ] Banner updates to "2 free ringtones remaining"

**Screenshot:** Take a screenshot after successful export

### Step 8: Create Second and Third Ringtones

1. Tap **"Select Song from Library"** again
2. Select another song (or same song)
3. Tap **"Export Ringtone (2 free left)"**
4. Verify counter updates to "1 free left"
5. Repeat once more for third ringtone
6. Verify counter updates to "0 free left"

**What to check:**
- [ ] Counter decrements correctly: 3 → 2 → 1 → 0
- [ ] Each export succeeds
- [ ] Banner disappears after 3rd creation

### Step 9: Test Free Limit

1. Select another song
2. Try to export (button should now say "Upgrade or Watch Ads" in orange)
3. Tap the orange button

**What to check:**
- [ ] Alert appears: "Limit Reached"
- [ ] Message: "You've used your 3 free ringtone creations..."
- [ ] Three buttons visible:
  - [ ] "Watch Ads"
  - [ ] "Go Premium"
  - [ ] "Cancel"

**Screenshot:** Take a screenshot of the limit alert

### Step 10: Test Persistence

1. Force quit the app (swipe up from bottom, swipe app away)
2. Relaunch the app
3. Try to export a ringtone

**What to check:**
- [ ] Counter still shows 0 remaining
- [ ] Limit alert still appears
- [ ] Data persisted across app restart

---

## Part 4: Test Rewarded Ads (5 minutes)

### Step 11: Watch First Ad

1. Reach the free limit (if not already there)
2. Tap **"Watch Ad to Unlock Ringtone"** button (blue)
3. Ad should load and play (test ad in DEBUG mode)
4. Watch the full ad (don't close early)

**What to check:**
- [ ] Ad loads (may take a few seconds)
- [ ] Ad plays (15-30 seconds)
- [ ] Success toast appears at top: "✅ Ad watched! 1/3 complete."
- [ ] Toast auto-hides after 3 seconds
- [ ] Progress bar shows 33% (1/3)
- [ ] Alert shows: "Great! You've watched 1/3 ads..."

**Screenshot:** Take a screenshot of the progress bar

### Step 12: Watch Second and Third Ads

1. Tap **"Watch Ad to Unlock Ringtone"** again
2. Watch second ad
3. Verify progress: "2/3 ads watched"
4. Tap **"Watch Ad"** one more time
5. Watch third ad

**What to check:**
- [ ] After 2nd ad: Progress shows 66% (2/3)
- [ ] After 3rd ad: Success toast shows "🎉 Unlocked 1 ringtone!"
- [ ] Banner appears: "1 ad-unlocked ringtones available"
- [ ] Export button changes to "Export Ringtone (1 unlocked)" in green
- [ ] Progress bar disappears

**Screenshot:** Take a screenshot after unlocking

### Step 13: Use Ad-Unlocked Ringtone

1. Select a song
2. Tap **"Export Ringtone (1 unlocked)"**
3. Verify export succeeds

**What to check:**
- [ ] Export works
- [ ] Counter decrements to 0 unlocked
- [ ] Button returns to "Upgrade or Watch Ads"
- [ ] Can watch 3 more ads to unlock another

---

## Part 5: Test Purchases (5 minutes)

### Step 14: View Paywall

1. Tap **"Upgrade to Premium"** button (gradient purple/blue)
   - OR tap "Go Premium" in the limit alert
2. Paywall should appear

**What to check:**
- [ ] Paywall shows with title "Upgrade to Premium"
- [ ] Three product cards visible:
  - [ ] Monthly: $4.99/month
  - [ ] Yearly: $25/year with "BEST VALUE" badge
  - [ ] Lifetime: $35 with "MOST POPULAR" badge
- [ ] Features list shows:
  - [ ] Unlimited Ringtones
  - [ ] No Ads
  - [ ] All Features
  - [ ] Support Development
- [ ] "Restore Purchases" button visible at bottom
- [ ] Legal text visible (subscription terms)

**Screenshot:** Take a screenshot of the paywall

### Step 15: Test Purchase (StoreKit Configuration)

**If you set up StoreKit configuration:**

1. Tap on **Monthly** product card
2. Apple Pay sheet should appear (simulated)
3. Confirm purchase
4. Wait for completion

**What to check:**
- [ ] Purchase completes successfully
- [ ] Paywall dismisses
- [ ] Export button shows "Export Ringtone (Unlimited)" in green
- [ ] "Watch Ads" button disappears
- [ ] "Upgrade to Premium" button disappears
- [ ] Can export unlimited ringtones

**If you didn't set up StoreKit:**
- Just verify the paywall UI looks correct
- Skip the actual purchase test

### Step 16: Test Restore Purchases

1. Tap **"Restore Purchases"** button in paywall
2. Wait for completion

**What to check:**
- [ ] Loading indicator appears
- [ ] Success or "No purchases to restore" message
- [ ] No crashes

---

## Part 6: Test Error Handling (3 minutes)

### Step 17: Test No Internet (Ads)

1. Turn off WiFi and cellular data
2. Reach free limit
3. Tap **"Watch Ad to Unlock Ringtone"**

**What to check:**
- [ ] Alert appears: "Ad Not Available"
- [ ] Message: "Unable to load ad. Please try again later..."
- [ ] No crash
- [ ] Can tap OK to dismiss

### Step 18: Test Invalid Song Selection

1. Turn WiFi back on
2. Try to select a cloud-only song (if you have any)
   - Songs with cloud icon that aren't downloaded

**What to check:**
- [ ] Error message appears
- [ ] Message mentions DRM or cloud-only
- [ ] App doesn't crash

### Step 19: Test Invalid Time Range

1. Select a song
2. In start time field, enter: `50`
3. In end time field, enter: `40`
4. Try to export

**What to check:**
- [ ] Validation prevents export
- [ ] Error message appears
- [ ] Times auto-adjust to valid range

---

## Part 7: Test UI/UX (Optional - 5 minutes)

### Step 20: Test Waveform Interactions

1. Select a song
2. Try pinch-to-zoom on waveform
3. Try dragging to pan
4. Adjust sliders
5. Tap preview button

**What to check:**
- [ ] Zoom works (1x to 3x)
- [ ] Pan works
- [ ] Sliders update times
- [ ] Preview plays selected portion
- [ ] Waveform highlights selected section (blue)

### Step 21: Test File Sharing

1. Export a ringtone
2. Tap **"Share as Ringtone"**
3. Share sheet should appear

**What to check:**
- [ ] Share sheet shows
- [ ] Options include: Files, AirDrop, Mail, Messages
- [ ] Can save to Files app
- [ ] File is M4R format

### Step 22: Test File Management

1. After exporting, tap **"Open in Files"**
2. Verify file opens in Files app
3. Go back to app
4. Tap **"Delete"**

**What to check:**
- [ ] Files app opens with ringtone
- [ ] Delete removes file
- [ ] Success message appears

---

## Testing Checklist Summary

### Critical Tests (Must Pass)

- [ ] App builds without errors
- [ ] App launches without crashing
- [ ] Can select song from library
- [ ] Can export 3 free ringtones
- [ ] Counter decrements correctly (3 → 2 → 1 → 0)
- [ ] Limit enforced after 3 creations
- [ ] "Watch Ads" button appears when needed
- [ ] Ads load and show (or simulate in DEBUG)
- [ ] Rewards granted after watching 3 ads
- [ ] Can export with ad-unlocked creation
- [ ] Paywall appears when tapping "Go Premium"
- [ ] All 3 products visible with correct prices
- [ ] Restore button visible
- [ ] No crashes during any flow

### Optional Tests (Nice to Have)

- [ ] Waveform zoom/pan works
- [ ] Preview plays correctly
- [ ] File sharing works
- [ ] Persistence across restarts
- [ ] Error handling works
- [ ] UI updates correctly

---

## What to Do If Something Fails

### Build Errors

**Error:** "Cannot find 'GADMobileAds' in scope"
- **Fix:** Add Google Mobile Ads SDK (see Step 1)
- **Or:** Comment out AdMob code temporarily

**Error:** "No such module 'FirebaseCore'"
- **Fix:** Firebase is optional, you can skip it for now

### Runtime Errors

**App crashes on launch:**
1. Check console for error message
2. Verify all files are included in target
3. Clean build folder: Product > Clean Build Folder
4. Rebuild: Cmd+B

**Ads don't load:**
- This is normal without AdMob SDK
- Debug mode simulates ads
- Check console for simulation messages

**Purchases don't work:**
- Verify StoreKit configuration is selected in scheme
- Check product IDs match exactly
- Try restarting Xcode

**Song selection fails:**
1. Check music library permission
2. Try a different song
3. Ensure song is downloaded (not cloud-only)

---

## Expected Console Output

When everything works correctly, you should see:

```
✅ Google Mobile Ads SDK initialized
  - GADMobileAds: State 1 - Ready
📺 Loading rewarded ad from AdMob...
✅ Ad loaded successfully
✅ [DEBUG] Simulated ad loaded
📺 Showing rewarded ad...
✅ [DEBUG] Simulated ad watched
✅ User earned reward: 1 Reward
📺 Ad dismissed
✅ Free creation used. Remaining: 2
✅ Free creation used. Remaining: 1
✅ Free creation used. Remaining: 0
📺 Progress to next unlock: 1/3
📺 Progress to next unlock: 2/3
🎉 Unlocked 1 ringtone!
```

---

## Recording Your Test Results

Create a simple test log:

```
Date: [Today's date]
Device: [iPhone 15 Pro Simulator / iPhone 14 Physical]
iOS Version: [17.2]

✅ Build successful
✅ App launches
✅ Song selection works
✅ First export works (3 → 2)
✅ Second export works (2 → 1)
✅ Third export works (1 → 0)
✅ Limit enforced
✅ Ad flow works (1/3, 2/3, 3/3)
✅ Unlock works
✅ Paywall displays correctly
❌ Purchase test skipped (no StoreKit config)
✅ No crashes

Issues found:
- None

Notes:
- All critical tests passed
- Ready for sandbox testing
```

---

## Next Steps After Testing

### If All Tests Pass ✅

1. **Add AdMob SDK** (if not done)
   - Follow ADMOB_INTEGRATION_GUIDE.md
   - Get real App ID and Ad Unit ID
   - Test with real ads

2. **Create Sandbox Accounts**
   - Go to App Store Connect
   - Create 2-3 test accounts
   - Test real purchases

3. **Beta Test**
   - Upload to TestFlight
   - Invite beta testers
   - Collect feedback

4. **Submit to App Store**
   - Follow APP_STORE_SUBMISSION.md
   - Upload final build
   - Submit for review

### If Tests Fail ❌

1. **Document the issue**
   - What failed?
   - Steps to reproduce
   - Console error messages
   - Screenshots

2. **Check documentation**
   - MONETIZATION_TESTING_CHECKLIST.md
   - ADMOB_INTEGRATION_GUIDE.md
   - TROUBLESHOOTING sections

3. **Fix and retest**
   - Address the issue
   - Rebuild
   - Test again

---

## Quick Test (5 Minutes)

If you're short on time, just test these:

1. ✅ Build and run (Cmd+R)
2. ✅ Select a song
3. ✅ Export 3 ringtones
4. ✅ Verify limit enforced
5. ✅ Tap "Watch Ads" (see if ad loads)
6. ✅ Tap "Go Premium" (see paywall)

If these 6 things work, your app is in good shape!

---

## Support

**Need help?**
- Check console for error messages
- Review MONETIZATION_TESTING_CHECKLIST.md
- Review ADMOB_INTEGRATION_GUIDE.md
- Check Xcode documentation

**Common issues:**
- AdMob SDK not installed → Add via SPM
- StoreKit not working → Check scheme configuration
- Songs not loading → Check permissions
- Crashes → Check console logs

---

**🧪 Happy Testing! 🚀**

**Estimated Time:** 30 minutes for full test  
**Minimum Time:** 5 minutes for quick test  
**Recommended:** Do full test first time, quick test for subsequent builds
