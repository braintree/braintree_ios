import SwiftUI

struct ExpirationDateFieldView<ViewModel: CardFieldsViewModelProtocol>: View {
    
    @ObservedObject var viewModel: ViewModel
    var onAutoAdvance: (() -> Void)?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        CardFieldsContainerView(
            validationState: viewModel.validationState,
            isFocused: isFocused
        ) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Expiration (MM/YY)")
                    .font(.caption)
                    .foregroundColor(Color(.secondaryLabel))
                
                TextField(
                    "",
                    text: Binding(
                    get: { viewModel.value },
                    set: { viewModel.updateValue($0) }
                  )
                )
                .keyboardType(.numberPad)
                .focused($isFocused)
                .font(.body)
                .foregroundColor(Color(.label))
            }
            
            Spacer()
        }
        .frame(width: 179, height: 64)
        // update `onChange(of:perform:)` signature once min deployment target is iOS 17
        .onChange(of: isFocused) { focused in
            viewModel.isFocused = focused
        }
        .onChange(of: viewModel.shouldAutoAdvance) { shouldAutoAdance in
            if shouldAutoAdance { onAutoAdvance?() }
        }
    }
}

#Preview {
    ExpirationDateFieldView(viewModel: ExpirationDateFieldViewModel())
}
