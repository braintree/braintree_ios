import Foundation

/// The POST body for `v1/payment_methods/venmo_accounts`
struct BTVenmoPOSTBody: Encodable {

    var venmoAccountNonce: Nonce

    init(nonce: String) {
        self.venmoAccountNonce = Nonce(nonce: nonce)
    }

    struct Nonce: Encodable {

        var nonce: String
    }
}
