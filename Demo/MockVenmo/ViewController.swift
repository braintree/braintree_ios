import UIKit

class ViewController: UIViewController {

    @IBAction func didTapSuccessWithPaymentContext(_ sender: UIButton) {
        guard let successURL = AppSwitcher.successURLWithPaymentContext else { return }
        open(successURL)
    }

    @IBAction func didTapSuccessWithoutPaymentContext(_ sender: UIButton) {
        guard let successURL = AppSwitcher.successURLWithoutPaymentContext else { return }
        open(successURL)
    }

    @IBAction func didTapError(_ sender: UIButton) {
        guard let errorURL = AppSwitcher.errorURL else { return }
        open(errorURL)
    }

    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        guard let cancelURL = AppSwitcher.cancelURL else { return }
        open(cancelURL)
    }

    private func open(_ url: URL) {
        UIApplication.shared.open(url) { success in
            print("DEBUG - MockVenmo UIApplication.shared.open(\(url.absoluteString)) success: \(success)")
        }
    }
}
