import Foundation

// MARK: - BTThreeDSecurePostBody
struct BTThreeDSecurePostBody: Encodable {
    let requestedExemptionType, requestedThreeDSecureVersion, accountType: String?
    let additionalInfo: AdditionalInfo
    let dfReferenceID: String?
    let dataOnlyRequested, challengeRequested: Bool
    let amount: String
    let customer: Customer
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

        var additionalInformation: [String: String?] = [
            "mobilePhoneNumber": request.mobilePhoneNumber,
            "email": request.email,
            "shippingMethod": request.shippingMethod.stringValue
        ]

        additionalInformation = additionalInformation.merging(request.billingAddress?.asParameters(withPrefix: "billing") ?? [:]) { $1 }
        additionalInformation = additionalInformation.merging(request.additionalInformation?.asParameters() ?? [:]) { $1 }

        requestParameters["additionalInfo"] = additionalInformation
        requestParameters = requestParameters.compactMapValues { $0 }
    }

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
    let billingLine1, billingLine2, billingCity, billingGivenName, email: String
    let billingPostalCode, billingSurname, billingCountryCode, shippingMethod: String
    let billingPhoneNumber: String
    
    init(request: BTThreeDSecureRequest) {
        if let region = request.billingAddress?.region {
            self.billingState = region
        }
        
        if let address1 = request.billingAddress?.streetAddress {
            self.billingLine1 = address1
        }
        
        if let address2 = request.billingAddress?.extendedAddress {
            self.billingLine2 = address2
        }
        
        if let locality = request.billingAddress?.locality {
            self.billingCity = locality
        }
        
        if let email = request.email {
            self.email = email
        }
        
//        self.billingGivenName = ""
//        self.billingGivenName = "" 
            
        self.mobilePhoneNumber = request.mobilePhoneNumber
        
        
    }
}

// MARK: - Customer
struct Customer: Codable {
}
