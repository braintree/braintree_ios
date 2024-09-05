import Foundation

/// Contains information about a PayPal credit financing option
@objcMembers public class BTPayPalCreditFinancing: NSObject {
    
    /// Indicates whether the card amount is editable after payer's acceptance on PayPal side.
    public let cardAmountImmutable: Bool
    
    /// Estimated amount per month that the customer will need to pay including fees and interest.
    public let monthlyPayment: BTPayPalCreditFinancingAmount?
    
    /// Status of whether the customer ultimately was approved for and chose to make the payment using the approved installment credit.
    public let payerAcceptance: Bool
    
    /// Length of financing terms in months.
    public let term: Int
    
    /// Estimated total payment amount including interest and fees the user will pay during the lifetime of the loan.
    public let totalCost: BTPayPalCreditFinancingAmount?
    
    /// Estimated interest or fees amount the payer will have to pay during the lifetime of the loan.
    public let totalInterest: BTPayPalCreditFinancingAmount?
    
    init(
        cardAmountImmutable: Bool,
        monthlyPayment: BTPayPalCreditFinancingAmount?,
        payerAcceptance: Bool,
        term: Int,
        totalCost: BTPayPalCreditFinancingAmount?,
        totalInterest: BTPayPalCreditFinancingAmount?
    ) {
        self.cardAmountImmutable = cardAmountImmutable
        self.monthlyPayment = monthlyPayment
        self.payerAcceptance = payerAcceptance
        self.term = term
        self.totalCost = totalCost
        self.totalInterest = totalInterest
    }
}
