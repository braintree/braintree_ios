import Foundation

struct CreateMandateResult: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case message
        case body
        case sepaDebitAccount
        case approvalURL = "approvalUrl"
        case ibanLastFour = "ibanLastChars"
        case customerID = "customerId"
        case bankReferenceToken
        case mandateType
    }
    
    let approvalURL: String
    let ibanLastFour: String
    let customerID: String
    let bankReferenceToken: String
    let mandateType: String
    
    init(
        approvalURL: String,
        ibanLastFour: String,
        customerID: String,
        bankReferenceToken: String,
        mandateType: String
    ) {
        self.approvalURL = approvalURL
        self.ibanLastFour = ibanLastFour
        self.customerID = customerID
        self.bankReferenceToken = bankReferenceToken
        self.mandateType = mandateType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let messageContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .message)
        let bodyContainer = try messageContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .body)
        let sepaDebitContainer = try bodyContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .sepaDebitAccount)
        
        approvalURL = try sepaDebitContainer.decode(String.self, forKey: .approvalURL)
        ibanLastFour = try sepaDebitContainer.decode(String.self, forKey: .ibanLastFour)
        customerID = try sepaDebitContainer.decode(String.self, forKey: .customerID)
        bankReferenceToken = try sepaDebitContainer.decode(String.self, forKey: .bankReferenceToken)
        mandateType = try sepaDebitContainer.decode(String.self, forKey: .mandateType)
    }
}
