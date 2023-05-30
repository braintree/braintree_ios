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
        sessionDidDisplay: @escaping (Bool) -> Void,
        sessionDidComplete: @escaping (URL?, Error?) -> Void,
        sessionDidCancel: @escaping () -> Void
    ) {
        sessionDidDisplay(cannedSessionDidDisplay)

        if let error = cannedErrorResponse as? NSError, error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
            sessionDidCancel()
        } else {
            sessionDidComplete(cannedResponseURL, cannedErrorResponse)
        }
    }
}
