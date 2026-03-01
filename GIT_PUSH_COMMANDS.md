# Git Commands to Push Rejection Fix

## Quick Commands

Copy and paste these commands in your terminal:

```bash
# 1. Check what files changed
git status

# 2. Add all changed files
git add .

# 3. Commit with descriptive message
git commit -m "Fix App Store rejection (Guideline 3.1.2) - Add Terms of Use and complete subscription info"

# 4. Push to GitHub
git push origin main
```

## What Gets Pushed

### New Files:
- `docs/terms.html` - Terms of Use (EULA) document
- `APP_STORE_REJECTION_FIX.md` - Detailed fix guide
- `RESUBMISSION_CHECKLIST.md` - Quick action checklist
- `APPLE_REQUIREMENTS_VISUAL.md` - Visual guide
- `REJECTION_FIX_SUMMARY.md` - Summary document
- `GIT_PUSH_COMMANDS.md` - This file

### Modified Files:
- `RingToneMaker/PurchaseView.swift` - Added subscription information
- `docs/README.md` - Updated documentation

## After Pushing

1. **Wait 1-2 minutes** for GitHub Pages to deploy

2. **Verify Terms of Use is live:**
   ```
   https://nbedzeti.github.io/ToneForge/terms.html
   ```

3. **Verify Privacy Policy is still live:**
   ```
   https://nbedzeti.github.io/ToneForge/privacy.html
   ```

4. **Test in the app:**
   - Build and run on device
   - Go to Premium screen
   - Tap "Terms of Use" link
   - Tap "Privacy Policy" link
   - Both should open in Safari

## Troubleshooting

### If push fails with "rejected" error:

```bash
# Pull latest changes first
git pull origin main

# Then push again
git push origin main
```

### If you need to see what changed:

```bash
# See all changes
git diff

# See specific file changes
git diff RingToneMaker/PurchaseView.swift
```

### If you made a mistake in commit message:

```bash
# Amend the last commit message
git commit --amend -m "New commit message here"

# Force push (only if you haven't pushed yet)
git push origin main --force
```

## Verify GitHub Pages

After pushing, check GitHub Pages status:

1. Go to: https://github.com/nbedzeti/ToneForge
2. Click **Settings** → **Pages**
3. Should show: "Your site is live at https://nbedzeti.github.io/ToneForge/"
4. If not, wait 1-2 minutes and refresh

## Next Steps

After successful push:

1. ✅ Verify both URLs work
2. ✅ Update App Store Connect metadata
3. ✅ Build and upload new version
4. ✅ Resubmit for review

See `RESUBMISSION_CHECKLIST.md` for complete steps.

---

**Ready to push?** Run the commands at the top of this file!
