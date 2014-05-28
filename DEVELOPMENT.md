# Braintree-iOS Development Notes

## Development Merchant Server

The included demo app utilizes a test merchant server hosted on heroku (`[http://taprooted.herokuapp.com](http://taprooted.herokuapp.com)`). It
produces client tokens that point to Braintree's QA Environment.

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
