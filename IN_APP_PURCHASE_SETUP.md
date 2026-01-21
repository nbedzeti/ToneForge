# In-App Purchase Setup Guide for ToneForge

This guide walks you through setting up in-app purchases in App Store Connect.

## Prerequisites

1. **Apple Developer Account** ($99/year)
   - Sign up at: https://developer.apple.com/programs/
   
2. **Paid Apps Agreement**
   - Must be signed in App Store Connect
   - Required for any paid features or in-app purchases

## Step 1: Create App in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Click **"My Apps"**
3. Click **"+"** button → **"New App"**
4. Fill in:
   - **Platform**: iOS
   - **Name**: ToneForge
   - **Primary Language**: English
   - **Bundle ID**: Select your app's bundle ID (e.g., com.yourcompany.toneforge)
   - **SKU**: Unique identifier (e.g., TONEFORGE001)
   - **User Access**: Full Access

## Step 2: Set Up In-App Purchases

### Create Monthly Subscription

1. In your app's page, go to **"In-App Purchases"** tab
2. Click **"+"** button
3. Select **"Auto-Renewable Subscription"**
4. Click **"Create"**

**Fill in details:**
- **Reference Name**: ToneForge Premium Monthly
- **Product ID**: `com.yourcompany.toneforge.premium.monthly`
  - ⚠️ Must match `PurchaseManager.ProductID.monthly` in code
- **Subscription Group**: Create new → "ToneForge Premium"

**Subscription Duration:**
- Select: **1 month**

**Subscription Prices:**
- Click **"Add Pricing"**
- Select your base country (e.g., United States)
- Enter price: **$4.99** (or your preferred price)
- Click **"Next"** → Review prices for other countries → **"Create"**

**Localizations:**
- Click **"Add Localization"**
- Language: English (U.S.)
- **Subscription Display Name**: Premium Monthly
- **Description**: Unlimited ringtones with no ads, billed monthly

**Review Information:**
- Upload a screenshot showing the premium features
- Add review notes if needed

Click **"Save"**

### Create Yearly Subscription

1. Click **"+"** button again
2. Select **"Auto-Renewable Subscription"**
3. **Reference Name**: ToneForge Premium Yearly
4. **Product ID**: `com.yourcompany.toneforge.premium.yearly`
5. **Subscription Group**: Select existing "ToneForge Premium"
6. **Duration**: 1 year
7. **Price**: $29.99 (or your preferred price)
8. **Localization**:
   - Display Name: Premium Yearly
   - Description: Unlimited ringtones with no ads, billed yearly. Best value!
9. Click **"Save"**

### Create Lifetime Purchase

1. Click **"+"** button
2. Select **"Non-Consumable"** (one-time purchase)
3. **Reference Name**: ToneForge Premium Lifetime
4. **Product ID**: `com.yourcompany.toneforge.premium.lifetime`
5. **Price**: $49.99 (or your preferred price)
6. **Localization**:
   - Display Name: Premium Lifetime
   - Description: Unlimited ringtones forever with a one-time payment
7. Click **"Save"**

## Step 3: Submit Products for Review

1. For each product, click on it
2. Click **"Submit for Review"**
3. Products must be approved before they work in production
4. ⚠️ You can test them in sandbox mode before approval

## Step 4: Set Up Sandbox Testing

### Create Sandbox Tester Account

1. In App Store Connect, go to **"Users and Access"**
2. Click **"Sandbox Testers"** tab
3. Click **"+"** button
4. Fill in:
   - **First Name**: Test
   - **Last Name**: User
   - **Email**: Create a NEW email (not your Apple ID)
     - Example: toneforge.test@gmail.com
   - **Password**: Create a strong password
   - **Country/Region**: Your country
   - **App Store Territory**: Same as country
5. Click **"Invite"**

### Test on Real Device

1. **Sign out of App Store** on your test device:
   - Settings → [Your Name] → Media & Purchases → Sign Out
   
2. **Install your app** via Xcode on the device

3. **Open the app** and try to purchase

4. When prompted, **sign in with sandbox tester account**

5. Purchase will be free and instant in sandbox mode

## Step 5: Update Your Code (If Needed)

Your product IDs in code must match App Store Connect:

```swift
// In PurchaseManager.swift
enum ProductID {
    static let monthly = "com.yourcompany.toneforge.premium.monthly"
    static let yearly = "com.yourcompany.toneforge.premium.yearly"
    static let lifetime = "com.yourcompany.toneforge.premium.lifetime"
}
```

⚠️ **Replace `com.yourcompany.toneforge` with your actual bundle ID!**

## Step 6: Enable In-App Purchase Capability

1. Open Xcode
2. Select your project → Target → **"Signing & Capabilities"**
3. Click **"+ Capability"**
4. Add **"In-App Purchase"**
5. Build and run on real device

## Troubleshooting

### Products Not Loading

**Problem**: "Loading products..." spins forever

**Solutions**:
1. ✅ Check product IDs match exactly between code and App Store Connect
2. ✅ Ensure you're testing on a **real device** (not simulator)
3. ✅ Products must be in "Ready to Submit" or "Approved" status
4. ✅ Wait 2-4 hours after creating products (Apple's servers need time)
5. ✅ Check internet connection
6. ✅ Sign out of App Store on device, restart app

### Purchase Fails

**Problem**: Purchase doesn't complete

**Solutions**:
1. ✅ Use sandbox tester account (not your real Apple ID)
2. ✅ Check "Paid Apps Agreement" is signed in App Store Connect
3. ✅ Ensure app has "In-App Purchase" capability enabled
4. ✅ Check Xcode console for error messages

### "Cannot connect to iTunes Store"

**Problem**: Error when trying to purchase

**Solutions**:
1. ✅ Sign out of App Store on device
2. ✅ Restart device
3. ✅ Try again and sign in with sandbox tester when prompted

## Testing Checklist

- [ ] Created app in App Store Connect
- [ ] Created all 3 products (monthly, yearly, lifetime)
- [ ] Product IDs match code exactly
- [ ] Products submitted for review (or in "Ready to Submit" status)
- [ ] Created sandbox tester account
- [ ] Signed out of App Store on test device
- [ ] Installed app via Xcode on real device
- [ ] Products load successfully
- [ ] Can complete test purchase
- [ ] Premium features unlock after purchase
- [ ] Restore purchases works

## Production Release

Before releasing to App Store:

1. ✅ All products must be **"Approved"** status
2. ✅ Test thoroughly with sandbox account
3. ✅ Test restore purchases
4. ✅ Verify subscription auto-renewal works
5. ✅ Add privacy policy and terms of service URLs
6. ✅ Submit app for review

## Important Notes

- **Sandbox purchases are FREE** - no real money charged
- **Sandbox subscriptions renew faster** - yearly = 1 hour in sandbox
- **Products take 2-4 hours** to propagate after creation
- **Real purchases only work in production** after app is approved
- **Keep sandbox tester credentials safe** - you'll need them for testing

## Support Resources

- [Apple In-App Purchase Documentation](https://developer.apple.com/in-app-purchase/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [StoreKit Testing Guide](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_with_sandbox)

---

**Need Help?** Check the Xcode console for detailed error messages when products fail to load.
