import SwiftUI

struct PaymentActionsView: View {

    @StateObject private var viewModel: PaymentActionsViewModel

    init(authorization: String) {
        _viewModel = StateObject(wrappedValue: PaymentActionsViewModel(authorization: authorization))
    }

    var body: some View {
        Form {
            Section("Card Details") {
                CardFormView(
                    cardNumber: $viewModel.cardNumber,
                    expirationDate: $viewModel.expirationDate,
                    cvv: $viewModel.cvv,
                    postalCode: $viewModel.postalCode,
                    phoneNumber: .constant(""),
                    hidePhoneNumberField: true,
                    fieldsEnabled: viewModel.isCardFieldsEnabled
                )

                Button("Autofill") {
                    viewModel.tappedAutofill()
                }
                .font(.subheadline.weight(.medium))
                .buttonStyle(.bordered)
                .tint(.black)
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(!viewModel.isCardFieldsEnabled)
            }

            Section("Payment Actions Flow") {
                Label(viewModel.paymentActionConfigText, systemImage: "gearshape")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Button {
                    viewModel.fetchClientToken()
                } label: {
                    Label("Get New Payment Action", systemImage: "arrow.clockwise")
                }

                payButton
            }

            if !viewModel.progressMessage.isEmpty {
                Section {
                    statusRow
                }
            }
        }
        .navigationTitle("Payment Actions")
        .onAppear {
            viewModel.onAppear()
        }
    }

    // MARK: - Styled Subviews

    private var payButton: some View {
        Button("Pay") {
            viewModel.tappedPay()
        }
        .buttonStyle(CapsuleButtonStyle(isEnabled: viewModel.isPayButtonEnabled))
        .disabled(!viewModel.isPayButtonEnabled)
        .listRowInsets(EdgeInsets())
        .padding(.horizontal)
        .listRowBackground(Color.clear)
    }

    private var statusRow: some View {
        Label(viewModel.progressMessage, systemImage: statusKind.icon)
            .font(.subheadline.weight(.medium))
            .foregroundColor(statusKind.color)
    }

    /// Best-effort classification of `progressMessage` for status coloring. `progressMessage` is a
    /// plain display string rather than a typed status, so this matches on the same substrings the
    /// view model already uses when setting it (e.g. "complete ✅", "declined", "Failed").
    private var statusKind: StatusKind {
        let message = viewModel.progressMessage
        if message.contains("✅") || message.contains("Ready") {
            return .success
        } else if message.contains("Failed") || message.contains("declined") {
            return .failure
        } else {
            return .neutral
        }
    }
}

// MARK: - Status Styling

private enum StatusKind {
    case success, failure, neutral

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .failure: return "exclamationmark.triangle.fill"
        case .neutral: return "clock"
        }
    }

    var color: Color {
        switch self {
        case .success: return .green
        case .failure: return .red
        case .neutral: return .secondary
        }
    }
}

// MARK: - Button Styling

/// Full-width black capsule button matching the house style used by CardTokenizationView's
/// "Submit" and UIComponentsViewController's primary action buttons.
private struct CapsuleButtonStyle: ButtonStyle {

    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isEnabled ? Color.black : Color.black.opacity(0.3))
            .clipShape(Capsule())
    }
}
