import SwiftUI

struct CardNumberFieldView: View {

    @ObservedObject var viewModel: CardNumberFieldViewModel
    var onAutoAdvance: (() -> Void)?
    @FocusState private var isFocused: Bool
    @State private var textFieldText: String = ""

    var body: some View {
        CardFieldsContainerView(
            validationState: viewModel.validationState,
            isFocused: isFocused
        ) {
            CardBrandView(brand: viewModel.cardBrand)

            VStack(alignment: .leading, spacing: 2) {
                Text("Card number")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.secondaryLabel))

                TextField("", text: $textFieldText)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .font(.system(size: 16))
                    .foregroundColor(Color(.label))
                    .onChange(of: textFieldText) { _, newValue in
                        let digits = String(newValue.filter { $0.isNumber }.prefix(viewModel.maxLength))
                        let formatted = viewModel.formatted(digits: digits)
                        if formatted != textFieldText {
                            textFieldText = formatted
                        }
                        viewModel.updateValue(digits)
                    }
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
