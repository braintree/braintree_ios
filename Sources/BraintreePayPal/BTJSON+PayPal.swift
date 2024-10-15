#if canImport(BraintreeCore)
import BraintreeCore
#endif

extension BTJSON {

    func asPayPalCreditFinancingAmount() -> BTPayPalCreditFinancingAmount? {
        guard
            self.isObject,
            let currency = self["currency"].asString(),
            let value = self["value"].asString()
        else {
            return nil
        }

        return BTPayPalCreditFinancingAmount(currency: currency, value: value)
    }
    
    func asPayPalCreditFinancing() -> BTPayPalCreditFinancing? {
        guard self.isObject else { return nil }
        
        let isCardAmountImmutable = self["cardAmountImmutable"].isTrue
        let monthlyPayment = self["monthlyPayment"].asPayPalCreditFinancingAmount()
        let payerAcceptance = self["payerAcceptance"].isTrue
        let term = self["term"].asIntegerOrZero()
        let totalCost = self["totalCost"].asPayPalCreditFinancingAmount()
        let totalInterest = self["totalInterest"].asPayPalCreditFinancingAmount()
        
        return BTPayPalCreditFinancing(
            cardAmountImmutable: isCardAmountImmutable,
            monthlyPayment: monthlyPayment,
            payerAcceptance: payerAcceptance,
            term: term,
            totalCost: totalCost,
            totalInterest: totalInterest
        )
    }
}
