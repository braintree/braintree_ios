# Braintree iOS SDK Overview

Our iOS SDK contains a set of tools and UI components that make it easy to
accept credit card payments inside your app.  The `BTPaymentViewController` bundles
all of the individual tools together so you can add payments to your app with a
few lines of code. Alternatively, each individual component is available for
use in your app on your own.

# Requirements

The Braintree iOS SDK and Venmo Touch require iOS 5.0.0 or higher. Currently,
Venmo Touch is available for US customers only.

# Components

* `VenmoTouch.framework`: Venmo Touch allows users to save credit cards for easier repeat purchases *across* all the apps in the Braintree Network.  When a user adds a card inside one app, they can save their card with Venmo, so when they checkout inside another app, they can add the saved card with a single touch, instead of re-typing all of the card details.
* `BTPaymentViewController`: the fastest way to add payments to your app. Allows users to pay with Venmo Touch saved cards and also provides a native credit card entry form that performs Client Side Validation and Client Side Encryption.
* `BTPaymentFormView`: a native credit card entry form that performs Client Side Validation and Client Side Encryption.
* `BTEncryption`: Client Side Encryption tool that enables PCI Compliant transmission of sensitive card data

# Documentation

* <a href="https://touch.venmo.com/braintree-ios-tutorial">Add a credit card form and Venmo Touch to your app</a>
* <a href="https://touch.venmo.com/add-venmo-touch-tutorial">Adding Venmo Touch to an app that already accepts credit cards</a>
* <a href="https://touch.venmo.com/server-side-changes">Venmo Touch Server Integration Tutorial</a>
* <a href="https://touch.venmo.com/integration-testing">Testing Venmo Touch</a>
* <a href="https://touch.venmo.com/client-side-validation-tutorial">`BTPaymentForm` Client Side Validation</a>
* <a href="https://touch.venmo.com/client-side-encryption-tutorial">`BTEncryption` Client Side Encryption</a>

For detailed class and method reference see the Venmo Touch header files and Braintree header/implementation files, all of which are extensively commented.
