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

#Preview("Validation Error States") {
    ScrollView {
        VStack(spacing: 24) {

            // Card Number — invalid
            CardFieldsContainerView(
                validationState: .invalid("Card number is invalid"),
                isFocused: false
            ) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Card number")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.secondaryLabel))
                    Text("4111 1111 1111 111")
                        .font(.system(size: 16))
                        .foregroundColor(Color(.label))
                }
                Spacer()
            }

            // Expiration — in the past
            CardFieldsContainerView(
                validationState: .invalid("Expiration date is invalid"),
                isFocused: false
            ) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Expiration (MM/YY)")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.secondaryLabel))
                    Text("12/23")
                        .font(.body)
                        .foregroundColor(Color(.label))
                }
                Spacer()
            }

            // CVV — blank
            CardFieldsContainerView(
                validationState: .invalid("CVV is invalid"),
                isFocused: false
            ) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CVV")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.secondaryLabel))
                    Text("")
                        .font(.system(size: 16))
                        .foregroundColor(Color(.label))
                }
                Spacer()
            }
        }
        .padding()
    }
}
