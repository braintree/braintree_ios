import UIKit
import BraintreeAmericanExpress
import BraintreeCard

class AmexViewController: PaymentButtonBaseViewController {

    lazy var amexClient = BTAmericanExpressClient(apiClient: apiClient)
    lazy var cardClient = BTCardClient(apiClient: apiClient)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Amex"
    }

    override func createPaymentButton() -> UIView {
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
        card.expirationYear = CardHelpers.generateFuture(.year)
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

                if let errorCode = rewardsBalance.errorCode, let errorMessage = rewardsBalance.errorMessage {
                    self.progressBlock("\(errorCode): \(errorMessage)")
                } else if
                    let rewardsAmount = rewardsBalance.rewardsAmount,
                    let rewardsUnit = rewardsBalance.rewardsUnit,
                    let currencyAmount = rewardsBalance.currencyAmount,
                    let currencyIsoCode = rewardsBalance.currencyIsoCode {
                    self.progressBlock("\(rewardsAmount) \(rewardsUnit), \(currencyAmount) \(currencyIsoCode)")
                }
            }
        }
    }
}
