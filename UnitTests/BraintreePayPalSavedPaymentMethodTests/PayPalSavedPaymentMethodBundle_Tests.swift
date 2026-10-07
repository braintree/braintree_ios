import XCTest
import UIKit
@testable import BraintreePayPalSavedPaymentMethod

final class PayPalSavedPaymentMethodBundle_Tests: XCTestCase {

    /// The rows load their artwork from this bundle at render time, so a mis-resolved bundle
    /// surfaces as silently missing artwork rather than a build error.
    func testBundle_containsTheRowAssets() {
        let bundle = Bundle.payPalSavedPaymentMethod

        for asset in ["CardFundingIcon", "BankFundingIcon", "EditPencil", "PayPalBadge"] {
            XCTAssertNotNil(
                UIImage(named: asset, in: bundle, compatibleWith: nil),
                "\(asset) missing from \(bundle.bundlePath)"
            )
        }
    }
}
