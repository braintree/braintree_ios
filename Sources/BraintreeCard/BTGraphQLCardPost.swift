import Foundation

struct BTGraphQLCardPost: Encodable {
        
    private let input: Input
    private let authenticationInsightInput: MerchantAccountID?
    
    struct MerchantAccountID: Encodable {
        
        private let merchantAccountId: String?
        
        init(merchantAccountId: String?) {
            self.merchantAccountId = merchantAccountId
        }
    }
    
    struct Input: Encodable {
        
        private let creditCard: BTCard
        private let options: Options
        
        init(creditCard: BTCard, options: Options) {
            self.creditCard = creditCard
            self.options = options
        }
    }
    
    struct Options: Encodable {
        
        private let validate: Bool
        
        init(validate: Bool) {
            self.validate = validate
        }
    }
    
    init(card: BTCard) {
        self.input = Input(
            creditCard: card,
            options: Options(validate: card.shouldValidate)
        )
        self.authenticationInsightInput = MerchantAccountID(merchantAccountId: card.merchantAccountID) // TODO mirror optional styling
    }
}
