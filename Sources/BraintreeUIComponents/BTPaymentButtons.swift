import Foundation
import SwiftUI

#if canImport(BraintreeCore)
import BraintreeCore
#endif

struct BTPaymentButton: ButtonStyle {
    let buttonColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(buttonColor)
            .cornerRadius(4)
            .frame(width: 300, height: 45, alignment: .center)
    }
}

struct ContentView: View {

    var body: some View {
        Button(action: {
            print("Button pressed!")
        }) {
            HStack {
                Spacer()
                Image(.payPalLogoBlack)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 26)
                Spacer()
            }
        }
        .buttonStyle(BTPaymentButton(buttonColor: Color(red: 96 / 255, green: 205 / 255, blue: 255 / 255)))
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
    }
}
