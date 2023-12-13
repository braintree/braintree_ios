import UIKit
import BraintreePayPalMessaging

class PayPalMessagingViewController: PaymentButtonBaseViewController {

    lazy var payPalMessagingClient = BTPayPalMessagingClient(apiClient: apiClient)

    let request = BTPayPalMessagingRequest(
        amount: 2.00,
        offerType: .payLaterLongTerm,
        buyerCountry: "US",
        logoType: .primary,
        textAlignment: .center
    )

    override func viewDidLoad() {
        payPalMessagingClient.delegate = self
        payPalMessagingClient.createView(request)

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

// TODO: update
extension PayPalMessagingViewController: BTPayPalMessagingDelegate {

    func didSelect(_ payPalMessagingClient: BTPayPalMessagingClient) {
        progressBlock("DELEGATE: didSelect fired")
    }

    func willApply(_ payPalMessagingClient: BTPayPalMessagingClient) {
        progressBlock("DELEGATE: willApply fired")
    }

    func willAppear(_ payPalMessagingClient: BTPayPalMessagingClient) {
        progressBlock("DELEGATE: willAppear fired")
    }

    func didAppear(_ payPalMessagingClient: BTPayPalMessagingClient) {
        progressBlock("DELEGATE: didAppear fired")
    }

    func onError(_ payPalMessagingClient: BTPayPalMessagingClient, error: Error) {
        progressBlock("DELEGATE: onError fired with \(error.localizedDescription)")
    }
}

