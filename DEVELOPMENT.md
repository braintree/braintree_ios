# Braintree iOS Development Notes

This document outlines development practices that we follow while developing this SDK.

## Development Merchant Server

The included demo app utilizes a [sandbox sample merchant server](https://braintree-sample-merchant.herokuapp.com) hosted on Heroku.

## Tests

There are a number of test targets for each section of the project.

It's a good idea to run `rake`, which runs all unit tests, before committing.

Use the following commands to run tests:
* UI tests: `bundle && rake spec:ui`
* Unit tests: `bundle && rake spec:unit`
* Integration tests: `bundle && rake spec:api:integration`
* All tests: `bundle && rake spec:all`

## Importing Header Files

To maintain support for CocoaPods, Swift Package Manager, and Carthage, our Objective-C import statements need specific attention.

While SPM, Carthage, and manual integrations use the same import style (`#import <BraintreeCore/BraintreeCore.h>`), CocoaPods requires a different syntax (`#import <Braintree/BraintreeCore.h>`). This is because CocoaPods creates a single Braintree framework out of the subspecs the merchant includes, whereas SPM, Carthage, and manual integrations treat each module as a separate framework, i.e., BraintreeCore, BraintreeCard, etc.

Public headers for each module must live in the directory `Public/<MODULE_NAME>`. This allows SPM to use the same import syntax as Carthage (e.g., `<BraintreeCore/BraintreCore.h>`).

We use if-else preprocessor directives to satisfy each dependency manager. See the below example for importing a public header file.

```
#if __has_include(<Braintree/BraintreeCore.h>) // CocoaPods
#import <Braintree/BraintreeCore.h>
#else // SPM or Carthage
#import <BraintreeCore/BraintreeCore.h>
#endif
```

In general, we avoid importing internal headers from other modules, but occasionally it's necessary. See the below example for importing an internal header file from another module:
```
#if __has_include(<Braintree/BraintreeAmericanExpress.h>) // CocoaPods
#import <Braintree/BTAPIClient_Internal.h>

#elif SWIFT_PACKAGE // SPM
#import "../BraintreeCore/BTAPIClient_Internal.h"

#else // Carthage
#import <BraintreeCore/BTAPIClient_Internal.h>
#endif
```
