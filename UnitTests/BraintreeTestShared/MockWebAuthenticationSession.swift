import Foundation
import AuthenticationServices
@testable import BraintreeCore

class MockWebAuthenticationSession: BTWebAuthenticationSession {
    var cannedResponseURL: URL?
    var cannedErrorResponse: Error?
    var cannedSessionDidDisplay: Bool = true
    var cannedSessionDidDuplicate: Bool = false
    var cannedBAToken: BAToken? = nil

    override func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidComplete: @escaping (URL?, Error?) -> Void,
        sessionDidAppear: @escaping (Bool, BAToken?) -> Void,
        sessionDidCancel: @escaping (BAToken?) -> Void,
        sessionDidDuplicate: @escaping (BAToken?) -> Void = { _ in }
    ) {
        guard !cannedSessionDidDuplicate else {
            sessionDidDuplicate(cannedBAToken)
            return
        }
        
        sessionDidAppear(cannedSessionDidDisplay, cannedBAToken)

        if let error = cannedErrorResponse as? NSError, error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
            sessionDidCancel(cannedBAToken)
        } else {
            sessionDidComplete(cannedResponseURL, cannedErrorResponse)
        }
    }
}
