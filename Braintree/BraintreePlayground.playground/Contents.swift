/*
# Braintree iOS
*/

import Braintree;

/*
This library enables you to accept mobile payments with Braintree

The primary function of this library is to collect sensitive payment data and securely tokenize them.

## Quick Start

To get started developing with Braintree, you first need to sign up for a sandbox account.

When you log in for the first time, you will receive a client key. This is used to initialize the SDK.

In this example, we will present drop-in checkout, the easiest way to add payments to your app:
*/
let checkoutRequest = BTCheckoutRequest()

/*
## Development Notes

### Organization

The Public API headers are located at the top level in the Braintree directory.

Meanwhile, the internal headers are located under sub-folders.


### Platform Support

This codebase is officially developed in the latest dev tool chain, based on Xcode 7/iOS 9. Recent older versions—e.g. Xcode 6.3—are also supported on a best-effort basis.

### Targeting Swift

This codebase is written in Objective-C in order to make it simpler to integrate in iOS 7 apps.

Nonetheless, we target Swift 2 as our first class integration as much as possible. Code examples, API design work and documentation are conducted using Swift.
*/
