import SwiftUI

struct PaymentButton: View {

    let type: BTPaymentButtonType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(type.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 26)
            }
            .frame(width: 300, height: 45)
            .background(type.backgroundColor)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(type.hasOutline ? Color.black : Color.clear, lineWidth: type.hasOutline ? 1 : 0)
            )
        }
    }
}

struct ContentView: View {

    var body: some View {
        VStack(spacing: 16) {
            // Primary Button
            PaymentButton(type: .primary) {}

            // Black Button
            PaymentButton(type: .black) {}

            // White Button
            PaymentButton(type: .white) {}
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
    }
}
