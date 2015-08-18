# Braintree Data - Advanced Fraud via Kount

## Overview

`Braintree/Data` is our advanced fraud solution that is powered by `BTData`, PayPal and Kount. This system enables you to collect device data and correlate it with a session identifier on your server.

By default, we suggest you utilize the default merchant credentials embedded in `[[BTData alloc] initWithClient:client environment:BTDataEnvironmentProduction]`.

For direct Fraud Integration, please see [our documentation](https://developers.braintreepayments.com/ios/guides/fraud-tools#direct-fraud-tool-integration) or [contact our accounts team](accounts@braintreepayments.com).

**Note:** Use of `Braintree/Data` and `BTData` is optional. 

**Note:** `Braintree/Data` no longer contains references to Apple's IDFA.

### Usage

First, add `pod "Braintree/Data"` to your `Podfile`.

#### Default

Please follow these steps to integrate Braintree Data in your app:

1. Initialize `BTData` using the convenience constructor `initWithClient:environment:` in your AppDelegate.
    * See [our documentation](https://developers.braintreepayments.com/ios/start/hello-client) for instructions on initializing BTClient
    * Be sure to pass the current Braintree environment, and remember to change this value before shipping to the app store.

2. Optionally, set a delegate to receive lifecycle notifications.

2. Retain your `BTData` instance for your entire application lifecycle.

3. Invoke `collect` (to generate a session id) or `collect:` (to provide a session id) as often as is needed. This will perform a device fingerprint and asynchronously send this data to Kount. This operation is relatively expensive. We recommend that you do this seldom and avoid interrupting your app startup with this call.

#### Direct Fraud Tool Integration

Direct fraud tool integration is similar to default.

After initializing `BTData` following the instructions above, invoke `setCollectorUrl:` and/or `setKountMerchantId:` with the appropriate data.

Please contact our account management team for more information.

### Server-Side Integration

When processing a user's purchase, pass the session id (returned by `collect` or passed into `collect:`) along with the other transaction details to your server. 

On your *server* include the session id in your request to Braintree.

For example in Ruby:

```ruby
result = Braintree::Transaction.sale(
  :amount => "100.00",
  :credit_card => {
    :number => params["credit_card_number"],
    :expiration_date => params["credit_card_expiration_date"],
    :cvv => params["credit_card_cvv"]
  },
  :device_session_id => params["BRAINTREE_DATA_SESSION_ID"]
)
```
