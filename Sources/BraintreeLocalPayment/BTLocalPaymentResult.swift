import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

@objcMembers public class BTLocalPaymentResult: NSObject {
    
    /// The billing address.
    public let billingAddress: BTPostalAddress?
    
    /// Client Metadata ID associated with this transaction.
    public let clientMetadataID: String?
    
    /// Payer's email address.
    public let email: String?
    
    /// Payer's first name.
    public let firstName: String?
    
    /// Payer's last name.
    public let lastName: String?
    
    /// The one-time use payment method nonce.
    public let nonce: String
    
    /// Payer ID associated with this transaction.
    public let payerID: String?
    
    /// Payer's phone number.
    public let phone: String?
    
    /// The shipping address.
    public let shippingAddress: BTPostalAddress?
    
    /// The type of the tokenized payment.
    public let type: String?
    
    /// :nodoc:
    @_documentation(visibility: private)
    init?(json: BTJSON) {
        let paypalAccount = json["paypalAccounts"][0]
        
        guard let nonce = paypalAccount["nonce"].asString() else { return nil }
        self.nonce = nonce
        
        type = paypalAccount["type"].asString()
        
        let details = paypalAccount["details"]
        clientMetadataID = details["correlationId"].asString()
        
        if details["payerInfo"]["email"].isString {
            email = details["payerInfo"]["email"].asString()
        } else {
            email = details["email"].asString()
        }
        
        firstName = details["payerInfo"]["firstName"].asString()
        lastName = details["payerInfo"]["lastName"].asString()
        phone = details["payerInfo"]["phone"].asString()
        payerID = details["payerInfo"]["payerId"].asString()
        
        if let payerShippingAddress = details["payerInfo"]["shippingAddress"].asAddress() {
            shippingAddress = payerShippingAddress
        } else {
            shippingAddress = details["payerInfo"]["accountAddress"].asAddress()
        }
        
        billingAddress = details["payerInfo"]["shippingAddress"].asAddress()
    }
}
