import UIKit
import BraintreeCore
import InAppSettingsKit

class ContainmentViewController: UIViewController {

    // MARK: - Private Properties

    private var statusItem: UIBarButtonItem?

    private var currentViewController: BaseViewController? {
        didSet {
            guard let currentViewController else {
                updateStatus("Demo not available")
                return
            }

            updateStatus("Presenting \(type(of: currentViewController))")
            currentViewController.progressBlock = progressBlock
            currentViewController.completionBlock = completionBlock

            appendViewController(currentViewController)
            title = currentViewController.title
        }
    }

    private var currentPaymentMethodNonce: BTPaymentMethodNonce? {
        didSet {
            statusItem?.isEnabled = (currentPaymentMethodNonce != nil)
        }
    }

    // MARK: - Progress and Completion Blocks

    func progressBlock(_ status: String?) {
        guard let status else { return }
        updateStatus(status)
    }

    func completionBlock(_ nonce: BTPaymentMethodNonce?) {
        currentPaymentMethodNonce = nonce
        updateStatus("Got a nonce. Tap to make a transaction.")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Braintree"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(tappedRefresh))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(tappedSettings))

        navigationController?.setToolbarHidden(false, animated: true)
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance

        setupToolbar()
        reloadIntegration()
    }

    private func setupToolbar() {
        let padding = UIBarButtonItem(systemItem: .flexibleSpace)

        let button = UIButton(type: .custom)
        button.titleLabel?.numberOfLines = 0
        button.setTitle("Ready", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(tappedStatus), for: .touchUpInside)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 14)

        let frame = navigationController?.navigationBar.frame
        button.frame = CGRect(x: 0, y: 0, width: frame?.size.width ?? 100, height: frame?.size.height ?? 20)

        // Use custom view with button so the text can span multiple lines
        statusItem = UIBarButtonItem(customView: button)
        statusItem?.isEnabled = false

        toolbarItems = [padding, statusItem!, padding]
    }

    // MARK: - UI Updates

    private func updateStatus(_ status: String) {
        DispatchQueue.main.async {
            (self.statusItem?.customView as? UIButton)?.setTitle(status, for: .normal)
            (self.statusItem?.customView as? UIButton)?.setTitleColor(.label, for: .normal)
            print((self.statusItem?.customView as? UIButton)?.titleLabel?.text ?? "no status returned")
        }
    }

    // MARK: - UI Handlers

    @objc func tappedRefresh() {
        reloadIntegration()
    }

    @objc func tappedSettings() {
        let appSettingsViewController = IASKAppSettingsViewController()
        appSettingsViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: appSettingsViewController)

        present(navigationController, animated: true)
    }

    @objc private func tappedStatus() {
        print("Tapped status!")

        if let currentPaymentMethodNonce {
            let nonce = currentPaymentMethodNonce.nonce
            updateStatus("Creating Transaction…")

            let merchantAccountID = currentPaymentMethodNonce.type == "UnionPay" ? "fake_switch_usd" : nil

            BraintreeDemoMerchantAPIClient.shared.makeTransaction(
                paymentMethodNonce: nonce,
                merchantAccountID: merchantAccountID
            ) { transactionID, error in
                self.currentPaymentMethodNonce = nil

                if let error {
                    self.updateStatus(error.localizedDescription)
                } else if let transactionID {
                    self.updateStatus(transactionID)
                } else {
                    self.updateStatus("No nonce or error was returned from the server side request")
                }
            }
        }
    }

    // MARK: - Demo Integration Lifecycle

    private func reloadIntegration() {
        if let currentViewController {
            currentViewController.willMove(toParent: nil)
            currentViewController.removeFromParent()
            currentViewController.view.removeFromSuperview()
        }

        title = "Braintree"

        if let authorizationOverride = BraintreeDemoSettings.authorizationOverride {
            currentViewController = instantiateViewController(with: authorizationOverride)
        }

        switch BraintreeDemoSettings.authorizationType {
        case .tokenizationKey:
            updateStatus("Using Tokenization Key")

            // If we're using a Tokenization Key, then we're not using a Customer.
            var tokenizationKey: String = ""
            switch BraintreeDemoSettings.currentEnvironment {
            case .sandbox:
                tokenizationKey = "sandbox_9dbg82cq_dcpspy2brwdjr3qn"
            case .production:
                tokenizationKey = "production_t2wns2y2_dfy45jdj3dxkmz5m"
            default:
                tokenizationKey = "development_testing_integration_merchant_id"
            }

            currentViewController = instantiateViewController(with: tokenizationKey)

        case .clientToken:
            updateStatus("Fetching Client Token...")

            BraintreeDemoMerchantAPIClient.shared.createCustomerAndFetchClientToken { clientToken, error in
                if let error {
                    self.updateStatus(error.localizedDescription)
                } else if let clientToken {
                    self.updateStatus("Using Client Token")
                    self.currentViewController = self.instantiateViewController(with: clientToken)
                } else {
                    self.updateStatus("No client token or error was returned from the server side request")
                }
            }

        //TODO Remove this once ModXO goes GA
        case .newPayPalCheckoutTokenizationKey:
            updateStatus("Fetching modXO (origami) checkout token...")
            
            var tokenizationKey: String = ""
            switch BraintreeDemoSettings.currentEnvironment {
            case .sandbox:
                tokenizationKey = "sandbox_rz48bqvw_jcyycfw6f9j4nj9c"
            case .production:
                tokenizationKey = "production_t2wns2y2_dfy45jdj3dxkmz5m"
            default:
                tokenizationKey = "development_testing_integration_merchant_id"
            }

            currentViewController = instantiateViewController(with: tokenizationKey)

        case .mockedPayPalTokenizationKey:
            let tokenizationKey = "sandbox_q7v35n9n_555d2htrfsnnmfb3"
            currentViewController = instantiateViewController(with: tokenizationKey)

        case .uiTestHardcodedClientToken:
            let uiTestClientToken = "eyJ2ZXJzaW9uIjozLCJhdXRob3JpemF0aW9uRmluZ2VycHJpbnQiOiIxYzM5N2E5OGZmZGRkNDQwM2VjNzEzYWRjZTI3NTNiMzJlODc2MzBiY2YyN2M3NmM2OWVmZjlkMTE5MjljOTVkfGNyZWF0ZWRfYXQ9MjAxNy0wNC0wNVQwNjowNzowOC44MTUwOTkzMjUrMDAwMFx1MDAyNm1lcmNoYW50X2lkPWRjcHNweTJicndkanIzcW5cdTAwMjZwdWJsaWNfa2V5PTl3d3J6cWszdnIzdDRuYzgiLCJjb25maWdVcmwiOiJodHRwczovL2FwaS5zYW5kYm94LmJyYWludHJlZWdhdGV3YXkuY29tOjQ0My9tZXJjaGFudHMvZGNwc3B5MmJyd2RqcjNxbi9jbGllbnRfYXBpL3YxL2NvbmZpZ3VyYXRpb24ifQ=="
            currentViewController = instantiateViewController(with: uiTestClientToken)
        }
    }

    private func instantiateViewController(with authorization: String) -> BaseViewController? {
        guard let integrationName = UserDefaults.standard.string(forKey: "BraintreeDemoSettingsIntegration") else {
            return PayPalWebCheckoutViewController(authorization: authorization)
        }

        switch integrationName {
        case "AmexViewController":
            return AmexViewController(authorization: authorization)
        case "ApplePayViewController":
            return ApplePayViewController(authorization: authorization)
        case "CardTokenizationViewController":
            return CardTokenizationViewController(authorization: authorization)
        case "DataCollectorViewController":
            return DataCollectorViewController(authorization: authorization)
        case "IdealViewController":
            return IdealViewController(authorization: authorization)
        case "PayPalNativeCheckoutViewController":
            return PayPalNativeCheckoutViewController(authorization: authorization)
        case "PayPalWebCheckoutViewController":
            return PayPalWebCheckoutViewController(authorization: authorization)
        case "SEPADirectDebitViewController":
            return SEPADirectDebitViewController(authorization: authorization)
        case "ShopperInsightsViewController":
            return ShopperInsightsViewController(authorization: authorization)
        case "ThreeDSecureViewController":
            return ThreeDSecureViewController(authorization: authorization)
        case "VenmoViewController":
            return VenmoViewController(authorization: authorization)
        case "PayPalMessagingViewController":
            return PayPalMessagingViewController(authorization: authorization)
        default:
            return PayPalWebCheckoutViewController(authorization: authorization)
        }
    }

    private func appendViewController(_ viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        viewController.didMove(toParent: self)
    }
}

// MARK: - InAppSettingsKit Delegate

extension ContainmentViewController: IASKSettingsDelegate {

    func settingsViewControllerDidEnd(_ settingsViewController: IASKAppSettingsViewController) {
        settingsViewController.dismiss(animated: true)
        reloadIntegration()
    }
}
