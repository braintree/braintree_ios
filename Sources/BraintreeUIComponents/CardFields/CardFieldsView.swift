import SwiftUI

struct CardFieldsView: View {

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
                ExpirationDateFieldView(
                    viewModel: viewModel.expirationDateViewModel,
                    onAutoAdvance: {
                        viewModel.cvvViewModel.isFocused = true
                    }
                )

                CVVFieldView(viewModel: viewModel.cvvViewModel)
            }
        }
        .padding()
    }
}

#Preview {
    CardFieldsView()
}
