import SwiftUI

/// Floating hint card shown on iPhone iOS 16.0–16.3 as a replacement for the native `.popover`,
/// which degrades to a full-screen sheet on those OS versions.
// NEXT_MAJOR_VERSION: delete this file when minimum target moved to iOS 16.4 or higher
struct CVVHintCard: View {

    let width: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CVV")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(.label))

            Text("The CVV is the 3 or 4-digit number on the back of your card")
                .font(.system(size: 14))
                .foregroundColor(Color(.secondaryLabel))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: width)
        .padding(CardFieldsConstants.popoverPadding)
        .background(
            RoundedRectangle(cornerRadius: CardFieldsConstants.cornerRadius)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: -4)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("CVV help information")
    }
}
