public struct BTCustomerSessionRequest {

    let hashedEmail: String?
    let hashedPhoneNumber: String?
    let payPalAppInstalled: Bool?
    let venmoAppInstalled: Bool?
    let purchaseUnits: [BTPurchaseUnit]?
    let payPalCampaigns: [BTPayPalCampaign]?

    public init(
        hashedEmail: String? = nil,
        hashedPhoneNumber: String? = nil,
        payPalAppInstalled: Bool? = nil,
        venmoAppInstalled: Bool? = nil,
        purchaseUnits: [BTPurchaseUnit]? = nil,
        payPalCampaigns: [BTPayPalCampaign]? = nil
    ) {
        self.hashedEmail = hashedEmail
        self.hashedPhoneNumber = hashedPhoneNumber
        self.payPalAppInstalled = payPalAppInstalled
        self.venmoAppInstalled = venmoAppInstalled
        self.purchaseUnits = purchaseUnits
        self.payPalCampaigns = payPalCampaigns
    }
}
