import Foundation

/// The POST body for `v1/payment_methods/venmo_accounts`
struct VenmoPOSTBody: Encodable {

    var venmoAccount: Nonce

    init(nonce: String) {
        self.venmoAccount = Nonce(nonce: nonce)
    }

    struct Nonce: Encodable {

        var nonce: String
    }
}
