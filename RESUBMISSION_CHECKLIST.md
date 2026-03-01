# App Store Resubmission Checklist

## Quick Fix Summary

Apple rejected the app for missing Terms of Use (EULA) link. We've fixed it.

## 5-Minute Action Plan

### 1. Push Code to GitHub (2 min)

```bash
git add .
git commit -m "Fix App Store rejection - Add Terms of Use (Guideline 3.1.2)"
git push origin main
```

### 2. Verify Links Work (1 min)

Wait 1-2 minutes, then check:
- ✅ https://nbedzeti.github.io/ToneForge/privacy.html
- ✅ https://nbedzeti.github.io/ToneForge/terms.html

### 3. Update App Store Connect (2 min)

1. Go to App Store Connect → Your App → App Store tab
2. Scroll to **Description** field
3. Add at the end:

```
Terms of Use: https://nbedzeti.github.io/ToneForge/terms.html
```

4. Click **Save**

### 4. Build & Upload (10 min)

1. Open Xcode
2. Increment build number: Target → General → Build (e.g., 1 → 2)
3. Product → Archive
4. Distribute → App Store Connect → Upload

### 5. Resubmit (2 min)

1. App Store Connect → Select new build
2. Add review note:

```
Fixed Guideline 3.1.2 rejection:
- Added Terms of Use at https://nbedzeti.github.io/ToneForge/terms.html
- Updated app to display all required subscription information
- Added EULA link to App Store metadata
```

3. Click **Submit for Review**

## Done! ✅

Expected review time: 1-3 days

---

## What We Fixed

### In the App:
- ✅ Added complete subscription information (titles, lengths, prices)
- ✅ Added Terms of Use link
- ✅ Added auto-renewal disclosure
- ✅ Added cancellation instructions

### In App Store Connect:
- ✅ Added Terms of Use URL to app description

### On GitHub Pages:
- ✅ Created comprehensive Terms of Use document
- ✅ Updated documentation

---

## Test Before Submitting

Run the app and verify:
- [ ] Premium screen shows subscription details
- [ ] "Privacy Policy" link opens in Safari
- [ ] "Terms of Use" link opens in Safari
- [ ] Both pages load correctly

---

**Total Time:** ~15-20 minutes  
**Files Changed:** 3 files  
**New Files:** 2 files

See `APP_STORE_REJECTION_FIX.md` for detailed explanation.
