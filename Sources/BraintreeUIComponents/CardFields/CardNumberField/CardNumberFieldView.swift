import SwiftUI

struct CardNumberFieldView: View {

    @ObservedObject var viewModel: CardNumberFieldViewModel
    var onAutoAdvance: (() -> Void)?
    var onBrandChanged: (CardBrand) -> Void
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
                    .accessibilityLabel("Card Number")
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
        .onChange(of: viewModel.cardBrand) { _, brand in
            onBrandChanged(brand)
        }
    }
}

#Preview {
    CardNumberFieldView(viewModel: CardNumberFieldViewModel()) { _ in }
}
