# Enable GitHub Pages - Step by Step

Your privacy policy file is ready and pushed to GitHub, but GitHub Pages needs to be enabled.

## Quick Fix (2 minutes)

### Step 1: Go to GitHub Settings
Click this link (or copy/paste into your browser):
```
https://github.com/nbedzeti/ToneForge/settings/pages
```

### Step 2: Configure Source
You'll see a page titled "GitHub Pages"

Under **"Build and deployment"** section:
1. **Source**: Select "Deploy from a branch"
2. **Branch**: Select "main"
3. **Folder**: Select "/docs"
4. Click **"Save"**

### Step 3: Wait 1-2 Minutes
GitHub will build your site. Refresh the page after a minute.

You'll see a message like:
```
✅ Your site is live at https://nbedzeti.github.io/ToneForge/
```

### Step 4: Test Your Privacy Policy
Visit this URL:
```
https://nbedzeti.github.io/ToneForge/privacy.html
```

You should see your privacy policy page!

---

## Troubleshooting

### If you still get 404:
1. Make sure you selected "/docs" folder (not "/ (root)")
2. Wait 2-3 minutes for GitHub to build
3. Try clearing your browser cache
4. Check that the branch is "main" (not "master")

### If the settings page looks different:
- Make sure you're logged into GitHub
- Make sure you have admin access to the repository
- The repository must be public (not private)

---

## What This Does

GitHub Pages will:
- Host your privacy policy at: `https://nbedzeti.github.io/ToneForge/privacy.html`
- Update automatically when you push changes
- Serve it for free, forever
- Make it accessible to everyone (required for App Store)

---

## After It's Live

1. ✅ Test the URL in your browser
2. ✅ Test the link in your app (Premium screen → Privacy Policy)
3. ✅ Use this URL in App Store Connect when submitting

---

## Current Status

✅ Privacy policy file created  
✅ File pushed to GitHub  
✅ Repository is public  
⚠️ **GitHub Pages needs to be enabled** ← Do this now!

---

**Need help?** If you're still getting 404 after following these steps, let me know and I'll help troubleshoot.

