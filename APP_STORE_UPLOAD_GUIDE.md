# 🚀 ToneForge Studio - App Store Upload Guide

**Your app is tested and ready! Let's get it on the App Store.**

---

## Step 1: Archive Your App in Xcode (15 minutes)

### 1.1 Open Your Project
```bash
# Open Xcode project
open ~/Documents/RingToneAPP\ Maker/RingToneMaker/RingToneMaker.xcodeproj
```

### 1.2 Select "Any iOS Device (arm64)"
- At the top of Xcode, click the device selector (next to the Run button)
- Select **"Any iOS Device (arm64)"** (NOT a simulator!)
- This is required for archiving

### 1.3 Archive the App
1. In Xcode menu: **Product → Archive**
2. Wait for the build to complete (2-5 minutes)
3. The Organizer window will open automatically

**If Archive is grayed out:**
- Make sure you selected "Any iOS Device (arm64)"
- Make sure you're signed in with your Apple Developer account
- Go to Signing & Capabilities tab and verify your Team is selected

---

## Step 2: Upload to App Store Connect (10 minutes)

### 2.1 In the Organizer Window
1. Your archive should appear in the list
2. Click **"Distribute App"** button (blue button on the right)

### 2.2 Select Distribution Method
1. Choose **"App Store Connect"**
2. Click **"Next"**

### 2.3 Select Destination
1. Choose **"Upload"**
2. Click **"Next"**

### 2.4 Distribution Options
1. Keep all default options checked:
   - ✅ Include bitcode for iOS content
   - ✅ Upload your app's symbols
   - ✅ Manage Version and Build Number
2. Click **"Next"**

### 2.5 Re-sign Your App
1. Choose **"Automatically manage signing"**
2. Click **"Next"**

### 2.6 Review and Upload
1. Review the app information
2. Click **"Upload"**
3. Wait for upload to complete (5-10 minutes depending on internet speed)

### 2.7 Success!
- You'll see "Upload Successful" message
- Click **"Done"**

**Note:** It takes 10-30 minutes for your build to appear in App Store Connect after upload.

---

## Step 3: Create App in App Store Connect (30 minutes)

### 3.1 Go to App Store Connect
1. Open browser: https://appstoreconnect.apple.com
2. Sign in with your Apple Developer account
3. Click **"My Apps"**

### 3.2 Create New App
1. Click the **"+"** button (top left)
2. Select **"New App"**

### 3.3 Fill in App Information

**Platforms:**
- ✅ iOS

**Name:**
```
ToneForge Studio
```

**Primary Language:**
```
English (U.S.)
```

**Bundle ID:**
```
com.IceFireSoul.ToneForge
```
(Select from dropdown - should be there if you uploaded correctly)

**SKU:**
```
TONEFORGE001
```
(Can be anything unique, used for your records only)

**User Access:**
```
Full Access
```

Click **"Create"**

---

## Step 4: Fill in App Store Information (45 minutes)

### 4.1 App Information Tab

**Name:**
```
ToneForge Studio
```

**Subtitle (Optional but recommended):**
```
Custom Ringtone Maker
```

**Privacy Policy URL:**
```
https://nbedzeti.github.io/ToneForge/privacy.html
```

**Category:**
- **Primary:** Music
- **Secondary:** Utilities

**Content Rights:**
- Select: "No, it does not contain, show, or access third-party content"

---

### 4.2 Pricing and Availability

1. Click **"Pricing and Availability"** in left sidebar
2. **Price:** Select **"Free"** (we have in-app purchases)
3. **Availability:** Select all countries (or choose specific ones)
4. Click **"Save"**

---

### 4.3 App Privacy

1. Click **"App Privacy"** in left sidebar
2. Click **"Get Started"**

**Data Collection:**
- Select: "No, we do not collect data from this app"
- (We don't collect personal data, only use local storage)

Click **"Save"** and **"Publish"**

---

### 4.4 Prepare for Submission

1. Click **"1.0 Prepare for Submission"** in left sidebar

---

### 4.5 Screenshots (REQUIRED)

**You need 6 screenshots at 1284 × 2778px**

You already have them! Upload from:
```
~/Desktop/ToneForge-AppStore-Screenshots-Resized/
```

1. Scroll to **"6.9" iPhone Display"** section
2. Drag and drop all 6 screenshots:
   - IMG_1.PNG
   - IMG_2.PNG
   - IMG_3.PNG
   - IMG_4.PNG
   - IMG_5.PNG
   - IMG_6.PNG

**Order matters!** Make sure they tell a story:
1. Welcome/Home screen
2. Audio selection
3. Waveform editor
4. Audio effects
5. Premium features
6. Final result/share

---

### 4.6 Promotional Text (Optional)

```
Create custom ringtones in seconds! Import any song, trim to perfection, add professional effects, and make your phone truly yours. Try 3 free ringtones, then unlock unlimited creativity with Premium.
```

---

### 4.7 Description (REQUIRED)

```
Transform any song into a custom ringtone with ToneForge Studio - the most powerful ringtone maker for iPhone.

🎵 EASY TO USE
• Import songs from your Music Library or Files
• Visual waveform makes editing simple
• Precise time selection with custom number pad
• Preview before exporting

✨ PROFESSIONAL FEATURES
• Fade in/out effects for smooth transitions
• Volume boost for louder ringtones
• Audio normalization for perfect levels
• 5-band equalizer with presets
• Reverb and echo effects
• Save favorites to your library

🎁 FREE TO START
• Create 3 custom ringtones for free
• No ads, no watermarks
• Full access to basic editing tools

⭐ PREMIUM BENEFITS
• Unlimited ringtone creation
• All premium audio effects
• Ringtone library management
• Priority support

💎 FLEXIBLE PRICING
• Monthly: $2.99/month
• Yearly: $17.99/year (50% savings!)
• Lifetime: $24.99 (one-time purchase)

Perfect for:
✓ Personalizing your iPhone
✓ Creating unique notification sounds
✓ Making ringtones for family and friends
✓ Standing out from default ringtones

Download ToneForge Studio today and make your phone sound as unique as you are!

Privacy Policy: https://nbedzeti.github.io/ToneForge/privacy.html
Support: nbedzeti.ny@icloud.com
```

---

### 4.8 Keywords (REQUIRED)

```
ringtone,maker,creator,custom,music,audio,editor,sound,notification,tone,song,trim,cut,effects,fade,equalizer
```

**Tips:**
- Max 100 characters
- Separate with commas (no spaces)
- No app name in keywords
- Focus on what users search for

---

### 4.9 Support URL (REQUIRED)

```
https://github.com/nbedzeti/ToneForge
```

---

### 4.10 Marketing URL (Optional)

```
https://github.com/nbedzeti/ToneForge
```

---

### 4.11 Version Information

**Version:** 1.0

**Copyright:**
```
2026 Your Name
```
(Replace "Your Name" with your actual name or company name)

**What's New in This Version:**
```
Welcome to ToneForge Studio!

🎉 Initial Release Features:
• Create custom ringtones from any song
• Professional audio editing tools
• Visual waveform editor
• Premium effects (fade, reverb, EQ, and more)
• Ringtone library for easy management
• 3 free ringtones to get started

Make your iPhone sound unique with ToneForge Studio!
```

---

### 4.12 Build Selection

1. Scroll to **"Build"** section
2. Click **"Select a build before you submit your app"**
3. Wait if your build isn't showing yet (can take 10-30 minutes after upload)
4. Once it appears, click the **"+"** button next to your build
5. Select your build (Version 1.0, Build 1)
6. Click **"Done"**

**If build doesn't appear:**
- Wait 30 minutes and refresh the page
- Check your email for any processing errors from Apple
- Make sure upload completed successfully in Xcode Organizer

---

### 4.13 App Review Information

**Contact Information:**
- **First Name:** Your first name
- **Last Name:** Your last name
- **Phone Number:** Your phone number
- **Email:** nbedzeti.ny@icloud.com

**Sign-in Required:**
- Select: "No" (app doesn't require login)

**Demo Account (if needed):**
- Leave blank (not needed)

**Notes:**
```
ToneForge Studio is a ringtone maker app that allows users to create custom ringtones from their music library or imported audio files.

Free users get 3 ringtones. Premium subscription unlocks unlimited ringtones and advanced audio effects.

No special setup required for testing. Simply:
1. Launch the app
2. Select "My Music Library" or "Import Audio File"
3. Choose any audio file
4. Edit the waveform to select desired portion
5. Tap "Create Ringtone"

Premium features can be tested using StoreKit testing (sandbox environment).

Thank you for reviewing our app!
```

**Attachment (Optional):**
- You can add a demo video if you want (not required)

---

### 4.14 Version Release

**Select:**
- ⚪ Manually release this version
- OR
- 🔘 Automatically release this version after App Review

**Recommendation:** Choose "Automatically release" for your first version.

---

### 4.15 Age Rating

1. Click **"Edit"** next to Age Rating
2. Answer the questionnaire:

**Frequent/Intense Cartoon or Fantasy Violence:** No  
**Frequent/Intense Realistic Violence:** No  
**Frequent/Intense Sexual Content or Nudity:** No  
**Frequent/Intense Profanity or Crude Humor:** No  
**Frequent/Intense Alcohol, Tobacco, or Drug Use:** No  
**Frequent/Intense Mature/Suggestive Themes:** No  
**Frequent/Intense Horror/Fear Themes:** No  
**Gambling:** No  
**Unrestricted Web Access:** No  
**Contests:** No  

3. Click **"Done"**
4. Rating should be **4+**

---

## Step 5: Set Up In-App Purchases (30 minutes)

### 5.1 Go to In-App Purchases

1. In left sidebar, click **"In-App Purchases"**
2. Click **"Manage"** (or the "+" button)

### 5.2 Create Monthly Subscription

1. Click **"Create"** or **"+"**
2. Select **"Auto-Renewable Subscription"**
3. Click **"Create"**

**Reference Name:**
```
Premium Monthly Subscription
```

**Product ID:**
```
com.IceFireSoul.ToneForge.premium.monthly
```

**Subscription Group:**
- Click **"Create New Subscription Group"**
- Name: `Premium Subscriptions`
- Click **"Create"**

**Subscription Duration:**
```
1 Month
```

**Subscription Prices:**
1. Click **"Add Pricing"**
2. Select **"United States"**
3. Enter **$2.99**
4. Click **"Next"**
5. Apple will auto-fill prices for other countries
6. Click **"Create"**

**Localization:**
1. Click **"Create Localization"**
2. Language: **English (U.S.)**
3. **Display Name:**
   ```
   Premium Monthly
   ```
4. **Description:**
   ```
   Unlimited ringtones and all premium features. Billed monthly.
   ```
5. Click **"Save"**

**Review Information:**
- Screenshot: Upload any app screenshot (required)
- Review Notes: Leave blank

Click **"Save"** in top right

---

### 5.3 Create Yearly Subscription

Repeat the same process:

**Reference Name:**
```
Premium Yearly Subscription
```

**Product ID:**
```
com.IceFireSoul.ToneForge.premium.yearly
```

**Subscription Group:**
- Select existing: `Premium Subscriptions`

**Subscription Duration:**
```
1 Year
```

**Subscription Prices:**
- **$17.99**

**Display Name:**
```
Premium Yearly
```

**Description:**
```
Unlimited ringtones and all premium features. Billed yearly. Save 50%!
```

Click **"Save"**

---

### 5.4 Create Lifetime Purchase

1. Click **"Create"** or **"+"**
2. Select **"Non-Consumable"**
3. Click **"Create"**

**Reference Name:**
```
Premium Lifetime Purchase
```

**Product ID:**
```
com.IceFireSoul.ToneForge.premium.lifetime
```

**Price:**
- **$24.99**

**Localization:**
- Language: **English (U.S.)**
- **Display Name:**
   ```
   Premium Lifetime
   ```
- **Description:**
   ```
   Unlimited ringtones and all premium features. One-time purchase, yours forever!
   ```

**Review Information:**
- Screenshot: Upload any app screenshot

Click **"Save"**

---

### 5.5 Submit IAPs for Review

1. Go back to **"In-App Purchases"** section
2. For each product, click on it
3. Click **"Submit for Review"** button
4. Repeat for all 3 products

**Note:** IAPs are reviewed together with your app.

---

## Step 6: Submit for Review (5 minutes)

### 6.1 Final Check

Go through this checklist:

```
□ Screenshots uploaded (6 images)
□ App icon showing (1024x1024)
□ Description written
□ Keywords added
□ Privacy policy URL added
□ Support URL added
□ Build selected
□ Age rating completed (4+)
□ In-app purchases created (3 products)
□ App review information filled
□ Version release option selected
```

---

### 6.2 Submit!

1. Scroll to the top of the page
2. Click **"Add for Review"** button (top right)
3. Review the summary
4. Click **"Submit to App Review"**

🎉 **Congratulations! Your app is submitted!**

---

## Step 7: Wait for Review (1-3 days)

### What Happens Next?

1. **In Review** (1-3 days)
   - Apple reviews your app
   - They test functionality
   - Check for guideline violations

2. **Possible Outcomes:**
   - ✅ **Approved** - Your app goes live!
   - ⚠️ **Metadata Rejected** - Fix description/screenshots, resubmit
   - ❌ **Rejected** - Fix issues, resubmit

3. **Email Notifications:**
   - You'll get emails at each status change
   - Check App Store Connect regularly

---

## Step 8: After Approval

### When Approved:

1. **App Goes Live** (if you selected auto-release)
2. **Check the App Store:**
   - Search for "ToneForge Studio"
   - Download and verify it works
   - Share the link!

3. **Monitor:**
   - Reviews (respond to all!)
   - Crashes (check Xcode Organizer)
   - Downloads (App Store Connect Analytics)

4. **Promote:**
   - Share on social media
   - Ask friends to download and review
   - Post on Reddit (r/iphone, r/iosapps)
   - Submit to Product Hunt

---

## Common Issues & Solutions

### Issue: "Build not appearing in App Store Connect"
**Solution:** 
- Wait 30 minutes after upload
- Check email for processing errors
- Verify upload completed in Xcode Organizer

### Issue: "Invalid Bundle ID"
**Solution:**
- Make sure Bundle ID in Xcode matches App Store Connect
- Should be: `com.IceFireSoul.ToneForge`

### Issue: "Missing Compliance"
**Solution:**
- After submission, you may get "Export Compliance" question
- Answer: "No" (app doesn't use encryption beyond standard iOS)

### Issue: "IAP products not showing in app"
**Solution:**
- Wait 24 hours after creating them
- Make sure they're "Ready to Submit" status
- Test with StoreKit Configuration file in Xcode

### Issue: "App Rejected"
**Solution:**
- Read rejection reason carefully
- Fix the specific issue mentioned
- Respond to Apple if you need clarification
- Resubmit (usually faster 2nd time)

---

## Need Help?

### Apple Resources:
- App Store Connect Help: https://help.apple.com/app-store-connect/
- Developer Forums: https://developer.apple.com/forums/
- Contact Apple: https://developer.apple.com/contact/

### Your Documentation:
- `V1.0_READY_TO_SUBMIT.md` - Complete guide
- `PRODUCTION_CHECKLIST.md` - Detailed checklist
- `READY_FOR_SUBMISSION.md` - Submission overview

---

## 🎊 You're Almost There!

Follow these steps carefully, and your app will be live on the App Store in 1-3 days!

**Good luck! 🚀**

---

**Last Updated:** January 25, 2026  
**App:** ToneForge Studio v1.0  
**Status:** Ready for Upload
