import Foundation
@testable import BraintreePayPal

/// Captures the flag at the moment of tokenization, since `withEditBillingAgreement` resets it afterwards.
final class MockPayPalClient: BTPayPalClient {

    var cannedNonce: BTPayPalAccountNonce?
    var cannedError: Error?

    private(set) var tokenizeCallCount = 0
    private(set) var editBillingAgreementDuringTokenize: Bool?

    override func tokenize(_ request: BTPayPalCheckoutRequest) async throws -> BTPayPalAccountNonce {
        tokenizeCallCount += 1
        editBillingAgreementDuringTokenize = request.editBillingAgreement

        if let cannedError {
            throw cannedError
        }

        guard let cannedNonce else {
            throw NSError(domain: "MockPayPalClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "No canned nonce"])
        }

        return cannedNonce
    }
}
