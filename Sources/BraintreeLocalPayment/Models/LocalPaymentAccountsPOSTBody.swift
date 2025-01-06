import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The POST body for v1/payment_methods/paypal_accounts
struct LocalPaymentPayPalAccountsPOSTBody: Encodable {
    
    // MARK: - Private Properties
    
    private let paypalAccount: LocalPaymentPayPalAccount
    private let meta: LocalPaymentPayPalAccountMetadata
    
    private var merchantAccountID: String?
    
    init(
        request: BTLocalPaymentRequest?,
        clientMetadata: BTClientMetadata,
        url: URL
    ) {
        self.meta = LocalPaymentPayPalAccountMetadata(clientMetadata: clientMetadata)
        self.paypalAccount = LocalPaymentPayPalAccount(request: request, url: url)
        
        if let merchantAccountID = request?.merchantAccountID {
            self.merchantAccountID = merchantAccountID
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case merchantAccountID = "merchant_account_id"
        case meta = "_meta"
        case paypalAccount = "paypal_account"
    }
}

extension LocalPaymentPayPalAccountsPOSTBody {
    
    struct LocalPaymentPayPalAccount: Encodable {
        
        let intent = "sale"
        let response: Response
        let responseType = "web"
        let options = [Option()]
        
        var correlationID: String?
        
        // swiftlint:disable nesting
        struct Option: Encodable {
            
            let validate = false
        }
        
        // swiftlint:disable nesting
        struct Response: Encodable {
            
            let webURL: String
        }
        
        init(request: BTLocalPaymentRequest?, url: URL) {
            self.response = Response(webURL: url.absoluteString)
            
            if let correlationID = request?.correlationID {
                self.correlationID = correlationID
            }
        }
        
        // swiftlint:disable nesting
        enum CodingKeys: String, CodingKey {
            case correlationID = "correlation_id"
            case intent
            case options
            case responseType = "response_type"
        }
    }
    
    struct LocalPaymentPayPalAccountMetadata: Encodable {
        
        let integration: String
        let sessionID: String
        let source: String
        
        init(clientMetadata: BTClientMetadata) {
            self.integration = clientMetadata.integration.stringValue
            self.sessionID = clientMetadata.sessionID
            self.source = clientMetadata.source.stringValue
        }
        
        // swiftlint:disable nesting
        enum CodingKeys: String, CodingKey {
            case integration
            case sessionID = "sessionId"
            case source
        }
    }
}
