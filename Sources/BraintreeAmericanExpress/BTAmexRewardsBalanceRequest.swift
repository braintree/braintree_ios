import Foundation

/// The GET parameters for `v1/payment_methods/amex_rewards_balance`
struct BTAmexRewardsBalanceRequest: Encodable {
    
    private let currencyIsoCode: String
    private let paymentMethodNonce: String
    
    init(currencyIsoCode: String, paymentMethodNonce: String) {
        self.currencyIsoCode = currencyIsoCode
        self.paymentMethodNonce = paymentMethodNonce
    }
}
