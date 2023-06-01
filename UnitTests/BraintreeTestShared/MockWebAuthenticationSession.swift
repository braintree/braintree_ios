import Foundation
import AuthenticationServices
@testable import BraintreeCore

class MockWebAuthenticationSession: BTWebAuthenticationSession {
    var cannedResponseURL: URL?
    var cannedErrorResponse: Error?
    var cannedSessionDidDisplay: Bool = true

    override func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidComplete: @escaping (URL?, Error?) -> Void,
        sessionDidAppear: @escaping (Bool) -> Void,
        sessionDidCancel: @escaping () -> Void
    ) {
        sessionDidAppear(cannedSessionDidDisplay)

        if let error = cannedErrorResponse as? NSError, error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
            sessionDidCancel()
        } else {
            sessionDidComplete(cannedResponseURL, cannedErrorResponse)
        }
    }
}
