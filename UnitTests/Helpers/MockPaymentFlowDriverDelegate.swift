class MockPaymentFlowDriverDelegate: BTPaymentFlowDriverDelegate {
    
    var _returnURLScheme = ""
    
    var onPaymentWithURLHandler: ((URL?, Error?) -> Void)?
    var onPaymentCancelHandler: (() -> Void)?
    var onPaymentCompleteHandler: ((BTPaymentFlowResult?, Error?) -> Void)?
    
    func onPayment(with url: URL?, error: Error?) {
        onPaymentWithURLHandler?(url, error)
    }
    
    func onPaymentCancel() {
        onPaymentCancelHandler?()
    }
    
    func onPaymentComplete(_ result: BTPaymentFlowResult?, error: Error?) {
        onPaymentCompleteHandler?(result, error)
    }
    
    func returnURLScheme() -> String {
        return _returnURLScheme
    }
    
    func apiClient() -> BTAPIClient {
        return MockAPIClient(authorization: "development_tokenization_key")!
    }
}
