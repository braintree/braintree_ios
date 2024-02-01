#if canImport(BraintreeCore)
import BraintreeCore
#endif

struct BTEligibilePaymentMethods {
    var paypal: BTEligiblePaymentMethodDetails?
    var venmo: BTEligiblePaymentMethodDetails?
    
    init(json: BTJSON?) {
        if let eligibileMethodsJSON = json?["eligible_methods"] {
            self.paypal = BTEligiblePaymentMethodDetails(json: eligibileMethodsJSON["paypal"])
            self.venmo = BTEligiblePaymentMethodDetails(json: eligibileMethodsJSON["venmo"])
        }
    }
}

struct BTEligiblePaymentMethodDetails {
    let canBeVaulted: Bool
    let eligibleInPaypalNetwork: Bool
    let recommended: Bool
    let recommendedPriority: Int
    
    init(json: BTJSON) {
        self.canBeVaulted = json["can_be_vaulted"].asBool() ?? false
        self.eligibleInPaypalNetwork = json["eligible_in_paypal_network"].asBool() ?? false
        self.recommended = json["recommended"].asBool() ?? false
        self.recommendedPriority = json["recommended_priority"].asIntegerOrZero()
    }
}
