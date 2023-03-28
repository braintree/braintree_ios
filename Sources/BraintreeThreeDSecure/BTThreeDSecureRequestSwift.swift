import Foundation
import BraintreeCore

@objcMembers public class BTThreeDSecureRequestSwift: NSObject {
    
    // MARK: - Public Properties
    
    public let nonce: String
    
    public let amount: Decimal
    
    public let accountType: BTThreeDSecureAccountTypeSwift
    
    public let billingAddress: BTThreeDSecurePostalAddress?
    
    public let mobilePhoneNumber: String?
    
    public let email: String?
    
    public let shippingMethod: BTThreeDSecureShippingMethodSwift
    
    public let additionalInformation: BTThreeDSecureAdditionalInformation?
    
    public let challengeRequested: Bool?
    
    public let exemptionRequested: Bool?
    
    public let requestedExcemptionType: BTThreeDSecureRequestedExemptionTypeSwift

    public let dataOnlyRequested: Bool?
    
    public let cardAddChallenge: BTThreeDSecureCardAddChallenge?
    
    public let v2UICustomization: BTThreeDSecureV2UICustomization?
    
    public weak var threeDSecureRequestDelegate: BTThreeDSecureRequestDelegate?
    
    // MARK: - Internal Properties
    
    weak var paymentFlowClientDelegate: BTPaymentFlowClientDelegate?
    let dfReferenceID: String = ""
    
    var accountTypeAsString: String? {
        switch self.accountType {
        case .credit:
            return "credit"
        case .debit:
            return "debit"
        case .unspecified:
            return nil
        }
    }
    
    var shippingMethodAsString: String? {
        switch self.shippingMethod {
        case .sameDay:
            return "01"
        case .expedited:
            return "02"
        case .priority:
            return "03"
        case .ground:
            return "04"
        case .electronicDelivery:
            return "05"
        case .shipToStore:
            return "06"
        case .unspecified:
            return nil
        }
    }
    
    var requestedExemptionTypeAsString: String? {
        switch self.requestedExcemptionType {
        case .lowValue:
            return "low_value"
        case .secureCorporate:
            return "secure_corporate"
        case .trustedBeneficiary:
            return "trusted_beneficiary"
        case .transactionRiskAnalysis:
            return "transaction_risk_analysis"
        case .unspecified:
            return nil
        }
    }
    
    // MARK: - Initializer
    
    public init(
        nonce: String, amount: Decimal,
        accountType: BTThreeDSecureAccountTypeSwift = .unspecified,
        billingAddress: BTThreeDSecurePostalAddress? = nil,
        mobilePhoneNumber: String? = nil,
        email: String? = nil,
        shippingMethod: BTThreeDSecureShippingMethodSwift = .unspecified,
        additionalInformation: BTThreeDSecureAdditionalInformation? = nil,
        challengeRequested: Bool? = nil,
        exemptionRequested: Bool? = nil,
        requestedExcemptionType: BTThreeDSecureRequestedExemptionTypeSwift = .unspecified,
        dataOnlyRequested: Bool? = nil,
        cardAddChallenge: BTThreeDSecureCardAddChallenge? = nil,
        v2UICustomization: BTThreeDSecureV2UICustomization? = nil,
        threeDSecureRequestDelegate: BTThreeDSecureRequestDelegate? = nil
    ) {
        self.nonce = nonce
        self.amount = amount
        self.accountType = accountType
        self.billingAddress = billingAddress
        self.mobilePhoneNumber = mobilePhoneNumber
        self.email = email
        self.shippingMethod = shippingMethod
        self.additionalInformation = additionalInformation
        self.challengeRequested = challengeRequested
        self.exemptionRequested = exemptionRequested
        self.requestedExcemptionType = requestedExcemptionType
        self.dataOnlyRequested = dataOnlyRequested
        self.cardAddChallenge = cardAddChallenge
        self.v2UICustomization = v2UICustomization
        self.threeDSecureRequestDelegate = threeDSecureRequestDelegate
    }
    
    // MARK: - Internal Methods
    
    func prepareLookup(apiClient: BTAPIClient, completion: (NSError?) -> Void) {
        
    }
    
    func processLookupResult(lookupResult: BTThreeDSecureResult, configuration: BTConfiguration) {
        
    }
    
    // MARK: - Private Methods
    
    func handleRequest(request: BTPaymentFlowRequest, apiClient: BTAPIClient, paymentClientDelegate: BTPaymentFlowClientDelegate) {
        
    }
    
    func startRequest(request: BTPaymentFlowRequest, configuration: BTConfiguration) {
        
    }
    
    func performV2Authentication(lookupResult: BTThreeDSecureResult) {
        
    }
    
    func handleOpenURL(url: NSURL) {
        
    }
    
    func logThreeDSecureCompletedAnalyticsForResult(result: BTThreeDSecureResult, apiClient: BTAPIClient) {
        
    }
    
    func paymentFlowName() -> String {
        return "three-d-secure"
    }
    
    func stringForBool(boolean: Bool) -> String {
        return boolean ? "true" : "false"
    }
    
    func onLookupComplete(_ request: BTThreeDSecureRequest, lookupResult result: BTThreeDSecureResult, next: (() -> Void)) {
        next()
    }
}
