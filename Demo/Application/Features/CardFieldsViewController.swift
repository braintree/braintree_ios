import SwiftUI
import UIKit
import BraintreeCard
import BraintreeUIComponents

class CardFieldsViewController: BaseViewController {

    private let authorization: String
    private var submit: (() -> Void)?

    private lazy var payButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pay", for: .normal)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        return button
    }()

    override init(authorization: String) {
        self.authorization = authorization
        super.init(authorization: authorization)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Card Fields"
        view.backgroundColor = .systemBackground

        let cardFields = CardFields(
            authorization: authorization,
            card: BTCard()
        ) { [weak self] nonce, error in
            if let error {
                self?.progressBlock(error.localizedDescription)
            } else if let nonce {
                self?.completionBlock(nonce)
            }
        }
        .onValidityChange { [weak self] valid, submit in
            self?.payButton.isEnabled = valid
            self?.submit = submit
        }

        let hostingController = UIHostingController(rootView: cardFields)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        view.addSubview(payButton)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            payButton.topAnchor.constraint(equalTo: hostingController.view.bottomAnchor, constant: 16),
            payButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    @objc private func payButtonTapped() {
        progressBlock("Tokenizing card...")
        submit?()
    }
}
