# Apple Pay and Google Pay Setup Guide

This document outlines the setup requirements for Apple Pay and Google Pay integration with Stripe in the Clubship Flutter app.

## Overview

The app now supports:
- **Credit/Debit Cards** (existing)
- **Apple Pay** (iOS only)
- **Google Pay** (Android only)
- **Pay at Door** (existing)

All payments are processed through Stripe's PaymentSheet API, which automatically shows the available payment methods based on device capabilities and user setup.

## Apple Pay Setup (iOS)

### 1. Apple Developer Account Configuration

#### Merchant ID Setup
1. Log into [Apple Developer Portal](https://developer.apple.com/)
2. Go to **Certificates, Identifiers & Profiles** > **Identifiers**
3. Create a new Merchant ID:
   - Type: Merchant IDs
   - Description: "Clubship Payments"
   - Identifier: `merchant.com.clubship` (must match entitlements)

#### App ID Configuration
1. Go to **Identifiers** > **App IDs**
2. Select your app ID (`com.clubship` or similar)
3. Enable **Apple Pay Payment Processing**
4. Configure with your Merchant ID

#### Payment Processing Certificate
1. In Merchant ID settings, create a **Payment Processing Certificate**
2. Download the certificate and upload it to your Stripe Dashboard
3. Go to [Stripe Dashboard](https://dashboard.stripe.com/) > **Settings** > **Apple Pay**
4. Upload the certificate and domain verification file

### 2. iOS Project Configuration

#### Entitlements File
✅ **Already Created**: `ios/Runner/Runner.entitlements`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.in-app-payments</key>
    <array>
        <string>merchant.com.clubship</string>
    </array>
</dict>
</plist>
```

#### Xcode Project Settings
**Manual Steps Required in Xcode:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the **Runner** target
3. Go to **Signing & Capabilities** tab
4. Add **Apple Pay** capability
5. Select your Merchant ID: `merchant.com.clubship`
6. Link the entitlements file:
   - **Code Signing Entitlements**: `Runner/Runner.entitlements`

### 3. Stripe Dashboard Configuration
1. Go to [Stripe Dashboard](https://dashboard.stripe.com/)
2. Navigate to **Settings** > **Payment methods** > **Apple Pay**
3. Add your domain (for web) - not required for mobile
4. Upload the Payment Processing Certificate from Apple

## Google Pay Setup (Android)

### 1. Google Cloud Console Configuration

#### Enable Google Pay API
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable **Google Pay API** for your project
3. Create API credentials if needed

### 2. Android Project Configuration

#### Add Google Pay Metadata (if required)
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<application>
    <!-- Existing configuration -->

    <!-- Google Pay metadata (if required by your setup) -->
    <meta-data
        android:name="com.google.android.gms.wallet.api.enabled"
        android:value="true" />
</application>
```

#### ProGuard Configuration (if using ProGuard)
Add to `android/app/proguard-rules.pro`:
```
# Google Pay
-keep class com.google.android.gms.wallet.** { *; }
```

### 3. Stripe Dashboard Configuration
1. Go to [Stripe Dashboard](https://dashboard.stripe.com/)
2. Navigate to **Settings** > **Payment methods** > **Google Pay**
3. Enable Google Pay for your account
4. Configure merchant settings

## Environment Configuration

### Environment Variables
Update your `.env` files with Stripe configuration:

```env
# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key
STRIPE_SECRET_KEY=sk_test_your_secret_key

# Apple Pay Merchant ID
APPLE_MERCHANT_ID=merchant.com.clubship

# For production, set testEnv to false
STRIPE_TEST_ENV=true
```

### Backend Configuration (Supabase Edge Functions)
Your existing Stripe integration should work with Apple Pay and Google Pay automatically. The PaymentSheet handles wallet detection and display.

#### Update Environment Settings
In your Supabase project settings, ensure the following are set:
- `STRIPE_SECRET_KEY`
- `APPLE_MERCHANT_ID=merchant.com.clubship`

## Testing

### Apple Pay Testing
**Simulator Testing:**
- Apple Pay works in iOS Simulator
- Add test cards in **Settings** > **Wallet & Apple Pay** > **Add Card**
- Use Stripe test card numbers

**Device Testing:**
- Requires physical iOS device
- Add real or test cards to Apple Wallet
- Test with Stripe test mode

**Test Cards for Apple Pay:**
- Visa: 4242 4242 4242 4242
- Mastercard: 5555 5555 5555 4444
- American Express: 3782 822463 10005

### Google Pay Testing
**Emulator/Device Testing:**
- Requires Google Play Services
- Add cards to Google Pay app
- Test with Stripe test mode

**Test Environment:**
- Set `testEnv: true` in `PaymentSheetGooglePay`
- Use Google's test card numbers
- Test on device with Google Play Services

## Implementation Details

### Code Changes Made

#### 1. Stripe Payment Handler (`lib/payment/stripe_payment_handler.dart`)
✅ **Updated**: Added Apple Pay and Google Pay configuration to all PaymentSheet initializations:
```dart
applePay: const PaymentSheetApplePay(
  merchantCountryCode: 'JP',
),
googlePay: const PaymentSheetGooglePay(
  merchantCountryCode: 'JP',
  currencyCode: 'JPY',
  testEnv: true, // Set to false in production
),
```

#### 2. Payment UI (`lib/event_ticket/payment_page.dart`)
✅ **Updated**:
- Added `PaymentMethod.applePay` and `PaymentMethod.googlePay` enum values
- Platform-specific UI display (Apple Pay on iOS, Google Pay on Android)
- Payment method selection and storage
- Payment processing logic

#### 3. Platform Availability Checks
✅ **Added**: Helper methods to check device support:
```dart
static Future<bool> isApplePaySupported() async {
  return await Stripe.instance.isApplePaySupported();
}

static Future<bool> isGooglePaySupported() async {
  return await Stripe.instance.isGooglePaySupported();
}
```

## Production Checklist

### Before Production Release:

#### Apple Pay:
- [ ] Create production Merchant ID in Apple Developer Portal
- [ ] Generate production Payment Processing Certificate
- [ ] Upload certificate to Stripe Dashboard
- [ ] Update `Runner.entitlements` with production Merchant ID
- [ ] Test on physical device with real cards

#### Google Pay:
- [ ] Enable production Google Pay API
- [ ] Configure production Stripe settings
- [ ] Set `testEnv: false` in `PaymentSheetGooglePay`
- [ ] Test on device with real Google Pay setup

#### Stripe Configuration:
- [ ] Switch to production Stripe keys
- [ ] Update `STRIPE_PUBLISHABLE_KEY` and `STRIPE_SECRET_KEY`
- [ ] Set `testEnv: false` for Google Pay
- [ ] Test payment flows with real payment methods

#### Backend:
- [ ] Update Supabase environment variables
- [ ] Test Supabase Edge Functions with production keys
- [ ] Verify webhook endpoints are configured

## Troubleshooting

### Common Issues:

#### Apple Pay Not Showing:
1. Check Merchant ID in entitlements matches Apple Developer Portal
2. Verify Apple Pay capability is enabled in Xcode
3. Ensure device has cards added to Apple Wallet
4. Check Stripe Dashboard for Apple Pay configuration

#### Google Pay Not Showing:
1. Verify Google Play Services is available
2. Check if user has cards added to Google Pay
3. Ensure `testEnv` setting matches your environment
4. Verify Google Pay is enabled in Stripe Dashboard

#### PaymentSheet Issues:
1. Check Stripe publishable key is correct
2. Verify PaymentIntent/SetupIntent creation on backend
3. Check network connectivity
4. Review device logs for Stripe SDK errors

## Support

For technical support:
- **Stripe Documentation**: https://stripe.com/docs/apple-pay
- **Stripe Documentation**: https://stripe.com/docs/google-pay
- **Flutter Stripe Plugin**: https://pub.dev/packages/flutter_stripe

## Security Notes

- Never hardcode Stripe secret keys in the app
- Use environment variables for configuration
- Validate payments on the backend
- Implement proper error handling
- Test thoroughly in both test and production environments