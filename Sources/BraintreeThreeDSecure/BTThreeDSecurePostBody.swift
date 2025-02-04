import Foundation

// MARK: - BTThreeDSecurePostBody
struct BTThreeDSecurePostBody: Encodable {
    let requestedExemptionType, requestedThreeDSecureVersion, accountType: String?
    let additionalInfo: AdditionalInfo
    let dfReferenceID: String?
    let dataOnlyRequested, challengeRequested: Bool
    let amount: String
//    let customer: Customer
    let exemptionRequested: Bool
    
//    let customFields
    
    init(request: BTThreeDSecureRequest) {
        self.requestedExemptionType = request.requestedExemptionType.stringValue
        self.requestedThreeDSecureVersion = "2"
        self.accountType = request.accountType.stringValue
//        self.additionalInfo = request.additionalInformation
        self.dfReferenceID = request.dfReferenceID
        self.dataOnlyRequested = request.dataOnlyRequested
        self.challengeRequested = request.challengeRequested
        self.amount = request.amount
        self.exemptionRequested = request.exemptionRequested
        
//        var requestParameters: [String: Any?] = [
//            "amount": request.amount,
//            "customer": customer,
//            "requestedThreeDSecureVersion": "2",
//            "dfReferenceId": request.dfReferenceID,
//            "accountType": request.accountType.stringValue,
//            "challengeRequested": request.challengeRequested,
//            "exemptionRequested": request.exemptionRequested,
//            "requestedExemptionType": request.requestedExemptionType.stringValue,
//            "dataOnlyRequested": request.dataOnlyRequested
//        ]

//        if let customFields = request.customFields {
//            requestParameters["customFields"] = customFields
//        }

//        if request.cardAddChallengeRequested {
//            requestParameters["cardAdd"] = true
//        }

        self.additionalInfo = AdditionalInfo(request: request)

//        additionalInformation = additionalInformation.merging(request.billingAddress?.asParameters(withPrefix: "billing") ?? [:]) { $1 }
//        additionalInformation = additionalInformation.merging(request.additionalInformation?.asParameters() ?? [:]) { $1 }

//        requestParameters["additionalInfo"] = additionalInformation
//        requestParameters = requestParameters.compactMapValues { $0 }
    }

    enum CodingKeys: String, CodingKey {
        case requestedExemptionType, requestedThreeDSecureVersion, accountType, additionalInfo
        case dfReferenceID = "dfReferenceId"
        case dataOnlyRequested, challengeRequested, amount, exemptionRequested
//        case customer
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
