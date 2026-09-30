import SwiftUI
import SafariServices

/// Presents the credit-messaging "Learn more" lander (`click_url`) in an
/// `SFSafariViewController`, giving buyers Safari's built-in security and reader chrome
/// without pulling in a new dependency or triggering an app-switch consent alert.
struct BTPayPalCreditMessagingLanderView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}
