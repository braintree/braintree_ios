# Braintree-iOS Development Notes

## Development Merchant Server

The included demo app utilizes a test merchant server hosted on heroku (`[https://braintree-sample-merchant.herokuapp.com](https://braintree-sample-merchant.herokuapp.com)`). It
produces client tokens that point to Braintree's Sandbox Environment.

This merchant server is also provided as a gem called
[taproot](https://github.com/benmills/taproot/). If you'd like, you can run
taproot locally and hit a development Gateway running on `localhost`:

```
cd Example
bundle
taprootd

# In a new shell
curl localhost:3132
curl localhost:3132/client_token
```

You can now change the merchant server base URL specified in `BraintreeDemoTransactionService`.

## Tests

There are a number of test targets for each section of the project. You can run all tests on the command line with `bundle && rake spec:all`. 

It's a good idea to run `rake`, which runs all unit tests, before committing.

## Deployment and Code Organization

* Code on master is assumed to be in a relatively good state at all times
  * Tests should be passing, all demo apps should run
  * Functionality and user experience should be cohesive
  * Dead code should be kept to a minimum
* Versioned deployments are tagged with their version numbers
  * Version numbers conform to [SEMVER](https://semver.org)
  * These versions are more heavily tested
  * We will provide support for these versions and commit to maintaining backwards compatibility on our servers
* Pull requests are welcome
  * Feel free to create an issue on Github before investing development time
* As needed, the Braintree team may develop features privately
  * If our internal and public branches get out of sync, we will reconcile this with merges (as opposed to rebasing)
  * In general, we will try to develop in the open as much as possible
