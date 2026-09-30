import XCTest
@testable import BraintreePayPalSavedPaymentMethod

final class BTPayPalSavedPaymentMethodViewStyle_Tests: XCTestCase {

    /// These three are opt-out, not opt-in: a merchant who passes no style gets the full component.
    func testDefaultStyle_showsLogoLabelAndCreditMessaging() {
        let style = BTPayPalSavedPaymentMethodViewStyle()

        XCTAssertTrue(style.showPayPalLogo)
        XCTAssertTrue(style.showPayPalLabel)
        XCTAssertTrue(style.showPayPalCreditMessaging)
    }
}
