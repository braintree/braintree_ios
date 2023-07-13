import Foundation
import CardinalMobile
@testable import BraintreeThreeDSecure

class MockCardinalSession: CardinalSessionTestable {
    
    func configure(_ sessionConfig: CardinalSessionConfiguration) {
        // do nothing
    }
    
    func setup(
        jwtString: String,
        completed didCompleteHandler: @escaping CardinalSessionSetupDidCompleteHandler,
        validated didValidateHandler: @escaping CardinalSessionSetupDidValidateHandler
    ) {
        didCompleteHandler("fake-df-reference-id")
    }
    
    func continueWith(transactionId: String, payload: String, validationDelegate: CardinalValidationDelegate) {
        // do nothing
    }
}
