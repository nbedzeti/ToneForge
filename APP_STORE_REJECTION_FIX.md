# App Store Rejection Fix Guide - Guideline 3.1.2

## Rejection Reason

**Guideline 3.1.2 - Business - Payments - Subscriptions**

Apple rejected the app because it's missing required information for auto-renewable subscriptions:
- ❌ Missing functional link to Terms of Use (EULA)
- ❌ Incomplete subscription information in the app

## What We Fixed

### 1. Created Terms of Use (EULA) ✅

**File:** `docs/terms.html`

A comprehensive Terms of Use document that includes:
- Subscription terms and pricing
- Auto-renewal details
- Cancellation instructions
- Payment information
- Refund policy
- All required legal disclosures

**Live URL:** https://nbedzeti.github.io/ToneForge/terms.html

### 2. Updated In-App Subscription Display ✅

**File:** `RingToneMaker/PurchaseView.swift`

Added complete subscription information in the legal section:
- ✅ Title of each subscription (Premium Monthly, Premium Yearly, Premium Lifetime)
- ✅ Length of subscription (per month, per year, one-time)
- ✅ Price of subscription ($4.99/month, $29.99/year, $49.99 lifetime)
- ✅ Functional link to Privacy Policy
- ✅ Functional link to Terms of Use (EULA)
- ✅ Auto-renewal disclosure
- ✅ Cancellation instructions

### 3. Updated Documentation ✅

**File:** `docs/README.md`

Updated to reflect both legal documents are now hosted.

## What You Need to Do

### Step 1: Push Changes to GitHub

```bash
git add docs/terms.html
git add docs/README.md
git add RingToneMaker/PurchaseView.swift
git add APP_STORE_REJECTION_FIX.md
git commit -m "Add Terms of Use and fix App Store rejection (Guideline 3.1.2)"
git push origin main
```

### Step 2: Verify Terms of Use is Live

1. Wait 1-2 minutes for GitHub Pages to deploy
2. Visit: https://nbedzeti.github.io/ToneForge/terms.html
3. Verify the page loads correctly
4. Check that all information is accurate

### Step 3: Test in the App

1. Build and run the app on a real device
2. Go to the Premium/Purchase screen
3. Scroll to the bottom
4. Verify you see:
   - Subscription information (titles, lengths, prices)
   - Auto-renewal disclosure
   - "Privacy Policy" link (should open in Safari)
   - "Terms of Use" link (should open in Safari)
5. Tap both links to ensure they work

### Step 4: Update App Store Connect Metadata

#### Option A: Add EULA Link to App Description (Recommended)

1. Go to App Store Connect
2. Select your app → App Store tab
3. Scroll to **Description** field
4. Add this text at the end of your description:

```
Terms of Use: https://nbedzeti.github.io/ToneForge/terms.html
```

#### Option B: Use Custom EULA Field

1. Go to App Store Connect
2. Select your app → App Store tab
3. Scroll to **App Information** section
4. Find **End User License Agreement (EULA)** field
5. Select "Custom EULA"
6. Paste the content from `docs/terms.html` (text only, no HTML)

**Note:** Option A is easier and recommended since you already have the HTML page.

### Step 5: Verify All Required Information

Before resubmitting, double-check:

#### In the App (PurchaseView.swift):
- ✅ Subscription titles displayed (Premium Monthly, Premium Yearly, Premium Lifetime)
- ✅ Subscription lengths shown (per month, per year, one-time)
- ✅ Prices displayed ($4.99/month, $29.99/year, $49.99 lifetime)
- ✅ Privacy Policy link works
- ✅ Terms of Use link works
- ✅ Auto-renewal disclosure present
- ✅ Cancellation instructions included

#### In App Store Connect Metadata:
- ✅ Privacy Policy URL in Privacy Policy field: https://nbedzeti.github.io/ToneForge/privacy.html
- ✅ Terms of Use URL in App Description OR Custom EULA field: https://nbedzeti.github.io/ToneForge/terms.html

### Step 6: Resubmit to App Store

1. In Xcode, increment the build number:
   - Select project → Target → General
   - Increment **Build** number (e.g., 1 → 2)
   
2. Archive and upload the new build:
   - Product → Archive
   - Distribute App → App Store Connect
   - Upload

3. In App Store Connect:
   - Go to your app
   - Select the new build
   - Click "Submit for Review"
   
4. In the review notes, add:

```
We have addressed the Guideline 3.1.2 rejection by:

1. Adding a comprehensive Terms of Use (EULA) document at:
   https://nbedzeti.github.io/ToneForge/terms.html

2. Including all required subscription information in the app:
   - Subscription titles, lengths, and prices
   - Auto-renewal disclosure
   - Cancellation instructions
   - Functional links to Privacy Policy and Terms of Use

3. Adding the Terms of Use link to the App Store metadata.

All subscription information is now clearly displayed both in the app 
and in the App Store listing as required by Guideline 3.1.2.
```

## Checklist Before Resubmission

- [ ] Terms of Use (EULA) created and live at https://nbedzeti.github.io/ToneForge/terms.html
- [ ] Privacy Policy live at https://nbedzeti.github.io/ToneForge/privacy.html
- [ ] PurchaseView.swift updated with complete subscription information
- [ ] Both links tested in the app and work correctly
- [ ] Terms of Use URL added to App Store Connect (Description or EULA field)
- [ ] Privacy Policy URL in App Store Connect Privacy Policy field
- [ ] Build number incremented
- [ ] New build uploaded to App Store Connect
- [ ] Review notes added explaining the fixes
- [ ] App resubmitted for review

## Expected Timeline

- **GitHub Pages deployment:** 1-2 minutes
- **App Store review:** 1-3 days (typically faster for resubmissions)

## What Apple is Looking For

Apple wants to ensure users have clear information about subscriptions before purchasing:

1. **In the App:**
   - Clear display of what they're buying
   - How much it costs
   - How often they'll be charged
   - How to cancel
   - Where to find legal terms

2. **In App Store Connect:**
   - Functional links to legal documents
   - Privacy Policy in the designated field
   - Terms of Use either in Description or EULA field

## Common Mistakes to Avoid

❌ **Don't** use Apple's standard EULA without adding your own link  
✅ **Do** provide a functional link to your custom Terms of Use

❌ **Don't** hide subscription terms in small print  
✅ **Do** display subscription information prominently in the app

❌ **Don't** forget to test the links before resubmitting  
✅ **Do** verify both Privacy Policy and Terms of Use links work

❌ **Don't** use broken or placeholder URLs  
✅ **Do** ensure URLs are live and accessible

## Support Resources

- [Apple Subscription Guidelines](https://developer.apple.com/app-store/subscriptions/)
- [App Store Review Guidelines 3.1.2](https://developer.apple.com/app-store/review/guidelines/#business)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)

## Need Help?

If you encounter issues:

1. **Links not working:** Verify GitHub Pages is enabled and deployed
2. **App Store still rejecting:** Double-check all information is visible in the app
3. **Build issues:** Ensure you incremented the build number
4. **Review questions:** Respond promptly to App Review team in Resolution Center

---

**Status:** Ready for resubmission  
**Last Updated:** January 28, 2025  
**Estimated Fix Time:** 15-30 minutes + review time

Good luck with the resubmission! 🚀
