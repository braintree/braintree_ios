import BraintreeCore

extension BTJSON {

    func asCreditFinancingAmount() -> BTPayPalCreditFinancingAmount? {
        guard self.isObject,
              let currency = self["currency"].asString(),
              let value = self["value"].asString() else {
                  return nil
              }
        
        return BTPayPalCreditFinancingAmount(currency: currency, value: value)
    }
    
    func asCreditFinancing() -> BTPayPalCreditFinancing? {
        guard self.isObject else { return nil }
        
        let isCardAmountImmutable = self["cardAmountImmutable"].isTrue
        let monthlyPayment = self["monthlyPayment"].asCreditFinancingAmount()
        let payerAcceptance = self["payerAcceptance"].isTrue
        let term = self["term"].asIntegerOrZero()
        let totalCost = self["totalCost"].asCreditFinancingAmount()
        let totalInterest = self["totalInterest"].asCreditFinancingAmount()
        
        return BTPayPalCreditFinancing(
            cardAmountImmutable: isCardAmountImmutable,
            monthlyPayment: monthlyPayment,
            payerAcceptance: payerAcceptance,
            term: term,
            totalCost: totalCost,
            totalInterest: totalInterest
        )
    }
    
    // TODO: Does this belong in BTJSON itself?
    func asAddress() -> BTPostalAddress? {
        guard self.isObject else { return nil }
        
        let address = BTPostalAddress()
        address.recipientName = self["recipientName"].asString() // Likely to be nil
        address.streetAddress = self["street1"].asString() ??
                                self["line1"].asString()
        address.extendedAddress = self["street2"].asString() ??
                                  self["line2"].asString()
        address.locality = self["city"].asString()
        address.region = self["state"].asString()
        address.postalCode = self["postalCode"].asString()
        address.countryCodeAlpha2 = self["country"].asString() ??
                                    self["countryCode"].asString()
        
        return address
    }
}
