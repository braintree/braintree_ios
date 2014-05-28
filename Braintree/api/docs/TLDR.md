0. *Read* [README.md](../README.md).
1. *Generate* a client token on the server: `Braintree::ClientToken.generate`.
2. *Transmit* client token to client.
3. *Initialize* `BTClient`: `BTClient *myClient = [[BTClient alloc] initWithClientToken:TOKEN]`.
4. *Use* client methods, e.g. `[myClient saveCardWithNumber:...];`.
5. *Transmit* credit card nonce(s) to your server for `Braintree::Transaction.create`-ing.
5. *Profit* $$$.

![$$$](http://gifs.joelglovier.com/excited/dinosaur-hands.gif)
