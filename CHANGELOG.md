## 2.2.7

* Hotfix: Fix broken 2.2.6 release.
* updates to Venmo Touch
* 64-bit support

## 2.2.6

* Deprecated. Do not use.

## 2.2.5

* Bugfix in Venmo Touch server communication protocols.

## 2.2.4

* Hotfix: Fix minor bug introduced in v2.2.3.

## 2.2.3

* Fix bug with client-side encryption changes.

## 2.2.2

* Fix bug where payment form would fail when hiding zip code request (thanks [leogiertz](https://github.com/leogiertz)).

## 2.2.1

* Update podspec.

## 2.2.0

* Redesigns Venmo Touch for iOS 7 look and feel.
* Addresses numerous Github issues.

## 2.1.2

* Add approvedPaymentMethodWithCodeAndCard helper method. This is similar to approvedPaymentMethodWithCode, but returns an object that contains additional information about the card referenced by the payment method code. 

## 2.1.1

* Rename VTClient method, "+ (VTClient *)sharedClient;" to "+ (VTClient *)sharedVTClient;" to avoid Apple's newly-introduced static analysis flag.
* Fix namespacing compilation error with TTTAttributedLabel.

## 2.1.0

* Library is renamed to "braintree_ios".
* iOS 7 Support
* New framework requirement: Please add AdSupport.framework, CoreTelephony.framework and CoreText.framework to "Link Binary with Libraries" under "Build Phases".
* New VTClient initializers that include "customerEmail" parameter, please see VTClient.h

## 2.0.3

* Centers modals to fit different screen sizes.
* Sets VTCheckbox height dynamically based on locale. (default English height is 46px)

## 2.0.2

* Fixes bug where some users could not enter Maestro or Union Pay cards of variable length
* Fixes crash where non-ARC users could see a crash when using BTPaymentCardUtils
* Resolves UI discrepancy where some cards could be displayed on the same session after the user logs out
* Smooths modal entry and dismissal transitions

## 2.0.1

* Add to CocoaPods

## 2.0.0

* Adds support for Venmo Touch.
* Library is renamed to "braintree-ios".

## 1.1.0

* Library now uses ARC.

## 1.0.1

* Bugfix for encrypted string format.

## 1.0.0

* Initial release.
