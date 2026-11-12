import SwiftUI

/// TODO: Remove once the Payment Actions backend is ready.
///
/// Explains what is and isn't real in the 3DS flow while the Payment Actions server is stubbed.
struct StubbedServerNotice: View {

    var body: some View {
        Text("Real Cardinal and Gateway lookup, with the Payment Actions server stubbed until the backend "
            + "is ready.")
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
