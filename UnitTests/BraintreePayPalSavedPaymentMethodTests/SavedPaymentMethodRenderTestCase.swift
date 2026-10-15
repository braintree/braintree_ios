import SwiftUI
import XCTest
@testable import BraintreeCore
@testable import BraintreePayPalSavedPaymentMethod

/// Shared rendering helpers for the component's render tests. `ImageRenderer` forces SwiftUI to
/// evaluate each `body`, which reaches layout defects the view model tests cannot.
@MainActor
class SavedPaymentMethodRenderTestCase: XCTestCase {

    /// `ImageRenderer` yields nil for zero-sized content, so a non-nil image means SwiftUI
    /// evaluated the whole tree and laid it out with a visible frame.
    @discardableResult
    func render(
        _ view: some View,
        width: CGFloat = 393,
        typeSize: DynamicTypeSize = .large
    ) throws -> UIImage {
        try XCTUnwrap(rendered(view, width: width, typeSize: typeSize))
    }

    func rendered(
        _ view: some View,
        width: CGFloat = 393,
        typeSize: DynamicTypeSize = .large
    ) -> UIImage? {
        let renderer = ImageRenderer(
            content: view
                .frame(width: width)
                .dynamicTypeSize(typeSize)
        )
        renderer.scale = 2
        return renderer.uiImage
    }

    func instrument(
        type: String = "CARD",
        label: String? = "Visa",
        lastDigits: String? = "1234",
        imageURL: String? = nil,
        subtype: String? = nil
    ) throws -> PayPalSavedPaymentMethod {
        var json: [String: Any] = ["type": type]
        json["label"] = label
        json["lastDigits"] = lastDigits
        json["imageUrl"] = imageURL
        json["subtype"] = subtype
        return try XCTUnwrap(PayPalSavedPaymentMethod(json: BTJSON(value: json)))
    }
}
