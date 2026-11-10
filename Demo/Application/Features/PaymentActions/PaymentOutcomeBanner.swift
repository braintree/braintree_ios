import SwiftUI

/// Shows the final outcome of a payment, with a distinct look for every variant.
struct PaymentOutcomeBanner: View {

    let outcome: PaymentOutcome

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: style.systemImage)
                .font(.title2)
                .foregroundColor(style.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(style.title)
                    .font(.headline)
                Text(style.detail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Payment Action \(outcome.paymentActionID)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(style.color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }

    // MARK: - Style

    private struct Style {

        let title: String
        let detail: String
        let systemImage: String
        let color: Color
    }

    private var style: Style {
        switch outcome.status {
        case .success:
            return Style(
                title: "Payment succeeded",
                detail: "The transaction was confirmed and captured.",
                systemImage: "checkmark.circle.fill",
                color: .green
            )
        case .capturePending:
            return Style(
                title: "Authorized, capture pending",
                detail: "The payment is authorized. The merchant still has to capture it.",
                systemImage: "clock.fill",
                color: .blue
            )
        case .declined:
            return Style(
                title: "Payment method declined",
                detail: "Try another card.",
                systemImage: "xmark.circle.fill",
                color: .red
            )
        case .threeDSecureCanceled:
            return Style(
                title: "Bank challenge canceled",
                detail: "The shopper abandoned the challenge. The Payment Action is still active, so tap Pay to try again.",
                systemImage: "hand.raised.fill",
                color: .orange
            )
        case .canceled:
            return Style(
                title: "Payment Action canceled",
                detail: "It can't be used again. Get a new Payment Action.",
                systemImage: "slash.circle.fill",
                color: .gray
            )
        case .expired:
            return Style(
                title: "Payment Action expired",
                detail: "Get a new Payment Action.",
                systemImage: "hourglass",
                color: .gray
            )
        case .unrecognized:
            return Style(
                title: "Unrecognized status",
                detail: "This SDK version doesn't recognize the Payment Action's status.",
                systemImage: "questionmark.circle.fill",
                color: .purple
            )
        case .processing:
            return Style(
                title: "Still processing",
                detail: "The SDK's retries ran out while the server was still settling. Wait, then check again.",
                systemImage: "arrow.triangle.2.circlepath.circle.fill",
                color: .indigo
            )
        case .customerActionRequired:
            return Style(
                title: "Customer action required",
                detail: "The payment needs input the SDK can't gather. Shown once, without looping.",
                systemImage: "person.fill.questionmark",
                color: .yellow
            )
        case .confirmationRequired:
            return Style(
                title: "Awaiting merchant confirmation",
                detail: "The merchant server still has to confirm this Payment Action.",
                systemImage: "checkmark.shield.fill",
                color: .teal
            )
        }
    }
}
