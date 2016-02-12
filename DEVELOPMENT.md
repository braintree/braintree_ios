# Braintree-iOS Development Notes

This document outlines development practices that we follow internally while developing this SDK.

## Development Merchant Server

The included demo app utilizes a test merchant server hosted on heroku ([https://braintree-sample-merchant.herokuapp.com](https://braintree-sample-merchant.herokuapp.com)). It
produces client tokens that point to Braintree's Sandbox Environment.

## Tests

There are a number of test targets for each section of the project. You can run all tests on the command line with `bundle && rake spec:all`. 

It's a good idea to run `rake`, which runs all unit tests, before committing.

The integration tests require a full Braintree stack running on localhost.

## Architecture

There are several components that comprise this SDK:

* `Braintree` is the top-level entry point to the SDK. You are here.
* [Braintree-Drop-In](Braintree/Drop-In) composes API with Credit Card and PayPal UI to create a "three liner" payment form. (See also BTDropInViewControler.h)
* [Braintree-Payments-UI](Braintree/UI) is a set of reusable UI components related to payments.
* [Braintree-PayPal](Braintree/PayPal) provides a PayPal button and view controller. (See also `BTPayPalButton`.)
* [Braintree-API](Braintree/api) provides the networking and communications layer. (See also `BTClient`.)
  * This component is intended to avoid any dependency on `UIKit` and could easily be ported to OS X.

The individual components may be of interest for advanced integrations and are each available as subspecs.

## Environmental Assumptions

* Xcode 6 and iOS 8 SDK
* iOS 7.0 target deployment
* iPhone and iPad of all sizes and resolutions and the simulator
* CocoaPods
* ARC
* `BT` namespace is reserved for Braintree
* Host app does not integrate the [PayPal iOS SDK](https://github.com/paypal/paypal-ios-sdk)
* Host app does not integrate with the Kount SDK
* Host app does not integrate with [card.io](https://www.card.io/)
* Host app has a secure, authenticated server with a [Braintree server-side integration](https://developers.braintreepayments.com/ios/start/hello-server)

## Committing

* Commits should be small but atomic. Tests should always be passing; the product should always function appropriately.
* Commit messages should be concise and descriptive.
* Commit messages reference the trello board by ID or URL. (Sorry, these are not externally viewable.)

## Deployment and Code Organization

* Code on master is assumed to be in a relatively good state at all times
  * Tests should be passing, all demo apps should run
  * Functionality and user experience should be cohesive
  * Dead code should be kept to a minimum
* Versioned deployments are tagged with their version numbers
  * Version numbers conform to [SEMVER](http://semver.org)
  * These versions are more heavily tested
  * We will provide support for these versions and commit to maintaining backwards compatibility on our servers
* Pull requests are welcome
  * Feel free to create an issue on Github before investing development time
* As needed, the Braintree team may develop features privately
  * If our internal and public branches get out of sync, we will reconcile this with merges (as opposed to rebasing)
  * In general, we will try to develop in the open as much as possible

## Releasing

The release process is self-documented in a number of rake tasks.

To release a new version of the SDK publicly, invoke an incantation that looks like this:

```sh
rake release && rake publish && rake distribute
```
