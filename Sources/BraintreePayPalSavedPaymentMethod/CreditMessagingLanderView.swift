import SwiftUI
import WebKit

/// Bottom-sheet webview shown when the buyer taps "Learn more" on the credit-messaging
/// line — it loads the offer's `click_url` lander. This is the one net-new UI surface for
/// the component (the FI row and messaging line are assembled natively).
///
/// The URL is supplied by the credit-messaging response when the API is wired in; until
/// then a placeholder is shown.
struct CreditMessagingLanderView: View {

    let url: URL?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Group {
                if let url {
                    CreditMessagingWebView(url: url)
                } else {
                    ContentUnavailableFallback()
                }
            }
            .navigationTitle("Pay Later")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

/// A thin `WKWebView` wrapper for the lander content.
private struct CreditMessagingWebView: UIViewRepresentable {

    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
}

/// Placeholder shown when no lander URL is available yet (API not wired in).
private struct ContentUnavailableFallback: View {

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "creditcard")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("Pay Later details will appear here.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
