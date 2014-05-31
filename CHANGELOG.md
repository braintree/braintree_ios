# Braintree iOS SDK Release Notes

## 3.0.0-rc3

* Fix crashes when adding PayPal an additional payment method, when displaying PayPal as a payment method, and in offline mode
* Add `dropInViewControllerWillComplete` delegate method.
* Add transitions, activity indicators, and streamline some parts of UI.
# Simplify implementation of `BTPayPalControl`.
* :rotating_light: Remove `BTDropinViewController shouldDisplayPaymentMethodsOnFile` property.

## 3.0.0-rc2

* :rotating_light: Breaking API Changes :rotating_light:
    * Reduce BTPayPalControl API
    * Rename a number of classes, methods, and files, e.g. `BTCard` -> `BTCardPaymentMethod`.

## 3.0.0-rc1

* First release candidate of the 3.0.0 version of the iOS SDK.
* Known issues:
    * Pre-release public APIs
    * SSL pinning not yet added
    * Incomplete / unpolished UI
        * Minor UX card validation issues in the card form
        * Drop-In UX flow issues and unaddressed edge cases
