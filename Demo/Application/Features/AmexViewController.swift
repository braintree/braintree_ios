import UIKit
import BraintreeAmericanExpress
import BraintreeCard

class AmexViewController: PaymentButtonBaseViewController {

    lazy var amexClient = BTAmericanExpressClient(authorization: authorization)
    lazy var cardClient = BTCardClient(authorization: authorization)

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
//        getRewards(for: "371260714673002")
        getAsyncRewards(for: "371260714673002")
    }

    @objc func tappedInsufficientPointsCard() {
//        getRewards(for: "371544868764018")
        getAsyncRewards(for: "371260714673002")
    }

    @objc func tappedIneligibleCard() {
//        getRewards(for: "378267515471109")
        getAsyncRewards(for: "371260714673002")
    }

    private func getRewards(for cardNumber: String) {
        let card = BTCard(
            number: cardNumber,
            expirationMonth: "12",
            expirationYear: CardHelpers.generateFuture(.year),
            cvv: "1234"
        )

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
    
    private func getAsyncRewards(for cardNumber: String) {
        let card = BTCard(
            number: cardNumber,
            expirationMonth: "12",
            expirationYear: CardHelpers.generateFuture(.year),
            cvv: "1234"
        )
        
        progressBlock("Tokenizing Card")
        
        Task {
            do {
                let tokenizedCard = try await cardClient.tokenize(card)
                
                self.progressBlock("Amex - getting rewards balance")
                
                let rewardsBalance = try await amexClient.getRewardsBalance(forNonce: tokenizedCard.nonce, currencyISOCode: "USD")
                
                if let errorCode = rewardsBalance.errorCode, let errorMessage = rewardsBalance.errorMessage {
                    self.progressBlock("\(errorCode): \(errorMessage)")
                } else if
                    let rewardsAmount = rewardsBalance.rewardsAmount,
                    let rewardsUnit = rewardsBalance.rewardsUnit,
                    let currencyAmount = rewardsBalance.currencyAmount,
                    let currencyIsoCode = rewardsBalance.currencyIsoCode {
                    self.progressBlock("\(rewardsAmount) \(rewardsUnit), \(currencyAmount) \(currencyIsoCode)")
                }
            } catch {
                progressBlock("\(error.localizedDescription)")
            }
        }
    }
}
