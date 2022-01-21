import UIKit

class ViewController: UIViewController {

    @IBAction func didTapSuccessWithPaymentContext(_ sender: UIButton) {
        guard let successURL = AppSwitcher.successURLWithPaymentContext else { return }
        UIApplication.shared.open(successURL)
    }

    @IBAction func didTapSuccessWithoutPaymentContext(_ sender: UIButton) {
        guard let successURL = AppSwitcher.successURLWithoutPaymentContext else { return }
        UIApplication.shared.open(successURL)
    }

    @IBAction func didTapError(_ sender: UIButton) {
        guard let errorURL = AppSwitcher.errorURL else { return }
        UIApplication.shared.open(errorURL)
    }

    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        guard let cancelURL = AppSwitcher.cancelURL else { return }
        UIApplication.shared.open(cancelURL)
    }
}
