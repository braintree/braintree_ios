import SwiftUI

struct CVVFieldView<ViewModel: CVVFieldViewModel>: View {

    // MARK: - Internal Properties

    @ObservedObject var viewModel: ViewModel
    var onAutoAdvance: (() -> Void)?

    // MARK: - Private Properties

    @FocusState private var isFocused: Bool
    @State private var showCVVHint: Bool = false

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
                    TextField("", text: Binding(
                        get: { viewModel.rawValue },
                        set: { viewModel.updateValue($0) }
                    ))
                    .keyboardType(.numberPad)
                    .focused($isFocused)
                    .foregroundColor(.clear)
                    .tint(Color(.label))
                    .font(.system(size: 16))

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
            .popover(isPresented: $showCVVHint, arrowEdge: .bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CVV")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(.label))

                    Text("The CVV is the 3 or 4-digit number on the back of your card")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.secondaryLabel))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .presentationCompactAdaptation(.popover)
            }
        }
        .onChange(of: isFocused) { _, focused in
            viewModel.isFocused = focused
        }
        .onChange(of: viewModel.shouldAutoAdvance) { _, shouldAdvance in
            if shouldAdvance { onAutoAdvance?() }
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
