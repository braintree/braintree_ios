# Braintree API iOS Design Thoughts

## Goal

Create a native Braintree Client API library.

## Mentality and design principles

* A RESTful interface is predictable and extendable.
* External testability and understandability.
* Friendly to front-end developers without an immediately available server stack.
* Three principle users:
  * Internal developers,
  * New merchant developers,
  * Existing (upgrading) merchant developers.
* Minimize assumptions about library's environment and avoid tight coupling to the products that could rely on it.

## Compatibility

To start with...

* iOS 7+ (armv7, armv7s, arm64)
* ARC Only

## Testing

* Internally, we have two layers of tests:
  * `Braintree-API-Specs`: Unit tests, no network access, may make assumptions about HTTP responses
  * `Braintree-API-Integration-Specs`: Integration tests against a real Gateway.
* Externally, we have a public test suite:
  * Utilizes the offline mock client.
  * Runs standalone with no external or network dependencies.
  * Easy for a developer with little to no context to run and read.
  * Should be thought of as a literate feature suite.
  * Runs in Travis-CI.

## Class hierarchy and layers of responsibility

The library is broken up into a number of layers, ranging from front-facing API to raw HTTP networking:

### Model

* `BTClient` - Provides public facing interface to client api for users of library. Client API API of sorts.
  * Translates HTTP bodies/status into domain objects.
  * API end-point names
  * User-Agent and default headers
  * Authentication

### Domain Resources

* `BTPaymentMethod`, `BTCardPaymentMethod` and friends - Type safe representations of Braintree resources.

### Service

* `BTHTTP` - HTTP in Objective C (Totally agnostic to CAPI.)
  * Relies on NSURLSession
  * SSL certificate pinning

## Error handling.
Externally, we represent errors with `NSError`s. Our various error codes refer to implications for implementors:
  - BTMerchantIntegrationError - Errors that are recoverable by fixing the integration, either on the server or in the iOS code.
  - BTCustomerInput - Expected errors that arise due to user input and interactions.
  - BTServerError - Unexpected errors that arise due to Braintree server-side issues.
