import SwiftUI

/// Venmo button doc here
public struct BTVenmoButton: View {

    let style: BTVenmoButtonStyle
    let action: () -> Void
    public var body: some View {
        Button(action: action) {
            HStack {
                Image(style.logoImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 26)
            }
            .frame(width: 300, height: 45)
            .background(style.backgroundColor)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(style.hasOutline ? Color.black : Color.clear, lineWidth: style.hasOutline ? 1 : 0)
            )
        }
    }
}
struct VenmoButton_Previews: PreviewProvider {

    static var previews: some View {
        VStack {
            BTVenmoButton(style: .black) {}
            BTVenmoButton(style: .blue) {}
            BTVenmoButton(style: .white) {}
        }
    }
}
