import SwiftUI

struct CardBrandView: View {
    
    // TODO: Add logic to display correct card brand 
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .stroke(Color(.systemGray4), lineWidth: 1)
            .frame(width: 44, height: 30)
    }
}

#Preview {
    CardBrandView()
}
