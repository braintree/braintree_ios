#if canImport(BraintreeCore)
import BraintreeCore
#endif

struct BTEligibilePaymentMethods {
    var paypal: BTEligiblePaymentMethodDetails?
    var venmo: BTEligiblePaymentMethodDetails?
    
    init(json: BTJSON?) {
        if let paypalJSON = json?["paypal"] {
            self.paypal = BTEligiblePaymentMethodDetails(json: paypalJSON)
        }
        
        if let venmoJSON = json?["venmo"] {
            self.venmo = BTEligiblePaymentMethodDetails(json: venmoJSON)
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
