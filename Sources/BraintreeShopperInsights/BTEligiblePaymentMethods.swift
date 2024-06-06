#if canImport(BraintreeCore)
import BraintreeCore
#endif

struct BTEligiblePaymentMethods {
    var payPal: BTEligiblePaymentMethodDetails?
    var venmo: BTEligiblePaymentMethodDetails?
    
    init(json: BTJSON?) {
        if let eligibleMethodsJSON = json?["eligible_methods"] {
            self.payPal = BTEligiblePaymentMethodDetails(json: eligibleMethodsJSON["paypal"])
            self.venmo = BTEligiblePaymentMethodDetails(json: eligibleMethodsJSON["venmo"])
        }
    }
}

struct BTEligiblePaymentMethodDetails {
    let canBeVaulted: Bool
    let eligibleInPayPalNetwork: Bool
    let recommended: Bool
    let recommendedPriority: Int
    
    init(json: BTJSON) {
        self.canBeVaulted = json["can_be_vaulted"].asBool() ?? false
        self.eligibleInPayPalNetwork = json["eligible_in_paypal_network"].asBool() ?? false
        self.recommended = json["recommended"].asBool() ?? false
        self.recommendedPriority = json["recommended_priority"].asIntegerOrZero()
    }
}
