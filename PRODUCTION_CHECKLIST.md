# ToneForge Studio - Production Release Checklist

## ✅ Code Cleanup (COMPLETED)

- [x] **Testing flag disabled** - `enablePremiumForTesting = false` in PurchaseManager.swift
- [x] **Debug prints removed** - Cleaned up console logging
- [x] **Build successful** - No errors or warnings
- [x] **Version set** - 1.0 (Build 1)

---

## 📱 App Store Connect Setup (TODO)

### 1. Create App Listing
- [ ] Log into App Store Connect
- [ ] Create new app: "ToneForge Studio"
- [ ] Bundle ID: `com.IceFireSoul.ToneForge`
- [ ] Primary Language: English
- [ ] Category: Music
- [ ] Age Rating: 4+

### 2. Create In-App Purchases
Create these 3 products in App Store Connect:

#### Monthly Subscription
- **Product ID**: `com.IceFireSoul.ToneForge.premium.monthly`
- **Reference Name**: Monthly Premium
- **Price**: $2.99 USD
- **Subscription Duration**: 1 month
- **Description**: "Monthly subscription for unlimited ringtone creations with premium features and no ads."

#### Yearly Subscription
- **Product ID**: `com.IceFireSoul.ToneForge.premium.yearly`
- **Reference Name**: Yearly Premium
- **Price**: $17.99 USD
- **Subscription Duration**: 1 year
- **Description**: "Yearly subscription for unlimited ringtone creations with premium features and no ads. Save 50% compared to monthly!"

#### Lifetime Purchase
- **Product ID**: `com.IceFireSoul.ToneForge.premium.lifetime`
- **Reference Name**: Lifetime Premium
- **Type**: Non-Consumable
- **Price**: $24.99 USD
- **Description**: "One-time purchase for unlimited ringtone creations with premium features, no ads, forever."

### 3. App Information

#### App Name
```
ToneForge Studio
```

#### Subtitle (30 chars max)
```
Custom Ringtone Maker
```

#### Keywords (100 chars max)
```
ringtone,maker,custom,music,sound,tone,notification,alert,audio,editor
```

#### Description
```
Create custom ringtones in 30 seconds.
No music degree required. No complicated tools.
Just pick a song, trim it, and you're done.

WHY TONEFORGE?

✓ Simple & Fast
  Pick a song, trim to 30 seconds, export. That's it.

✓ Professional Effects
  Add reverb, echo, EQ, fade in/out, volume boost, and audio normalization.

✓ Organize Your Ringtones
  Save unlimited ringtones to your personal library.

✓ Beautiful Interface
  Clean, modern design that's easy to understand.

✓ No Subscription Required
  Choose monthly, yearly, or lifetime - you decide.

FEATURES

Free Version:
• Create 3 ringtones
• Basic trimming
• Export to Files app

Premium Features:
• Unlimited ringtones
• No ads
• Fade in/out effects
• Volume boost
• Audio normalization
• Reverb (5 presets)
• Echo/Delay
• EQ presets (4 modes)
• Ringtone library
• Preview with effects
• Save to library

IMPORTANT NOTE

Due to copyright protection, streaming music from Spotify, Apple Music, and other services cannot be accessed. Use purchased music from iTunes, synced music from your computer, or import your own audio files.

PRICING

Monthly: $2.99/month
Yearly: $17.99/year (Save 50%!)
Lifetime: $24.99 one-time

Privacy Policy: [Your URL]
Terms of Service: [Your URL]
Support: [Your email]
```

#### Promotional Text (170 chars max)
```
🎉 Launch Special: Get started with 3 free ringtones! Upgrade for unlimited creations, professional effects, and no ads. Simple. Fast. Beautiful.
```

#### What's New (Version 1.0)
```
Welcome to ToneForge Studio!

Create custom ringtones in seconds with our simple, beautiful interface.

Features:
• Waveform editor
• Professional audio effects
• Ringtone library
• No subscription required

We'd love your feedback!
```

---

## 📸 Screenshots Required (TODO)

You need screenshots for these device sizes:

### iPhone 6.7" (iPhone 15 Pro Max, 14 Pro Max, etc.)
- 1290 x 2796 pixels
- 3-10 screenshots

### iPhone 6.5" (iPhone 11 Pro Max, XS Max)
- 1242 x 2688 pixels
- 3-10 screenshots

### Recommended Screenshots:
1. **Welcome Screen** - "Create Ringtones in 30 Seconds"
2. **Waveform Editor** - Show trimming interface
3. **Audio Effects** - Show effects panel expanded
4. **Library** - Show saved ringtones
5. **Premium Features** - Show upgrade screen

**Tools to create screenshots:**
- Use Xcode Simulator
- Cmd+S to save screenshot
- Or use Screenshot.app on Mac

---

## 🎬 App Preview Video (Optional but Recommended)

- 15-30 seconds
- Show: Pick song → Trim → Add effects → Export
- Use screen recording on simulator
- Edit with iMovie or Final Cut Pro

---

## 🔐 Privacy & Permissions

### Privacy Policy Required
You need a privacy policy URL. Create one at:
- https://www.privacypolicygenerator.info/
- Or use https://app-privacy-policy-generator.firebaseapp.com/

### Permissions Used:
- **Music Library Access** - To select songs for ringtones
- **File Access** - To import audio files
- **AdMob** - For showing ads to free users

### App Privacy Questions (App Store Connect):
- **Data Collection**: Yes (for ads)
- **Data Types**: Device ID (for ads)
- **Data Usage**: Analytics, Advertising
- **Data Linked to User**: No
- **Tracking**: Yes (AdMob)

---

## 🧪 TestFlight (Recommended)

Before public release, test with TestFlight:

1. Archive app in Xcode
2. Upload to App Store Connect
3. Submit for TestFlight review (1-2 days)
4. Invite 5-10 beta testers
5. Test for 1 week
6. Fix any critical bugs
7. Then submit for App Store review

---

## 📤 Submission Checklist

### Before Archiving:
- [ ] Testing flag is FALSE
- [ ] Debug prints removed
- [ ] Version number correct (1.0)
- [ ] Build number correct (1)
- [ ] Bundle ID correct: `com.IceFireSoul.ToneForge`
- [ ] Team ID correct: 7PV9J7D87S
- [ ] Signing configured for distribution

### Archive & Upload:
- [ ] Product → Archive in Xcode
- [ ] Validate archive (check for issues)
- [ ] Distribute to App Store Connect
- [ ] Wait for processing (10-30 minutes)

### App Store Connect:
- [ ] All 3 IAP products created and approved
- [ ] Screenshots uploaded (all sizes)
- [ ] App icon uploaded (1024x1024)
- [ ] Description written
- [ ] Keywords added
- [ ] Privacy policy URL added
- [ ] Support URL added
- [ ] Age rating completed
- [ ] Pricing set (Free with IAP)
- [ ] Availability: All countries

### Submit for Review:
- [ ] Click "Submit for Review"
- [ ] Answer review questions
- [ ] Add notes for reviewer (optional)
- [ ] Wait 1-3 days for review

---

## 🚀 Post-Approval

### Launch Day:
- [ ] App goes live
- [ ] Post on Product Hunt
- [ ] Post on Reddit (r/iphone, r/iosapps)
- [ ] Tweet launch announcement
- [ ] Email friends/family for reviews

### First Week:
- [ ] Monitor reviews daily
- [ ] Respond to all reviews
- [ ] Fix critical bugs immediately
- [ ] Track analytics (downloads, conversions)

### First Month:
- [ ] Aim for 50+ reviews
- [ ] Plan first update (bug fixes)
- [ ] Gather feature requests
- [ ] Analyze pricing effectiveness

---

## 📊 Success Metrics

### Week 1 Goals:
- 500-1,000 downloads
- 10-20 reviews
- 4.0+ star rating
- 3-5% conversion to premium

### Month 1 Goals:
- 2,000-5,000 downloads
- 50+ reviews
- 4.5+ star rating
- $500-$2,000 revenue

---

## ⚠️ Common Rejection Reasons

Watch out for these:
- Missing privacy policy
- Incomplete IAP descriptions
- Misleading screenshots
- Crashes on launch
- Missing required permissions explanations
- Incomplete metadata

---

## 📞 Support

If rejected, don't panic:
1. Read rejection reason carefully
2. Fix the issue
3. Resubmit (usually faster 2nd time)
4. Use App Review Board if unfair

---

## 🎉 You're Ready!

Your app is production-ready. Good luck with the launch!

Remember:
- Reviews are everything
- Respond to users quickly
- Iterate based on feedback
- Be patient - success takes time

---

**Last Updated**: January 24, 2025
**Version**: 1.0 (Build 1)
**Status**: Ready for submission
