# Braintree iOS SDK Release Notes

## 3.0.0-rc3

* Fix crash when adding PayPal an additional payment method.

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
