import UIKit
import BraintreeCore

class PaymentButtonBaseViewController: BaseViewController {

    let authorization: String

    var heightConstraint: CGFloat?
    var usesIntrinsicContentHeight = false

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var paymentButton = UIView()

    override init(authorization: String) {
        self.authorization = authorization
        super.init(authorization: authorization)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Payment Button"
        view.backgroundColor = .systemBackground

        paymentButton = createPaymentButton()
        paymentButton.translatesAutoresizingMaskIntoConstraints = false

        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(paymentButton)

        let contentViewEqualHeightConstraint = contentView.heightAnchor.constraint(
            equalTo: scrollView.frameLayoutGuide.heightAnchor
        )
        contentViewEqualHeightConstraint.priority = .defaultLow

        let paymentButtonTopConstraint = paymentButton.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: 20
        )
        paymentButtonTopConstraint.priority = .defaultHigh

        let paymentButtonBottomConstraint = paymentButton.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -20
        )
        paymentButtonBottomConstraint.priority = .defaultHigh

        var constraints = [
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor),
            contentViewEqualHeightConstraint,

            paymentButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            paymentButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            paymentButton.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 20),
            paymentButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20),
            paymentButtonTopConstraint,
            paymentButtonBottomConstraint,
            paymentButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]

        if !usesIntrinsicContentHeight {
            constraints.append(paymentButton.heightAnchor.constraint(equalToConstant: heightConstraint ?? 100))
        }

        NSLayoutConstraint.activate(constraints)
    }

    /// A factory method that subclasses must implement to return a payment button view.
    func createPaymentButton() -> UIView {
        UIView()
    }

    func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.setTitleColor(.lightGray, for: .disabled)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // MARK: - Helpers

    func buttonsStackView(label: String, views: [UIView]) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = label

        let buttonsStackView = UIStackView(arrangedSubviews: [titleLabel] + views)
        buttonsStackView.axis = .vertical
        buttonsStackView.distribution = .fillProportionally
        buttonsStackView.backgroundColor = .systemGray6
        buttonsStackView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        buttonsStackView.isLayoutMarginsRelativeArrangement = true

        return buttonsStackView
    }
}
