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
    
    /// Used to initialize a `BTPayPalAccountNonce` with parameters.
    public init(
        nonce: String,
        email: String?,
        firstName: String?,
        lastName: String?,
        phone: String?,
        billingAddress: BTPostalAddress?,
        shippingAddress: BTPostalAddress?,
        clientMetadataID: String?,
        payerID: String?,
        isDefault: Bool,
        creditFinancing: BTPayPalCreditFinancing?
    ) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.billingAddress = billingAddress
        self.shippingAddress = shippingAddress
        self.clientMetadataID = clientMetadataID
        self.payerID = payerID
        self.creditFinancing = creditFinancing
        super.init(nonce: nonce, type: "PayPal", isDefault: isDefault)
    }
    
    init?(json: BTJSON) {
        guard let nonce = json["nonce"].asString() else { return nil }
        
        let details = json["details"]
        let payerInfo = details["payerInfo"]

        // TODO: add a comment on why we did this
        self.email = payerInfo["email"].asString() ??
                     details["email"].asString()
        
        self.firstName = payerInfo["firstName"].asString()
        self.lastName = payerInfo["lastName"].asString()
        self.phone = payerInfo["phone"].asString()
        self.billingAddress = payerInfo["billingAddress"].asAddress()
        self.shippingAddress = payerInfo["shippingAddress"].asAddress()
        self.clientMetadataID = payerInfo["correlationId"].asString()
        self.payerID = payerInfo["payerId"].asString()
        self.creditFinancing = details["creditFinancingOffered"].asCreditFinancing()
        super.init(nonce: nonce, type: "PayPal", isDefault: json["default"].isTrue)
    }
}
