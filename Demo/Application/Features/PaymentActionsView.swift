import SwiftUI

struct PaymentActionsView: View {

    @StateObject private var viewModel: PaymentActionsViewModel

    init(authorization: String, onProgress: @escaping (String?) -> Void = { _ in }) {
        _viewModel = StateObject(wrappedValue: PaymentActionsViewModel(authorization: authorization, onProgress: onProgress))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                flowPicker

                optionPickers

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
                    viewModel.createPaymentAction()
                } label: {
                    Label("Get New Payment Action", systemImage: "arrow.clockwise")
                }
                .disabled(viewModel.isRunning)

                payButton

                if let outcome = viewModel.outcome {
                    PaymentOutcomeBanner(outcome: outcome)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    // MARK: - Styled Subviews

    private var flowPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Flow", selection: $viewModel.flow) {
                ForEach(PaymentFlowKind.allCases) { flow in
                    Text(flow.title).tag(flow)
                }
            }
            .pickerStyle(.segmented)

            if viewModel.flow == .threeDSecure {
                StubbedServerNotice() // MOCK-REMOVAL
            } else {
                Text("A real sample-merchant Payment Action. 3DS isn't requested.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .disabled(viewModel.isRunning)
    }

    private var optionPickers: some View {
        VStack(spacing: 8) {
            modePicker(title: "Confirmation", selection: $viewModel.confirmationMode)
            modePicker(title: "Capture", selection: $viewModel.captureMode)
        }
        .disabled(viewModel.isRunning)
    }

    private func modePicker(title: String, selection: Binding<PaymentActionMode>) -> some View {
        HStack {
            Text(title)
            Spacer()
            Picker(title, selection: selection) {
                ForEach(PaymentActionMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 180)
        }
    }

    private var payButton: some View {
        Button("Pay") {
            viewModel.tappedPay()
        }
        .buttonStyle(CapsuleButtonStyle(isEnabled: viewModel.isPayButtonEnabled && !viewModel.isRunning))
        .disabled(!viewModel.isPayButtonEnabled || viewModel.isRunning)
        .padding(.horizontal)
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
