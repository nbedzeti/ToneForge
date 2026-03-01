# GitHub Pages Setup - Detailed Visual Guide

## Step-by-Step Instructions

### Step 1: Go to Your Repository
1. Open your browser
2. Go to: `https://github.com/nbedzeti/ToneForge`
3. Make sure you're logged in

### Step 2: Click on "Settings"
- Look at the top of the page
- You'll see tabs: `< > Code`, `Issues`, `Pull requests`, etc.
- Click on **"Settings"** (it's usually the last tab with a gear icon ⚙️)

### Step 3: Find "Pages" in the Left Sidebar
- On the left side, you'll see a menu
- Scroll down until you see **"Pages"** (under "Code and automation" section)
- Click on **"Pages"**

### Step 4: What You Should See

You should now see a page titled **"GitHub Pages"**

There are a few possible scenarios:

#### Scenario A: GitHub Pages is Not Enabled Yet
You'll see:
```
GitHub Pages
Source
GitHub Pages is currently disabled. Select a source below to enable GitHub Pages for this repository.
```

**What to do:**
1. Under "Source", click the dropdown that says "None"
2. Select **"Deploy from a branch"**
3. Two new dropdowns will appear:
   - **Branch**: Select "main"
   - **Folder**: Select "/docs"
4. Click **"Save"**

#### Scenario B: GitHub Pages is Already Enabled (but wrong settings)
You'll see:
```
Your site is published at https://nbedzeti.github.io/ToneForge/
```

**What to do:**
1. Check the "Branch" dropdown - make sure it says "main"
2. Check the "Folder" dropdown - make sure it says "/docs" (NOT "/ (root)")
3. If either is wrong, change it and click "Save"

#### Scenario C: Different Interface (New GitHub UI)
If you see a different interface:
1. Look for "Build and deployment" section
2. Under "Source", select "Deploy from a branch"
3. Under "Branch", select "main" and "/docs"
4. Click "Save"

### Step 5: Wait for Deployment
After clicking Save:
1. Wait 1-2 minutes
2. Refresh the page
3. You should see: "Your site is live at https://nbedzeti.github.io/ToneForge/"

### Step 6: Test Your Privacy Policy
Open this URL in your browser:
```
https://nbedzeti.github.io/ToneForge/privacy.html
```

You should see your privacy policy page (green header, "Privacy Policy for ToneForge Studio")

---

## Can't Find "Settings"?

### Possible Reasons:

1. **Not logged in**: Make sure you're logged into GitHub
2. **Not the owner**: Make sure you're logged in as `nbedzeti`
3. **Wrong repository**: Make sure you're at `https://github.com/nbedzeti/ToneForge`

### How to Check:
- Look at the top left of the page
- You should see: `nbedzeti / ToneForge`
- If you see "Settings" tab, you're in the right place

---

## Alternative: Use GitHub CLI (if you have it)

If you're comfortable with terminal:

```bash
# Enable GitHub Pages via API (requires GitHub CLI)
gh api repos/nbedzeti/ToneForge/pages -X POST -f source[branch]=main -f source[path]=/docs
```

---

## Still Can't Find It?

### Take a Screenshot
1. Go to: `https://github.com/nbedzeti/ToneForge`
2. Take a screenshot of what you see
3. Let me know what tabs you see at the top

### Or Try This Direct Link
Sometimes this works:
```
https://github.com/nbedzeti/ToneForge/settings/pages
```

If you get a 404 on that link, it means:
- You're not logged in, OR
- You don't have admin access to the repository

---

## What Each Setting Means

**Source**: How GitHub should build your site
- "Deploy from a branch" = Use files from a specific branch
- "GitHub Actions" = Use a custom build process (not needed for you)

**Branch**: Which branch to use
- "main" = Your main branch (where your code is)

**Folder**: Which folder contains your website files
- "/docs" = Use the docs folder (where your privacy.html is)
- "/ (root)" = Use the root folder (wrong for you)

---

## After It's Working

Once you see "Your site is live", you can:
1. ✅ Use the URL in your app
2. ✅ Use the URL in App Store Connect
3. ✅ Share it with users
4. ✅ Update it anytime by pushing to GitHub

---

**Current Status:**
- ✅ Repository exists: https://github.com/nbedzeti/ToneForge
- ✅ Privacy policy file exists: docs/privacy.html
- ✅ File is pushed to GitHub
- ⚠️ GitHub Pages needs to be enabled

**Next Step:** Find the Settings → Pages section and enable it!

