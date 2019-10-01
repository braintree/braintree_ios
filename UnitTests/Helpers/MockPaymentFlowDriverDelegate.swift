class MockPaymentFlowDriverDelegate: BTPaymentFlowDriverDelegate {
    
    var onPaymentHandler: ((URL?, Error?) -> Void)?
    var onPaymentCancelHandler: (() -> Void)?
    var onPaymentCompleteHandler: ((BTPaymentFlowResult?, Error?) -> Void)?
    
    func onPayment(with url: URL?, error: Error?) {
        onPaymentHandler?(url, error)
    }
    
    func onPaymentCancel() {
        onPaymentCancelHandler?()
    }
    
    func onPaymentComplete(_ result: BTPaymentFlowResult?, error: Error?) {
        onPaymentCompleteHandler?(result, error)
    }
    
    func returnURLScheme() -> String {
        return ""
    }
    
    func apiClient() -> BTAPIClient {
        return MockAPIClient(authorization: "development_tokenization_key")!
    }
}
