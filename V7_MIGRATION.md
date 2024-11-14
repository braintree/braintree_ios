# Braintree iOS v7 Migration Guide

See the [CHANGELOG](/CHANGELOG.md) for a complete list of changes. This migration guide outlines the basics for updating your client integration from v6 to v7.

_Documentation for v7 will be published to https://developer.paypal.com/braintree/docs once it is available for general release._

## Table of Contents

1. [Supported Versions](#supported-versions)
1. [Card](#card)
1. [Venmo](#venmo)
1. [SEPA Direct Debit](#sepa-direct-debit)
1. [Local Payments](#local-payments)
1. [PayPal Native Checkout](#paypal-native-checkout)

## Supported Versions

v7 bumps to a minimum deployment target of iOS 16+.

## Card
v7 updates `BTCard` to require setting all properties through the initializer, removing support for dot syntax. To construct a `BTCard`, pass the properties directly in the initializer.

## Venmo
All properties within `BTVenmoRequest` can only be accessed on the initializer vs via the dot syntax.

Remove the `fallbackToWeb` boolean parameter from `BTVenmoRequest`. If a Buyer has the Venmo app installed and taps on "Pay with Venmo", they will automatically be switched to the Venmo app. If the Venmo app isn't installed, the Buyer will fallback to their default web brower to checkout.

```
let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse, vault: true)
```

## SEPA Direct Debit
All properties within `BTSEPADirectDebitRequest` can only be accessed on the initializer vs via the dot syntax.

## Local Payments
v7 updates `BTLocalPaymentRequest` to require setting all properties through the initializer, removing support for dot syntax. To construct a `BTLocalPaymentRequest`, pass the properties directly in the initializer.

## PayPal Native Checkout
The PayPal Native Checkout integration is no longer supported. Please remove it from your app and 
use the [PayPal (web)](https://developer.paypal.com/braintree/docs/guides/paypal/overview/ios/v6) integration.

