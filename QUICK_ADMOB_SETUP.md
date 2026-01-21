# Quick AdMob Setup - 5 Steps

## ⚡ Fast Track (20 minutes total)

---

## Step 1: Add SDK (5 min)

### Swift Package Manager (Recommended)
```
1. Open RingToneMaker.xcodeproj
2. File > Add Package Dependencies
3. Paste: https://github.com/googleads/swift-package-manager-google-mobile-ads.git
4. Version: 11.0.0+
5. Add Package
```

### OR CocoaPods
```bash
cd RingToneMaker
pod install
open RingToneMaker.xcworkspace
```

---

## Step 2: Create AdMob Account (10 min)

1. Go to [admob.google.com](https://admob.google.com)
2. Sign in with Google
3. Click **Get Started**
4. Click **Apps** > **Add App**
5. Select **iOS**
6. Name: **RingToneMaker**
7. Copy **App ID**: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`

---

## Step 3: Create Ad Unit (2 min)

1. Click **Ad units** > **Add Ad Unit**
2. Select **Rewarded**
3. Name: **Ringtone Unlock Reward**
4. Click **Create Ad Unit**
5. Copy **Ad Unit ID**: `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY`

---

## Step 4: Update IDs (2 min)

### Info.plist
Replace line 8:
```xml
<key>GADApplicationIdentifier</key>
<string>YOUR_APP_ID_HERE</string>
```

### AdManager.swift
Replace line 24:
```swift
private let productionAdUnitID = "YOUR_AD_UNIT_ID_HERE"
```

---

## Step 5: Test (5 min)

```bash
1. Build: Cmd+B
2. Run: Cmd+R
3. Check console:
   ✅ Google Mobile Ads SDK initialized
   📺 Loading rewarded ad...
   ✅ Ad loaded successfully

4. In app:
   - Use 3 free ringtones
   - Tap "Watch Ad to Unlock Ringtone"
   - Watch test ad
   - See success toast: "🎉 Unlocked 1 ringtone!"
```

---

## ✅ Done!

**Test ads work automatically in DEBUG builds.**

**For production:**
- Replace test IDs with your real IDs
- Build in Release mode
- Submit to App Store

---

## Need Help?

- 📚 Full guide: [ADMOB_INTEGRATION_GUIDE.md](ADMOB_INTEGRATION_GUIDE.md)
- 📚 Setup details: [ADMOB_SETUP_COMPLETE.md](ADMOB_SETUP_COMPLETE.md)
- 🔧 Run setup script: `./setup_admob.sh`

---

## Troubleshooting

**"Cannot find GADMobileAds"**
→ Add SDK via SPM or CocoaPods

**"Ad failed to load"**
→ Check internet, verify IDs are correct

**"SDK not initialized"**
→ Verify import GoogleMobileAds in RingToneMakerApp.swift

---

**🚀 Ready to monetize!**
