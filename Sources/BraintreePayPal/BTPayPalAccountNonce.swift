import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Contains information about a PayPal payment method
@objcMembers public class BTPayPalAccountNonce: BTPaymentMethodNonce {
    
    /// Payer's email address.
    public let email: String?
    
    /// Payer's first name.
    public let firstName: String?
    
    /// Payer's last name.
    public let lastName: String?
    
    /// Payer's phone number.
    public let phone: String?
    
    /// The billing address.
    public let billingAddress: BTPostalAddress?
    
    /// The shipping address.
    public let shippingAddress: BTPostalAddress?
    
    /// Client metadata id associated with this transaction.
    public let clientMetadataID: String?
    
    /// Optional. Payer id associated with this transaction.
    /// Will be provided for Vault and Checkout.
    public let payerID: String?
    
    /// Optional. Credit financing details if the customer pays with PayPal Credit.
    /// Will be provided for Vault and Checkout.
    public let creditFinancing: BTPayPalCreditFinancing?
    
    init?(json: BTJSON) {
        guard let nonce = json["nonce"].asString() else { return nil }
        
        let details = json["details"]
        let payerInfo = details["payerInfo"]

        self.email = payerInfo["email"].asString() ?? details["email"].asString()
        self.firstName = payerInfo["firstName"].asString()
        self.lastName = payerInfo["lastName"].asString()
        self.phone = payerInfo["phone"].asString()
        self.billingAddress = payerInfo["billingAddress"].asAddress()
        self.shippingAddress = payerInfo["shippingAddress"].asAddress() ?? payerInfo["accountAddress"].asAddress()
        self.clientMetadataID = details["correlationId"].asString()
        self.payerID = payerInfo["payerId"].asString()
        self.creditFinancing = details["creditFinancingOffered"].asPayPalCreditFinancing()
        super.init(nonce: nonce, type: "PayPal", isDefault: json["default"].isTrue)
    }
}
