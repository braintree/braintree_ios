import SwiftUI

struct CardFieldsView: View {

    // MARK: - Private Properties

    @StateObject private var viewModel = CardFieldsViewModel()

    // TODO: Programmatic focus transfer between fields requires the individual field views
    // to share a container-level @FocusState. Currently each field owns its @FocusState
    // internally. Auto-advance callbacks are wired up but focus movement is a follow-up task.

    // MARK: - View

    var body: some View {
        VStack(spacing: 12) {
            CardNumberFieldView(
                viewModel: viewModel.cardNumberViewModel,
                onAutoAdvance: {
                    // TODO: Move focus to expiration date field
                }
            )

            HStack(spacing: 12) {
                ExpirationDateFieldView(
                    viewModel: viewModel.expirationDateViewModel,
                    onAutoAdvance: {
                        // TODO: Move focus to CVV field
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
