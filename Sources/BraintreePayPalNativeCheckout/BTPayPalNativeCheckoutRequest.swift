import Foundation

@objcMembers
public class BTPayPalNativeCheckoutRequest: NSObject {
    public let returnURL: String
    public let amount: String
    
    public init(returnURL: String, amount: String) {
        self.returnURL = returnURL
        self.amount = amount
    }
}
