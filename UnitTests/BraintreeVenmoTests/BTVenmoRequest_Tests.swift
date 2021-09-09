import XCTest
import BraintreeVenmo

class BTVenmoRequest_Tests: XCTestCase {

    func testPaymentMethodUsageAsString_whenPaymentMethodUsageIsMultiUse_returnsMultiUse() {
        let request = BTVenmoRequest()
        request.paymentMethodUsage = .multiUse
        XCTAssertEqual(request.paymentMethodUsageAsString, "MULTI_USE")
    }

    func testPaymentMethodUsageAsString_whenPaymentMethodUsageIsSingleUse_returnsSingleUse() {
        let request = BTVenmoRequest()
        request.paymentMethodUsage = .singleUse
        XCTAssertEqual(request.paymentMethodUsageAsString, "SINGLE_USE")
    }

    func testPaymentMethodUsageAsString_whenPaymentMethodUsageIsDefault_returnsNil() {
        let request = BTVenmoRequest()
        XCTAssertEqual(request.paymentMethodUsageAsString, nil)
    }
}
