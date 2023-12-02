import Foundation
import PassKit

/// The POST body for `v1/payment_methods/apple_payment_tokens`
struct BTApplePaymentTokensRequest: Encodable {
    
    private let applePaymentToken: ApplePaymentToken
    
    init(token: PKPaymentToken) {
        self.applePaymentToken = ApplePaymentToken(
            paymentData: token.paymentData.base64EncodedString(),
            transactionIdentifier: token.transactionIdentifier,
            paymentInstrumentName: token.paymentMethod.displayName,
            paymentNetwork: token.paymentMethod.network?.rawValue
        )
    }
    
    private struct ApplePaymentToken: Encodable {
        
        let paymentData: String
        let transactionIdentifier: String
        let paymentInstrumentName: String?
        let paymentNetwork: String?
    }
}

// MAIN
//"{\"applePaymentToken\":{\"paymentData\":\"\",\"paymentInstrumentName\":\"Simulated Instrument\",\"paymentNetwork\":\"Visa\",\"transactionIdentifier\":\"Simulated Identifier\"},\"_meta\":{\"platform\":\"iOS\",\"sessionId\":\"80F9B1235C6A4D23935BC5B2D904AF8B\",\"integration\":\"custom\",\"source\":\"unknown\",\"version\":\"6.10.0\"},\"authorization_fingerprint\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IjIwMTgwNDI2MTYtc2FuZGJveCIsImlzcyI6Imh0dHBzOi8vYXBpLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20ifQ.eyJleHAiOjE3MDE1NDE3NjUsImp0aSI6IjI1MzZiMmI0LTk5ODYtNDg1NS04OWJhLWM1ZmQzNjdjNjE1ZCIsInN1YiI6ImRjcHNweTJicndkanIzcW4iLCJpc3MiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwibWVyY2hhbnQiOnsicHVibGljX2lkIjoiZGNwc3B5MmJyd2RqcjNxbiIsInZlcmlmeV9jYXJkX2J5X2RlZmF1bHQiOnRydWV9LCJyaWdodHMiOlsibWFuYWdlX3ZhdWx0Il0sInNjb3BlIjpbIkJyYWludHJlZTpWYXVsdCJdLCJvcHRpb25zIjp7ImN1c3RvbWVyX2lkIjoiMTRENzM1RUQtQjlGMi00OUUzLTk1NkItOTRFMDYzNDdCMzYyIn19.mthqHIasRTDJokuO1ccKbRHnpQL5sA1t8F6rf2nLvaaZGr2qnx6ICP6eoHspZoijfnJEF_a64NzbFYD9pQfpQA?customer_id=\"}"

// CURRENT MINE
// "{\"_meta\":{\"version\":\"6.10.0\",\"integration\":\"custom\",\"sessionId\":\"64F33ABEF7F54E4BA80E566A37ECFEC5\",\"source\":\"unknown\",\"platform\":\"iOS\"},\"applePaymentToken\":{\"paymentInstrumentName\":\"Simulated Instrument\",\"paymentNetwork\":\"Visa\",\"paymentData\":\"\",\"transactionIdentifier\":\"Simulated Identifier\"},\"authorization_fingerprint\":\"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiIsImtpZCI6IjIwMTgwNDI2MTYtc2FuZGJveCIsImlzcyI6Imh0dHBzOi8vYXBpLnNhbmRib3guYnJhaW50cmVlZ2F0ZXdheS5jb20ifQ.eyJleHAiOjE3MDE2MTExNTUsImp0aSI6IjZhMDkyODVlLWMwNWMtNDY0ZS05NmNmLTE4M2Y1YTBlZjJjMiIsInN1YiI6ImRjcHNweTJicndkanIzcW4iLCJpc3MiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tIiwibWVyY2hhbnQiOnsicHVibGljX2lkIjoiZGNwc3B5MmJyd2RqcjNxbiIsInZlcmlmeV9jYXJkX2J5X2RlZmF1bHQiOnRydWV9LCJyaWdodHMiOlsibWFuYWdlX3ZhdWx0Il0sInNjb3BlIjpbIkJyYWludHJlZTpWYXVsdCJdLCJvcHRpb25zIjp7ImN1c3RvbWVyX2lkIjoiRjU4QzRFMjItMjg5RS00Q0FCLUFCOTQtMjU3QjNFNkJDODdDIn19.eUbfM7vY9shdmRdYmMLcRWM5uSWWQopW1pSK1OtDaJjKwCvpOVGRtJWQOugzIjumC-O7QAoj6__LW7372ctMJg?customer_id=\"}"
