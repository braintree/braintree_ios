import Foundation
import AuthenticationServices
@testable import BraintreeSEPADirectDebit

@available(iOS 13.0, *)
class MockWebAuthenticationSession: WebAuthenticationSession {

    var cannedResponseURL: URL?
    var cannedErrorResponse: Error?

    // TODO: add mock implementation
}
