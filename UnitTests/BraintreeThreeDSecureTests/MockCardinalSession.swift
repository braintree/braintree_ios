import Foundation
import CardinalMobile
@testable import BraintreeThreeDSecure

class MockCardinalSession: CardinalSessionTestable {

    var dfReferenceID = "fake-df-reference-id"

    func configure(_ sessionConfig: CardinalSessionConfiguration) {
        // do nothing
    }
    
    func setup(
        jwtString: String,
        completed didCompleteHandler: @escaping CardinalSessionSetupDidCompleteHandler,
        validated didValidateHandler: @escaping CardinalSessionSetupDidValidateHandler
    ) {
        didCompleteHandler(dfReferenceID)
    }
    
    func continueWith(transactionId: String, payload: String, validationDelegate: CardinalValidationDelegate) {
        // do nothing
    }
}
