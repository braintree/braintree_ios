import Foundation
import AuthenticationServices
@testable import BraintreeSEPADirectDebit

class MockWebAuthenticationSession: WebAuthenticationSession {

    var cannedResponseURL: URL?
    var cannedErrorResponse: Error?
    
    @available(iOS 13.0, *)
    override func start(url: URL, context: ASWebAuthenticationPresentationContextProviding, completion: @escaping (URL?, Error?) -> Void) {
        completion(cannedResponseURL, cannedErrorResponse)
    }
    
    override func start(url: URL, completion: @escaping (URL?, Error?) -> Void) {
        completion(cannedResponseURL, cannedErrorResponse)
    }
}
