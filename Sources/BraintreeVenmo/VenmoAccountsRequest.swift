/// The POST body for `v1/payment_methods/venmo_accounts`
struct VenmoAccountsRequest: Encodable {
        
    private let venmoAccount: VenmoAccountNonce
    
    struct VenmoAccountNonce: Encodable {
        
        let nonce: String
    }

    init(nonce: String) {
        self.venmoAccount = VenmoAccountNonce(nonce: nonce)
    }
}
