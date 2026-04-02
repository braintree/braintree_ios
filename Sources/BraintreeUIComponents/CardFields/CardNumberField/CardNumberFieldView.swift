import SwiftUI

struct CardNumberFieldView<ViewModel: CardFieldsViewModelProtocol>: View {
    
    @ObservedObject var viewModel: ViewModel
    var onAutoAdvance: (() -> Void)?
    @FocusState private var isFocused: Bool

    
    var body: some View {
        CardFieldsContainerView(
            validationState: viewModel.validationState,
            isFocused: isFocused
        ) {
            CardBrandView()

            VStack(alignment: .leading, spacing: 2) {
                Text("Card number")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.secondaryLabel))

                TextField("", text: Binding(
                    get: { viewModel.value },
                    set: { viewModel.updateValue($0) }
                ))
                .keyboardType(.numberPad)
                .focused($isFocused)
                .font(.system(size: 16))
                .foregroundColor(Color(.label))
            }

            Spacer()
        }
        // TODO: update to new onChange when minimum target moved to iOS 17.0
        .onChange(of: isFocused) { focused in
            viewModel.isFocused = focused
        }
        .onChange(of: viewModel.shouldAutoAdvance) { shouldAdvance in
            if shouldAdvance { onAutoAdvance?() }
        }
    }
}

#Preview {
    CardNumberFieldView(viewModel: CardNumberFieldViewModel())
}
