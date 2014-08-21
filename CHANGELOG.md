# Braintree iOS SDK Release Notes

## 3.1.2 (2014-08-21)

* Fixes
  * Minor internationalization issue
  * PayPal payment method display issue in Drop In UI

## 3.1.1 (2014-08-17)

* Enhancements
  * Accept four digit years in expiry field
  * Internationalize
  * Support iOS 8 SDK
* Integration changes
  * Merge `api` and `API` directory content
  * Deprecate `savePaypalPaymentMethodWithAuthCode:correlationId:success:failure` in favor of
    `savePaypalPaymentMethodWithAuthCode:applicationCorrelationID:success:failure`

## 3.1.0 (2014-07-22)

* Integration Change:
  * `Braintree/data` is no longer a default subspec. If you are currently using `BTData`, please add `pod "Braintree/data"` to your `Podfile`.

## 3.0.1 (2014-07-21)

* Enhancements
  * Add support for [PayPal Application Correlation ID](https://github.com/paypal/PayPal-iOS-SDK/blob/master/docs/future_payments_mobile.md#obtain-an-application-correlation-id)

## 3.0.0 (2014-07-09)

Initial release of 3.0.0

https://www.braintreepayments.com/v.zero

* Enhancements since rc8
  * Added details to DEVELOPMENT.md
  * Updated demo app to not use removed card properties
  * Updated PayPal acceptance tests

## 3.0.0-rc8

* Breaking Change
  * Renamed a method in `BTDropInViewControllerDelegate` to send
    cancelation messages to user. All errors within Drop In are now
    handled internally with user interaction.
  * Removed completion block interface on `BTDropInViewController`
  * Removed crufty `BTMerchantIntegrationErrorUnknown` which was unused
* Enhancements
  * Added basic analytics instrumentation
  * Improved Drop-in's error handling
  * BTPayPalPaymentMethod now implements `NSMutableCopying`

## 3.0.0-rc7

* Breaking Change
  * Based on feedback from our beta developers, we have removed the block-based interfaces from
    Braintree and BTPayPalButton.
    * If you were previously relying on the completion block for receiving a payment method nonce,
      you should replace that code with a delegate method implementation which reads the nonce from
      the BTPaymentMethod object it receives.

* Bug fixes:
  * Fix Braintree/PayPal subspec build

## 3.0.0-rc6

* Bug fixes:
  * Fix issue with incorrect nesting of credit-card params in API requests, which caused
    incorrect behavior while validating credit cards in custom and Drop-In.
  * Bugfixes and improvements to demo app
  * Fix crasher in demo app when PayPal is not enabled
  * Demo App now points to a publicly accessible merchant server

* Enhancements:
  * Drop-In now supports server-side validation, including CVV/AVS verification failure
  * Drop-In's customer-facing error handling is now consistent and allows for retry
  * Increased robustness of API layer

* Features:
  * :new: `BTData` - Advanced fraud solution based on Kount SDK

## 3.0.0-rc5

* :rotating_light: Remove dependency on AFNetworking!
* :rotating_light: Rename `BTPayPalControl` -> `BTPayPalButton`.
* Security - Enforce SSL Pinning against a set of vendored SSL certificates
* Drop-In
  * Improve visual customizability and respect tint color
  * UI and Layout improvements
  * Detailing and polish
* UI
  * Float labels on credit card form fields
  * Vibration upon critical validation errors :vibration_mode:

Thanks for the feedback so far. Keep it coming!

## 3.0.0-rc4

* UX/UI improvements in card form and Drop In
  * PayPal button and payment method view are full width
  * Vibration on invalid entry
  * Improved spinners and loading states
  * Detailing and polish
* Add support for v2 client tokens, which are base64 encoded
  * Reverse compatibility with v1 client tokens is still supported
* Clean up documentation

## 3.0.0-rc3

* Fix crashes when adding PayPal an additional payment method, when displaying PayPal as a payment method, and in offline mode
* Add `dropInViewControllerWillComplete` delegate method.
* Add transitions, activity indicators, and streamline some parts of UI.
* Simplify implementation of `BTPayPalButton`.
* :rotating_light: Remove `BTDropinViewController shouldDisplayPaymentMethodsOnFile` property.

## 3.0.0-rc2

* :rotating_light: Breaking API Changes :rotating_light:
    * Reduce BTPayPalButton API
    * Rename a number of classes, methods, and files, e.g. `BTCard` -> `BTCardPaymentMethod`.

## 3.0.0-rc1

* First release candidate of the 3.0.0 version of the iOS SDK.
* Known issues:
    * Pre-release public APIs
    * SSL pinning not yet added
    * Incomplete / unpolished UI
        * Minor UX card validation issues in the card form
        * Drop-In UX flow issues and unaddressed edge cases
