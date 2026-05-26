import SwiftUI

/// A SwiftUI view that renders a complete card entry form, including fields for card number,
/// expiration date, and CVV. It handles input validation, card brand detection, and focus
/// advancement between fields automatically.
struct CardFields: View {

    // MARK: - Private Properties

    @StateObject private var viewModel = CardFieldsViewModel()

    // MARK: - View

    var body: some View {
        VStack(spacing: 12) {
            CardNumberFieldView(
                viewModel: viewModel.cardNumberViewModel,
                onAutoAdvance: {
                    viewModel.expirationDateViewModel.isFocused = true
                },
                onBrandChanged: { brand in
                    let length: Int? = brand == .unknown ? nil : brand.cvvLength
                    viewModel.cvvViewModel.updateExpectedLength(length)
                }
            )

            HStack(spacing: 12) {
                ExpirationDateFieldView(viewModel: viewModel.expirationDateViewModel) {
                    viewModel.cvvViewModel.isFocused = true
                }

                CVVFieldView(viewModel: viewModel.cvvViewModel)
            }
        }
        .padding()
    }
}

#Preview {
    CardFields()
}
