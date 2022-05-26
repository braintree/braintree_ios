# Braintree iOS v6 Migration Guide

See the [CHANGELOG](/CHANGELOG.md) for a complete list of changes. This migration guide outlines the basics for updating your client integration from v5 to v6.

_Documentation for v6 will be published to https://developer.paypal.com/braintree/docs once it is available for general release._

## Table of Contents

1. [Supported Versions](#supported-versions)
2. [Carthage](#carthage)
3. [Braintree Core](#braintree-core)
4. [Venmo](#venmo)
5. [PayPal](#paypal)

## Supported Versions

v6 supports a minimum deployment target of iOS 13+. It requires the use of Xcode 13+. If your application contains Objective-C code, the `Enable Modules` build setting must be set to `YES`.

## Carthage

v6 requires Carthage v0.38.0+, which adds support for xcframework binary dependencies.

```
carthage update --use-xcframeworks
```

## Braintree Core
`BTAppContextSwitchDriver` has been renamed to `BTAppContextSwitchClient`

`BTViewControllerPresentingDelegate` protocol functions `paymentDriver` are renamed to `paymentClient` now takes in the `client` parameter instead of `driver`:
```
public func paymentClient(_ client: Any, requestsDismissalOf viewController: UIViewController) {
    // implementation here
}

public func paymentClient(_ client: Any, requestsPresentationOf viewController: UIViewController) {
    // implementation here
}
```

## Venmo
`BTVenmoDriver` has been renamed to `BTVenmoClient`

`BTVenmoRequest` must now be initialized with a `paymentMethodUsage`. 

The possible values for `BTVenmoPaymentMethodUsage` include:
* `.multiUse` - the Venmo payment will be authorized for future payments and can be vaulted.
* `.singleUse` - the Venmo payment will be authorized for a one-time payment and cannot be vaulted.

```
let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse)
venmoRequest.profileID = "my-profile-id"
venmoRequest.vault = true

venmoClient.tokenizeVenmoAccount(with: venmoRequest) { (venmoAccountNonce, error) -> Void in
  if (error != nil) {
    // handle error
  }

  // transact with nonce on server
}
```

## PayPal
`BTPayPalDriver` has been renamed to `BTPayPalClient`
