# Braintree iOS SDK Release Notes

## master

* Update README.md and Braintree Demo app for iOS 9 and Xcode 7
* Update PayPal mSDK to 2.12.1 with bitcode
* Update Apple Pay support for iOS 9. `BTApplePayPaymentMethod` changes:
  * Deprecate `ABRecordRef` properties: `billingAddress` and `shippingAddress`
  * Add `PKContact` properties: `billingContact` and `shippingContact`

## 3.9.3 (2015-08-31)

* Xcode 7 support
* Improved Swift interface with nullability annotations and lightweight generics
* Update PayPal mSDK to 2.11.4-bt1
  * Remove checking via canOpenURL:
* Bug fix for `BTPaymentButton` edge case where it choose the wrong payment option when the option availability changes after UI setup.

## 3.9.2 (2015-07-08)

* :rotating_light: This version requires Xcode 6.3+ (otherwise you'll get duplicate symbol errors)
* :rotating_light: New: `Accelerate.framework` must be linked to your project (CocoaPods should do this automatically)
* Remove Coinbase CocoaPods library as an external dependency
  * Integrating Coinbase SDK is no longer a prerequisite for manual integrations
  * No change to Braintree Coinbase support; existing integrations remain unaffected
  * Braintree iOS SDK now vendors Coinbase SDK
* Add session ID to analytics tracking data
* Add `BTPayPalScopeAddress`
* Update PayPal mSDK to 2.11.1-bt1
  * Requires Xcode 6.3+
  * Fix an iPad display issue
  * Improve mSDK screen blurring when app is backgrounded. NOTE: This change requires that you add `Accelerate.framework` to your project
  * Bug fixes

## 3.9.0 (2015-06-12)

* Add support for additional scopes during PayPal authorization
  * Specifically supporting the `address` scope
  * BTPayPalPaymentMethod now has a `billingAddress` property that is set when an address is present. This property is of type `BTPostalAddress`.

## 3.8.2 (2015-06-04)

* Fix bug in Demo app
  * Menu button now works correctly
* Fix bug with PayPal app switching
  * The bug occurred when installing a new app after the Braintree SDK had been initialized. When attempting to authorize with PayPal in this scenario, the SDK would switch to the `wallet` and launch the `in-app` authorization. 

## 3.8.1 (2015-05-22)

* 3D Secure only: :rotating_light: Breaking API Changes for 3D Secure :rotating_light:
  * Fix a bug in native mobile 3D Secure that, in some cases, prevented access to the new nonce.
  * Your delegate will now receive `-paymentMethodCreator:didCreatePaymentMethod:` even when liability shift is not possible and/or liability was not shifted.
  * You must check `threeDSecureInfo` to determine whether liability shift is possible and liability was shifted. This property is now of type `BTThreeDSecureInfo`. Example:

```objectivec
- (void)paymentMethodCreator:(__unused id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {

    if ([paymentMethod isKindOfClass:[BTCardPaymentMethod class]]) {
        BTCardPaymentMethod *cardPaymentMethod = (BTCardPaymentMethod *)paymentMethod;
        if (cardPaymentMethod.threeDSecureInfo.liabilityShiftPossible &&
            cardPaymentMethod.threeDSecureInfo.liabilityShifted) {

            NSLog(@"liability shift possible and liability shifted");

        } else {

            NSLog(@"3D Secure authentication was attempted but liability shift is not possible");

        }
    }
}
```

* Important: Since `cardPaymentMethod.threeDSecureInfo.liabilityShiftPossible` and `cardPaymentMethod.threeDSecureInfo.liabilityShifted` are client-side values, they should be used for UI flow only. They should not be trusted for your server-side risk assessment. To require 3D Secure in cases where the buyer's card is enrolled for 3D Secure, set the `required` option to `true` in your server integration. [See our 3D Secure docs for more details.](https://developers.braintreepayments.com/guides/3d-secure)

## 3.8.0 (2015-05-21)

* Work around iOS 8.0-8.2 bug in UITextField
  * Fix subtle bug in Drop-in and BTUICardFormView float label behavior
* It is now possible to set number, expiry, cvv and postal code field values programmatically in BTUICardFormView
  * This is useful for making the card form compatible with card.io

## 3.8.0-rc3 (2015-05-11)

* Upgrade PayPal mSDK to 2.10.1
* Revamp Demo app
* Merge with 3.7.x changes

## 3.8.0-rc2 (2015-04-20)

* Coinbase improvements
  * Resolved: Drop-in will now automatically save Coinbase accounts in the vault
  * Coinbase accounts now appear correctly in Drop-in
  * Expose method to disable Coinbase in Drop-in
* Demo app: Look sharp on iPhone 6 hi-res displays
* Modified `BTUIPayPalWordmarkVectorArtView`, `BTUIVenmoWordmarkVectorArtView` slightly to
  help logo alignment in `BTPaymentButton` and your payment buttons

## 3.8.0-rc1 (2015-04-03)

* Coinbase integration - beta release
  * Coinbase is now available in closed beta. See [the Coinbase page on our website](https://www.braintreepayments.com/features/coinbase) to join the beta.
  * Coinbase UI is integrated with Drop-in and BTPaymentButton
  * Known issue: Drop-in vaulting behavior for Coinbase accounts
* [Internal only] Introduced a new asynchronous initializer for creating the `Braintree` object

## 3.7.2 (2015-04-23)

* Bugfixes
  * Fix recognition of Discover, JCB, Maestro and Diners Club in certain cases ([Thanks, @RyPoints!](https://github.com/braintree/braintree_ios/pull/117))
  * Fix a bug in Drop-in that prevented Venmo from appearing if PayPal was disabled
  * Revise text for certain Venmo One Touch errors in Drop-in
  * Fix [compile error](https://github.com/braintree/braintree_ios/issues/106) that could occur when 'No Common Blocks' is Yes
* Demo app
  * Look sharp on iPhone 6 hi-res displays
  * Improve direct Apple Pay integration: use recommended tokenization method and handle Cancel gracefully
* Update tooling for Xcode 6.3
* Improve Apple Pay error handling
* Localization helpers now fall-back to [NSBundle mainBundle] if the expected i18n bundle resource is not found

## 3.7.1 (2015-03-27)

* Update PayPal Mobile SDK to new version (PayPal-iOS-SDK 2.8.5-bt1)
  * Change "Send Payment" button to simply "Pay"
  * Minor fixes
* Remove `en_UK` from Braintree-Demo-Info.plist (while keeping `en_GB`)
* Fix for Venmo button in BTPaymentButton [#103](https://github.com/braintree/braintree_ios/issues/103)
* Fix issue with wrapping text in Drop-in ([thanks nirinchev](https://github.com/braintree/braintree_ios/pull/107))
* Update [manual integration doc](Docs/Manual%20Integration.md)

## 3.7.0 (2015-03-02)

* Refactor and improve SSL Pinning code
* Update PayPal Mobile SDK to new version (PayPal-iOS-SDK 2.8.4-bt1) that does not include card.io.
  * :rotating_light: Please note! :rotating_light:  

      This change breaks builds that depend on a workaround introduced in 3.4.0 that added card.io headers to fix [card.io duplicate symbol issues](https://github.com/braintree/braintree_ios/issues/53). 

      Since card.io is not officially part of the Braintree API, and since the headers were only included as part of a workaround for use by a small group of developers, this potentially-breaking change is not accompanied by a major version release. 

      If your build breaks due to this change, you can re-add card.io to your project's Podfile: 

          pod 'CardIO', '~> 4.0'

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
  * Drop-in - Auto-correction and auto-capitalization improvements for postal code field in BTUICardFormView
  * Remove private header `BTClient_Metadata.h` from public headers
* Internal changes
  * Simplifications to API response parsing logic

## 3.5.0 (2014-12-03)

* Add localizations to UI and Drop-in subspecs:
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
  * Fix double-dismisal bug in presentation of in-app PayPal login in Drop-in

* New minimum requirements
  * Xcode 6+
  * Base SDK iOS 8+ (still compatible with iOS 7+ deployment target)

## 3.3.1 (2014-09-16)

* Enhancements
  * Update Kount library to 2.5.3, which removes use of IDFA
  * Use @import for system frameworks
* Fixes
  * Crasher in Drop-in that treats BTPaymentButton like a UIControl
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

* Fix another PayPal payment method display issue in Drop-in UI

## 3.1.2 (2014-08-21)

* Fixes
  * Minor internationalization issue
  * PayPal payment method display issue in Drop-in UI

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
    cancelation messages to user. All errors within Drop-in are now
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
    incorrect behavior while validating credit cards in custom and Drop-in.
  * Bugfixes and improvements to demo app
  * Fix crasher in demo app when PayPal is not enabled
  * Demo App now points to a publicly accessible merchant server

* Enhancements:
  * Drop-in now supports server-side validation, including CVV/AVS verification failure
  * Drop-in's customer-facing error handling is now consistent and allows for retry
  * Increased robustness of API layer

* Features:
  * :new: `BTData` - Advanced fraud solution based on Kount SDK

## 3.0.0-rc5

* :rotating_light: Remove dependency on AFNetworking!
* :rotating_light: Rename `BTPayPalControl` -> `BTPayPalButton`.
* Security - Enforce SSL Pinning against a set of vendored SSL certificates
* Drop-in
  * Improve visual customizability and respect tint color
  * UI and Layout improvements
  * Detailing and polish
* UI
  * Float labels on credit card form fields
  * Vibration upon critical validation errors :vibration_mode:

Thanks for the feedback so far. Keep it coming!

## 3.0.0-rc4

* UX/UI improvements in card form and Drop-in
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
* :rotating_light: Remove `BTDropInViewController shouldDisplayPaymentMethodsOnFile` property.

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
        * Drop-in UX flow issues and unaddressed edge cases

