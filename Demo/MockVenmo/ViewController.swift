import UIKit

class ViewController: UIViewController {

    @IBAction func didTapSuccess(_ sender: UIButton) {
        guard let successURL = AppSwitcher.successURL else { return }
        UIApplication.shared.open(successURL, options: [:], completionHandler: nil)
    }

    @IBAction func didTapError(_ sender: UIButton) {
        guard let errorURL = AppSwitcher.errorURL else { return }
        UIApplication.shared.open(errorURL, options: [:], completionHandler: nil)
    }

    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        guard let cancelURL = AppSwitcher.cancelURL else { return }
        UIApplication.shared.open(cancelURL, options: [:], completionHandler: nil)
    }
}
