# Sample Merchant Server

The easiest way to get started the SDK without a server implementation is by using `[BTClient offlineTestClientTokenWithAdditionalParameters:nil]` from `#import <Braintree/BTClient+Offline.h>`. 

However, if you'd like to try things out with real network communication, you can use our sample merchant server, `taproot`.

Ideally, you should integrate against your own server implementation. Check out our [integration notes](https://github.com/braintree/client-sdk-docs/blob/master/SERVER_DOCS.md) for instructions.


## Getting started with `taproot`

```
cd braintree-ios/Sample\ Merchant\ Server
bundle
$EDITOR taproot.yml # Modify this file with your sandbox credentials.
taprootd
```

Now you'll be able to obtain a client token with `curl localhost:3132/client_token`. 

For a full listing of available endpoints, `curl localhost:3132`.
