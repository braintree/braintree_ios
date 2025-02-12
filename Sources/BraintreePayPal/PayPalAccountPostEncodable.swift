import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// The POST body for /v1/payment_methods/paypal_accounts
struct PayPalAccountPostEncodable: Encodable {
    
    let paypalAccount: PayPalAccount
    let meta: Meta
    
    init(
        request: BTPayPalRequest,
        client: BTAPIClient,
        paymentType: BTPayPalPaymentType,
        url: URL?,
        correlationID: String?
    ) {
        self.paypalAccount = PayPalAccount(
            request: request,
            client: client,
            paymentType: paymentType,
            url: url,
            correlationID: correlationID
        )
        
        self.meta = Meta(meta: client.metadata)
    }

    enum CodingKeys: String, CodingKey {
        case paypalAccount = "paypal_account"
        case meta = "_meta"
    }
}

struct PayPalAccount: Encodable {
    
    let responseType: String
    let intent: String?
    let correlationId: String?
    let options: Options?
    let client: Client
    let response: PayPalResponse

    init(request: BTPayPalRequest, client: BTAPIClient, paymentType: BTPayPalPaymentType, url: URL?, correlationID: String?) {
        responseType = "web"
        correlationId = correlationID
        
        options = paymentType == .checkout ? Options(validate: false) : nil
        intent  = paymentType == .checkout
            ? (request as? BTPayPalCheckoutRequest)?.intent.stringValue
            : nil
        
        self.client   = Client()
        self.response = PayPalResponse(webURL: url?.absoluteString ?? "")
    }
    
    enum CodingKeys: String, CodingKey {
        case responseType = "response_type"
        case intent
        case correlationId = "correlation_id"
        case options
        case client
        case response
    }
}

struct Options: Encodable {
    
    let validate: Bool
}

struct Client: Encodable {

    let platform = "iOS"
    let productName = "PayPal"
    let paypalSdkVersion = "version"

    enum CodingKeys: String, CodingKey {
        case platform
        case productName = "product_name"
        case paypalSdkVersion = "paypal_sdk_version"
    }
}

struct PayPalResponse: Encodable {
    
    let webURL: String

    enum CodingKeys: String, CodingKey {
        case webURL
    }
}

struct Meta: Encodable {
    
    let integration: String
    let source: String
    let sessionId: String
    
    init(meta: BTClientMetadata) {
        meta.source = .payPalBrowser
        
        self.integration = meta.integration.stringValue
        self.source = meta.source.stringValue
        self.sessionId = meta.sessionID
    }
}
