import SwiftUI

struct CVVFieldView: View {

    // MARK: - Internal Properties

    @ObservedObject var viewModel: CVVFieldViewModel
    var containerWidth: CGFloat = CardFieldsConstants.defaultContainerWidth
    var onAutoAdvance: (() -> Void)?

    // MARK: - Private Properties

    @FocusState private var isFocused: Bool
    @State private var showCVVHint: Bool = false
    @State private var textFieldText: String = ""

    private var popoverWidth: CGFloat {
        let preferred = containerWidth - CardFieldsConstants.popoverWidthPadding
        return min(max(CardFieldsConstants.popoverMinWidth, preferred), CardFieldsConstants.popoverMaxWidth)
    }

    // MARK: - View

    var body: some View {
        CardFieldsContainerView(
            validationState: viewModel.validationState,
            isFocused: isFocused
        ) {
            VStack(alignment: .leading, spacing: 2) {
                Text("CVV")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.secondaryLabel))

                ZStack(alignment: .leading) {
                    TextField("", text: $textFieldText)
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .foregroundColor(.clear)
                    .tint(Color(.label))
                    .font(.system(size: 16))
                    .accessibilityLabel("CVV")
                    .accessibilityHint("3 or 4-digit security code")
                    .onChange(of: textFieldText) { _, newValue in
                        let digits = String(newValue.filter { $0.isNumber }.prefix(viewModel.maxLength))
                        if digits != textFieldText {
                            textFieldText = digits
                        }
                        viewModel.updateValue(digits)
                    }

                    if viewModel.characters.isEmpty {
                        Text("•••")
                            .font(.system(size: 16))
                            .foregroundColor(Color(.placeholderText))
                    } else {
                        HStack(spacing: 2) {
                            ForEach(viewModel.characters) { character in
                                Text(character.isMasked ? "•" : String(character.value))
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(.label))
                                    .animation(.easeInOut(duration: 0.3), value: character.isMasked)
                            }
                        }
                    }
                }
                .frame(height: 24)
            }

            Spacer()

            // Help icon
            Button {
                showCVVHint = true
            } label: {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(Color(.secondaryLabel))
                    .font(.system(size: 16))
            }
            .accessibilityLabel("CVV help")
            .accessibilityHint("Tap for information about where to find your CVV")
            .popover(isPresented: $showCVVHint, arrowEdge: .bottom) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("CVV")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(.label))

                    Text("The CVV is the 3 or 4-digit number on the back of your card")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.secondaryLabel))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: popoverWidth)
                .padding(CardFieldsConstants.popoverPadding)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("CVV help information")
                .presentationCompactAdaptation(.popover)
            }
        }
        .onChange(of: isFocused) { _, focused in
            viewModel.isFocused = focused
        }
        .onChange(of: viewModel.shouldAutoAdvance) { _, shouldAdvance in
            if shouldAdvance { onAutoAdvance?() }
        }
        .onChange(of: viewModel.isFocused) { _, focused in
            if focused { isFocused = true }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
    }
}

#Preview {
    CVVFieldView(viewModel: CVVFieldViewModel())
        .padding()
}
