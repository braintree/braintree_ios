import Foundation
import PassKit
import BraintreeCore

struct BTApplePaymentTokensRequest: Encodable {
    
    let applePaymentToken: ApplePaymentToken
    // let meta: Metadata
    
    init(token: PKPaymentToken) {
        self.applePaymentToken = ApplePaymentToken(
            paymentData: token.paymentData.base64EncodedString(),
            transactionIdentifier: token.transactionIdentifier,
            paymentInstrumentName: token.paymentMethod.displayName,
            paymentNetwork: token.paymentMethod.network?.rawValue
        )
//        self.meta = Metadata(
//            integration: metadata.integration.stringValue,
//            sessionID: metadata.sessionID,
//            source: metadata.source.stringValue
//        )
    }
    
    enum CodingKeys: String, CodingKey {
        case applePaymentToken = "applePaymentToken"
        //case meta = "_meta"
    }
    
    struct ApplePaymentToken: Encodable {
        
        let paymentData: String
        let transactionIdentifier: String
        let paymentInstrumentName: String?
        let paymentNetwork: String?
    }
}

struct ApplePaymentToken: Encodable {
    
    let paymentData: String
    let transactionIdentifier: String
    let paymentInstrumentName: String?
    let paymentNetwork: String?
}

public struct GatewayRequestModel: Encodable {
    
    let actualPostDetails: Encodable
    let metadata: Metadata

    public func encode(to encoder: Encoder) throws {
        try actualPostDetails.encode(to: encoder)
        try metadata.encode(to: encoder)
    }
}

struct Metadata: Encodable {
    
    let integration: String
    let sessionID: String
    let source: String
    let platform = "iOS"
    let version = BTCoreConstants.braintreeSDKVersion
    
    enum CodingKeys: String, CodingKey {
        case integration = "integration"
        case sessionID = "sessionId"
        case source = "source"
        case platform = "platform"
        case version = "version"
    }
}


//func parametersForPaymentToken(token: PKPaymentToken) -> [String: Any?] {
//    [
//        "paymentData": token.paymentData.base64EncodedString(),
//        "transactionIdentifier": token.transactionIdentifier,
//        "paymentInstrumentName": token.paymentMethod.displayName,
//        "paymentNetwork": token.paymentMethod.network
//    ]
//}


//let metaParameters: [String: String] = [
//    "source": self.apiClient.metadata.source.stringValue,
//    "integration": self.apiClient.metadata.integration.stringValue,
//    "sessionId": self.apiClient.metadata.sessionID
//]

// MAIN
//"{\"applePaymentToken\":{\"paymentData\":\"\",\"paymentInstrumentName\":\"Simulated Instrument\",\"paymentNetwork\":\"Visa\",\"transactionIdentifier\":\"Simulated Identifier\"},\"_meta\":{\"platform\":\"iOS\",\"sessionId\":\"80F9B1235C6A4D23935BC5B2D904AF8B\",\"integration\":\"custom\",\"source\":\"unknown\",\"version\":\"6.10.0\"},\"authorization_fingerprint\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IjIwMTgwNDI2MTYtc2FuZGJveCIsImlzcyI6Imh0dHBzOi8vYXBpLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20ifQ.eyJleHAiOjE3MDE1NDE3NjUsImp0aSI6IjI1MzZiMmI0LTk5ODYtNDg1NS04OWJhLWM1ZmQzNjdjNjE1ZCIsInN1YiI6ImRjcHNweTJicndkanIzcW4iLCJpc3MiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwibWVyY2hhbnQiOnsicHVibGljX2lkIjoiZGNwc3B5MmJyd2RqcjNxbiIsInZlcmlmeV9jYXJkX2J5X2RlZmF1bHQiOnRydWV9LCJyaWdodHMiOlsibWFuYWdlX3ZhdWx0Il0sInNjb3BlIjpbIkJyYWludHJlZTpWYXVsdCJdLCJvcHRpb25zIjp7ImN1c3RvbWVyX2lkIjoiMTRENzM1RUQtQjlGMi00OUUzLTk1NkItOTRFMDYzNDdCMzYyIn19.mthqHIasRTDJokuO1ccKbRHnpQL5sA1t8F6rf2nLvaaZGr2qnx6ICP6eoHspZoijfnJEF_a64NzbFYD9pQfpQA?customer_id=\"}"

// CURRENT MINE
// "{\"_meta\":{\"version\":\"6.10.0\",\"integration\":\"TEST\",\"sessionId\":\"TEST\",\"source\":\"TEST\",\"platform\":\"iOS\"},\"applePaymentToken\":{\"paymentNetwork\":\"Visa\",\"paymentInstrumentName\":\"Simulated Instrument\",\"paymentData\":\"\",\"transactionIdentifier\":\"Simulated Identifier\"},\"authorization_fingerprint\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IjIwMTgwNDI2MTYtc2FuZGJveCIsImlzcyI6Imh0dHBzOi8vYXBpLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20ifQ.eyJleHAiOjE3MDE1NDgyNjgsImp0aSI6Ijg5MjZkMjVmLWE1ZDEtNDMwZi1iNjYzLWM1NzRkYzI3ZGRhMiIsInN1YiI6ImRjcHNweTJicndkanIzcW4iLCJpc3MiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwibWVyY2hhbnQiOnsicHVibGljX2lkIjoiZGNwc3B5MmJyd2RqcjNxbiIsInZlcmlmeV9jYXJkX2J5X2RlZmF1bHQiOnRydWV9LCJyaWdodHMiOlsibWFuYWdlX3ZhdWx0Il0sInNjb3BlIjpbIkJyYWludHJlZTpWYXVsdCJdLCJvcHRpb25zIjp7ImN1c3RvbWVyX2lkIjoiRDE0NUMyNEUtRDI0Ny00MDhCLUIyMUEtOTY2MTU0ODM3RjNBIn19.wVWolNjAXJCThYonwlvzm01zqQfPAJl_YX-WV0n8tXVrHednSweVcZbbjzYzLNqr_HhzT0_Ymlu04zvR5mVJ4g?customer_id=\"}"
