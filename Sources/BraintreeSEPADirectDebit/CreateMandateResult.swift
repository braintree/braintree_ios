import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The result returned from the SEPADirectDebitAPI.createMandate API call. This result is used to display the mandate to the customer.
struct CreateMandateResult {

    /// Defaulting the approval URL to the string "null" if the API returns nil for this field because the mandate has already been approved.
    /// Swift automatically converts the string "null" to nil, so we want to convert it back to indicate that the mandate was already approved.
    /// This also allows us to still handle an actually nil approval URL if needed vs treating it like an already approved mandate.
    static let mandateAlreadyApprovedURLString: String = "null"
    
    /// The approval URL used to present the mandate to the customer.
    let approvalURL: String

    /// The last four digits of the IBAN.
    let ibanLastFour: String?

    /// The customer ID of the user.
    let customerID: String?

    /// The bank reference token that ties the IBAN to a specific bank.
    let bankReferenceToken: String?

    /// The `BTSEPADirectDebitMandateType` of either `.recurring` or `.oneOff`
    let mandateType: String?
    
    init(json: BTJSON) {
        let sepaDebitAccount = json["message"]["body"]["sepaDebitAccount"]
        self.approvalURL = sepaDebitAccount["approvalUrl"].asString() ?? CreateMandateResult.mandateAlreadyApprovedURLString
        self.ibanLastFour = sepaDebitAccount["last4"].asString()
        self.customerID = sepaDebitAccount["merchantOrPartnerCustomerId"].asString()
        self.bankReferenceToken = sepaDebitAccount["bankReferenceToken"].asString()
        self.mandateType = sepaDebitAccount["mandateType"].asString()
    }
}
