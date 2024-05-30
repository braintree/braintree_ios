import BraintreePayPalMessaging

class MockBTPayPalMessagingDelegate: BTPayPalMessagingDelegate {

    var willAppear: Bool = false
    var error: Error?

    func didSelect(_ payPalMessagingView: BTPayPalMessagingView) {
        // not unit testable
    }

    func willApply(_ payPalMessagingView: BTPayPalMessagingView) {
        // not unit testable
    }
    
    func willAppear(_ payPalMessagingView: BTPayPalMessagingView) {
        willAppear = true
    }
    
    func didAppear(_ payPalMessagingView: BTPayPalMessagingView) {
        // not unit testable
    }
    
    func onError(_ payPalMessagingView: BTPayPalMessagingView, error: Error) {
        self.error = error
    }
}
