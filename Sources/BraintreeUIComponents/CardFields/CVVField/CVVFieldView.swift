import SwiftUI

struct CVVFieldView: View {

    // MARK: - Internal Properties

    @ObservedObject var viewModel: CVVFieldViewModel
    @Binding var showCVVHint: Bool
    var containerWidth: CGFloat = CardFieldsConstants.defaultContainerWidth
    var onAutoAdvance: (() -> Void)?

    // MARK: - Private Properties

    @FocusState private var isFocused: Bool
    @State private var textFieldText: String = ""

    private var popoverWidth: CGFloat {
        let preferred = containerWidth - CardFieldsConstants.popoverWidthPadding
        return min(max(CardFieldsConstants.popoverMinWidth, preferred), CardFieldsConstants.popoverMaxWidth)
    }

    // NEXT_MAJOR_VERSION: remove this and always return $showCVVHint when minimum target moved to iOS 16.4 or higher
    /// Returns the real binding on iOS 16.4+ and iPad where `.popover` works correctly.
    /// On iPhone < iOS 16.4, `.popover` degrades to a full-screen sheet — suppress it here
    /// so `CardFields` can show the custom floating hint card instead.
    private var nativeHintBinding: Binding<Bool> {
        if #available(iOS 16.4, *) {
            return $showCVVHint
        }
        if UIDevice.current.userInterfaceIdiom == .pad {
            return $showCVVHint
        }
        return .constant(false)
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
                    .onChange(of: textFieldText) { newValue in
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
            .popover(isPresented: nativeHintBinding, arrowEdge: .bottom) {
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
                .presentationCompactAdaptationIfAvailable()
            }
        }
        .onChange(of: isFocused) { focused in
            viewModel.isFocused = focused
        }
        .onChange(of: viewModel.shouldAutoAdvance) { shouldAdvance in
            if shouldAdvance { onAutoAdvance?() }
        }
        .onChange(of: viewModel.isFocused) { focused in
            if focused { isFocused = true }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
    }
}

// MARK: - Private Extensions

private extension View {
    
    // NEXT_MAJOR_VERSION: remove this and call .presentationCompactAdaptation(.popover) directly
    // when minimum target moved to iOS 16.4 or higher
    /// Applies `.presentationCompactAdaptation(.popover)` on iOS 16.4+, keeping the `.popover`
    /// modifier from degrading to a full-screen sheet on iPhone compact size class.
    @ViewBuilder
    func presentationCompactAdaptationIfAvailable() -> some View {
        if #available(iOS 16.4, *) {
            self.presentationCompactAdaptation(.popover)
        } else {
            self
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        
        @State private var showHint = false
        var body: some View {
            CVVFieldView(viewModel: CVVFieldViewModel(), showCVVHint: $showHint)
                .padding()
        }
    }
    return PreviewWrapper()
}
