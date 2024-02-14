import XCTest
@testable import BraintreeVenmo

class BTVenmoRequest_Tests: XCTestCase {

    func testPaymentMethodUsageAsString_whenPaymentMethodUsageIsMultiUse_returnsMultiUse() {
        let request = BTVenmoRequest(paymentMethodUsage: .multiUse)
        XCTAssertEqual(request.paymentMethodUsage.stringValue, "MULTI_USE")
    }

    func testPaymentMethodUsageAsString_whenPaymentMethodUsageIsSingleUse_returnsSingleUse() {
        let request = BTVenmoRequest(paymentMethodUsage: .singleUse)
        XCTAssertEqual(request.paymentMethodUsage.stringValue, "SINGLE_USE")
    }
    
    func testCollectAddressFlags_setsDefaultValues() {
        let request = BTVenmoRequest(paymentMethodUsage: .singleUse)
        XCTAssertEqual(request.collectCustomerShippingAddress, false)
        XCTAssertEqual(request.collectCustomerBillingAddress, false)
    }

    func testIsFinalAmount_whenIsFinalAmountSetAsTrue_returnsTrue() {
        let request = BTVenmoRequest(paymentMethodUsage: .singleUse)
        request.isFinalAmount = true
        
        XCTAssertEqual(request.isFinalAmount, true)

    }

    func testIsFinalAmount_whenIsFinalAmountSetAsFalse_returnsFalse() {
        let request = BTVenmoRequest(paymentMethodUsage: .singleUse)
        request.isFinalAmount = false

        XCTAssertEqual(request.isFinalAmount, false)

    }

    func testIsFinalAmount_whenIsFinalAmountNotSet_defaultsToFalse() {
        let request = BTVenmoRequest(paymentMethodUsage: .singleUse)
        XCTAssertEqual(request.isFinalAmount, false)
    }
}
