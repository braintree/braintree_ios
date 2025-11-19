//
//  VenmoButton.swift
//  BraintreeUIComponents
//
//  Created by Brent Busby on 11/18/25.
//

import SwiftUI

struct VenmoButton: View {

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
struct VenmoButton_Previews: PreviewProvider {

    static var previews: some View {
        VenmoButton(type: .black) {}
        VenmoButton(type: .venmoBlue) {}
        VenmoButton(type: .white) {}
    }
}
