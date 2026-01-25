# Enable GitHub Pages - Step by Step

Your privacy policy files are already in the repo. You just need to enable GitHub Pages.

## Step-by-Step Instructions

### 1. Go to Settings
Visit: https://github.com/nbedzeti/ToneForge/settings/pages

### 2. Configure Source
Under **"Build and deployment"** section:

**Source:** Deploy from a branch

**Branch:** 
- Select: `main`
- Folder: `/docs`

**Click the "Save" button**

### 3. Wait 1-2 Minutes
GitHub will build your site. You'll see a message like:
"Your site is live at https://nbedzeti.github.io/ToneForge/"

### 4. Test the Privacy Policy
Visit: https://nbedzeti.github.io/ToneForge/privacy.html

You should see a styled privacy policy page.

---

## Troubleshooting

### If you see "404 Not Found":
- Wait another minute (deployment takes time)
- Make sure you selected `/docs` folder (not `/` root)
- Refresh the page

### If Settings → Pages doesn't exist:
- Make sure the repo is public (not private)
- Or enable Pages for private repos in Settings

---

## After It's Live

1. Test in your app:
   - Open ToneForge Studio
   - Go to Premium screen
   - Tap "Privacy Policy" at bottom
   - Should open in Safari

2. Add URL to App Store Connect:
   - When submitting app
   - Add: https://nbedzeti.github.io/ToneForge/privacy.html

---

## That's It!

Once you click "Save" in GitHub settings, you're done.

The privacy policy will be live at:
**https://nbedzeti.github.io/ToneForge/privacy.html**
