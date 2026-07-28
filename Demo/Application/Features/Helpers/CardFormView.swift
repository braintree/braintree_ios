import SwiftUI

struct CardFormView: View {

    @Binding var cardNumber: String
    @Binding var expirationDate: String
    @Binding var cvv: String
    @Binding var postalCode: String
    @Binding var phoneNumber: String

    var hidePostalCodeField: Bool = false
    var hidePhoneNumberField: Bool = false
    var hideCVVField: Bool = false
    var fieldsEnabled: Bool = true

    private enum Field: Hashable {
        case cardNumber, expirationDate, cvv, postalCode, phoneNumber
    }

    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: 12) {
            styledField("Card Number", text: $cardNumber, field: .cardNumber, keyboard: .numberPad)

            HStack(spacing: 12) {
                styledField("MM/YY", text: $expirationDate, field: .expirationDate, keyboard: .numberPad)

                if !hideCVVField {
                    styledField("CVV", text: $cvv, field: .cvv, keyboard: .numberPad)
                }
            }

            if !hidePostalCodeField {
                styledField("Postal Code", text: $postalCode, field: .postalCode, keyboard: .default)
            }

            if !hidePhoneNumberField {
                styledField("Phone Number", text: $phoneNumber, field: .phoneNumber, keyboard: .phonePad)
            }
        }
    }

    @ViewBuilder
    private func styledField(
        _ placeholder: String,
        text: Binding<String>,
        field: Field,
        keyboard: UIKeyboardType
    ) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboard)
            .disabled(!fieldsEnabled)
            .focused($focusedField, equals: field)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor(for: field), lineWidth: 1)
            )
    }

    private func borderColor(for field: Field) -> Color {
        focusedField == field ? Color(.systemBlue) : Color(.systemGray4)
    }
}

#Preview {
    CardFormView(
        cardNumber: .constant(""),
        expirationDate: .constant(""),
        cvv: .constant(""),
        postalCode: .constant(""),
        phoneNumber: .constant("")
    )
    .padding()
}
