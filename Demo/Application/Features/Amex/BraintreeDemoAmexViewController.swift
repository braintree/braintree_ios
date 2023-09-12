import Foundation
import BraintreeAmericanExpress
import BraintreeCard

class BraintreeDemoAmexViewController: BraintreeDemoPaymentButtonBaseViewController {

    lazy var amexClient = BTAmericanExpressClient(apiClient: apiClient)
    lazy var cardClient = BTCardClient(apiClient: apiClient)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Amex"
    }

    override func createPaymentButton() -> UIView! {
        let validCardButton = createButton(title: "Valid card", action: #selector(tappedValidCard))
        let insufficientPointsCardButton = createButton(title: "Insufficient points card", action: #selector(tappedInsufficientPointsCard))
        let ineligibleCardButton = createButton(title: "Ineligible card", action: #selector(tappedIneligibleCard))

        let stackView = UIStackView(arrangedSubviews: [validCardButton, insufficientPointsCardButton, ineligibleCardButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }

    @objc func tappedValidCard() {
        getRewards(for: "371260714673002")
    }

    @objc func tappedInsufficientPointsCard() {
        getRewards(for: "371544868764018")
    }

    @objc func tappedIneligibleCard() {
        getRewards(for: "378267515471109")
    }

    private func getRewards(for cardNumber: String) {
        let card = BTCard()
        card.number = cardNumber
        card.expirationMonth = "12"
        card.expirationYear = generateFutureYear()
        card.cvv = "1234"

        progressBlock("Tokenizing Card")

        cardClient.tokenize(card) { tokenizedCard, error in
            guard let tokenizedCard else {
                self.progressBlock(error?.localizedDescription)
                return
            }

            self.progressBlock("Amex - getting rewards balance")

            self.amexClient.getRewardsBalance(forNonce: tokenizedCard.nonce, currencyISOCode: "USD") { rewardsBalance, error in
                guard let rewardsBalance else {
                    self.progressBlock(error?.localizedDescription)
                    return
                }

                if let errorCode = rewardsBalance.errorCode, let errorMessage = rewardsBalance.errorMessage  {
                    self.progressBlock("\(errorCode): \(errorMessage)")
                } else if let rewardsAmount = rewardsBalance.rewardsAmount,
                          let rewardsUnit = rewardsBalance.rewardsUnit,
                          let currencyAmount = rewardsBalance.currencyAmount,
                          let currencyIsoCode = rewardsBalance.currencyIsoCode {
                    self.progressBlock("\(rewardsAmount) \(rewardsUnit), \(currencyAmount) \(currencyIsoCode)")
                }
            }
        }
    }

    private func generateFutureYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy"

        let futureYear = Calendar.current.date(byAdding: .year, value: 3, to: Date())!
        return dateFormatter.string(from: futureYear)
    }

    // TODO: move this helper into BraintreeDemoPaymentButtonBaseViewController once converted so all buttons share the same characteristics
    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.lightGray, for: .highlighted)
        button.setTitleColor(.lightGray, for: .disabled)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}
