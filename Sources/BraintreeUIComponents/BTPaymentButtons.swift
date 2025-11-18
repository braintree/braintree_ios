import Foundation
import SwiftUI

#if canImport(BraintreeCore)
import BraintreeCore
#endif

struct PaymentButtonStyle: ButtonStyle {
    
    let backgroundColor: Color
    let imageName: ImageResource
    let hasOutline: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(hasOutline ? Color.black : Color.clear, lineWidth: hasOutline ? 1 : 0)
            )
            .cornerRadius(4)
            .frame(width: 300, height: 45, alignment: .center)
    }
}

struct PaymentButton: View {
    
    let imageName: ImageResource
    let backgroundColor: Color
    let hasOutline: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 26)
                Spacer()
            }
        }
        .buttonStyle(PaymentButtonStyle(backgroundColor: backgroundColor, imageName: imageName, hasOutline: hasOutline))
    }
}
