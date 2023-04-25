import Foundation
import AuthenticationServices
@testable import BraintreeSEPADirectDebit

class MockWebAuthenticationSession: WebAuthenticationSession {

    var cannedResponseURL: URL?
    var cannedErrorResponse: Error?
    
    override func start(url: URL, context: ASWebAuthenticationPresentationContextProviding,
                        sessionDidDisplay: @escaping (Bool) -> Void, 
                        sessionDidComplete: @escaping (URL?, Error?) -> Void) {
        sessionDidComplete(cannedResponseURL, cannedErrorResponse)
    }
}
