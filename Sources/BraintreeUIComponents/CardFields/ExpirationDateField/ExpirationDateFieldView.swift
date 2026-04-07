import SwiftUI

struct ExpirationDateFieldView<ViewModel: CardFieldsViewModelProtocol>: View {
    
    // MARK: - Internal Properties
    
    @ObservedObject var viewModel: ViewModel
    var onAutoAdvance: (() -> Void)?
    
    // MARK: - Private Properties
    
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
        .onChange(of: isFocused) { _, focused in
            viewModel.isFocused = focused
        }
        .onChange(of: viewModel.shouldAutoAdvance) { _, shouldAutoAdance in
            if shouldAutoAdance { onAutoAdvance?() }
        }
    }
}

#Preview {
    ExpirationDateFieldView(viewModel: ExpirationDateFieldViewModel())
}
