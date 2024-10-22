# Braintree iOS v7 Migration Guide

See the [CHANGELOG](/CHANGELOG.md) for a complete list of changes. This migration guide outlines the basics for updating your client integration from v6 to v7.

_Documentation for v7 will be published to https://developer.paypal.com/braintree/docs once it is available for general release._

## Table of Contents

1. [Supported Versions](#supported-versions)
1. [Card](#card)

## Supported Versions

v7 bumps to a minimum deployment target of iOS 16+.

## Card
v7 updates `BTCard` to require setting all properties through the initializer, removing support for dot syntax. To construct a `BTCard`, pass the properties directly in the initializer:

```
let card = BTCard(
    number = "4111111111111111"
    expirationMonth = "12"
    expirationYear = "2025"
    cvv = "123"
)
```
