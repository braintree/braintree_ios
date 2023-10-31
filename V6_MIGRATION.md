# Braintree iOS v6 Migration Guide

See the [CHANGELOG](/CHANGELOG.md) for a complete list of changes. This migration guide outlines the basics for updating your client integration from v5 to v6.

_Documentation for v6 will be published to https://developer.paypal.com/braintree/docs once it is available for general release._

## Table of Contents

1. [Supported Versions](#supported-versions)
1. [Carthage](#carthage)
1. [Venmo](#venmo)
1. [PayPal](#paypal)
1. [PayPal Native Checkout](#paypal-native-checkout)
1. [Data Collector](#data-collector)
1. [Union Pay](#union-pay)
1. [SEPA Direct Debit](#sepa-direct-debit)
1. [Local Payments](#local-payments)
1. [3D Secure](#3d-secure)

## Supported Versions

v6 supports a minimum deployment target of iOS 14+. It requires the use of Xcode 14+ and Swift version 5.7+. If your application contains Objective-C code, the `Enable Modules` build setting must be set to `YES`.

## Carthage

v6 requires Carthage v0.38.0+, which adds support for xcframework binary dependencies.

```
carthage update --use-xcframeworks
```

## Venmo
`BTVenmoDriver` has been renamed to `BTVenmoClient`

`BTVenmoRequest` must now be initialized with a `paymentMethodUsage`. 

The possible values for `BTVenmoPaymentMethodUsage` include:
* `.multiUse` - the Venmo payment will be authorized for future payments and can be vaulted.
* `.singleUse` - the Venmo payment will be authorized for a one-time payment and cannot be vaulted.

`BTVenmoClient.tokenizeVenmoAccount(with:completion:)` has been renamed to `BTVenmoClient.tokenize(_:completion:)`

`BTVenmoClient.isiOSAppAvailableForAppSwitch()` has been renamed to `BTVenmoClient.isVenmoAppInstalled()`

The following `BTAppContextSwitcher` methods have been renamed:
* `BTAppContextSwitcher.setReturnURLScheme()` has been renamed to setting the `BTAppContextSwitcher.sharedInstance.returnURLScheme` property
* `BTAppContextSwitcher.handleOpenURL(context:)` has been renamed to `BTAppContextSwitcher.sharedInstance.handleOpenURL(context:)`
* `BTAppContextSwitcher.handleOpenURL(_)` has been renamed to `BTAppContextSwitcher.sharedInstance.handleOpen(_)`

```
let apiClient = BTAPIClient("<TOKENIZATION_KEY_OR_CLIENT_TOKEN>")
let venmoClient = BTVenmoClient(apiClient: apiClient)
let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
venmoRequest.profileID = "my-profile-id"
venmoRequest.vault = true

venmoClient.tokenize(venmoRequest) { venmoAccountNonce, error in
    guard let venmoAccountNonce = venmoAccountNonce else {
        // handle error
    }
    // send nonce to server
}
```

## PayPal
`BTPayPalDriver` has been renamed to `BTPayPalClient`

Removed `BTPayPalDriver.requestOneTimePayment` and `BTPayPalDriver.requestBillingAgreement` in favor of `BTPayPalClient.tokenize`:
```
let apiClient = BTAPIClient("<TOKENIZATION_KEY_OR_CLIENT_TOKEN>")
let payPalClient = BTPayPalClient(apiClient: apiClient)
let request = BTPayPalCheckoutRequest(amount: "1")

payPalClient.tokenize(request) { payPalAccountNonce, error in
    guard let payPalAccountNonce = payPalAccountNonce else {
        // handle error
    }
    // send nonce to server
}
```

`BTPayPalClient.tokenizePayPalAccount(with:completion:)` has been replaced with two methods called: `BTPayPalClient.tokenize(_:completion:)` taking in either a `BTPayPalCheckoutRequest` or `BTPayPalVaultRequest`

```
// BTPayPalCheckoutRequest
let apiClient = BTAPIClient("<TOKENIZATION_KEY_OR_CLIENT_TOKEN>")
let payPalClient = BTPayPalClient(apiClient: apiClient)
let request = BTPayPalCheckoutRequest(amount: "1")
payPalClient.tokenize(request) { payPalAccountNonce, error in 
    // handle response
}

// BTPayPalVaultRequest
let apiClient = BTAPIClient("<TOKENIZATION_KEY_OR_CLIENT_TOKEN>")
let payPalClient = BTPayPalClient(apiClient: apiClient)
let request = BTPayPalVaultRequest()
payPalClient.tokenize(request) { payPalAccountNonce, error in 
    // handle response
}
```

## PayPal Native Checkout
`BTPayPalNativeCheckoutClient.tokenizePayPalAccount(with:completion:` has been replaced with two methods called: `tokenize(_:completion:)` taking in either a `BTPayPalNativeCheckoutRequest` or `BTPayPalNativeVaultRequest`

```
// BTPayPalNativeCheckoutRequest
let apiClient = BTAPIClient("<TOKENIZATION_KEY_OR_CLIENT_TOKEN>")
let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)
let request = BTPayPalNativeCheckoutRequest(amount: "1")
payPalNativeCheckoutClient.tokenize(request) { payPalNativeCheckoutAccountNonce, error in 
    // handle response
}

// BTPayPalNativeVaultRequest
let apiClient = BTAPIClient("<TOKENIZATION_KEY_OR_CLIENT_TOKEN>")
let payPalNativeCheckoutClient = BTPayPalNativeCheckoutClient(apiClient: apiClient)
let request = BTPayPalNativeVaultRequest()
payPalNativeCheckoutClient.tokenize(request) { payPalNativeCheckoutAccountNonce, error in 
    // handle response
}
```

## Data Collector
`PayPalDataCollector` module has been removed in favor of `BraintreeDataCollector`.

The new integration for collecting device data will look like the following:
```
let apiClient = BTAPIClient("<TOKENIZATION_KEY_OR_CLIENT_TOKEN>")
let dataCollector = BTDataCollector(apiClient: apiClient)

dataCollector.collectDeviceData { deviceData, error in
    // handle response
}
```

Note: Kount is no longer supported.

## Union Pay
The `BraintreeUnionPay` module, and all containing classes, was removed in v6. UnionPay cards can now be processed as regular cards, through the `BraintreeCard` module. You no longer need to manage card enrollment via SMS authorization. 

Now, you can tokenize just with the card details:

```
let apiClient = BTAPIClient("<TOKENIZATION_KEY_OR_CLIENT_TOKEN>")
let cardClient = BTCardClient(apiClient: apiClient)

let card = BTCard()
card.number = "4111111111111111"
card.expirationMonth = "12"
card.expirationYear = "2025"

cardClient.tokenize(card) { tokenizedCard, error in
    // handle response
}
```

## SEPA Direct Debit
We have removed the `context` parameter from the `BTSEPADirectDebit.tokenize()` method. Additionally, conformance to the `ASWebAuthenticationPresentationContextProviding` protocol is no longer needed.

`BTSEPADirectDebitClient.tokenize(request:context:completion:)` has been renamed to `BTSEPADirectDebitClient.tokenize(_:completion:)`

The updated `tokenize` method is as follows:
```
let apiClient = BTAPIClient("<TOKENIZATION_KEY_OR_CLIENT_TOKEN>")
let sepaDirectDebitClient = BTSEPADirectDebitClient(apiClient: apiClient)

sepaDirectDebitClient.tokenize(sepaDirectDebitRequest) { sepaDirectDebitNonce, error in
    // handle response
}
```

## Local Payments

We have renamed the module `BraintreePaymentFlow` to `BraintreeLocalPayment`
We have replaced `SFAuthenticationSession` with `ASWebAuthenticationSession` in the Local Payment Method flow. With this change, you no longer need to:
  * Register a URL Scheme or set a return URL via the `BTAppContextSwitcher.setReturnURLScheme()` method
  * Handle app context switching via the `BTAppContextSwitcher.handleOpenURL(context: UIOpenURLContext)` or `BTAppContextSwitcher.handleOpenURL(URL)`
  
Instantiate a `BTLocalPaymentClient` instead of a `BTPaymentFlowDriver`. The result returned in the `startPaymentFlow()` completion no longer needs to be cast to `BTLocalPaymentResult`.

```diff
- let paymentFlowDriver = BTPaymentFlowDriver(apiClient: self.apiClient)
- paymentFlowDriver.viewControllerPresentingDelegate = self
+ let localPaymentClient = BTLocalPaymentClient(apiClient: self.apiClient)

- paymentFlowDriver.startPaymentFlow(request) { result, error in
+ localPaymentClient.startPaymentFlow(request) { result, error in
-     guard let result = result as? BTLocalPaymentResult else { return }
         // Handle result
    }
 }
```

## 3D Secure

Instantiate a `BTThreeDSecureClient` instead of a `BTPaymentFlowDriver`. The result returned in the `startPaymentFlow()` completion no longer needs to be cast to `BTThreeDSecureResult`.

```diff
- let paymentFlowDriver = BTPaymentFlowDriver(apiClient: self.apiClient)
- paymentFlowDriver.viewControllerPresentingDelegate = self
+ let threeDSecureClient = BTThreeDSecureClient(apiClient: self.apiClient)

 cardClient.tokenize(cardDetails) { (tokenizedCard, error) in
     // Handle error

     request.threeDSecureRequestDelegate = self

-    self.paymentFlowDriver.startPaymentFlow(request) { (result, error) in
+    self.threeDSecureClient.startPaymentFlow(request) { (result, error) in
-        guard let result = result as? BTThreeDSecureResult else { return }

         // Handle result
    }
 }
```

The `BTViewControllerPresentingDelegate` has been removed, since 3DS 1 is no longer supported.
