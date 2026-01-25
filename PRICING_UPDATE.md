# ToneForge Studio - Updated Pricing

**Date**: January 24, 2025  
**Status**: Ready to Configure in App Store Connect

---

## New Pricing Structure

| Plan | Price | Savings |
|------|-------|---------|
| **Monthly** | $2.99/month | - |
| **Yearly** | $17.99/year | 50% off |
| **Lifetime** | $24.99 one-time | Best value |

---

## What Changed

### Old Pricing:
- Monthly: $2.99/month
- Yearly: $19.99/year (44% savings)
- Lifetime: $24.99

### New Pricing:
- Monthly: $2.99/month (unchanged)
- Yearly: **$17.99/year** (50% savings) ← Changed from $19.99
- Lifetime: $24.99 (unchanged)

---

## Why This Change?

1. **Better Value Proposition**: 50% savings is more compelling than 44%
2. **Competitive Pricing**: More attractive compared to competitors
3. **Psychological Pricing**: $17.99 feels significantly better than $19.99
4. **Lifetime Becomes More Attractive**: Only $7 more than yearly makes lifetime more appealing

---

## App Store Connect Configuration

When setting up your IAP products, use these exact prices:

### 1. Monthly Subscription
- **Product ID**: `com.IceFireSoul.ToneForge.premium.monthly`
- **Reference Name**: Monthly Premium
- **Price**: **$2.99 USD**
- **Subscription Duration**: 1 month
- **Description**: "Monthly subscription for unlimited ringtone creations with premium features and no ads."

### 2. Yearly Subscription
- **Product ID**: `com.IceFireSoul.ToneForge.premium.yearly`
- **Reference Name**: Yearly Premium
- **Price**: **$17.99 USD**
- **Subscription Duration**: 1 year
- **Description**: "Yearly subscription for unlimited ringtone creations with premium features and no ads. Save 50% compared to monthly!"

### 3. Lifetime Purchase
- **Product ID**: `com.IceFireSoul.ToneForge.premium.lifetime`
- **Reference Name**: Lifetime Premium
- **Price**: **$24.99 USD**
- **Type**: Non-Consumable
- **Description**: "One-time purchase for unlimited ringtone creations forever. All premium features, no ads, lifetime access."

---

## Code Changes Required

**NONE!** ✅

The app code automatically:
- Fetches prices from App Store Connect
- Calculates savings percentage dynamically
- Displays the correct prices in the UI

The `yearlySavings()` function in `PurchaseManager.swift` will automatically show "50%" when you configure the yearly price at $17.99.

---

## Marketing Copy Updates

### App Store Description
Use this pricing in your App Store listing:

```
PRICING:
• Monthly: $2.99/month
• Yearly: $17.99/year (Save 50%!)
• Lifetime: $24.99 (Best Value)

Start with 3 free ringtones, then choose your plan.
```

### In-App Messaging
The app will automatically display:
- "Save 50%" badge on yearly plan
- "BEST VALUE" badge on yearly plan
- "MOST POPULAR" badge on lifetime plan

---

## Revenue Impact

### Monthly Revenue Comparison (per 1,000 users)

**Old Pricing ($19.99/year):**
- 5% yearly subs: 50 users × $19.99 = $999.50/year = $83.29/month

**New Pricing ($17.99/year):**
- 5% yearly subs: 50 users × $17.99 = $899.50/year = $74.96/month
- **Difference**: -$8.33/month per 1,000 users

### But Consider:

**Increased Conversion Rate:**
If the better value proposition increases yearly conversion from 5% to 6%:
- 6% yearly subs: 60 users × $17.99 = $1,079.40/year = $89.95/month
- **Net gain**: +$6.66/month per 1,000 users

**Lifetime Upsell:**
Lower yearly price makes $24.99 lifetime more attractive:
- Only $7 more than yearly
- "Just $7 more for lifetime access" is compelling
- Could increase lifetime conversions by 20-30%

---

## Testing Checklist

After configuring in App Store Connect:

- [ ] Verify prices display correctly in app
- [ ] Confirm "Save 50%" shows on yearly plan
- [ ] Test purchase flow for all three tiers
- [ ] Verify receipts and entitlements
- [ ] Test restore purchases
- [ ] Check subscription management in Settings

---

## Next Steps

1. **Log into App Store Connect**
   - Go to your app → Features → In-App Purchases

2. **Update Yearly Subscription**
   - Edit the yearly product
   - Change price from $19.99 to $17.99
   - Update description to mention "Save 50%"

3. **Test in Sandbox**
   - Use sandbox tester account
   - Verify new price displays
   - Test purchase flow

4. **Submit for Review**
   - No app update needed (prices are server-side)
   - Changes take effect immediately after approval

---

## Documentation Updated

The following files have been updated with new pricing:

✅ `READY_FOR_SUBMISSION.md`  
✅ `PRODUCTION_CHECKLIST.md`  
✅ `PRICING_UPDATE.md` (this file)

Other documentation files may still reference old pricing - they will be updated as needed.

---

**Questions?** The pricing is configured in App Store Connect, not in the app code. The app automatically fetches and displays whatever prices you set.

