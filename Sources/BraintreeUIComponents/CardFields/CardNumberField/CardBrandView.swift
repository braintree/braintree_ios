import SwiftUI

struct CardBrandView: View {
    
    let brand: CardBrand
    
    // TODO: Add logic to display correct card brand
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .stroke(Color(.systemGray4), lineWidth: 1)
            .frame(width: 44, height: 30)
            .overlay {
                brand.image
                    .resizable()
                    .scaledToFit()
            }
    }
}

#Preview {
    CardBrandView(brand: .unknown)
    CardBrandView(brand: .visa)
    CardBrandView(brand: .mastercard)
    CardBrandView(brand: .amex)
    CardBrandView(brand: .jcb)
    CardBrandView(brand: .unionPay)
}
