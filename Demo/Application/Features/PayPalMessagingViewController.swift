import UIKit
import BraintreePayPalMessaging

class PayPalMessagingViewController: PaymentButtonBaseViewController {

    lazy var payPalMessagingClient = BTPayPalMessagingView(apiClient: apiClient)

    let request = BTPayPalMessagingRequest(
        amount: 2.00,
        offerType: .payLaterLongTerm,
        buyerCountry: "US",
        logoType: .primary,
        textAlignment: .center
    )

    override func viewDidLoad() {
        title = "PayPal Messaging"
        
        payPalMessagingClient.delegate = self
        payPalMessagingClient.start(request)
    }

    private func setupView() {
        payPalMessagingClient.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(payPalMessagingClient)

        NSLayoutConstraint.activate([
            payPalMessagingClient.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            payPalMessagingClient.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            payPalMessagingClient.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            payPalMessagingClient.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}

extension PayPalMessagingViewController: BTPayPalMessagingDelegate {

    func didSelect(_ payPalMessagingView: BTPayPalMessagingView) {
        progressBlock("DELEGATE: didSelect fired")
    }

    func willApply(_ payPalMessagingView: BTPayPalMessagingView) {
        progressBlock("DELEGATE: willApply fired")
    }

    func willAppear(_ payPalMessagingView: BTPayPalMessagingView) {
        progressBlock("Loading BTPayPalMessagingClient")
    }

    func didAppear(_ payPalMessagingView: BTPayPalMessagingView) {
        progressBlock("DELEGATE: didAppear fired")
        setupView()
    }

    func onError(_ payPalMessagingView: BTPayPalMessagingView, error: Error) {
        progressBlock("DELEGATE: onError fired with \(error.localizedDescription)")
    }
}

