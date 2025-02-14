import XCTest
import CardinalMobile
@testable import BraintreeTestShared
@testable import BraintreeThreeDSecure

class BTThreeDSecureRequest_Tests: XCTestCase {

    // MARK: - accountTypeAsString

    func testCustomFields_whenCustomFieldsExist_notNil() {
        let request = BTThreeDSecureRequest(amount: "10.0", nonce: "fake-nonce", customFields: ["test": "test"])
        XCTAssertNotNil(request.customFields)
    }

    func testAccountTypeAsString_whenAccountTypeIsCredit_returnsCredit() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", accountType: .credit)
        XCTAssertEqual(request.accountType.stringValue, "credit")
    }

    func testAccountTypeAsString_whenAccountTypeIsDebit_returnsDebit() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", accountType: .debit)
        XCTAssertEqual(request.accountType.stringValue, "debit")
    }

    func testAccountTypeAsString_whenAccountTypeIsUnspecified_returnsNil() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", accountType: .unspecified)
        XCTAssertEqual(request.accountType.stringValue, nil)
    }

    func testAccountTypeAsString_whenAccountTypeIsNotSet_returnsNil() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce")
        XCTAssertEqual(request.accountType.stringValue, nil)
    }

    // MARK: - shippingMethodAsString

    func testShippingMethodAsString_whenShippingMethodIsSameDay_returns01() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", shippingMethod: .sameDay)
        XCTAssertEqual(request.shippingMethod.stringValue, "01")
    }

    func testShippingMethodAsString_whenShippingMethodIsExpedited_returns02() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", shippingMethod: .expedited)
        XCTAssertEqual(request.shippingMethod.stringValue, "02")
    }

    func testShippingMethodAsString_whenShippingMethodIsPriority_returns03() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", shippingMethod: .priority)
        XCTAssertEqual(request.shippingMethod.stringValue, "03")
    }

    func testShippingMethodAsString_whenShippingMethodIsGround_returns04() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", shippingMethod: .ground)
        XCTAssertEqual(request.shippingMethod.stringValue, "04")
    }

    func testShippingMethodAsString_whenShippingMethodIsElectronicDelivery_returns05() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", shippingMethod: .electronicDelivery)
        XCTAssertEqual(request.shippingMethod.stringValue, "05")
    }

    func testShippingMethodAsString_whenShippingMethodIsShipToStore_returns06() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", shippingMethod: .shipToStore)
        XCTAssertEqual(request.shippingMethod.stringValue, "06")
    }

    func testShippingMethodAsString_whenShippingMethodIsUnspecified_returnsNil() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", shippingMethod: .unspecified)
        XCTAssertEqual(request.shippingMethod.stringValue, nil)
    }

    func testShippingMethodAsString_whenShippingMethodIsNotSet_returnsNil() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce")
        XCTAssertEqual(request.shippingMethod.stringValue, nil)
    }

    // MARK: - requestedExemptionTypeAsString

    func testRequestedExemptionTypeAsString_whenRequestedExemptionTypeIsLowValue_returnsLowValue() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", requestedExemptionType: .lowValue)
        XCTAssertEqual(request.requestedExemptionType.stringValue, "low_value")
    }

    func testRequestedExemptionTypeAsString_whenRequestedExemptionTypeIsSecureCorporate_returnsSecureCorporate() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", requestedExemptionType: .secureCorporate)
        XCTAssertEqual(request.requestedExemptionType.stringValue, "secure_corporate")
    }

    func testRequestedExemptionTypeAsString_whenRequestedExemptionTypeIsTrustedBeneficiary_returnsTrustedBeneficiary() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", requestedExemptionType: .trustedBeneficiary)
        XCTAssertEqual(request.requestedExemptionType.stringValue, "trusted_beneficiary")
    }

    func testRequestedExemptionTypeAsString_whenRequestedExemptionTypeIsTransactionRiskAnalysis_returnsTransactionRiskAnalysis() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", requestedExemptionType: .transactionRiskAnalysis)
        XCTAssertEqual(request.requestedExemptionType.stringValue, "transaction_risk_analysis")
    }

    func testRequestedExemptionTypeAsString_whenAccountTypeIsUnspecified_returnsNil() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", requestedExemptionType: .unspecified)
        XCTAssertEqual(request.requestedExemptionType.stringValue, nil)
    }

    func testRequestedExemptionTypeAsString_whenAccountTypeIsNotSet_returnsNil() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce")
        XCTAssertEqual(request.requestedExemptionType.stringValue, nil)
    }

    // MARK: - UIType

    func testUIType_whenUITypeNative_setsCardinalUITypeNative() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", uiType: .native)
        XCTAssertEqual(request.uiType.cardinalValue, CardinalSessionUIType.native)
    }

    func testUIType_whenUITypeHTML_setsCardinalUITypeHTML() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", uiType: .html)
        XCTAssertEqual(request.uiType.cardinalValue, CardinalSessionUIType.HTML)
    }

    func testUIType_whenUITypeBoth_setsCardinalUITypeBoth() {
        let request = BTThreeDSecureRequest(amount: "10.00", nonce: "fake-nonce", uiType: .both)
        XCTAssertEqual(request.uiType.cardinalValue, CardinalSessionUIType.both)
    }

    // MARK: RenderTypes

    func testRenderTypes_whenAllRenderTypesAreSet_setsAllCardinalRenderTypes() {
        let request = BTThreeDSecureRequest(
            amount: "10.00",
            nonce: "fake-nonce",
            renderTypes: [.otp, .singleSelect, .multiSelect, .oob, .html]
        )

        XCTAssertEqual(
            request.renderTypes?.compactMap { $0.cardinalValue },
            [
                CardinalSessionRenderTypeOTP,
                CardinalSessionRenderTypeSingleSelect,
                CardinalSessionRenderTypeMultiSelect,
                CardinalSessionRenderTypeOOB,
                CardinalSessionRenderTypeHTML
            ]
        )
    }
    
    func testAsParameters_parameterizesAllProperties() {
        let billingAddress = BTThreeDSecurePostalAddress()
     
        billingAddress.givenName = "Given"
        billingAddress.surname = "Surname"
        billingAddress.streetAddress = "123 Street Address"
        billingAddress.extendedAddress = "Suite Number"
        billingAddress.line3 = "#2"
        billingAddress.locality = "Locality"
        billingAddress.region = "Region"
        billingAddress.postalCode = "12345"
        billingAddress.countryCodeAlpha2 = "US"
        billingAddress.phoneNumber = "1234567"
        
        let info = BTThreeDSecureAdditionalInformation()
        
        let threeDSecureRequest = BTThreeDSecureRequest(
            amount: "9.97",
            nonce: "fake-card-nonce",
            accountType: .credit,
            additionalInformation: info,
            billingAddress: billingAddress,
            cardAddChallengeRequested: true,
            challengeRequested: true,
            dataOnlyRequested: true,
            dfReferenceID: "df-reference-id",
            email: "tester@example.com",
            exemptionRequested: true,
            mobilePhoneNumber: "5151234321",
            shippingMethod: .priority
        )

        //Same as billingAddress
        info.shippingAddress = billingAddress

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
        info.accountID = "ABC123"
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
        
        let params = ThreeDSecurePOSTBody(request: threeDSecureRequest)

        XCTAssertEqual(params.additionalInfo.shippingGivenName, "Given")
        XCTAssertEqual(params.additionalInfo.shippingSurname, "Surname")
        XCTAssertEqual(params.additionalInfo.shippingLine1, "123 Street Address")
        XCTAssertEqual(params.additionalInfo.shippingLine2, "Suite Number")
        XCTAssertEqual(params.additionalInfo.shippingLine3, "#2")
        XCTAssertEqual(params.additionalInfo.shippingCity, "Locality")
        XCTAssertEqual(params.additionalInfo.shippingState, "Region")
        XCTAssertEqual(params.additionalInfo.shippingPostalCode, "12345")
        XCTAssertEqual(params.additionalInfo.shippingCountryCode, "US")
        XCTAssertEqual(params.additionalInfo.shippingPhone, "1234567")

        XCTAssertEqual(params.additionalInfo.shippingMethodIndicator, "01")
        XCTAssertEqual(params.additionalInfo.productCode, "GEN")
        XCTAssertEqual(params.additionalInfo.deliveryTimeframe, "03")
        XCTAssertEqual(params.additionalInfo.deliveryEmail, "email@test.com")
        XCTAssertEqual(params.additionalInfo.reorderIndicator, "01")
        XCTAssertEqual(params.additionalInfo.preorderIndicator, "02")
        XCTAssertEqual(params.additionalInfo.preorderDate, "20200101")
        XCTAssertEqual(params.additionalInfo.giftCardAmount, "10")
        XCTAssertEqual(params.additionalInfo.giftCardCurrencyCode, "USD")
        XCTAssertEqual(params.additionalInfo.giftCardCount, "5")
        XCTAssertEqual(params.additionalInfo.accountAgeIndicator, "05")
        XCTAssertEqual(params.additionalInfo.accountCreateDate, "20180203")
        XCTAssertEqual(params.additionalInfo.accountChangeIndicator, "02")
        XCTAssertEqual(params.additionalInfo.accountChangeDate, "20190304")
        XCTAssertEqual(params.additionalInfo.accountPwdChangeIndicator, "03")
        XCTAssertEqual(params.additionalInfo.accountPwdChangeDate, "20190101")
        XCTAssertEqual(params.additionalInfo.shippingAddressUsageIndicator, "01")
        XCTAssertEqual(params.additionalInfo.shippingAddressUsageDate, "20190405")
        XCTAssertEqual(params.additionalInfo.transactionCountDay, "1")
        XCTAssertEqual(params.additionalInfo.transactionCountYear, "2")
        XCTAssertEqual(params.additionalInfo.addCardAttempts, "3")
        XCTAssertEqual(params.additionalInfo.accountPurchases, "4")
        XCTAssertEqual(params.additionalInfo.fraudActivity, "01")
        XCTAssertEqual(params.additionalInfo.shippingNameIndicator, "02")
        XCTAssertEqual(params.additionalInfo.paymentAccountIndicator, "03")
        XCTAssertEqual(params.additionalInfo.paymentAccountAge, "20190101")
        XCTAssertEqual(params.additionalInfo.addressMatch, "N")
        XCTAssertEqual(params.additionalInfo.accountId, "ABC123")
        XCTAssertEqual(params.additionalInfo.ipAddress, "127.0.0.1")
        XCTAssertEqual(params.additionalInfo.orderDescription, "Description")
        XCTAssertEqual(params.additionalInfo.taxAmount, "1234")
        XCTAssertEqual(params.additionalInfo.userAgent, "User Agent")
        XCTAssertEqual(params.additionalInfo.authenticationIndicator, "03")
        XCTAssertEqual(params.additionalInfo.installment, "2")
        XCTAssertEqual(params.additionalInfo.purchaseDate, "20190401123456")
        XCTAssertEqual(params.additionalInfo.recurringEnd, "20201231")
        XCTAssertEqual(params.additionalInfo.recurringFrequency, "30")
        XCTAssertEqual(params.additionalInfo.sdkMaxTimeout, "10")
        XCTAssertEqual(params.additionalInfo.workPhoneNumber, "5551115555")
    }

    func testAsParameters_parameterizesWithNilProperties() {
        let info = BTThreeDSecureAdditionalInformation()
        
        info.productCode = "AIR"
        
        let threeDSecureRequest = BTThreeDSecureRequest(
            amount: "9.97",
            nonce: "fake-card-nonce",
            additionalInformation: info
        )

        let params = ThreeDSecurePOSTBody(request: threeDSecureRequest)
        
        XCTAssertNil(params.additionalInfo.shippingMethodIndicator)
        XCTAssertEqual(params.additionalInfo.productCode, "AIR")
    }

}
