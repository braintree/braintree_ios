import Foundation

// MARK: - Welcome
struct BTThreeDSecurePostBody: Encodable {
    let requestedExemptionType, requestedThreeDSecureVersion, accountType: String
    let additionalInfo: AdditionalInfo
    let dfReferenceID: String
    let dataOnlyRequested, challengeRequested: Bool
    let amount: String
    let customer: Customer
    let exemptionRequested: Bool

    enum CodingKeys: String, CodingKey {
        case requestedExemptionType, requestedThreeDSecureVersion, accountType, additionalInfo
        case dfReferenceID = "dfReferenceId"
        case dataOnlyRequested, challengeRequested, amount, customer, exemptionRequested
    }
}

// MARK: - AdditionalInfo
struct AdditionalInfo: Codable {
    let billingState: String
    let mobilePhoneNumber: String?
    let billingLine2, billingCity, billingGivenName, email: String
    let billingPostalCode, billingSurname, billingCountryCode, shippingMethod: String
    let billingLine1, billingPhoneNumber: String
}

// MARK: - Customer
struct Customer: Codable {
}
