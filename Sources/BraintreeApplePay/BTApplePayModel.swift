import Foundation
import PassKit
import BraintreeCore

struct BTApplePaymentTokensRequest: Encodable {
    
    let applePaymentToken: ApplePaymentToken
    let meta: Metadata
    
    init(token: PKPaymentToken, metadata: BTClientMetadata) {
        self.applePaymentToken = ApplePaymentToken(
            paymentData: token.paymentData.base64EncodedString(),
            transactionIdentifier: token.transactionIdentifier,
            paymentInstrumentName: token.paymentMethod.displayName,
            paymentNetwork: token.paymentMethod.network?.rawValue
        )
        self.meta = Metadata(
            source: metadata.source.stringValue,
            integration: metadata.integration.stringValue,
            sessionID: metadata.sessionID
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case applePaymentToken = "applePaymentToken"
        case meta = "_meta"
    }
}

struct ApplePaymentToken: Encodable {
    
    let paymentData: String
    let transactionIdentifier: String
    let paymentInstrumentName: String?
    let paymentNetwork: String?
}

struct Metadata: Encodable {
    
    let source: String
    let integration: String
    let sessionID: String
    
    enum CodingKeys: String, CodingKey {
        case source = "source"
        case integration = "integration"
        case sessionID = "sessionId"
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
// "{\"_meta\":{\"sessionID\":\"88B10C30FB464E4F83FE6BDF0F6AFE90\",\"integration\":\"custom\",\"source\":\"unknown\"},\"applePaymentToken\":{\"paymentNetwork\":\"Visa\",\"paymentInstrumentName\":\"Simulated Instrument\",\"paymentData\":\"\",\"transactionIdentifier\":\"Simulated Identifier\"},\"authorization_fingerprint\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IjIwMTgwNDI2MTYtc2FuZGJveCIsImlzcyI6Imh0dHBzOi8vYXBpLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20ifQ.eyJleHAiOjE3MDE1NDQ1ODYsImp0aSI6ImRlYjI5ODVlLWYxYjAtNGE5NS05OWQ3LTdmNzgxZjE0NzViZSIsInN1YiI6ImRjcHNweTJicndkanIzcW4iLCJpc3MiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwibWVyY2hhbnQiOnsicHVibGljX2lkIjoiZGNwc3B5MmJyd2RqcjNxbiIsInZlcmlmeV9jYXJkX2J5X2RlZmF1bHQiOnRydWV9LCJyaWdodHMiOlsibWFuYWdlX3ZhdWx0Il0sInNjb3BlIjpbIkJyYWludHJlZTpWYXVsdCJdLCJvcHRpb25zIjp7ImN1c3RvbWVyX2lkIjoiOUY3NEUwNTItQTUzNS00NTA1LTg0RUQtNzMxNjA3NDZFMTBGIn19.5mCccRpsEoe0cOHURxVxvBDIUBSMwvSZySwJNo1Ou72mnsJ0tNQGbeUYTrshwZNsHQDkryqX8IrBnp5Q49-kmA?customer_id=\"}"
