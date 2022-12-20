import Foundation
import BraintreeCore

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
    
    ///  Used to initialize a `BTPayPalAccountNonce` with parameters.
    public init(
        nonce: String,
        email: String,
        firstName: String,
        lastName: String,
        phone: String,
        billingAddress: BTPostalAddress,
        shippingAddress: BTPostalAddress,
        clientMetadataID: String,
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
        
        let billingAddress = payerInfo["billingAddress"]
        let shippingAddress = payerInfo["shippingAddress"]
        let creditFinancing = details["creditFinancingOffered"]
        
        self.email = details["email"].asString()
        self.firstName = payerInfo["firstName"].asString()
        self.lastName = payerInfo["lastName"].asString()
        self.phone = payerInfo["phone"].asString()
        self.billingAddress = BTPayPalAccountNonce.address(from: billingAddress)
        self.shippingAddress = BTPayPalAccountNonce.address(from: shippingAddress)
        self.clientMetadataID = payerInfo["correlationId"].asString()
        self.payerID = payerInfo["payerId"].asString()
        self.creditFinancing = BTPayPalAccountNonce.creditFinancing(from: creditFinancing)
        super.init(nonce: nonce, type: "PayPal", isDefault: json["default"].isTrue)
    }
    
    private static func address(from json: BTJSON) -> BTPostalAddress? {
        guard json.isObject else { return nil }
        
        let address = BTPostalAddress()
        address.recipientName = json["recipientName"].asString() // Likely to be nil
        address.streetAddress = json["street1"].asString()
        address.locality = json["city"].asString()
        address.region = json["state"].asString()
        address.postalCode = json["postalCode"].asString()
        address.countryCodeAlpha2 = json["country"].asString()
        
        return address
    }
    
    // TODO: Refactor into BTJSON + PayPal
    private static func creditFinancing(from json: BTJSON) -> BTPayPalCreditFinancing? {
        guard json.isObject else { return nil }
        
        let isCardAmountImmutable = json["cardAmountImmutable"].isTrue
        let monthlyPayment = creditFinancingAmount(from: json["monthlyPayment"])
        let payerAcceptance = json["payerAcceptance"].isTrue
        let term = json["term"].asIntegerOrZero()
        let totalCost = creditFinancingAmount(from: json["totalCost"])
        let totalInterest = creditFinancingAmount(from: json["totalInterest"])
        
        return BTPayPalCreditFinancing(
            cardAmountImmutable: isCardAmountImmutable,
            monthlyPayment: monthlyPayment,
            payerAcceptance: payerAcceptance,
            term: term,
            totalCost: totalCost,
            totalInterest: totalInterest
        )
    }
    
    // TODO: Refactor into BTJSON + PayPal
    private static func creditFinancingAmount(from json: BTJSON) -> BTPayPalCreditFinancingAmount? {
        guard json.isObject,
              let currency = json["currency"].asString(),
              let value = json["value"].asString() else {
            return nil
        }
        
        return BTPayPalCreditFinancingAmount(currency: currency, value: value)
    }
}
