import Foundation

/// The POST body for `v1/payment_methods/\(urlSafeNonce)/three_d_secure/lookup`
struct ThreeDSecurePostBody: Encodable {
    
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
        
        self.customFields = request.customFields
        self.cardAdd = request.cardAddChallengeRequested ? true : nil

        self.additionalInfo = AdditionalInfo(request: request)
        self.customer = Customer()
    }

    enum CodingKeys: String, CodingKey {

        case accountType
        case additionalInfo
        case amount
        case cardAdd
        case challengeRequested
        case customFields
        case customer
        case dataOnlyRequested
        case dfReferenceID = "dfReferenceId"
        case exemptionRequested
        case requestedExemptionType
        case requestedThreeDSecureVersion
    }
    
    // MARK: - AdditionalInfo
    struct AdditionalInfo: Encodable {

        let accountAgeIndicator: String?
        let accountChangeDate: String?
        let accountChangeIndicator: String?
        let accountCreateDate: String?
        let accountId: String?
        let accountPwdChangeDate: String?
        let accountPwdChangeIndicator: String?
        let accountPurchases: String?
        let addCardAttempts: String?
        let addressMatch: String?
        let authenticationIndicator: String?
        let billingCity: String?
        let billingCountryCode: String?
        let billingGivenName: String?
        let billingLine1: String?
        let billingLine2: String?
        let billingLine3: String?
        let billingPhoneNumber: String?
        let billingPostalCode: String?
        let billingState: String?
        let billingSurname: String?
        let deliveryEmail: String?
        let deliveryTimeframe: String?
        let email: String?
        let fraudActivity: String?
        let giftCardAmount: String?
        let giftCardCount: String?
        let giftCardCurrencyCode: String?
        let installment: String?
        let ipAddress: String?
        let mobilePhoneNumber: String?
        let orderDescription: String?
        let paymentAccountAge: String?
        let paymentAccountIndicator: String?
        let preorderDate: String?
        let preorderIndicator: String?
        let productCode: String?
        let purchaseDate: String?
        let recurringEnd: String?
        let recurringFrequency: String?
        let reorderIndicator: String?
        let sdkMaxTimeout: String?
        let shippingAddressUsageDate: String?
        let shippingAddressUsageIndicator: String?
        let shippingCity: String?
        let shippingCountryCode: String?
        let shippingGivenName: String?
        let shippingLine1: String?
        let shippingLine2: String?
        let shippingLine3: String?
        let shippingMethod: String?
        let shippingMethodIndicator: String?
        let shippingNameIndicator: String?
        let shippingPhone: String?
        let shippingPostalCode: String?
        let shippingState: String?
        let shippingSurname: String?
        let taxAmount: String?
        let transactionCountDay: String?
        let transactionCountYear: String?
        let userAgent: String?
        let workPhoneNumber: String?
        
        // swiftlint:disable:next function_body_length
        init(request: BTThreeDSecureRequest) {
            // Billing Address
            self.billingCity = request.billingAddress?.locality
            self.billingCountryCode = request.billingAddress?.countryCodeAlpha2
            self.billingGivenName = request.billingAddress?.givenName
            self.billingLine1 = request.billingAddress?.streetAddress
            self.billingLine2 = request.billingAddress?.extendedAddress
            self.billingLine3 = request.billingAddress?.line3
            self.billingPhoneNumber = request.billingAddress?.phoneNumber
            self.billingPostalCode = request.billingAddress?.postalCode
            self.billingState = request.billingAddress?.region
            self.billingSurname = request.billingAddress?.surname
            
            // Shipping Address
            self.shippingCity = request.additionalInformation?.shippingAddress?.locality
            self.shippingCountryCode = request.additionalInformation?.shippingAddress?.countryCodeAlpha2
            self.shippingGivenName = request.additionalInformation?.shippingAddress?.givenName
            self.shippingLine1 = request.additionalInformation?.shippingAddress?.streetAddress
            self.shippingLine2 = request.additionalInformation?.shippingAddress?.extendedAddress
            self.shippingLine3 = request.additionalInformation?.shippingAddress?.line3
            self.shippingPhone = request.additionalInformation?.shippingAddress?.phoneNumber
            self.shippingPostalCode = request.additionalInformation?.shippingAddress?.postalCode
            self.shippingState = request.additionalInformation?.shippingAddress?.region
            self.shippingSurname = request.additionalInformation?.shippingAddress?.surname
            
            // Request properties
            self.email = request.email
            self.mobilePhoneNumber = request.mobilePhoneNumber
            self.shippingMethod = request.shippingMethod.stringValue
            
            // AdditionalInformation
            self.accountAgeIndicator = request.additionalInformation?.accountAgeIndicator
            self.accountChangeDate = request.additionalInformation?.accountChangeDate
            self.accountChangeIndicator = request.additionalInformation?.accountChangeIndicator
            self.accountCreateDate = request.additionalInformation?.accountCreateDate
            self.accountId = request.additionalInformation?.accountID
            self.accountPwdChangeDate = request.additionalInformation?.accountPwdChangeDate
            self.accountPwdChangeIndicator = request.additionalInformation?.accountPwdChangeIndicator
            self.accountPurchases = request.additionalInformation?.accountPurchases
            self.addCardAttempts = request.additionalInformation?.addCardAttempts
            self.addressMatch = request.additionalInformation?.addressMatch
            self.authenticationIndicator = request.additionalInformation?.authenticationIndicator
            self.deliveryEmail = request.additionalInformation?.deliveryEmail
            self.deliveryTimeframe = request.additionalInformation?.deliveryTimeframe
            self.fraudActivity = request.additionalInformation?.fraudActivity
            self.giftCardAmount = request.additionalInformation?.giftCardAmount
            self.giftCardCount = request.additionalInformation?.giftCardCount
            self.giftCardCurrencyCode = request.additionalInformation?.giftCardCurrencyCode
            self.installment = request.additionalInformation?.installment
            self.ipAddress = request.additionalInformation?.ipAddress
            self.orderDescription = request.additionalInformation?.orderDescription
            self.paymentAccountAge = request.additionalInformation?.paymentAccountAge
            self.paymentAccountIndicator = request.additionalInformation?.paymentAccountIndicator
            self.preorderDate = request.additionalInformation?.preorderDate
            self.preorderIndicator = request.additionalInformation?.preorderIndicator
            self.productCode = request.additionalInformation?.productCode
            self.purchaseDate = request.additionalInformation?.purchaseDate
            self.recurringEnd = request.additionalInformation?.recurringEnd
            self.recurringFrequency = request.additionalInformation?.recurringFrequency
            self.reorderIndicator = request.additionalInformation?.reorderIndicator
            self.sdkMaxTimeout = request.additionalInformation?.sdkMaxTimeout
            self.shippingAddressUsageDate = request.additionalInformation?.shippingAddressUsageDate
            self.shippingAddressUsageIndicator = request.additionalInformation?.shippingAddressUsageIndicator
            self.shippingMethodIndicator = request.additionalInformation?.shippingMethodIndicator
            self.shippingNameIndicator = request.additionalInformation?.shippingNameIndicator
            self.taxAmount = request.additionalInformation?.taxAmount
            self.transactionCountDay = request.additionalInformation?.transactionCountDay
            self.transactionCountYear = request.additionalInformation?.transactionCountYear
            self.userAgent = request.additionalInformation?.userAgent
            self.workPhoneNumber = request.additionalInformation?.workPhoneNumber
        }
    }

    // MARK: - Customer
    struct Customer: Codable { }
}
