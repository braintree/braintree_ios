import SwiftUI
import SafariServices

/// Presents the credit-messaging "Learn more" lander (`click_url`) in an
/// `SFSafariViewController`, giving buyers Safari's built-in security and reader chrome
/// without pulling in a new dependency or triggering an app-switch consent alert.
struct PayPalCreditMessagingLanderView: UIViewControllerRepresentable {

    let url: URL

    /// Called when the buyer taps Safari's "Done" button, so the presenter can clear its state.
    let onFinish: () -> Void

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: url)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {
        context.coordinator.onFinish = onFinish
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, SFSafariViewControllerDelegate {

        var onFinish: () -> Void

        init(onFinish: @escaping () -> Void) {
            self.onFinish = onFinish
        }

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            onFinish()
        }
    }
}
