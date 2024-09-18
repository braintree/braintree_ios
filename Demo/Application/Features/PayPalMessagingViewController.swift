import UIKit
import BraintreePayPalMessaging

class PayPalMessagingViewController: PaymentButtonBaseViewController {

    lazy var payPalMessagingView = BTPayPalMessagingView(apiClient: apiClient)

    let request = BTPayPalMessagingRequest(
        amount: 2.00,
        offerType: .payLaterLongTerm,
        buyerCountry: "US",
        logoType: .primary,
        textAlignment: .center
    )

    override func viewDidLoad() {
        title = "PayPal Messaging"
        
        payPalMessagingView.delegate = self
        payPalMessagingView.start(request)
        super.viewDidLoad()
    }

    private func setupView() {
        payPalMessagingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(payPalMessagingView)

        NSLayoutConstraint.activate([
            payPalMessagingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            payPalMessagingView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            payPalMessagingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            payPalMessagingView.heightAnchor.constraint(equalToConstant: 80)
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
        progressBlock("Loading BTPayPalMessagingView")
    }

    func didAppear(_ payPalMessagingView: BTPayPalMessagingView) {
        progressBlock("DELEGATE: didAppear fired")
        setupView()
    }

    func onError(_ payPalMessagingView: BTPayPalMessagingView, error: Error) {
        progressBlock("DELEGATE: onError fired with \(error.localizedDescription)")
    }
}
