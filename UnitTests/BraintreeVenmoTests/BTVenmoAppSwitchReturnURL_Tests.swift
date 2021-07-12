import XCTest
import BraintreeTestShared
import BraintreeVenmo

class BTVenmoAppSwitchReturnURL_Tests: XCTestCase {

    func testInitWithUrl_whenSuccessReturnUrl_createsNonce_andSetsSuccessState() {
        let returnUrl = BTVenmoAppSwitchReturnURL.init(url: URL(string: "com.example.app://x-callback-url/vzero/auth/venmo/success?paymentMethodNonce=a-nonce"))

        XCTAssertEqual(returnUrl?.nonce, "a-nonce")
        XCTAssertEqual(returnUrl?.state, .succeeded)
        XCTAssertNil(returnUrl?.paymentContextID)
        XCTAssertNil(returnUrl?.error)
    }

    func testInitWithURL_whenSuccessReturnURL_withPaymentContextID_setsSuccessWithPaymentContextState() {
        let returnUrl = BTVenmoAppSwitchReturnURL.init(url: URL(string: "com.example.app://x-callback-url/vzero/auth/venmo/success?resource_id=12345"))

        XCTAssertEqual(returnUrl?.state, .succeededWithPaymentContext)
        XCTAssertEqual(returnUrl?.paymentContextID, "12345")
        XCTAssertNil(returnUrl?.nonce)
        XCTAssertNil(returnUrl?.username)
        XCTAssertNil(returnUrl?.error)
    }

    func testInitWithUrl_whenCancelReturnUrl_doesNotParseErrorOrPaymentMethod_andSetsCanceledState() {
        let returnUrl = BTVenmoAppSwitchReturnURL.init(url: URL(string: "com.example.app://x-callback-url/vzero/auth/venmo/cancel"))

        XCTAssertEqual(returnUrl?.state, .canceled)
        XCTAssertNil(returnUrl?.error)
        XCTAssertNil(returnUrl?.nonce)
    }

    func testInitWithUrl_whenValidErrorReturnUrl_returnsError_andSetsFailedState() {
        let returnUrl = BTVenmoAppSwitchReturnURL.init(url: URL(string: "com.example.app://x-callback-url/vzero/auth/venmo/error?errorMessage=Venmo%20Fail&errorCode=-7"))

        XCTAssertEqual(returnUrl?.state, .failed)
        guard let error = returnUrl?.error as NSError? else {
            XCTFail()
            return
        }
        XCTAssertEqual(error.domain, BTVenmoAppSwitchReturnURLErrorDomain)
        XCTAssertEqual(error.code, -7)
        XCTAssertEqual(error.localizedDescription, "Venmo Fail")
    }

}

