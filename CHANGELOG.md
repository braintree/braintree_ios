# Braintree iOS SDK Release Notes

## 3.7.0 (2015-03-02)

* Refactor and improve SSL Pinning code
* Update PayPal Mobile SDK to new version (PayPal-iOS-SDK 2.8.4-bt1) that does not include card.io.
  * :rotating_light: Please note! :rotating_light:  

      This change breaks builds that depend on a workaround introduced in 3.4.0 that added card.io headers to fix [card.io duplicate symbol issues](https://github.com/braintree/braintree_ios/issues/53). 

      Since card.io is not officially part of the Braintree API, and since the headers were only included as part of a workaround for use by a small group of developers, this potentially-breaking change is not accompanied by a major version release. 

      If your build breaks due to this change, you can re-add card.io to your project's Podfile: 

          pod 'CardIO', '~> 4.0'`

      And adjust your card.io imports to:

          #import <CardIO/CardIO.h>

## 3.6.1 (2015-02-24)

* Fixes
  * Remove `GCC_TREAT_WARNINGS_AS_ERRORS` and `GCC_WARN_ABOUT_MISSING_NEWLINE` config from podspec.

## 3.6.0 (2015-02-20)

* Features
  * Beta support for native mobile 3D Secure
    * Requires additional import of a new subspec in your Podfile, `pod "Braintree/3d-secure"`
    * See `BTThreeDSecure` for full more details
  * Make Apple Pay a build option, enabled via `Braintree/Apple-Pay` subspec,
    which adds a `BT_ENABLE_APPLE_PAY=1` preprocesor macro.
    * Addresses an issue [reported by developers attempting to submit v.zero integrations without Apple Pay to the app store](https://github.com/braintree/braintree_ios/issues/60).
* Enhancements
  * Minor updates to UK localization
  * Expose a new `status` property on `BTPaymentProvider`, which exposes the current status of payment method creation (Thanks, @Reflejo!)
* Bug fixes
  * Fix swift build by making BTClient_Metadata.h private (https://github.com/braintree/braintree_ios/pull/84 and https://github.com/braintree/braintree_ios/pull/85)
  * Drop In - Auto-correction and auto-capitalization improvements for postal code field in BTUICardFormView
  * Remove private header `BTClient_Metadata.h` from public headers
* Internal changes
  * Simplifications to API response parsing logic

## 3.5.0 (2014-12-03)

* Add localizations to UI and Drop-In subspecs:
  * Danish (`da`)
  * German (`de`)
  * Additional English locales (`en_AU`, `en_CA`, `en_UK`, `en_GB`)
  * Spanish (`es` and `es_ES`)
  * French (`fr`, `fr_CA`, `fr_FR`)
  * Hebrew (`he`)
  * Italian (`it`)
  * Norwegian (`nb`)
  * Dutch (`nl`)
  * Polish (`pl`)
  * Portugese (`pt`)
  * Russian (`ru`)
  * Swedish (`sv`)
  * Turkish (`tr`)
  * Chinese (`zh-Hans`)
* Add newlines to all files to support `GCC_WARN_ABOUT_MISSING_NEWLINE`

## 3.4.2 (2014-11-19)

* Upgrade PayPal Mobile SDK to version 2.7.1
  * Fixes symbol conflicts with 1Password
  * Upgrades embedded card.io library to version 3.10.1 

## 3.4.1 (2014-11-05)

* Bug fixes
  * Remove duplicate symbols with 1Password SDK by upgrading internal PayPal SDK

## 3.4.0 (2014-10-27)

* Features
  * Stable Apple Pay support
    * New method in `Braintree` for tokenizing a `PKPayment` into a nonce
      * This is useful for merchants who integrate with Apple Pay using `PassKit`, rather than `BTPaymentProvider`
    * `BTPaymentProvider` support for Apple Pay
    * `BTApplePayPaymentMethod` with nonce and address information
  * `BTData` now includes PayPal application correlation ID in device data blob
  * Card.IO headers are now included in SDK
  * In-App PayPal login now supports 1Password

* API Changes and Deprecations
  * `-[Braintree tokenizeCard:completion:]` and `-[BTClient saveCardWithRequest:success:failure:]` now take an extensible "request" object as an argument to pass the various raw card details:
    * The previous signatures that accepted raw details in the arguments are now deprecated.
    * These will be removed in the next major version (4.0.0).

* Integration
  * This SDK now officially supports integration without CocoaPods
    * Please see `docs/Manual Integration.md`
    * Report bugs with these new integration instructions via [Github](https://github.com/braintree/braintree_ios/issues/new)
  * Project Organization
    * All library code is now located under `/Braintree`

* Bug fixes
  * Fix a number of minor static analysis recommendations
  * Avoid potential nil-block crasher
  * Fix iOS 8 `CoreLocation` deprecation in `BTData`
  * Fix double-dismisal bug in presentation of in-app PayPal login in Drop In

* New minimum requirements
  * Xcode 6+
  * Base SDK iOS 8+ (still compatible with iOS 7+ deployment target)

## 3.3.1 (2014-09-16)

* Enhancements
  * Update Kount library to 2.5.3, which removes use of IDFA
  * Use @import for system frameworks
* Fixes
  * Crasher in Drop-In that treats BTPaymentButton like a UIControl
  * Xcode 6 and iOS 8 deprecations
  * Bug in BTPaymentButton intrinsic size height calculation
  * Autolayout ambiguity in demo app

## 3.3.0 (2014-09-08)

* Features
  * App switch based payments for Venmo and PayPal ("One Touch")
    * New methods for registering a URL Scheme: `+[Braintree setReturnURLScheme:]` and `+[Braintree handleOpenURL:]`
      * PayPal continues to have a view controller option for in-app login
      * Both providers can be enabled via the Control Panel and client-side overrides
    * See [the docs](https://developers.braintreepayments.com/ios/guides/one-touch) for full upgrade instructions
  * Unified Payment Button (`BTPaymentButton`) for Venmo and/or PayPal payments
    * New UI and API designs for PayPal button
    * All new Venmo button
  * Unified mechanism for custom (headless) multi-provider payments (`BTPaymentProvider`)

* Enhancements
  * Minor fixes
  * Test improvements
  * Internal API tweaks
  * Update PayPal implementation to always support PayPal display email/phone across client and server
    * Your PayPal app (client ID) must now have the email scope capability. This is default for Braintree-provisioned PayPal apps. 
  * Improved Braintree-Demo app that demonstrates many integration styles
  * Upgraded underlying PayPal Mobile SDK

* Deprecations (For each item: deprecated functionality -> suggested replacement)
  * `BTPayPalButton` -> `BTPaymentButton`
  * `-[Braintree payPalButtonWithDelegate:]` -> `-[Braintree paymentButtonWithDelegate:]`
  * `BTPayPalButtonDelegate` -> `BTPaymentCreationDelegate`

* Known Issues
  * Crasher when app switching to Venmo and `CFBundleDisplayName` is unavailable.
    * Workaround: add a value for `CFBundleDisplayName` in your `Info.plist`

## 3.2.0 (2014-09-02)

* Update BTData (fraud) API to match Braintree-Data.js
  * New method `collectDeviceData` provides a device data format that is identical to the JSON generated by Braintree-Data.js
* Minor improvements to developer demo app (Braintree Demo)

## 3.1.3 (2014-08-22)

* Fix another PayPal payment method display issue in Drop In UI

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

