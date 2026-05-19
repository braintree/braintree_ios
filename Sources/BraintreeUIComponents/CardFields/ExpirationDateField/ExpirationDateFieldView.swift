import SwiftUI

struct ExpirationDateFieldView: View {

    // MARK: - Internal Properties

    @ObservedObject var viewModel: ExpirationDateFieldViewModel
    var onAutoAdvance: (() -> Void)?
    
    // MARK: - Private Properties

    @FocusState private var isFocused: Bool
    @State private var textFieldText: String = ""

    var body: some View {
        CardFieldsContainerView(
            validationState: viewModel.validationState,
            isFocused: isFocused
        ) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Expiration (MM/YY)")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.secondaryLabel))

                TextField("", text: $textFieldText)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .font(.body)
                    .foregroundColor(Color(.label))
                    .onChange(of: textFieldText) { _, newValue in
                        let digits = String(newValue.filter { $0.isNumber }.prefix(viewModel.maxLength))
                        let formatted = digits.count > 2
                            ? "\(digits.prefix(2))/\(digits.dropFirst(2))"
                            : String(digits)
                        if formatted != textFieldText {
                            textFieldText = formatted
                        }
                        viewModel.updateValue(formatted)
                    }
            }

            Spacer()
        }
        .onChange(of: isFocused) { _, focused in
            viewModel.isFocused = focused
        }
        .onChange(of: viewModel.shouldAutoAdvance) { _, shouldAutoAdvance in
            if shouldAutoAdvance { onAutoAdvance?() }
        }
        .onChange(of: viewModel.isFocused) { _, focused in
            if focused { isFocused = true }
        }
    }
}

#Preview {
    ExpirationDateFieldView(viewModel: ExpirationDateFieldViewModel())
}
