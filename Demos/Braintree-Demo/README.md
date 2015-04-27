# Braintree Demo

This is a universal iOS app that exercises just about every feature of Braintree iOS.

You can take a look at the classes under [Features](./Features) to get a sense of how this SDK can be used.

## Usage

This app allows you to switch between the different features, or sample integrations, that it showcases. Each integration starts with loading a client token from a sample merchant server. This happens automatically when you open the app. Once the client token is loaded, the current integration is shown.

You can switch between features using the `settings` menu. This app will remember which feature you last looked at; the in app settings are synchronized with the Apple Settings app.

You can reload the current integration by tapping on the the reload button on the upper left.

The current status is shown on the bottom toolbar. If you've created a payment method nonce, you tap on the status toolbar to create a transaction.

## Implementation

This code base has three primary sections:

*. **Demo Framework** - contains boiler plate code that facilitates switching between demo integrations.
*. **Merchant API Client** - cointains a API client that might be similar to one found in a real app; note that it consumes a _hypothetical merchant_ API, not Braintree's API.
*. **Features** - contains a number of Braintree iOS demo integrations

Each demo integration must provide a `BraintreeDemoBaseViewController` subclass. Most importantly, the demo  provides a `paymentButton`, which is presented to the user when the demo is selected.

To add a new demo, you will additionally need to register the demo in the [Settings bundle](./Demo Framework/Settings/Settings.bundle/Root.plist), identifying the view controller by class name.

The most common class of integration, which involves presenting the user with a single button—to trigger whatever type of payment experience you choose—can be powered by another base class, `BraintreeDemoPaymentButtonBaseViewController`.

Your demo view controllers may call their `progressBlock` or `completionBlock` in order to send the demo framework, and, in turn, the user, updates about the payment method creation lifecycle.

### Steps to Add a New Demo

1. Create a new `BraintreeDemoBaseViewController` subclass in a new directory under Features.
2. Utilize `self.briantree` to implement a Braintree integration, and call `completionBlock` upon successfully creating a payment method.
3. Register this class in the Settings bundle, by adding new items in the `Integration` multi value item, under `titles`, `shortTitles` and `values`.

💸👍🏻
