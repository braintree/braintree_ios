# Braintree iOS v5 (Beta) Migration Guide

See the [CHANGELOG](/CHANGELOG.md) for a complete list of changes. This migration guide outlines the basics for updating your client integration from v4 to v5.

_Documentation for v5 will be published to https://developers.braintreepayments.com once it is available for general release._

## Supported iOS versions

v5 supports a minimum deployment target of iOS 12+. It requires the use of Xcode 12+.

## Swift Package Manager

v5 introduces limited support for Swift Package Manager. See the [README](/README.md#swift-package-manager-v5-beta) for more details.

## 3D Secure

In v4, 3D Secure classes were housed in the `BraintreePaymentFlow` module. In v5, `BraintreeThreeDSecure` is a standalone module offering the same 3DS functionality. The `BraintreePaymentFlow` module still houses Local Payment functionality.

### CocoaPods
In your Podfile, add:
```
pod `Braintree/ThreeDSecure`
```

### Carthage
You will need to add the `BraintreeThreeDSecure` framework to your project. See the Carthage docs for [integration instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

### Swift Package Manager

The `BraintreeThreeDSecure` library does not currently support Swift Package Manager. It relies on a third party framework which we do not yet have in the `.xcframework` format.

## PayPal

Implementing the `BTViewControllerPresentingDelegate` is no longer required.

Registering a custom URL scheme in your Xcode project is also no longer required. 

Code previously used to set your return URL scheme can be deleted. **Note:** This only applies to the PayPal flow. Other payment methods (ex: Venmo, Local Payment Methods, 3DS) still require a custom URL scheme.
```
BTAppSwitch.setReturnURLScheme("com.your-company.your-app.payments")
```
