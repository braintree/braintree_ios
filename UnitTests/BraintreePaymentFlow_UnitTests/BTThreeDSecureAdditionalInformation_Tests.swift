import XCTest

class BTThreeDSecureAdditionalInformation_Tests: XCTestCase {
    func testAsParameters_parameterizesAllProperties() {
        let info = BTThreeDSecureAdditionalInformation()

        let shippingAddress = BTThreeDSecurePostalAddress()
        shippingAddress.givenName = "Given"
        shippingAddress.surname = "Surname"
        shippingAddress.streetAddress = "123 Street Address"
        shippingAddress.extendedAddress = "Suite Number"
        shippingAddress.line3 = "#2"
        shippingAddress.locality = "Locality"
        shippingAddress.region = "Region"
        shippingAddress.postalCode = "12345"
        shippingAddress.countryCodeAlpha2 = "US"
        shippingAddress.phoneNumber = "1234567"
        info.shippingAddress = shippingAddress

        info.shippingMethodIndicator = "01"
        info.productCode = "GEN"
        info.deliveryTimeframe = "03"
        info.deliveryEmail = "email@test.com"
        info.reorderIndicator = "01"
        info.preorderIndicator = "02"
        info.preorderDate = "20200101"
        info.giftCardAmount = "10"
        info.giftCardCurrencyCode = "USD"
        info.giftCardCount = "5"
        info.accountAgeIndicator = "05"
        info.accountCreateDate = "20180203"
        info.accountChangeIndicator = "02"
        info.accountChangeDate = "20190304"
        info.accountPwdChangeIndicator = "03"
        info.accountPwdChangeDate = "20190101"
        info.shippingAddressUsageIndicator = "01"
        info.shippingAddressUsageDate = "20190405"
        info.transactionCountDay = "1"
        info.transactionCountYear = "2"
        info.addCardAttempts = "3"
        info.accountPurchases = "4"
        info.fraudActivity = "01"
        info.shippingNameIndicator = "02"
        info.paymentAccountIndicator = "03"
        info.paymentAccountAge = "20190101"
        info.addressMatch = "N"
        info.accountId = "ABC123"
        info.ipAddress = "127.0.0.1"
        info.orderDescription = "Description"
        info.taxAmount = "1234"
        info.userAgent = "User Agent"
        info.authenticationIndicator = "03"
        info.installment = "2"
        info.purchaseDate = "20190401123456"
        info.recurringEnd = "20201231"
        info.recurringFrequency = "30"
        info.sdkMaxTimeout = "10"
        info.workPhoneNumber = "5551115555"

        let parameters = info.asParameters() as! Dictionary<String, String>

        XCTAssertEqual(parameters["shippingGivenName"], "Given")
        XCTAssertEqual(parameters["shippingSurname"], "Surname")
        XCTAssertEqual(parameters["shippingLine1"], "123 Street Address")
        XCTAssertEqual(parameters["shippingLine2"], "Suite Number")
        XCTAssertEqual(parameters["shippingLine3"], "#2")
        XCTAssertEqual(parameters["shippingCity"], "Locality")
        XCTAssertEqual(parameters["shippingState"], "Region")
        XCTAssertEqual(parameters["shippingPostalCode"], "12345")
        XCTAssertEqual(parameters["shippingCountryCode"], "US")
        XCTAssertEqual(parameters["shippingPhone"], "1234567")

        XCTAssertEqual(parameters["shippingMethodIndicator"], "01")
        XCTAssertEqual(parameters["productCode"], "GEN")
        XCTAssertEqual(parameters["deliveryTimeframe"], "03")
        XCTAssertEqual(parameters["deliveryEmail"], "email@test.com")
        XCTAssertEqual(parameters["reorderIndicator"], "01")
        XCTAssertEqual(parameters["preorderIndicator"], "02")
        XCTAssertEqual(parameters["preorderDate"], "20200101")
        XCTAssertEqual(parameters["giftCardAmount"], "10")
        XCTAssertEqual(parameters["giftCardCurrencyCode"], "USD")
        XCTAssertEqual(parameters["giftCardCount"], "5")
        XCTAssertEqual(parameters["accountAgeIndicator"], "05")
        XCTAssertEqual(parameters["accountCreateDate"], "20180203")
        XCTAssertEqual(parameters["accountChangeIndicator"], "02")
        XCTAssertEqual(parameters["accountChangeDate"], "20190304")
        XCTAssertEqual(parameters["accountPwdChangeIndicator"], "03")
        XCTAssertEqual(parameters["accountPwdChangeDate"], "20190101")
        XCTAssertEqual(parameters["shippingAddressUsageIndicator"], "01")
        XCTAssertEqual(parameters["shippingAddressUsageDate"], "20190405")
        XCTAssertEqual(parameters["transactionCountDay"], "1")
        XCTAssertEqual(parameters["transactionCountYear"], "2")
        XCTAssertEqual(parameters["addCardAttempts"], "3")
        XCTAssertEqual(parameters["accountPurchases"], "4")
        XCTAssertEqual(parameters["fraudActivity"], "01")
        XCTAssertEqual(parameters["shippingNameIndicator"], "02")
        XCTAssertEqual(parameters["paymentAccountIndicator"], "03")
        XCTAssertEqual(parameters["paymentAccountAge"], "20190101")
        XCTAssertEqual(parameters["addressMatch"], "N")
        XCTAssertEqual(parameters["accountId"], "ABC123")
        XCTAssertEqual(parameters["ipAddress"], "127.0.0.1")
        XCTAssertEqual(parameters["orderDescription"], "Description")
        XCTAssertEqual(parameters["taxAmount"], "1234")
        XCTAssertEqual(parameters["userAgent"], "User Agent")
        XCTAssertEqual(parameters["authenticationIndicator"], "03")
        XCTAssertEqual(parameters["installment"], "2")
        XCTAssertEqual(parameters["purchaseDate"], "20190401123456")
        XCTAssertEqual(parameters["recurringEnd"], "20201231")
        XCTAssertEqual(parameters["recurringFrequency"], "30")
        XCTAssertEqual(parameters["sdkMaxTimeout"], "10")
        XCTAssertEqual(parameters["workPhoneNumber"], "5551115555")
    }

    func testAsParameters_parameterizesWithNilProperties() {
        let info = BTThreeDSecureAdditionalInformation()
        info.productCode = "AIR"

        let parameters = info.asParameters() as! Dictionary<String, String>

        XCTAssertNil(parameters["shippingMethodIndicator"])
        XCTAssertEqual(parameters["productCode"], "AIR")
    }
}
