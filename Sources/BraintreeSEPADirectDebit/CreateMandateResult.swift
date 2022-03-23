import Foundation

/// The result returned from the SEPADirectDebitAPI.createMandate API call. This result is used to display the mandate to the customer.
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
    
    /// The approval URL used to present the mandate to the customer.
    let approvalURL: String

    /// The last four digits of the IBAN.
    let ibanLastFour: String

    /// The customer ID of the user.
    let customerID: String

    /// The bank reference token that ties the IBAN to a specific bank.
    let bankReferenceToken: String

    /// The `BTSEPADirectDebitMandateType` of either `.recurring` or `.oneOff`
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
