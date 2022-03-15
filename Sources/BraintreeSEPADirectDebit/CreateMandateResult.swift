import Foundation

// TODO: this will need to conform to Decodable
struct CreateMandateResult {
    
    private enum CodingKeys: String, CodingKey {
        case approvalURL = "approvalUrl"
        case ibanLastFour = "ibanLastChars"
        case customerID = "customerId"
        case bankReferenceToken
        case mandateType
    }
    
    private let approvalURL: String
    private let ibanLastFour: String
    private let customerID: String
    private let bankReferenceToken: String
    private let mandateType: BTSEPADirectDebitMandateType
    
    init(
        approvalURL: String,
        ibanLastFour: String,
        customerID: String,
        bankReferenceToken: String,
        mandateType: BTSEPADirectDebitMandateType
    ) {
        self.approvalURL = approvalURL
        self.ibanLastFour = ibanLastFour
        self.customerID = customerID
        self.bankReferenceToken = bankReferenceToken
        self.mandateType = mandateType
    }
}
