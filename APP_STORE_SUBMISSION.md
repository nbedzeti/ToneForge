# App Store Submission Guide

## Overview

This guide covers everything needed to submit RingToneMaker to the Apple App Store, including required configurations, App Store Connect setup, and post-submission considerations.

---

## 1. Pre-Submission Requirements

### 1.1 Xcode Project Configuration

#### App Information
- **Bundle Identifier:** `com.yourcompany.RingToneMaker` (update in project settings)
- **Version:** 1.0
- **Build Number:** 1 (increment for each submission)
- **Deployment Target:** iOS 15.0
- **Supported Devices:** iPhone, iPad

#### Capabilities Required

In Xcode, enable the following capabilities:

1. **In-App Purchase** - Required for subscriptions and lifetime purchase
   - Enable in Signing & Capabilities
   - StoreKit Configuration file (for testing)

2. **Standard Frameworks** (no special capabilities needed):
   - MediaPlayer (for music library access)
   - AVFoundation (for audio processing)
   - UniformTypeIdentifiers (for file types)
   - StoreKit (for IAP)
   - AdSupport (for IDFA - ads only)

#### Info.plist Required Keys

Verify these keys are present in `Info.plist`:

```xml
<!-- REQUIRED: Music Library Access -->
<key>NSAppleMusicUsageDescription</key>
<string>RingToneMaker needs access to your music library to select songs for creating ringtones.</string>

<!-- File Sharing -->
<key>UIFileSharingEnabled</key>
<true/>

<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>

<!-- Supported File Types -->
<key>UTImportedTypeDeclarations</key>
<array>
    <!-- M4R ringtone format -->
    <dict>
        <key>UTTypeConformsTo</key>
        <array>
            <string>public.audio</string>
        </array>
        <key>UTTypeDescription</key>
        <string>iPhone Ringtone</string>
        <key>UTTypeIdentifier</key>
        <string>com.apple.m4a-audio</string>
        <key>UTTypeTagSpecification</key>
        <dict>
            <key>public.filename-extension</key>
            <array>
                <string>m4r</string>
            </array>
        </dict>
    </dict>
</array>
```

### 1.2 Code Signing

#### Development
- **Team:** Select your Apple Developer team
- **Signing Certificate:** Apple Development
- **Provisioning Profile:** Automatic

#### Distribution
- **Team:** Select your Apple Developer team
- **Signing Certificate:** Apple Distribution
- **Provisioning Profile:** App Store

### 1.3 Build Settings

Verify these settings:
- **Swift Language Version:** Swift 5
- **Optimization Level (Release):** Optimize for Speed [-O]
- **Enable Bitcode:** No (deprecated)
- **Strip Debug Symbols:** Yes (Release)

---

## 2. App Store Connect Setup

### 2.1 App Information

#### Basic Information
- **App Name:** RingToneMaker
- **Subtitle:** Create Custom iPhone Ringtones
- **Primary Language:** English (U.S.)
- **Bundle ID:** com.yourcompany.RingToneMaker
- **SKU:** RINGTONEMAKER001

#### Category
- **Primary Category:** Music
- **Secondary Category:** Utilities

#### Age Rating
- **Rating:** 4+ (No objectionable content)
- **Unrestricted Web Access:** No
- **Gambling:** No
- **Contests:** No

### 2.2 Pricing and Availability

#### Pricing
- **Price:** Free (with in-app purchases)
- **In-App Purchases:**
  - Monthly Subscription: $4.99/month
  - Yearly Subscription: $25/year
  - Lifetime Purchase: $35 (one-time)
- **Availability:** All territories

#### In-App Purchase Configuration

**Subscription Group:** "Premium Access"

**Products:**
1. **Monthly Subscription**
   - Product ID: `com.yourapp.ringtonemaker.monthly`
   - Type: Auto-renewable subscription
   - Duration: 1 month
   - Price: $4.99
   - Free Trial: 7 days (optional)
   - Localized: Yes

2. **Yearly Subscription**
   - Product ID: `com.yourapp.ringtonemaker.yearly`
   - Type: Auto-renewable subscription
   - Duration: 1 year
   - Price: $25.00
   - Free Trial: 7 days (optional)
   - Localized: Yes

3. **Lifetime Purchase**
   - Product ID: `com.yourapp.ringtonemaker.lifetime`
   - Type: Non-consumable
   - Price: $35.00
   - Restorable: Yes
   - Family Sharing: Yes (recommended)
   - Localized: Yes

#### App Store Distribution
- **Available on:** iPhone, iPad
- **Pre-order:** Optional

### 2.3 Privacy Information

#### Privacy Policy
**Required:** Yes - Create a privacy policy covering:
- Music library access
- File storage
- No data collection
- No third-party sharing

**Sample Privacy Policy URL:** `https://yourwebsite.com/ringtonemaker/privacy`

#### Data Collection
Answer App Store Connect privacy questions:

**Do you collect data from this app?**
- **Answer:** Yes (for ads only)

**Data Types Collected:**
- **Identifiers:** Advertising identifier (IDFA) - Used for ad serving
- **Usage Data:** Ad interaction data - Used for ad optimization

**Data Linked to User:**
- None - All ad data is anonymous

**Data Used to Track You:**
- Advertising identifier (IDFA) - For personalized ads (user can opt-out)

**Explanation:** RingToneMaker uses Google AdMob for rewarded video ads. AdMob may collect device identifiers and ad interaction data for ad serving and optimization. Users can opt-out of personalized ads in iOS Settings. No other user data is collected, transmitted, or stored. All audio processing happens locally on the device.

### 2.4 App Privacy Details

#### Data Types
- **Contact Info:** Not collected
- **Health & Fitness:** Not collected
- **Financial Info:** Not collected (handled by Apple)
- **Location:** Not collected
- **Sensitive Info:** Not collected
- **Contacts:** Not collected
- **User Content:** Not collected
- **Browsing History:** Not collected
- **Search History:** Not collected
- **Identifiers:** Advertising identifier (IDFA) - For ads only, user can opt-out
- **Purchases:** Handled by Apple (not collected by app)
- **Usage Data:** Ad interaction data - Anonymous, for ad optimization
- **Diagnostics:** Not collected
- **Other Data:** Not collected

**Ad Network Disclosure:**
- Google AdMob collects IDFA for ad serving
- Users can opt-out in iOS Settings > Privacy > Tracking
- No personally identifiable information collected
- Ad data is anonymous and not linked to user identity

---

## 3. App Store Assets

### 3.1 App Icon

Required sizes (all in PNG format):
- **1024x1024** - App Store icon (no alpha channel)
- **180x180** - iPhone @3x
- **120x120** - iPhone @2x
- **167x167** - iPad Pro @2x
- **152x152** - iPad @2x
- **76x76** - iPad @1x

**Design Guidelines:**
- No transparency
- No rounded corners (iOS adds them)
- Simple, recognizable design
- Music/audio theme
- Looks good at small sizes

### 3.2 Screenshots

#### iPhone 6.7" (Required)
- **Size:** 1290 x 2796 pixels
- **Count:** 3-10 screenshots
- **Devices:** iPhone 15 Pro Max, 14 Pro Max, 13 Pro Max, 12 Pro Max

**Suggested Screenshots:**
1. Main screen with "Select Song" button
2. Waveform view with time selection
3. Export success with share options
4. Music library picker (if possible)
5. Preview playback in action

#### iPhone 6.5" (Required)
- **Size:** 1242 x 2688 pixels
- **Count:** 3-10 screenshots
- **Devices:** iPhone 11 Pro Max, XS Max

#### iPad Pro 12.9" (Required if supporting iPad)
- **Size:** 2048 x 2732 pixels
- **Count:** 3-10 screenshots

**Screenshot Tips:**
- Use actual app screenshots (no mockups)
- Show key features
- Add text overlays explaining features
- Use consistent styling
- Show the app in action
- Highlight unique features

### 3.3 Preview Videos (Optional)

- **Length:** 15-30 seconds
- **Format:** MP4 or MOV
- **Orientation:** Portrait
- **Content:** Show app workflow from start to finish

---

## 4. App Description

### 4.1 App Store Description

```
Create custom ringtones from your music library in seconds!

RingToneMaker makes it easy to turn your favorite songs into personalized iPhone ringtones. Select any song, choose the perfect 30-second clip, and export as a ringtone file.

🎁 START FREE
• 3 free ringtone creations
• Full feature access
• No credit card required

📺 WATCH & CREATE
• Watch ads to unlock more ringtones
• 3 ads = 1 additional ringtone
• Optional - never forced
• Keep creating for free

💎 GO PREMIUM
• Unlimited ringtone creations
• No ads ever
• Choose your plan:
  - Monthly: $4.99/month
  - Yearly: $25/year (save 58%)
  - Lifetime: $35 (one-time, forever)

KEY FEATURES:

🎵 Music Library Integration
• Access your entire music library
• Select any downloaded song
• Support for MP3, M4A, and AAC formats

📊 Interactive Waveform
• Visual representation of your audio
• Pinch to zoom for precise editing
• Drag to pan across the waveform

⏱️ Flexible Time Selection
• Text fields for precise timing
• Sliders for smooth control
• Stepper buttons for quick adjustments
• All methods sync automatically

🎧 Preview Before Export
• Play your selection before creating
• Ensure it sounds perfect
• Make adjustments on the fly

✂️ Professional Export
• High-quality M4R format
• Automatic 30-second duration limit
• Unique filenames for each ringtone

📤 Easy Sharing
• Save to Files app
• AirDrop to your Mac
• Share via Email or Messages
• Simple installation process

🎨 Beautiful Interface
• Clean, modern design
• Dark mode support
• Smooth animations
• Intuitive controls

PERFECT FOR:
• Creating unique ringtones for different contacts
• Using your favorite song as your ringtone
• Making custom notification sounds
• Personalizing your iPhone

HOW IT WORKS:
1. Select a song from your library
2. Choose which 30 seconds to use
3. Preview your selection
4. Export as M4R ringtone
5. Share to Files or AirDrop to Mac
6. Sync to your iPhone via Finder/iTunes

SUBSCRIPTION DETAILS:
• Monthly: $4.99/month, auto-renews monthly
• Yearly: $25/year, auto-renews yearly
• Lifetime: $35, one-time purchase, never expires
• Payment charged to Apple ID at confirmation
• Auto-renewal can be turned off in Account Settings
• Subscriptions may be managed by the user
• No cancellation of current subscription during active period
• 7-day free trial available (optional)

REQUIREMENTS:
• iOS 15.0 or later
• Downloaded songs in your music library
• Computer with Finder (Mac) or iTunes (PC) for final installation

Note: Due to iOS restrictions, ringtones must be synced via computer to appear in Settings > Sounds & Haptics. See our installation guide for detailed instructions.

Privacy: RingToneMaker uses ads for free users. Ad networks may collect device identifiers for ad serving. You can opt-out of personalized ads in iOS Settings. No other user data is collected. All processing happens locally on your device.

Support: Questions? Contact us at support@yourcompany.com
```

### 4.2 Keywords

Maximum 100 characters, comma-separated:

```
ringtone,maker,creator,music,audio,trim,editor,custom,personalize,sound,notification,alert,tone,m4r,song
```

### 4.3 Promotional Text

Maximum 170 characters (can be updated without new version):

```
Create custom ringtones from your music library! Select, trim, and export in seconds. Perfect for personalizing your iPhone with your favorite songs.
```

### 4.4 What's New (Version 1.0)

```
Welcome to RingToneMaker!

Create custom iPhone ringtones from your music library with ease.

Features:
• Interactive waveform with zoom and pan
• Multiple time selection methods
• Audio preview
• High-quality M4R export
• Easy sharing via Files, AirDrop, Email, or Messages

We'd love to hear your feedback! Please rate and review.
```

---

## 5. App Review Information

### 5.1 Contact Information

- **First Name:** Your first name
- **Last Name:** Your last name
- **Phone Number:** +1 (555) 123-4567
- **Email:** support@yourcompany.com

### 5.2 Demo Account (Not Required)

RingToneMaker doesn't require a demo account as it uses the device's music library.

### 5.3 Notes for Reviewer

```
Thank you for reviewing RingToneMaker!

TESTING INSTRUCTIONS:

1. The app requires access to the Music Library. Please grant permission when prompted.

2. To test the app, you'll need songs in the Music app. If the test device doesn't have music:
   - Open the Music app
   - Add some songs to the library
   - Return to RingToneMaker

3. Key features to test:
   - Select a song from the library
   - View the waveform visualization
   - Adjust start/end times using sliders or text fields
   - Tap "Preview" to hear the selection
   - Tap "Trim & Export Ringtone" to create the M4R file
   - Tap "Share as Ringtone" to access the share sheet

4. The exported M4R file is saved to the app's Documents directory and can be shared via the iOS share sheet.

5. Note: Due to iOS restrictions, the final step of installing the ringtone requires syncing via Finder (Mac) or iTunes (PC). This is a platform limitation, not an app limitation.

PRIVACY:
The app does not collect, transmit, or store any user data. All audio processing happens locally on the device.

PERMISSIONS:
- Music Library Access: Required to select songs for ringtone creation

If you have any questions, please contact: support@yourcompany.com

Thank you!
```

---

## 6. Build Upload

### 6.1 Archive Process

1. **Select Target Device:**
   - Product > Destination > Any iOS Device (arm64)

2. **Archive:**
   - Product > Archive
   - Wait for archive to complete

3. **Validate:**
   - In Organizer, select archive
   - Click "Validate App"
   - Fix any issues

4. **Distribute:**
   - Click "Distribute App"
   - Select "App Store Connect"
   - Upload
   - Wait for processing (15-60 minutes)

### 6.2 TestFlight (Recommended)

Before submitting for review:
1. Upload build to TestFlight
2. Add internal testers
3. Test thoroughly
4. Fix any issues
5. Upload new build if needed
6. Once stable, submit for review

---

## 7. Post-Submission

### 7.1 Review Timeline

- **Typical:** 24-48 hours
- **First submission:** May take longer
- **Resubmission:** Usually faster

### 7.2 Possible Rejection Reasons

#### Common Issues:
1. **Missing Privacy Policy**
   - Solution: Add privacy policy URL

2. **Unclear Usage Description**
   - Solution: Update NSAppleMusicUsageDescription

3. **Misleading Screenshots**
   - Solution: Use actual app screenshots

4. **Incomplete Functionality**
   - Solution: Ensure all features work

5. **Crashes**
   - Solution: Fix bugs, test thoroughly

### 7.3 If Rejected

1. Read rejection reason carefully
2. Fix the issue
3. Respond to reviewer if needed
4. Submit new build or resubmit
5. Provide additional information if requested

---

## 8. User Instructions (Post-Install)

### 8.1 In-App Help

Consider adding a help screen explaining:

**How to Install Your Ringtone:**

1. **Create Your Ringtone**
   - Select a song
   - Choose your favorite 30 seconds
   - Export as M4R file

2. **Share to Files or Computer**
   - Tap "Share as Ringtone"
   - Save to Files app OR
   - AirDrop to your Mac

3. **Sync to iPhone** (Required)
   - Connect iPhone to computer
   - Open Finder (Mac) or iTunes (PC)
   - Drag M4R file to Tones section
   - Sync your iPhone

4. **Set as Ringtone**
   - Open Settings on iPhone
   - Go to Sounds & Haptics
   - Tap Ringtone
   - Select your custom ringtone

**Why is a computer required?**
Due to iOS security restrictions, ringtones cannot be installed directly from third-party apps. Apple requires ringtones to be synced via Finder or iTunes.

### 8.2 Support Resources

Create these support resources:
- **FAQ page** on your website
- **Video tutorial** on YouTube
- **Email support** for questions
- **In-app tips** for first-time users

---

## 9. Marketing & Launch

### 9.1 Launch Checklist

- [ ] App Store listing complete
- [ ] Screenshots finalized
- [ ] Description optimized
- [ ] Keywords researched
- [ ] Privacy policy published
- [ ] Support email configured
- [ ] Website/landing page created
- [ ] Social media accounts ready
- [ ] Press kit prepared
- [ ] Launch date set

### 9.2 Post-Launch

- Monitor reviews and ratings
- Respond to user feedback
- Track downloads and usage
- Plan updates and improvements
- Engage with users on social media

---

## 10. Compliance Checklist

### 10.1 App Store Guidelines

Verify compliance with:
- [ ] 2.1 - App Completeness
- [ ] 2.3 - Accurate Metadata
- [ ] 4.0 - Design (Human Interface Guidelines)
- [ ] 5.1.1 - Privacy (Data Collection)
- [ ] 5.1.2 - Privacy (Permission Usage)

### 10.2 Legal Requirements

- [ ] Privacy policy created and accessible
- [ ] Terms of service (if applicable)
- [ ] Copyright compliance
- [ ] Trademark compliance
- [ ] Export compliance (if applicable)

---

## Support Contact

For questions about this submission guide:
- **Email:** dev@yourcompany.com
- **Documentation:** See README.md and other guides

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | TBD | Initial release |

---

**Good luck with your App Store submission! 🚀**
