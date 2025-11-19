import SwiftUI

struct PayPalButton: View {

    let type: BTPaymentButtonStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(type.logoImage)
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
            PayPalButton(type: .primaryPayPal) {}

            // Black Button
            PayPalButton(type: .black) {}

            // White Button
            PayPalButton(type: .white) {}
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
    }
}
