# Braintree iOS v7 Migration Guide

See the [CHANGELOG](/CHANGELOG.md) for a complete list of changes. This migration guide outlines the basics for updating your client integration from v6 to v7.

_Documentation for v7 will be published to https://developer.paypal.com/braintree/docs once it is available for general release._

## Table of Contents

1. [Supported Versions](#supported-versions)
1. [Card](#card)
1. [Venmo](#venmo)
1. [SEPA Direct Debit](#sepa-direct-debit)
1. [Local Payments](#local-payments)
1. [3D Secure](#3d-secure)]
1. [PayPal](#paypal)
1. [PayPal Native Checkout](#paypal-native-checkout)
1. [American Express](#american-express)
1. [Apple Pay](#apple-pay)
1. [Data Collector](#data-collector)

## Supported Versions

v7 supports a minimum deployment target of iOS 16+. It requires the use of Xcode 16.2+ and Swift 5.10+.

## Card
v7 updates `BTCard` to require setting all properties through the initializer, removing support for dot syntax. To construct a `BTCard`, pass the properties directly in the initializer.

Update initializer for `BTCardClient`:
```diff
-  var cardClient = BTCardClient(apiClient: apiClient)
+  var cardClient = BTCardClient(authorization: "<CLIENT_AUTHORIZATION>")
```

## Venmo
All properties within `BTVenmoRequest` can only be accessed on the initializer vs via the dot syntax.

Remove the `fallbackToWeb` boolean parameter from `BTVenmoRequest`. If a Buyer has the Venmo app installed and taps on "Pay with Venmo", they will automatically be switched to the Venmo app. If the Venmo app isn't installed, the Buyer will fallback to their default web browser to checkout.

```
let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse, vault: true)
```

The `BTVenmoClient` initializer now requires a `universalLink` for switching to and from the Venmo app or web fallback flow

```swift
let apiClient = BTAPIClient("<TOKENIZATION_KEY_OR_CLIENT_TOKEN>")
let venmoClient = BTVenmoClient(
    apiClient: apiClient, 
    universalLink: URL(string: "https://merchant-app.com/braintree-payments")! // merchant universal link
)
```

Update initializer for `BTVenmoClient`:
```diff
-  var venmoClient = BTVenmoClient(
        apiClient: apiClient, 
        universalLink: URL(string: "https://merchant-app.com/braintree-payments")! // merchant universal link
    )
+  var venmoClient = BTVenmoClient(
        authorization: "<CLIENT_AUTHORIZATION>"
        universalLink: URL(string: "https://merchant-app.com/braintree-payments")! // merchant universal link
    )
```


## SEPA Direct Debit
All properties within `BTSEPADirectDebitRequest` can only be accessed on the initializer vs via the dot syntax.

## Local Payments
v7 updates `BTLocalPaymentRequest` to require setting all properties through the initializer, removing support for dot syntax. To construct a `BTLocalPaymentRequest`, pass the properties directly in the initializer.

## 3D Secure
All properties within `BTThreeDSecureRequest` can only be accessed on the initializer vs via the dot syntax.

## PayPal

v7 updates `BTPayPalRequest`, `BTPayPalVaultRequest` and `BTPayPalCheckoutRequest` to make all properties accessible on the initializer only vs via the dot syntax.

Update initializer for `BTPayPalClient`:
```diff
-  var payPalClient = BTPayPalClient(apiClient: apiClient)
+  var payPalClient = BTPayPalClient(authorization: "<CLIENT_AUTHORIZATION>")
```

### App Switch
For the App Switch flow, you must update your `info.plist` with a simplified URL query scheme name, `paypal`.

```diff
<key>LSApplicationQueriesSchemes</key>
<array>
-  <string>paypal-app-switch-checkout</string>
+  <string>paypal</string>
</array>
```

## PayPal Native Checkout
The PayPal Native Checkout integration is no longer supported. Please remove it from your app and 
use the [PayPal (web)](https://developer.paypal.com/braintree/docs/guides/paypal/overview/ios/v6) integration.

## American Express
Update initializer for `BTAmericanExpressClient`:
```diff
-  var amexClient = BTAmericanExpressClient(apiClient: apiClient)
+  var amexClient = BTAmericanExpressClient(authorization: "<CLIENT_AUTHORIZATION>")
```

## Apple Pay
Update initializer for `BTApplePayClient`:
```diff
-  var applePayClient = BTApplePayClient(apiClient: apiClient)
+  var applePayClient = BTApplePayClient(authorization: "<CLIENT_AUTHORIZATION>")
```

## Data Collector
Update initializer for `BTDataCollector`:
```diff
- var dataCollector = BTDataCollector(apiClient: apiClient)
+ var dataCollector = BTDataCollector(authorization: "<CLIENT_AUTHORIZATION>")
```
