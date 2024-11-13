/// The POST body for `v1/payment_methods/venmo_accounts`
struct VenmoAccountsPOSTBody: Encodable {
        
    private let venmoAccount: VenmoAccount
    
    struct VenmoAccount: Encodable {
        
        let nonce: String
    }

    init(nonce: String) {
        self.venmoAccount = VenmoAccount(nonce: nonce)
    }
}
