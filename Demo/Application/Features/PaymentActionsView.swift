import SwiftUI

struct PaymentActionsView: View {
    
    @StateObject private var viewModel: PaymentActionsViewModel

    init(authorization: String, onProgress: @escaping (String?) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: PaymentActionsViewModel(authorization: authorization, onProgress: onProgress))
    }

    var body: some View {
        VStack(spacing: 10) {
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
            .disabled(!viewModel.isCardFieldsEnabled)

            Button {
                viewModel.fetchClientToken()
            } label: {
                Label("Get New Payment Action", systemImage: "arrow.clockwise")
            }

            payButton
        }
        .padding(.horizontal)
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
