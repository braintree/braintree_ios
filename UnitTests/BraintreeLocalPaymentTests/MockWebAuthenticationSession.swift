import Foundation
import AuthenticationServices
@testable import BraintreePaymentFlow

class MockWebAuthenticationSession: WebAuthenticationSession {
    var cannedResponseURL: URL?
    var cannedErrorResponse: Error?
    var cannedSessionDidDisplay: Bool = true
    
    override func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidDisplay: @escaping(Bool) -> Void,
        sessionDidComplete: @escaping(URL?, Error?) -> Void
    ) {
        sessionDidDisplay(cannedSessionDidDisplay)
        sessionDidComplete(cannedResponseURL, cannedErrorResponse)
    }
}
