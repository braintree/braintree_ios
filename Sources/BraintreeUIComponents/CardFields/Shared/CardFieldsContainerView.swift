import SwiftUI

struct CardFieldsContainerView<Content: View>: View {

    let validationState: ValidationResult
    let isFocused: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                content()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
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
