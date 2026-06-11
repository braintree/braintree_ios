import SwiftUI

struct CardFieldsContainerView<Content: View>: View {

    let validationState: ValidationResult
    let isFocused: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: CardFieldsConstants.fieldSpacing) {
                content()
            }
            .padding(.horizontal, CardFieldsConstants.fieldHorizontalPadding)
            .padding(.vertical, CardFieldsConstants.fieldVerticalPadding)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: CardFieldsConstants.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: CardFieldsConstants.cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
            )

            if case .invalid(let message) = validationState {
                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 14))
                        .foregroundColor(.cardFieldErrorBorder)
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.cardFieldErrorBorder)
                        .padding(.horizontal, 4)
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var borderColor: Color {
        if case .invalid = validationState {
            return .cardFieldErrorBorder
        }
        return isFocused ? Color(.systemBlue) : Color(.systemGray4)
    }
}
