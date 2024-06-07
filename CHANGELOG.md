# Braintree iOS SDK Release Notes

## unreleased
* BraintreePayPal
  * Add `BTPayPalVaultRequest(userAuthenticationEmail:enablePayPalAppSwitch:offerCredit:)`
    * This init should be used for the PayPal App Switch flow
  * Add `BTPayPalClient(apiClient:universalLink:)`
    * This init should be used for the PayPal App Switch flow
  * Send `link_type` and `paypal_installed` in `event_params` when available to PayPal's analytics service (FPTI)
  * **Note:** This feature is currently in beta and may change or be removed in future releases.
  
## 6.20.0 (2024-06-06)
* Re-use existing URLSession instance for `v1/configuration` and subsequent BT GW API calls
* BraintreeShopperInsights (BETA)
  * Add PrivacyInfo.xcprivacy file
  * Add `BTShopperInsightsClient.getRecommendedPaymentMethods()` for returning recommendations based on the buyer
* BraintreePayPal
  * Add `BTPayPalCheckoutRequest.userAuthenticationEmail` optional property

## 6.19.0 (2024-05-30)
* BraintreeCore
  * Batch analytics events to FPTI
  * Send `start_time`, `end_time`, and `endpoint` to FPTI for tracking API request latency
  * Send `isVaultRequest` to FPTI for tracking in Venmo and PayPal flows

## 6.18.2 (2024-05-15)
* BraintreePayPal
  * Send `start_time`, `end_time`, and `endpoint` to FPTI for tracking API request latency

## 5.26.0 (2024-05-07)
* Updated expiring pinned vendor SSL certificates

## 6.18.1 (2024-05-06)
* Remove throttle delay in accessing configuration, added in v5.9.0
  * Move from URLCache to NSCache for configuration caching

## 6.18.0 (2024-04-25)
* BraintreePayPalNativeCheckout
  * Bump PayPalCheckout to version 1.3.0 with code signing & a privacy manifest file.

## 5.25.0 (2024-04-10)
* Require Xcode 15.0+ and Swift 5.9+ (per [Apple App Store requirements](https://developer.apple.com/news/upcoming-requirements/?id=04292024a)) 
* [Meets Apple's new Privacy Update requirements](https://developer.apple.com/news/?id=3d8a9yyh)
* BraintreePayPalDataCollector  
  * Update PPRiskMagnes to version 5.5.0 with privacy manifest changes and code-signing
  * This version of the PPRiskMagnes framework is dynamic
* BraintreeThreeDSecure
  * Bump CardinalMobile SDK to version 2.2.5-9 with code signing and a privacy manifest file.
  
## 6.17.0 (2024-04-10)
* Require Xcode 15.0+ and Swift 5.9+ (per [App Store requirements](https://developer.apple.com/news/?id=khzvxn8a))
* Updated expiring pinned vendor SSL certificates
* BraintreeThreeDSecure
  * Bump CardinalMobile SDK to version 2.2.5-9 with code signing and a privacy manifest file.
* BraintreeDataCollector
  * Bump to PPRiskMagnes version 5.5.0 with fix for Xcode 15.3 Swift Pacakge Manager validation bug (fixes #1229))

## 6.16.0 (2024-03-19)
* Add `BTPayPalVaultRequest.userAuthenticationEmail` optional property

## 6.15.0 (2024-03-18)
* [Meets Apple's new Privacy Update requirements](https://developer.apple.com/news/?id=3d8a9yyh)

## 6.14.0 (2024-03-13)
* BraintreeDataCollector
  * Bump to PPRiskMagnes v5.5.0 with code signing & a privacy manifest file

## 6.13.0 (2024-03-12)
* BraintreeVenmo
  * Add `isFinalAmount` to `BTVenmoRequest`
  * Add `BTVenmoRequest.fallbackToWeb`
    * If set to `true` customers will fallback to a web based Venmo flow if the Venmo app is not installed
    * This method uses Universal Links instead of URL Schemes
* BraintreeCore
  * Send `paypal_context_id` in `event_params` to PayPal's analytics service (FPTI) when available
  * Send `link_type` in `event_params` to PayPal's analytics service (FPTI)
  * Fix bug where FPTI analytic events were being sent multiple times

## 6.12.0 (2024-01-18)
* BraintreePayPal
  * Add `imageURL`, `upcCode`, and `upcType` to `BTPayPalLineItem`

## 6.11.0 (2023-12-20)
* Update all SDK errors to be public and [Equatable](https://developer.apple.com/documentation/swift/equatable) (fixes #1152 and #1080)
* BraintreeThreeDSecure
  * Fix bug where `BTThreeDSecureClient.initializeChallenge()` callback wasn't properly invoked (fixes #1154)

## 6.10.0 (2023-11-17)
* BraintreePayPalNativeCheckout
  * Update PayPalCheckout from 1.1.0 to 1.2.0.
  * Add `userAuthenticationEmail` to `BTPayPalNativeCheckoutRequest`
* BraintreeDataCollector
  * Update previously incorrect version of PPRiskMagnes with 5.4.1 for Carthage users

## 5.24.1 (2023-11-17)
* BraintreePayPalDataCollector
  * Update previously incorrect version of PPRiskMagnes 5.4.1 with staging removed 
  * This version of the PPRiskMagnes framework is dynamic

## 6.9.0 (2023-11-16)
* BraintreeThreeDSecure
  * Add `cardAddChallengeRequested`, `uiType`, and `renderTypes` to `BTThreeDSecureRequest`
  * Deprecate `BTThreeDSecureRequest.cardAddChallenge`
  * Fix bug where defaults for `BTThreeDSecureRequest.accountType`, `BTThreeDSecureRequest.requestedExemptionType`, and `BTThreeDSecureRequest.dfReferenceID` were improperly returning an error if not passed into the request
* BraintreeCard
  * Deprecate unused `BTCardRequest` class

## 5.24.0 (2023-10-30)
* BraintreePayPalDataCollector
  * Update PPRiskMagnes with 5.4.1 - staging removed (fixes #1107)
  * This version of the PPRiskMagnes framework is static

## 6.8.0 (2023-10-24)
* BraintreeDataCollector
  * Update PPRiskMagnes with 5.4.1 - staging removed (fixes #1107)

## 6.7.0 (2023-10-09)
* BraintreeCore
  * Fix bug where `type` was always returned as `Unknown` in `fetchPaymentMethodNonces` (fixes #1099)
  * Analytics
    * Send `tenant_name` in `event_params` to PayPal's analytics service (FPTI)
    * Update `component` from `btmobilesdk` to `braintreeclientsdk` for PayPal's analytics service (FPTI)
    * Send `correlation_id`, when possible, in PayPal analytic events

## 6.6.0 (2023-08-22)
* BraintreePayPalNativeCheckout
  * Update PayPalCheckout from 1.0.0 to 1.1.0.

## 5.23.0 (2023-08-18)
* BraintreeVenmo
  * Allow merchants to collect enriched customer data if enabled in the Braintree Control Panel
  * Add the following properties to `BTVenmoRequest`
    * `collectCustomerBillingAddress`
    * `collectCustomerShippingAddress`
    * `totalAmount`
    * `subTotalAmount`
    * `discountAmount`
    * `taxAmount`
    * `shippingAmount`
    * `lineItems`

## 6.5.0 (2023-08-10)
* BraintreeVenmo
  * Add additional error parsing for Venmo errors
  * Throw cancelation specific error for `BTVenmoClient.tokenize()` (fixes #1085) 
    * _The callback style version of this function previously returned `(nil, nil)` for the cancel scenario, but will now return `(nil, error)` instead._
* BraintreeCore
  * Send `live` instead of `production` for the `merchant_sdk_env` tag to PayPal's analytics service (FPTI)

## 6.4.0 (2023-07-18)
* Expose reference documentation for `BTAppContextSwitcher.handleOpen(_:)` and `BTAppContextSwitcher.handleOpenURL(context:)`
* Fixed a bug to return `firstName`, `lastName`, `email`, and `payerID` on `BTPayPalNativeCheckoutAccountNonce` when available.
* BraintreeVenmo
  * Fix bug where tokenizations failed when sending an empty dictionary for `transactionDetails` in the `CreateVenmoPaymentContext` call (fixes #1074)

## 6.3.0 (2023-07-10)
* BraintreePayPalNativeCheckout (General Availability release)
  * Update PayPalCheckout from 0.110.0 to 1.0.0. This is our newly released General Availability version
     * _Note: This module will now be subject to semantic versioning_

## 6.2.0 (2023-06-27)
* BraintreePayPalNativeCheckout (BETA)
  * Fix bug where setting `userAction` does not update button as expected
* BraintreeSEPADirectDebit
  * Add `BTSEPADirectDebitRequest.locale`
* BraintreePayPal
  * Fix bug where `BTPayPalAccountNonce` values were not being returned as expected (fixes #1063)

## 6.1.0 (2023-06-22)
* BraintreeVenmo
  * Allow merchants to collect enriched customer data if enabled in the Braintree Control Panel
  * Add the following properties to `BTVenmoRequest`
    * `collectCustomerBillingAddress`
    * `collectCustomerShippingAddress`
    * `totalAmount`
    * `subTotalAmount`
    * `discountAmount`
    * `taxAmount`
    * `shippingAmount`
    * `lineItems`

## 6.0.0 (2023-06-20)
* The Braintree SDK is now written in Swift
* Breaking Changes
  * All SDK error enums are now internal
  * See [list of new / updated error cases and codes](SDK_ERROR_CODES.md)
  
**Note:** Includes all changes in [6.0.0-beta4](#600-beta4-2023-06-01), [6.0.0-beta3](#600-beta3-2023-04-18), [6.0.0-beta2](#600-beta2-2023-01-30), and [6.0.0-beta1](#600-beta1-2022-12-13)

## 5.22.0 (2023-06-08)
* Require Xcode 14.1 (per [App Store requirements](https://developer.apple.com/news/?id=jd9wcyov#:~:text=Starting%20April%2025%2C%202023%2C%20iOS,on%20the%20Mac%20App%20Store))
* Deprecate 3DS v1. Any attempt to use 3DS v1 will now throw an error. See [Migrating to 3D Secure 2](https://developer.paypal.com/braintree/docs/guides/3d-secure/migration) for more information.
* Carthage `.framework`s are no longer supported in Xcode 14.1, please replace all Frameworks with XCFrameworks and use `--use-xcframeworks` for all Carthage steps
  * Multi-architecture platforms are not supported when building framework bundles in Xcode 12+. [Prefer building with XCFrameworks](https://github.com/Carthage/Carthage#building-platform-independent-xcframeworks-xcode-12-and-above)).

## 6.0.0-beta4 (2023-06-01)
* Move from Braintree to PayPal analytics service
* Make `BTConfiguration` extensions internal
* Breaking Changes    
  * Require Xcode 14.3+ and Swift 5.8+
  * Rename `BraintreePaymentFlow` module to `BraintreeLocalPayment`
  * BraintreeThreeDSecure
    * Add `BTThreeDSecureClient`
      * Remove `BTPaymentFlowClient+ThreeDSecure` extension
      * Move `BTPaymentFlowClient+ThreeDSecure` and `BTThreeDSecureRequest` methods to `BTThreeDSecureClient`
      * Remove `BTThreeDSecureError.cannotCastRequest` case
    * Remove dependency on `BraintreePaymentFlow` module
  * BraintreeLocalPayment (formerly named BraintreePaymentFlow)
    * Rename `BTPaymentFlowClient` to `BTLocalPaymentClient`
    * Move `BTLocalPaymentRequest` methods to `BTLocalPaymentClient`
    
## 6.0.0-beta3 (2023-04-18)
* Remove `iosBaseSDK`, `iosDeploymentTarget`, `iosIdentifierForVendor`, `deviceAppGeneratedPersistentUuid`, and `deviceScreenOrientation` from `BTAnalyticsMetadata`
* Fixes error `@objcMembers attribute used without importing module 'Foundation'` in Xcode 14.3+
* Add async/await support back to all public Swift methods
* Convert `BraintreeVenmo` module to Swift
* Convert `BraintreeCard` module to Swift
* Convert `BraintreeThreeDSecure` module to Swift
* Convert `BraintreePaymentFlow` module to Swift
* Breaking Changes
  * BraintreePaymentFlow
    * Replaced `SFSafariViewController` with `ASWebAuthenticationSession`
    * Removed `BTViewControllerPresentingDelegate` protocol and correlating methods
    * Rename `BTLocalPaymentRequest.shippingAddressRequired` to `isShippingAddressRequired`
  * BraintreeApplePay
    * Rename `BTApplePayClient.tokenizeApplePay(_:completion:)` to `BTApplePayClient.tokenize(_:completion:)`
    * Rename `BTApplePayClient.paymentRequest()` to `BTApplePayClient.makePaymentRequest()`
    * Make `BTApplePayCardNonce` initializer internal
  * BraintreeDataCollector
    * Update PPRiskMagnes to static XCFramework
  * BraintreeVenmo
    * Rename `BTVenmoAccountNonce.externalId` to `BTVenmoAccountNonce.externalID`
    * Renamed `BTVenmoClient.tokenizeVenmoAccount(with:completion:)` to `BTVenmoClient.tokenize(_:completion:)`
    * Renamed `BTVenmoClient.isiOSAppAvailableForAppSwitch()` to `BTVenmoClient.isVenmoAppInstalled()`
  * BraintreeAmericanExpress
    * Rename `BTAmericanExpressClient.getRewardsBalance(forNonce:currencyIsoCode:completion:)` to `BTAmericanExpressClient.getRewardsBalance(forNonce:currencyISOCode:completion:)`
  * BraintreeSEPADirectDebit
    * Rename `BTSEPADirectDebitClient.tokenize(request:completion:)` to `BTSEPADirectDebitClient.tokenize(_:completion:)`
  * BraintreeCard
    * Make `BTAuthenticationInsight` initializer internal
    * Rename `BTCardClient.tokenizeCard(_:completion)` to `BTCardClient.tokenize(_:completion:)`
  * BraintreeThreeDSecure
    * 3D Secure version 1 is no longer supported
      * Removed the following: `BTThreeDSecureV1UICustomization` class, `BTThreeDSecureRequest.v1UICustomization` property, and `BTThreeDSecureVersion` enum
        * All 3D Secure requests will use version 2
      * Rename `BTThreeDSecureV2ButtonType` enum cases to: `.verify`, `.continue`, `.next`, `.cancel`, and `.resend`

## 5.21.0 (2023-03-14)
* Add missed deprecation warnings to `BTCardRequest` Union Pay properties
* Update Cardinal SDK to version 2.2.5-6
* BraintreePayPalNativeCheckout (BETA)
  * Expose `payerID` property on `BTPayPalNativeCheckoutAccountNonce` publicly
  * Expose all properties on `BTPayPalNativeCheckoutAccountNonce` to Objective-C

## 5.20.1 (2023-01-31)
* BraintreePayPalNativeCheckout (BETA)
  * Fix bug where some request dictionaries were being constructed incorrectly
  * Fix bug where passing `BTPayPalNativeVaultRequest.shippingAddressOverride` as `nil` was incorrectly throwing an error

## 6.0.0-beta2 (2023-01-30)
* Convert `BraintreePayPal` module to Swift
* Breaking Changes
  * BraintreePayPal
    * Rename `BTPayPalRequest.riskCorrelationId` to `BTPayPalRequest.riskCorrelationID`
    * Removed `BTPayPalRequest.activeWindow` property
      * The window will be set to the first window or a new `ASPresentationAnchor` if the first window is `nil`
    * Update `BTPayPalRequestLandingPageType` enum default case to `.none`
        * Update enum values
            * `.none` = 0
            * `.login` = 1
            * `.billing` = 2
    * `BTPayPalRequestUserAction`
        * Update enum cases to `.none` and `.payNow`
        * Update enum values
            * `.none` = 0
            * `.payNow` = 1
    * Update `BTPayPalRequestIntent` enum values
        * `.authorize` = 0
        * `.sale` = 1
        * `.order` = 2
    * Update `BTPayPalLineItemKind` enum values
        * `.debit` = 0
        * `.credit` = 1
    * Create `BTPayPalLocaleCode` enum
    * `BTPayPalRequest.localeCode` now uses the `BTPayPalLocaleCode` enum instead of a `String`
    * Renamed and replaced `BTPayPalClient.tokenizePayPalAccount` with two methods called `tokenize()` taking in requests of either `BTPayPalCheckoutRequest` or `BTPayPalVaultRequest`
    * Make `BTPayPalNonce` initializer internal
  * BraintreePayPalNativeCheckout (BETA)
    * Renamed and replaced `BTPayPalNativeCheckoutClient.tokenizePayPalAccount` with two methods called `tokenize()` taking in requests of either `BTPayPalNativeCheckoutRequest` or `BTPayPalNativeVaultRequest`
    * `BTPayPalNativeCheckoutRequest` now takes in an `intent` of type `BTPayPalRequestIntent` instead of `BTPayPalNativeRequestIntent`
    * `BTPayPalNativeCheckoutRequest.localeCode` now uses the `BTPayPalLocaleCode` enum instead of a `String` value
  * BraintreeUnionPay
    * Remove `BraintreeUnionPay` module
      * UnionPay cards can now be processed as regular cards (through the BraintreeCard module) due to their partnership with Discover
  * BraintreeCore
    * Remove `BTPreferredPaymentMethods` and `BTPreferredPaymentMethodResult`
  * BraintreeSEPADirectDebit
    * The `tokenize` method no longer takes in a `context` parameter
    * Merchants no longer need to conform to the `ASWebAuthenticationPresentationContextProviding` protocol

## 5.20.0 (2023-01-24)
* BraintreeThreeDSecure
  * Add `requestedExemptionType` to `BTThreeDSecureRequest`

## 5.19.0 (2022-12-19)
* BraintreePayPalNativeCheckout (BETA)
  * Update NativeCheckout version from 0.108.0 to 0.110.0
  * Fix issue with multiple clientIDs causing incorrect web fallback

## 6.0.0-beta1 (2022-12-13)
* Convert `BraintreeCore` module to Swift
* Convert `BraintreeAmericanExpress` module to Swift
* Convert `BraintreeDataCollector` module to Swift
* Removed `PayPalDataCollector` module in favor of single `BraintreeDataCollector`
* Kount is no longer supported through the SDK
* Breaking Changes
  * Bump minimum supported deployment target to iOS 14+
  * Require Carthage 0.38.0+ and xcframeworks via `carthage update --use-xcframeworks`
  * Require Xcode 14
    * Bump Swift Tools Version to 5.7 for CocoaPods & SPM
  * BraintreeCore
    * Renamed `BTAppContextSwitchDriver` protocol to `BTAppContextSwitchClient
    * `BTViewControllerPresentingDelegate` protocol now takes in the `client` parameter instead of `driver`
    * Renamed `BTClientMetadataSourceType` to `BTClientMetadataSource`
    * Renamed `BTClientMetadataIntegrationType` to `BTClientMetadataIntegration`
    * Removed static wrapper methods from `BTAppContextSwitcher`
    * Replaced `BTLogger` with `BTLogLevel` and `BTLogLevelDescription`
    * Renamed `BTCardNetworkUKMaestro` to `BTCardNetworkUkMaestro` in `BTCardNetwork` enum
  * BraintreeVenmo
    * Renamed `BTVenmoDriver` to `BTVenmoClient`
    * Remove `.unspecified` case from `BTVenmoPaymentMethodUsage` enum
    * Require `paymentMethodUsage` param in `BTVenmoRequest` initializer
    * Move category extension of `BTConfiguration` into `BraintreeCore`
  * BraintreePayPal
    * Renamed `BTPayPalDriver` to `BTPayPalClient`
    * Remove `BTPayPalDriver.requestOneTimePayment` in favor of `BTPayPalClient.tokenizePayPalAccount`
    * Remove `BTPayPalDriver.requestBillingAgreement` in favor of `BTPayPalClient.tokenizePayPalAccount`
    * Move category extension of `BTConfiguration` into `BraintreeCore`
  * BraintreeAmericanExpress
    * Make `BTAmericanExpressRewardsBalance` initializer private
  * BraintreePaymentFlow
    * Renamed `BTPaymentFlowDriver` to `BTPaymentFlowClient`
    * Renamed `BTPaymentFlowDriverDelegate` protocol to `BTPaymentFlowClientDelegate`
    * `handleRequest` in delegate protocol now takes in `paymentClientDelegate` parameter instead of `paymentDriverDelegate`
    * Move category extension of `BTConfiguration` into `BraintreeCore`
  * PayPalDataCollector
    * Removed `PayPalDataCollector` module in favor of single `BraintreeDataCollector`
  * BraintreeDataCollector
    * Kount is no longer supported through the SDK
    * Combine `PayPalDataCollector` and `BraintreeDataCollector` into one module to create single entrypoint for data collection
    * Merchants should use the new `collectDeviceData` function for data collection which will now return a completion with either device data or an error
  * BraintreeApplePay
      * Move category extension of `BTConfiguration` into `BraintreeCore`
  * BraintreeUnionPay
      * Move category extension of `BTConfiguration` into `BraintreeCore`
  * BraintreeThreeDSecure
      * Move category extension of `BTConfiguration` into `BraintreeCore`

## 5.18.0 (2022-12-13)
* Deprecate Kount Custom integrations
* Deprecate the `BraintreeUnionPay` module and containing classes
  * UnionPay cards can now be processed as regular cards (through the `BraintreeCard` module) due to their partnership with Discover

## 5.17.0 (2022-12-05)
* BraintreePayPalNativeCheckout (BETA)
  * Fix CocoaPods bug emitting "Cannot find interface declaration" error ([CocoaPods issue #11672](https://github.com/CocoaPods/CocoaPods/issues/11672))
  * Rename `riskCorrelationId` to `riskCorrelationID`
  * Rename `nativeRequest` to `request` internally in `tokenizePayPalAccount`
  * `tokenizePayPalAccount` now takes in a `request` of type `BTPayPalNativeRequest` instead of a `nativeRequest` of type `BTPayPalRequest`

## 5.16.0 (2022-10-27)
* BraintreePayPalDataCollector
  * Update PPRiskMagnes with a version of 5.4.0 with `ENABLE_BITCODE` removed
    * _The App Store no longer accepts bitcode submissions from Xcode 14_
    * This version of PPRiskMagnes drops support for Xcode 12 and requires Swift 5.5+
      * [As of April 25, 2022 Apple requires all apps to be submitted with Xcode 13+](https://developer.apple.com/news/upcoming-requirements/?id=04252022a)
    * This version of the PPRiskMagnes framework is dynamic. This reverts a breaking change that was introduced in minor version 5.8.0 (See GitHub issue #920).

## 5.15.0 (2022-10-26)
* BraintreePayPalNativeCheckout (BETA)
  * Fix `merchant_account_id` and `correlation_id` keys to be nested at the top level of the internal create order request
  * Update Package.swift to fetch `PayPalCheckout` binary dependency directly instead of hosting copy in `braintree_ios` repo
* BraintreePayPal
  * Resolve depreciation warning with `UIApplication.sharedApplication` for iOS 15+ targets (fixes #884)

## 5.14.0 (2022-10-05)
* Remove `ENABLE_BITCODE` from framework target build settings
  * _The App Store no longer accepts bitcode submissions from Xcode 14_
* BraintreePayPalNativeCheckout (BETA)
  * Update NativeCheckout version from 0.106.0 to 0.108.0
  * Fixes an issue where merchants with multiple client IDs would fallback to web on subsequent checkout sessions
  * Remove exit survey when canceling Native Checkout flow
* BraintreeSEPADirectDebit
  * Resolve Invalid Bundle error when uploading to the App Store

## 5.13.0 (2022-09-16)
* BraintreePayPalNativeCheckout (BETA)
  * Fix CocoaPods integrations to pin exact `PayPalCheckout` version
  * Update NativeCheckout version from 0.100.0 to 0.106.0
  * This version update allows US based customers with a confirmed phone number to log into their PayPal account using a one time passcode sent via SMS without needing to authenticate through a webview.
  * Update Package.swift to use local `PayPalCheckout` dependency instead of fetching remotely.
    * Fixes a bug where all Braintree merchants using SPM (including those not using the `BraintreePayPalNativeCheckout` module), would get `PayPalCheckout` in their projects.

## 5.12.0 (2022-09-07)
* Adds support for Xcode 14 and iOS 16 
* BraintreeSEPADirectDebit
  * Update `BTSEPADirectDebitNonce` to pull in `ibanLastFour` and `customerID` as expected
  * Remove unused `presentationContextProvider` (fixes #854)

## 5.11.0 (2022-07-20)
* BraintreeSEPADirectDebit
  * Add support for SEPA Direct Debit for approved merchants through the Braintree SDK
  * SEPA Direct Debit is only available to select merchants, please contact your Customer Support Manager or Sales to start processing SEPA bank payments
  * Merchants should use the `BTSepaDirectDebitClient.tokenize` method while passing in the `BTSEPADirectDebitRequest` and `context` while conforming to `ASWebAuthenticationPresentationContextProviding`
* BraintreePayPalNativeCheckout (BETA)
  * This module can handle the same flows as the existing `BraintreePayPal` module, but will present the end user with an in-context checkout flow using native UI components.
  * To get started, create a `BTPayPalNativeCheckoutClient`, and call `tokenizePayPalAccount` with either a `BTPayPalNativeCheckoutRequest` (for one time payment transactions), or a `BTPayPalNativeVaultRequest` (for vaulted flows)

## 5.10.0 (2022-06-06)
* Fix potential crash when http request fails with no error but empty data (thanks @cltnschlosser)
* Update Cardinal SDK to version 2.2.5-3

## 5.9.0 (2022-04-14)
* Venmo
  * Reduce network connection lost error frequency on older iOS and Venmo app versions
* PPDataCollector
  * Allow passing isSandbox bool for data collection in `clientMetadataID` and `collectPayPalDeviceData` functions

## 5.8.0 (2022-03-24)
* PPRiskMagnes
  * Update PPRiskMagnes to 5.4.0
  * This version of PPRiskMagnes replaces the dynamic framework/xcframework with a static framework/xcframework

## 5.7.0 (2022-03-02)
* Fix configuration caching

## 5.6.3 (2022-02-09)
* Swift Package Manager
  * Add explicit package dependancies for `BraintreeDataCollector`, `BraintreeThreeDSecure`, and `PayPalDataCollector` (fixes #735)

## 5.6.2 (2022-02-01)
* Update import statement of header file from `kDataCollector` to `KDataCollector`

## 5.6.1 (2022-01-14)
* Fix error construction for duplicate card error

## 5.6.0 (2022-01-13)
* Card Tokenization
  * Remove expiration date duplication in card tokenization (fixes #772)
  * Add `BTCardClientErrorTypeCardAlreadyExists` to `BTCardClientErrorType` 
* 3DS
  * Add nil checks for 3DS handlers (fixes #769)

## 5.5.0 (2021-11-01)
* Add `displayName` to `BTLocalPaymentRequest`
* Add `riskCorrelationId` to `BTPayPalRequest`
* Update `CardinalMobile` frameworks
  * Update `CardinalMobile.xcframework` to 2.2.5-2
    * Adds `arm64` simulator / Apple Silicon support (discussed in #564)
    * Fixes 3DS (iOS 15 translucent toolbar issue)[#748]
  * Update `CardinalMobile.framework` to 2.2.5-1
  * _Note:_
      * This release allows all SPM, CocoaPods, and Carthage users using `--use-xcframeworks` to get **Apple Silicon support** and the iOS 15 3DS toolbar fix.
      * Carthage users not using `--use-xcframeworks` will not get these updates until a later version.
      * See PR #750 for more details.

## 5.4.4 (2021-10-05)
* Re-organize `/Frameworks` binaries into nested `/FatFrameworks` and `/XCFrameworks` directories.
  * Provides fix for this [CocoaPods issue](https://github.com/CocoaPods/CocoaPods/issues/10731) & allows proper usage of `PPRiskMagnes.xcframework` by `PayPalDataCollector` subspec.
* Swift Package Manager
  * Update Package.swift to include `PPRiskMagnes` as explicit target for library products that require `PayPalDataCollector`
  * _Note:_ No longer requires manual inclusion of `PayPalDataCollector` in order to use `BraintreeThreeDSecure`, `BraintreePayPal`, and `BraintreePaymentFlow`

## 4.38.0 (2021-08-24)
* Add `offerPayLater` to `BTPayPalRequest`

## 5.4.3 (2021-07-22)
* Swift Package Manager
  * Adds `NS_EXTENSION_UNAVAILABLE` annotations to methods unavailable for use in app extensions. Fixes (Drop-In issue #343)[https://github.com/braintree/braintree-ios-drop-in/issues/343] for Xcode 13-beta3.
* ThreeDSecure
  * Add `cardAddChallenge` to `BTThreeDSecureRequest`

## 5.4.2 (2021-06-24)
* Swift Package Manager
  * Remove product libraries for `KountDataCollector`, `PPRiskMagnes`, and `CardinalMobile` (requires Xcode 12.5+)
    * _Notes:_
      * This was a workaround for an Xcode bug discussed in #576. The bug resolved in Xcode 12.5.
      * You can remove the `KountDataCollector`, `PPRiskMagnes`, and `CardinalMobile` explicit dependencies.
      * You can also remove any run-script phase or post-action [previously required](https://github.com/braintree/braintree_ios/blob/5.x/SWIFT_PACKAGE_MANAGER.md) for using these frameworks.
  * Xcode 13 Beta
    * Remove invalid file path exclusions from `Package.swift` (thanks @JonathanDowning)

## 5.4.1 (2021-06-22)
* Re-add `BraintreeCore` dependency to `PayPalDataCollector` for Swift Package Manager archive issue workaround (fixes #679)

## 5.4.0 (2021-06-07)
* Venmo
  * Add `paymentMethodUsage` to `BTVenmoRequest`
  * Add `displayName` to `BTVenmoRequest`
* Update PPRiskMagnes to 5.2.0
* Carthage
    * Add xcframework support (requires [Carthage 0.38.0+](https://github.com/Carthage/Carthage/releases/tag/0.38.0))

## 5.3.2 (2021-05-25)
* Fix `Braintree-Swift.h` imports for React Native projects using CocoaPods (fixes #671)
* Fix `BTJSON` compatability for Swift

## 5.3.1 (2021-05-11)
* Update Kount SDK to v4.1.5
* Fix bug where `userAction` on `BTPayPalCheckoutRequest` was ignored

## 4.37.1 (2021-04-06)
* Update PPRiskMagnesOC to 4.0.12 (resolves potential duplicate symbols errors)

## 5.3.0 (2021-03-23)
* Add CardinalMobile.xcframework version 2.2.5-1
* Update Kount SDK to v4.1.4

**NOTE:** For Swift Package Manager integrations using `BraintreeThreeDSecure`, manually including `CardinalMobile.framework` is no longer required. You should delete it from your project and add `CardinalMobile` via SPM. If you added the run script to remove simulator architectures from `CardinalMobile.framework`, you should remove this as well. See the [Swift Package Manager guide](https://github.com/braintree/braintree_ios/blob/5.x/SWIFT_PACKAGE_MANAGER.md) for more information.

## 5.2.0 (2021-03-15)
* Fix potential crash if `legacyCode` param missing from GraphQL error response
* PayPal
  * Add `offerCredit` to `BTPayPalVaultRequest`

## 5.1.0 (2021-03-08)
* Local Payment Methods
  * Add `bic` (Bank Identification Code) to `BTLocalPaymentRequest`
* Apple Pay
  * Add support for `PKPaymentNetworkElo` to Apple Pay configuration

## 5.0.1 (2021-03-01)
* SPM
  * Remove `KountDataCollector` binary dependency from `BraintreeDataCollector` target (fixes #624)
  * Remove `PPRiskMagnes` binary dependency from `PayPalDataCollector` target (fixes #624)
* Carthage
  * Fix timeout when building from source using --no-use-binaries or --use-xcframeworks flags

## 5.0.0 (2021-02-11)
* Breaking Changes
  * Make `shippingMethod` property on `BTThreeDSecureRequest` an enum instead of a string
  * Remove `BTTokenizationService`
  * Make `BTPaymentMethodNonceParser` private
  * Remove `BTAppSwitchDelegate`
  * Rename `BTAppSwitch` to `BTAppContextSwitcher`
    * Rename `handleAppSwitchReturnURL()` to `handleReturnURL()`
    * Rename `canHandleAppSwitchReturnURL()` to `canHandleReturnURL()`
    * Remove `unregisterAppSwitchHandler()`
  * Rename properties to use `ID` instead of `Id`:
    * `BTAmericanExpressRewardsBalance.requestID`
    * `BTCard.merchantAccountID`
    * `BTThreeDSecureInfo.acsTransactionID`
    * `BTThreeDSecureInfo.dsTransactionID`
    * `BTThreeDSecureInfo.threeDSecureAuthenticationID`
    * `BTThreeDSecureInfo.threeDSecureServerTransactionID`
    * `BTBinData.productID`
    * `BTClientMetadata.sessionID`
    * `BTConfiguration+DataCollector.kountMerchantID`
    * `BTDataCollector.fraudMerchantID`
    * `BTPayPalAccountNonce.clientMetadataID`
    * `BTPayPalAccountNonce.payerID`
    * `BTPayPalRequest.merchantAccountID`
    * `BTLocalPaymentRequest.merchantAccountID`
    * `BTLocalPaymentResult.clientMetadataID`
    * `BTLocalPaymentResult.payerID`
    * `BTThreeDSecureAdditionalInformation.accountID`
    * `BTThreeDSecureLookup.transactionID`
  * Rename methods to use `ID` instead of `Id`:
    * `BTLocalPaymentRequest.localPaymentStarted(request:paymentID:start:)`
    * `BTVenmoDriver.authorizeAccount(profileID:vault:completion:)`
  * Remove `initWithNumber` and `initWithParameters` initializers from `BTCard`
  * Replace `BTVenmoDriver.authorizeAccount` methods with `BTVenmoDriver.tokenizeVenmoAccount`
  * PayPal
    * Update `BTPayPalDriver.requestOneTimePayment` to expect a `BTPayPalCheckoutRequest` and deprecate method
    * Update `BTPayPalDriver.requestBillingAgreement` to expect a `BTPayPalVaultRequest` and deprecate method
    * Remove `offerCredit` from `BTPayPalRequest` (`offerPayLater` should be used instead)
  * BraintreeDataCollector
    * Remove `BTDataCollectorDelegate`
    * Remove `BTDataCollector.collectCardFraudData()`
    * Remove `BTDataCollectorKountErrorDomain`
* Add `environment` to `BTConfiguration`
* Add `BTVenmoRequest`
* Update Kount SDK to v4.1.3 (includes arm64 simulator architecture for Apple silicon)
* PayPal
  * Fix memory leak in `BTPayPalDriver`
  * Add `BTPayPalCheckoutRequest`
  * Add `BTPayPalVaultRequest`
  * Add `tokenizePayPalAccount` method to `BTPayPalDriver`
  * Add `offerPayLater` and `requestBillingAgreement` to `BTPayPalCheckoutRequest`
* Update CardinalMobile.framework to v2.2.5

**Note:** Includes all changes in [5.0.0-beta2](#500-beta2-2021-01-20) and [5.0.0-beta1](#500-beta1-2020-12-01)

## 5.0.0-beta2 (2021-01-20)
* Add SPM support for `BraintreeDataCollector` and `BraintreeThreeDSecure`
* Add SPM libraries for `KountDataCollector` and `PPRiskMagnes` to workaround Xcode bug (addresses #576)
* Bump Kount to v4.0.4.3 pre-release (provides an xcframework for SPM)
* Bump PPRiskMagnes to v5.10.0 (resolves #564)
* Fix Xcode 12.3 issue with building PPRiskMagnes.framework for iOS + iOS Simulator
* Add `accountType` to `BTThreeDSecureRequest`
* Breaking Changes
  * Remove `type` and `nonce` params on `BTApplePayCardNone` initializer
  * Replace `uiCustomization` with `v2UICustomization` on `BTThreeDSecureRequest`
  * Introduce new classes for 3DS2 UI customization:
    * `BTThreeDSecureV2UICustomization`
    * `BTThreeDSecureV2ButtonCustomization`
    * `BTThreeDSecureV2LabelCustomization`
    * `BTThreeDSecureV2TextBoxCustomization`
    * `BTThreeDSecureV2ToolbarCustomization`
  * Default `versionRequested` on `BTThreeDSecureRequest` to 3DS2 instead of 3DS1

## 4.37.0 (2021-01-20)
* Add `paymentTypeCountryCode` to `BTLocalPaymentRequest`

## 5.0.0-beta1 (2020-12-01)
* Add support for Swift Package Manager (resolves #462)
* Bump Kount to v4.0.4.2 (supports iOS 9.3+)
* Replace deprecated `SecTrustEvaluate` with `SecTrustEvaluateWithError` (fixes #536)
* Only check if the Venmo app is installed if the BraintreeVenmo module is being used (resolves #231)
* Breaking Changes
  * Bump minimum supported deployment target to iOS 12
  * Remove deprecated `BraintreeUI` module
  * Remove all deprecated methods and properties
  * Core
    * Remove the `localizedDescription` property on `BTPaymentMethodNonce`
    * Update all methods on `BTAppSwitchDelegate` to be optional
    * Remove `options` and `sourceApplication` params on `BTAppSwitch` methods
  * PaymentFlow
    * Update dismiss button style from done to cancel for `SFSafariViewController`s presented via the `BTPaymentFlowDriver`. This update applies to both the 3D Secure and Local Payments payment flows.
    * Remove the `localizedDescription` property on `BTLocalPaymentResult`
    * Remove unused `BTPaymentFlowDriverErrorTypeInvalidRequestURL` option from `BTPaymentFlowDriverErrorDomain`
  * PayPal
    * Remove PayPalOneTouch and PayPalUtils modules
    * Remove `authorizeAccountWithCompletion` and `authorizeAccountWithAdditionalScopes` methods from `BTPayPalDriver`
    * Remove `requestOneTimePayment` and `requestBillingAgreement` overloads with custom `handler` parameters from `BTPayPalDriver`
    * Remove `viewControllerPresentingDelegate` property from `BTPayPalDriver`
    * Remove use of `SFSafariViewController` from PayPal flow
    * Replace deprecated `SFAuthenticationSession` with `ASWebAuthenticationSession` in PayPal flow
    * Update `requestBillingAgreement` and `requestOneTimePayment` completion blocks to return an error when user cancels the PayPal flow
    * Remove custom URL scheme requirement for PayPal flow
    * Update `BTPayPalDriverErrorType` enum
      * Remove `BTPayPalDriverErrorTypeIntegrationReturnURLScheme`
      * Remove `BTPayPalDriverErrorTypeAppSwitchFailed`
      * Remove `BTPayPalDriverErrorTypeInvalidConfiguration`
  * ThreeDSecure
    * Remove deprecated `Braintree3DSecure` module
    * Restructure `BTThreeDSecureResult` and `BTThreeDSecureLookup`
    * Create a stand-alone 3DS module
  * PayPalDataCollector
    * Add `PPRiskMagnes.framework` and `PPRiskMagnes.xcframework` v5.0.1 (requires Swift 5.1+)
    * Remove `collectPayPalDeviceInfoWithClientMetadataID` method on `PayPalDataCollector.h`

## 4.36.1 (2020-11-10)
* Update CardinalMobile.framework to v2.2.4-1
* Exclude arm64 simulator architectures via Podspec (fixes [Drop-In #233](https://github.com/braintree/braintree-ios-drop-in/issues/233))

## 4.36.0 (2020-10-07)
* Add `cardholderName` to `BTCardNonce`
* Add support for `PKPaymentNetworkMaestro` to Apple Pay configuration

## 4.35.0 (2020-08-10)
* Update CardinalMobile.framework to v2.2.3-1
* Add `expirationMonth` and `expirationYear` to `BTCardNonce`
* Update PPDataCollector

## 4.34.0 (2020-06-09)
* Add `environment` property to `BTPayPalUAT`

## 4.33.0 (2020-04-16)

* Add support for iOS 13 SceneDelegate to `BTAppSwitch`
* Add `lastFour` property to `BTCardNonce`
* Make `BTURLUtils.h` public
* Add support for authorizing the Braintree SDK with a `PayPalUAT` (universal access token)
* Remove `AddressBook.framework` from Podspec (thanks @ignotusverum)
* Add `threeDSecureAuthenticationId` to `BTThreeDSecureInfo`

## 4.32.1 (2020-02-21)

* Fix crash when `ThreeDSecureRequest` `amount` field is set to NaN (resolves #507)
* Update CardinalMobile.framework to v2.2.2-1 for Carthage users

## 4.32.0 (2020-02-18)

* Update CardinalMobile.framework to v2.2.2-1
* Update PPDataCollector

## 4.31.0 (2020-01-15)

* Add support for basic UI customization of 3DS1 flows. See `BTThreeDSecureV1UICustomization`.

## 4.30.2 (2019-11-15)

* Updated CardinalMobile.framework to v2.2.1-2

## 4.30.1 (2019-11-04)

* Updated CardinalMobile.framework to v2.2.1

## 4.30.0 (2019-10-01)

* Fix nullability annotations on `BTPostalAddress` fields (resolves #472)
* Add ability to request `AuthenticationInsight` when tokenizing a credit card, which can be used to make a decision about whether to perform 3D Secure verification
* Set error message on `BTThreeDSecureInfo` when 3D Secure 2.0 challenge fails

## 4.29.0 (2019-09-19)

* Fix issue when returning from the Venmo app on iOS13
* Fix crash and return error when `threeDSecureRequest.amount` is `nil` and 3DS v1 is requested

## 4.28.0 (2019-09-05)

* Add ability to customize UI for 3D Secure challenge views
* Add authentication and lookup transaction status information to BTThreeDSecureInfo

## 4.27.1 (2019-08-29)

* Fix url parsing bug (thanks @pedrocid)

## 4.27.0 (2019-08-15)

* Remove unneeded pre-processor directives
* Added new fields to BTThreeDSecureInfo

## 4.26.3 (2019-07-31)

* Fixed issue with Carthage binary spec for CardinalMobile

## 4.26.2 (2019-07-31)

* Add support for CardinalMobile binary only framework when using Carthage

## 4.26.1 (2019-07-26)

* Update CardinalMobile to v2.1.4-2
  * Fix issue distributing to App Store

## 4.26.0 (2019-07-26)

* Send analytics timestamps in milliseconds
* Fix crash on apps with deployment targets without minor version (thanks @squall09s)
* Add additional fields to BTThreeDSecureInfo

## 4.25.1 (2019-07-15)

* Correct importing of BTConfiguration+ThreeDSecure (thanks @ejensen)
* Add missing header documentation for BTThreeDSecureLookup

## 4.25.0 (2019-07-12)

* Update CardinalMobile to v2.1.4
  * Remove use of `advertisingIdentifier`

## 4.24.0 (2019-07-09)

* Add 3DS 2 Support
* Update 3DS redirect to newest version
* Update platform to iOS 8.0 in podspec
* Remove location data from analytics collection

## 4.23.2 (2019-06-20)

* Fix issue that caused a crash when 3DS auth response is invalid

## 4.23.1 (2019-06-17)

* Update analytics parameters
* Update local payment endpoint

## 4.23.0 (2019-03-07)

* Add Hiper and Hipercard support

## 4.22.0 (2019-01-30)

* Add support for `BTPayPalLineItem`
* Fix build issue for Demo app

## 4.21.0 (2018-12-12)

* Fix occasional crash in `libPPRiskComponent.a`

## 4.20.2 (2018-11-16)

* Fix minimum iOS version in `libPPRiskComponent.a`

## 4.20.1 (2018-11-14)

* Update `libPPRiskComponent.a` to latest version

## 4.20.0 (2018-10-30)

* Luhn validate UnionPay cards
  * Luhn-invalid UnionPay cards were previously rejected server side rather than client side
* Fix retain cycle when ovewriting an NSURLSession
* Update `PayPalDataCollector` to include latest `libPPRiskComponent.a`

## 4.19.0 (2018-09-13)

* Update properties on BTLocalPaymentRequest

## 4.18.0 (2018-08-31)

* Add optional merchantAccountId to BTPayPalRequest
* Add openVenmoAppPageInAppStore to BTVenmoDriver
* Add BTLocalPayment to BTPaymentFlow
  * Replaces the BTIdeal integration

## 4.17.0 (2018-07-17)

* Update GraphQL URLs

## 4.16.0 (2018-06-15)

* Add shippingAddressEditable flag to BTPayPalRequest

## 4.15.2 (2018-06-13)

* Fix issue where address override was not set for PayPal billing agreements

## 4.15.1 (2018-06-07)

* Use angled brackets for BraintreeVenmo header imports (thanks @vicpenap)

## 4.15.0 (2018-04-30)

* 3D Secure
  * Add support for American Express SafeKey params

## 4.14.0 (2018-04-03)

* Ensure animations are consistent for PayPal SFSafariViewController flow (thanks @nudge)
* Update header documentation
* Add BTAppSwitchDelegate events `appContextWillSwitch` and `appContextDidReturn`
  * Addresses the issue that notifications were inconsistent across app switches [#383](https://github.com/braintree/braintree_ios/issues/383)

## 4.13.0 (2018-03-20)

* Update `PayPalDataCollector` to include latest `libPPRiskComponent.a`

## 4.12.0 (2018-03-06)

* Add support for Venmo profiles
* Fix demo app issue with CocoaPods

## 4.11.0 (2018-02-05)

* Fix code for implicit retain self warning (thanks @keith)

## 4.10.1 (2018-02-01)

* Add BTThreeDSecureInfo to BTCardNonce
* Use angled brackets for BraintreePayPal header imports (thanks @nudge)

## 4.10.0 (2017-12-08)

* Add iDEAL support
* Add new 3D Secure integration with browser support
* Fix issue where ApplePay nonces were not having their default property set (Thanks @rksaraf)

## 4.9.6 (2017-11-13)

* Fix issue where Venmo attempted to vault when using a Tokenization Key

## 4.9.5 (2017-11-03)

* Fix a timeout issue on configuration fetch
* Static analysis fixes
* Add BraintreeAmericanExpress module and getRewardsBalance method

## 4.9.4 (2017-10-02)

* Fix Xcode9 compatibility issues with iOS 7.0

## 4.9.3 (2017-09-28)

* Update Xcode 9 code for availability checking
* Fix analytics thread issue

## 4.9.2 (2017-09-25)

* Fix Xcode9 build warnings
* Add additional billing address params to card builder
  * Country Code Alpha 3
  * Country Code Numeric
  * Company
  * Extended Address

## 4.9.1 (2017-09-20)

* Update libPPRiskComponent to latest version

## 4.9.0 (2017-09-13)

* Add support for `SFAuthenticationSession` for PayPal payments

## 4.8.7 (2017-08-30)

* Add firstName and lastName to BTCard

## 4.8.6 (2017-08-17)

* Add additional bin data to card based payment methods

## 4.8.5 (2017-07-21)

* Fix bug that caused a crash on iOS11 (Beta 3) when using a Tokenization Key in production (Thanks @peterstuart)

## 4.8.4 (2017-06-26)

* Update to Kount 3.2
* Update Demo to support Xcode9 (Beta 1) and iOS11
* Update README

## 4.8.3 (2017-05-30)

* Fix Pay with Venmo bug

## 4.8.2 (2017-05-11)

* Add PayPal Credit support to PayPal Billing Agreements flow
* Add V3 Client Token support
* Enable client side vaulting of Venmo nonces
* Fix potential memory leak issue [#312](https://github.com/braintree/braintree_ios/issues/312)
* Fix bug causing random crashes in 3DS flow [#329](https://github.com/braintree/braintree_ios/issues/329)

## 4.8.1 (2017-04-07)

* Optimize BTAPIClient:initWithAuthorization: when using a client token
* Fix invalid documentation tags

## 4.8.0 (2017-03-30)

* Enable PayPal Credit
* Add support for `displayName` and `landing_page_type` PayPal options
* Fix issue with 3DS error callbacks [#318](https://github.com/braintree/braintree_ios/issues/318)
* Resolve build error in Xcode 8.3

## 4.7.5 (2017-02-22)

* Fix issue where PayPal correlation_id was not set correctly
* Add support for custom PayPal authentication handler
* Update docs to specify Xcode 8+ requirement
* Fix header import in BTAnalyticsMetadata.m
* Additional tuning for Travis CI

## 4.7.4 (2017-01-13)

* Update UnitTests to Swift 3
* Update PayPal header docs
* Update CocoaDocs and remove styling

## 4.7.3 (2016-11-18)

* Allow `BraintreeCore` to be compatible with App Extensions
* Fix `BraintreePayPal` use of `queryItems` for iOS 7 compatibility
* Present SFSafariViewControllers from the top UIViewController via Drop-in to avoid blank SFSafariViewController
  * Set `BTPaymentRequest` `presentViewControllersFromTop` to `YES` to opt in to this behavior
* Fix `@param` warning for incorrect argument name
* Fix CocoaDocs and add styling

## 4.7.2 (2016-11-08)

* Update Apple-Pay
  * Fix issue when using `BTConfiguration:applePaySupportedNetworks` with `Discover` enabled on devices `<iOS 9`
  * Add `BTApplePayClient:paymentRequest:` - creates a `PKPaymentRequest` with values from your Braintree Apple Pay configuration
* Update documentation and README

## 4.7.1 (2016-10-18)

* Update to Kount 3.1
* Update libPPRiskComponent to latest version
* Refactored ACKNOWLEDGEMENTS.md with links instead of text
* Re-add new Drop-In demo from BraintreeDropIn
* Fix fbinfer warnings

## 4.7.0 (2016-09-23)

* Move `BraintreeDropIn` and `BraintreeUIKit` to a new [separate repository](https://github.com/braintree/braintree-ios-drop-in)
  to allow cleaner separation and iteration for newer versions of Drop-In.
  * Please see the new repository for updated integration instructions if you were using the Beta Drop-In Update.
  * If you were using Drop-In from `BraintreeUI`, you do not have to update. However, you may want to check out the
    new Drop-In for an updated experience.
* Fix issue with `DataCollector` setting the merchant ID automatically to configure Kount

## 4.6.1 (2016-09-15)

* Fix conflicting private API name Fixes #265
* Fix deprecation warnings for Xcode 8 Fixes #267
* Fix target membership for static library Fixes #264
* Improve Maestro card number recognition

## 4.6.0 (2016-09-09)

* Fix nullability annotations for Xcode 8 Fixes #260
* Add `userAction` property to `BTPayPalRequest`
* (BETA) Updates to `BraintreeDropIn`

## 4.5.0 (2016-08-05)

* Update `DataCollector` API
  * Add initializer and new data collection methods that take a completion block
    * New data collection methods use Braintree gateway configuration to configure Kount
  * Previous API for `BTDataCollector` has been deprecated
* Remove Venmo user whitelist – all Venmo users may now make merchant purchases using Venmo.

## 4.4.1 (2016-07-22)

* Update and fix issues in `BraintreeDropIn` based on feedback
* Make more headers public in `BraintreeUIKit`
* Fix `BraintreeUIKit` module name for Cocoapods
* Add support for 3D Secure to `BraintreeDropIn` (see Drop-In docs)
* Update the [Drop-In docs](Docs/Drop-In-Update.md)
* Add features to support vaulting Venmo when using Drop-In (coming soon)

## 4.4.0 (2016-07-14)

* (BETA) Release of new `BraintreeDropIn` and `BraintreeUIKit` frameworks
  * `BraintreeDropIn` bundles our new UI components and Braintree API's for a whole new Drop-In experience
  * UI components, helpers, vector art and localizations are now public and fully accessible via `BraintreeUIKit`
  * [Learn more about our Drop-In Update](Docs/Drop-In-Update.md)
  * Note that our legacy Drop-In (`BraintreeUI`) has not changed
* (BETA) Various updates to the UnionPay component
* Improve error messages when Braintree gateway returns 422 validation errors

## 4.3.2 (2016-06-09)

* Update Pay with Venmo to use merchant ID and environment from configuration
* PayPal Checkout supports an intent option, which can be authorize or sale
  * See `BTPayPalRequest`'s `intent` property
* Provide better `NSError` descriptions when Braintree services return a 4xx or 5xx HTTP error

## 4.3.1 (2016-05-25)

* Add public method to fetch a customer's vaulted payment method nonces
* Drop-in bug fixes
  * Do not show mobile phone number field
  * Fix issue where American Express display text is truncated
* Merge [#241](https://github.com/braintree/braintree_ios/pull/241) - Add missing source files to Braintree static library target. (Thanks @AlexDenisov!)

## 4.3.0 (2016-05-03)

* Add support for UnionPay cards
  * UnionPay is now in private beta. To request access, email [unionpay@braintreepayments.com](mailto:unionpay@braintreepayments.com).
* Drop-in displays vaulted payment methods by default first
  * Payment method nonces have an `isDefault` property
* Add `BTHTTPErrorCodeRateLimitError` to indicate when Braintree is rate-limiting your app's API requests
* Update support for static library integrations
  * Fix issues with missing classes in the Braintree static library target
  * Add [guide for Static Library integrations](Docs/Braintree-Static-Integration-Guide.md)
* Use in-memory `NSURLCache` for configuration caching
* Analytics events are batched together for better performance
* Update theme of card form child components when using custom theme
* `PayPalOneTouch` is less chatty when logging to console
* Add ACKNOWLEDGEMENTS.md
* Update `PayPalDataCollector` to include latest `libPPRiskComponent.a`
* Remove unused targets and schemes: `Demo-StaticLibrary`, `UnitTests-CocoaPods`, and `UnitTests-StaticLibrary`

## 4.2.3 (2016-02-22)

* Remove assertion from PayPal One Touch Core when reading from Keychain fails
* Remove NSLog() from PayPal One Touch Core
* Fix nullability annotation in `PPFPTITracker.h` to squelch error in Xcode 7.3 Beta

## 4.2.2 (2016-02-11)

* Fix crash that occurs when downgrading Braintree from 4.2.x to previous versions

## 4.2.1 (2016-02-05)

* Fix deprecation warning/error in PayPal One Touch for apps that target >= iOS 9.0

## 4.2.0 (2016-02-04)

* Open source PayPal One Touch library
  * Source code for PayPal One Touch library is now included in Braintree iOS SDK repository
  * Added CocoaPods subspecs for PayPalOneTouch and PayPalDataCollector
* Improve `BTPaymentButton`
  * Payment button displays payment options based on configuration
  * Shows loading activity indicator when fetching configuration
  * Updated style for PayPal button when PayPal is the only available payment option
  * Can manually configure available payment options via `enabledPaymentOptions` property
* Added `setCardNumber:` and `setCardExpirationMonth:year:` to `BTDropInViewController`
  * Drop-in card form can be prepopulated, e.g. by card.io
* Deprecate `BTDataCollector` `payPalClientMetadataID` and `collectPayPalClientMetadataId`
  * Use `PPDataCollector` `collectPayPalDeviceData` when you only need to collect PayPal device data
* Add Travis CI to run tests

## 4.1.3 (2016-01-08)

* Prevent crash when `BTPayPalDriver` instantiates `SFSafariViewController` with an invalid URL, and return an error instead
* Update `BTTokenizationService` `allTypes` property to be `NSArray <NSString *>`

## 4.1.2 (2015-12-09)

* Workaround for Swift compiler bug that causes `BTJSON` to conflict with Alamofire (see Issue [#195](https://github.com/braintree/braintree_ios/issues/195))
  * For the merchant apps that read their configuration directly from `BTJSON` via Objective-C, you may need to switch from dot syntax to square brackets to call `BTJSON` methods
* Ignore `UIAlertView` deprecation warning in `BTDropInErrorAlert`

## 4.1.1 (2015-12-08)

* Bug fix for Drop-in view controller showing empty `BTPaymentButton`
* Update Kount to 2.6.2

## 4.1.0 (2015-12-07)

* Limited release of Pay With Venmo
  * Contact [pay-with-venmo@braintreepayments.com](mailto:pay-with-venmo@braintreepayments.com) if you are interested in early access
* Fix for Carthage integrations: remove reference to Braintree developer team from Xcode framework targets
* Streamlined vector graphics for JCB logo to reduce build time of BraintreeUI

## 4.0.2 (2015-11-30)

* If the Client Token has a Customer ID, Drop-in will automatically fetch the customer's vaulted payment methods.
  * A bug in 4.0.0-4.0.1 prevented Drop-in from fetching payment methods even if a Customer ID is provided in the Client Token; apps needed to call `fetchPaymentMethodsOnCompletion` before presenting Drop-in.
  * You can still call `fetchPaymentMethodsOnCompletion` to pre-fetch payment methods, so that Drop-in doesn't need to show its own loading activity indicator.
* Prevent calling requestsDismissalOfViewController on iOS 8 when there is nothing to dismiss. (Merge [#199](https://github.com/braintree/braintree_ios/pull/199) - thanks, @Reflejo!)
* Drop-in Add Payment Method fixes
  * Show/hide CVV and postal code fields without flicker
  * Use Save bar button item in upper right to add additional payment methods
* `BTPayPalDriver` will not call `BTAppSwitchDelegate` callback methods when `SFSafariViewController` is presented (Issue [#188](https://github.com/braintree/braintree_ios/issues/188))

## 4.0.1 (2015-11-17)

* Drop-in fixes
  * Fixed a bug that prevented cards from being vaulted.
    * Note: [BTCard's behavior has changed slightly](https://github.com/braintree/braintree_ios/commit/18b67d3).
  * Fixed a bug that prevented card types from being parsed.
  * Updated Demo to use paymentRequest and always call completionBlock.
* Resolved an analyzer warning in BTAPIClient.m.

## 4.0.0 (2015-11-09)

* Remodel the iOS SDK into frameworks with smaller filesize and greater flexibility.
* The public API has changed significantly in this release. For details, see the [v4 Migration Guide](Docs/Braintree-4.0-Migration-Guide.md) and the public header files.
* APIs have been refactored to use completion blocks instead of delegate methods.
* BTPaymentProvider has been removed. Instead, use payment option frameworks. For example, import BraintreeApplePay and use BTApplePayClient.
* Added support for [Tokenization Keys](https://developers.braintreepayments.com/guides/authorization/tokenization-key) in addition to Client Tokens.
* All methods and properties have been updated with nullability annotations.
* Added support for Carthage in addition to CocoaPods.
* PayPal One Touch is greatly improved in this release. It's slimmer and provides a better user experience, with browser switch on iOS 8 and SFSafariViewController on iOS 9.
* Added support for PayPal billing agreements (the New Vault Flow) and one-time payments.
* Drop-in is now part of the new BraintreeUI framework. BraintreeUI has been refactored for greater flexibility; it will automatically exclude any payment options that are not included in your build (as determined by CocoaPods subspecs or Carthage frameworks).
* Venmo One Touch has been excluded from this version. To join the beta for Pay with Venmo, contact Braintree Support.
* BTData has been renamed to BTDataCollector.
* BTPaymentMethod has been renamed to BTPaymentMethodNonce.

As always, feel free to [open an Issue](https://github.com/braintree/braintree_ios/issues/new) with any questions or suggestions that you have.

## 3.9.7 (2015-12-21)

* Ignore `UIAlertView` deprecation warning in `BTDropInErrorAlert`

## 3.9.6 (2015-10-08)

* Update Kount DeviceCollectorSDK to v2.6.2 to [fix #175](https://github.com/braintree/braintree_ios/issues/175) (thanks, @keith)

## 3.9.5 (2015-10-05)

* Add runtime checks before using new features in Apple Pay iOS 9
  * Bug in 3.9.4 caused `shippingContact`, `billingContact`, and `paymentMethod` to be used on < iOS 9 devices, which causes unrecognized selector crashes

## 3.9.4 (2015-09-25)

* :rotating_light: This version requires Xcode 7 and iOS SDK 9.0+
* Update README.md and Braintree Demo app for iOS 9 and Xcode 7
* Update PayPal mSDK to 2.12.1 with bitcode
* Update Kount library with bitcode support
* Update Apple Pay support for iOS 9. `BTApplePayPaymentMethod` changes:
  * Deprecate `ABRecordRef` properties: `billingAddress` and `shippingAddress`
  * Add `PKContact` properties: `billingContact` and `shippingContact`

## 3.9.2-pre6 (2015-08-28)
* PayPal
  * Fix canOpenUrl warnings in iOS9
* Added `PayerId` and `ClientMetadataId` to `BTPayPalPaymentMethod`

## 3.9.2-pre5 (2015-08-19)
* PayPal
  * Fix Billing Agreements support
  * Update PayPal One Touch Core

## 3.9.2-pre4 (2015-08-04)
* PayPal
  * Update support for PayPal Checkout
  * Add support for PayPal Billing Agreement authorization
  * Update PayPal One Touch Core

## 4.0.0-pre2 (2015-06-23)

* PayPal
  * For single payments, `BTPayPalPaymentMethod` now provides `firstName`, `lastName`, `phone`, `billingAddress`, and `shippingAddress` properties.
  * For future payments, add support for additional scopes.
  * Add demo for PayPal Checkout and scopes.
* Change @import to #import (#124).
* Add accessibility label to BTUICTAControl.

## 4.0.0-pre1

* Replace mSDK with One Touch Core
  * This replaces PayPal in-app login with browser switch for future payments consent
  * This adds the capability to perform checkout (single payments) with One Touch

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

## 3.9.1 (2015-06-12)

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
