# Braintree iOS v7 Migration Guide

See the [CHANGELOG](/CHANGELOG.md) for a complete list of changes. This migration guide outlines the basics for updating your client integration from v6 to v7.

_Documentation for v7 will be published to https://developer.paypal.com/braintree/docs once it is available for general release._

## Table of Contents

1. [Supported Versions](#supported-versions)
1. [Venmo](#venmo)
1. [SEPA Direct Debit](#sepa-direct-debit)
1. [Local Payments](#local-payments)

## Supported Versions

v7 bumps to a minimum deployment target of iOS 16+.

## Venmo
All properties within `BTVenmoRequest` can only be accessed on the initializer vs via the dot syntax.

```
let venmoRequest = BTVenmoRequest(paymentMethodUsage: .multiUse, vault: true, fallbackToWeb: true)
```

## SEPA Direct Debit
All properties within `BTSEPADirectDebitRequest` can only be accessed on the initializer vs via the dot syntax.

## Local Payments
v7 updates `BTLocalPaymentRequest` to require setting all properties through the initializer, removing support for dot syntax. To construct a `BTLocalPaymentRequest`, pass the properties directly in the initializer.
