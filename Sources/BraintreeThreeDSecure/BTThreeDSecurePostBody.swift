import Foundation

// MARK: - BTThreeDSecurePostBody
struct BTThreeDSecurePostBody: Encodable {
    let accountType: String?
    let additionalInfo: AdditionalInfo
    let amount: String
    let cardAdd: Bool?
    let challengeRequested: Bool
    let customFields: [String: String]?
    let customer: Customer
    let dataOnlyRequested: Bool
    let dfReferenceID: String?
    let exemptionRequested: Bool
    let requestedExemptionType: String?
    let requestedThreeDSecureVersion: String?

    init(request: BTThreeDSecureRequest) {
        self.requestedExemptionType = request.requestedExemptionType.stringValue
        self.requestedThreeDSecureVersion = "2"
        self.accountType = request.accountType.stringValue
        self.dfReferenceID = request.dfReferenceID
        self.dataOnlyRequested = request.dataOnlyRequested
        self.challengeRequested = request.challengeRequested
        self.amount = request.amount
        self.exemptionRequested = request.exemptionRequested

        if let customFields = request.customFields {
            self.customFields = customFields
        } else {
            self.customFields = nil
        }

        if request.cardAddChallengeRequested {
            cardAdd = true
        } else {
            cardAdd = nil
        }

        self.additionalInfo = AdditionalInfo(request: request)
        self.customer = Customer()
    }

    enum CodingKeys: String, CodingKey {
        case requestedExemptionType, requestedThreeDSecureVersion, accountType, additionalInfo
        case dfReferenceID = "dfReferenceId"
        case dataOnlyRequested, challengeRequested, amount, exemptionRequested
        case customer
    }
}

// MARK: - AdditionalInfo
struct AdditionalInfo: Codable {
    let billingCity: String?
    let billingCountryCode: String?
    let billingGivenName: String?
    let billingLine1: String?
    let billingLine2: String?
    let billingPhoneNumber: String?
    let billingPostalCode: String?
    let billingState: String?
    let billingSurname: String?
    let email: String?
    let mobilePhoneNumber: String?
    let shippingMethod: String?
    
    init(request: BTThreeDSecureRequest) {
        self.billingCity = request.billingAddress?.locality
        self.billingCountryCode = request.billingAddress?.countryCodeAlpha2
        self.billingGivenName = request.billingAddress?.givenName
        self.billingLine1 = request.billingAddress?.streetAddress
        self.billingLine2 = request.billingAddress?.extendedAddress
        self.billingPhoneNumber = request.billingAddress?.phoneNumber
        self.billingPostalCode = request.billingAddress?.postalCode
        self.billingState = request.billingAddress?.region
        self.billingSurname = request.billingAddress?.surname
        self.email = request.email
        self.mobilePhoneNumber = request.mobilePhoneNumber
        self.shippingMethod = request.shippingMethod.stringValue
    }
}

// MARK: - Customer
struct Customer: Codable {
}
