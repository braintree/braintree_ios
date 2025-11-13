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
        
        let info = BTThreeDSecureAdditionalInformation(
            accountAgeIndicator: "05",
            accountChangeDate: "20190304",
            accountChangeIndicator: "02",
            accountCreateDate: "20180203",
            accountID: "ABC123",
            accountPurchases: "4",
            accountPwdChangeDate: "20190101",
            accountPwdChangeIndicator: "03",
            addCardAttempts: "3",
            addressMatch: "N",
            authenticationIndicator: "03",
            deliveryEmail: "email@test.com",
            deliveryTimeframe: "03",
            fraudActivity: "01",
            giftCardAmount: "10",
            giftCardCount: "5",
            giftCardCurrencyCode: "USD",
            installment: "2",
            ipAddress: "127.0.0.1",
            orderDescription: "Description",
            paymentAccountAge: "20190101",
            paymentAccountIndicator: "03",
            preorderDate: "20200101",
            preorderIndicator: "02",
            productCode: "GEN",
            purchaseDate: "20190401123456",
            recurringEnd: "20201231",
            recurringFrequency: "30",
            reorderIndicator: "01",
            sdkMaxTimeout: "10",
            shippingAddress: billingAddress,
            shippingAddressUsageDate: "20190405",
            shippingAddressUsageIndicator: "01",
            shippingMethodIndicator: "01",
            shippingNameIndicator: "02",
            taxAmount: "1234",
            transactionCountDay: "1",
            transactionCountYear: "2",
            userAgent: "User Agent",
            workPhoneNumber: "5551115555"
        )
        
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
        
        let params = try! ThreeDSecurePOSTBody(request: threeDSecureRequest).toDictionary()

        let additionalInfoDict = params["additionalInfo"] as! [String: Any]
            
        XCTAssertEqual(additionalInfoDict["shippingGivenName"] as? String, "Given")
        XCTAssertEqual(additionalInfoDict["shippingSurname"] as? String, "Surname")
        XCTAssertEqual(additionalInfoDict["shippingLine1"] as? String, "123 Street Address")
        XCTAssertEqual(additionalInfoDict["shippingLine2"] as? String, "Suite Number")
        XCTAssertEqual(additionalInfoDict["shippingLine3"] as? String, "#2")
        XCTAssertEqual(additionalInfoDict["shippingCity"] as? String, "Locality")
        XCTAssertEqual(additionalInfoDict["shippingState"] as? String, "Region")
        XCTAssertEqual(additionalInfoDict["shippingPostalCode"] as? String, "12345")
        XCTAssertEqual(additionalInfoDict["shippingCountryCode"] as? String, "US")
        XCTAssertEqual(additionalInfoDict["shippingPhone"] as? String, "1234567")
        
        XCTAssertEqual(additionalInfoDict["billingGivenName"] as? String, "Given")
        XCTAssertEqual(additionalInfoDict["billingSurname"] as? String, "Surname")
        XCTAssertEqual(additionalInfoDict["billingLine1"] as? String, "123 Street Address")
        XCTAssertEqual(additionalInfoDict["billingLine2"] as? String, "Suite Number")
        XCTAssertEqual(additionalInfoDict["billingLine3"] as? String, "#2")
        XCTAssertEqual(additionalInfoDict["billingCity"] as? String, "Locality")
        XCTAssertEqual(additionalInfoDict["billingState"] as? String, "Region")
        XCTAssertEqual(additionalInfoDict["billingPostalCode"] as? String, "12345")
        XCTAssertEqual(additionalInfoDict["billingCountryCode"] as? String, "US")
        XCTAssertEqual(additionalInfoDict["billingPhoneNumber"] as? String, "1234567")
        
        XCTAssertEqual(additionalInfoDict["shippingMethodIndicator"] as? String, "01")
        XCTAssertEqual(additionalInfoDict["productCode"] as? String, "GEN")
        XCTAssertEqual(additionalInfoDict["deliveryTimeframe"] as? String, "03")
        XCTAssertEqual(additionalInfoDict["deliveryEmail"] as? String, "email@test.com")
        XCTAssertEqual(additionalInfoDict["reorderIndicator"] as? String, "01")
        XCTAssertEqual(additionalInfoDict["preorderIndicator"] as? String, "02")
        XCTAssertEqual(additionalInfoDict["preorderDate"] as? String, "20200101")
        XCTAssertEqual(additionalInfoDict["giftCardAmount"] as? String, "10")
        XCTAssertEqual(additionalInfoDict["giftCardCurrencyCode"] as? String, "USD")
        XCTAssertEqual(additionalInfoDict["giftCardCount"] as? String, "5")
        XCTAssertEqual(additionalInfoDict["accountAgeIndicator"] as? String, "05")
        XCTAssertEqual(additionalInfoDict["accountCreateDate"] as? String, "20180203")
        XCTAssertEqual(additionalInfoDict["accountChangeIndicator"] as? String, "02")
        XCTAssertEqual(additionalInfoDict["accountChangeDate"] as? String, "20190304")
        XCTAssertEqual(additionalInfoDict["accountPwdChangeIndicator"] as? String, "03")
        XCTAssertEqual(additionalInfoDict["accountPwdChangeDate"] as? String, "20190101")
        XCTAssertEqual(additionalInfoDict["shippingAddressUsageIndicator"] as? String, "01")
        XCTAssertEqual(additionalInfoDict["shippingAddressUsageDate"] as? String, "20190405")
        XCTAssertEqual(additionalInfoDict["transactionCountDay"] as? String, "1")
        XCTAssertEqual(additionalInfoDict["transactionCountYear"] as? String, "2")
        XCTAssertEqual(additionalInfoDict["addCardAttempts"] as? String, "3")
        XCTAssertEqual(additionalInfoDict["accountPurchases"] as? String, "4")
        XCTAssertEqual(additionalInfoDict["fraudActivity"] as? String, "01")
        XCTAssertEqual(additionalInfoDict["shippingNameIndicator"] as? String, "02")
        XCTAssertEqual(additionalInfoDict["paymentAccountIndicator"] as? String, "03")
        XCTAssertEqual(additionalInfoDict["paymentAccountAge"] as? String, "20190101")
        XCTAssertEqual(additionalInfoDict["addressMatch"] as? String, "N")
        XCTAssertEqual(additionalInfoDict["accountId"] as? String, "ABC123")
        XCTAssertEqual(additionalInfoDict["ipAddress"] as? String, "127.0.0.1")
        XCTAssertEqual(additionalInfoDict["orderDescription"] as? String, "Description")
        XCTAssertEqual(additionalInfoDict["taxAmount"] as? String, "1234")
        XCTAssertEqual(additionalInfoDict["userAgent"] as? String, "User Agent")
        XCTAssertEqual(additionalInfoDict["authenticationIndicator"] as? String, "03")
        XCTAssertEqual(additionalInfoDict["installment"] as? String, "2")
        XCTAssertEqual(additionalInfoDict["purchaseDate"] as? String, "20190401123456")
        XCTAssertEqual(additionalInfoDict["recurringEnd"] as? String, "20201231")
        XCTAssertEqual(additionalInfoDict["recurringFrequency"] as? String, "30")
        XCTAssertEqual(additionalInfoDict["sdkMaxTimeout"] as? String, "10")
        XCTAssertEqual(additionalInfoDict["workPhoneNumber"] as? String, "5551115555")
    }

    func testAsParameters_parameterizesWithNilProperties() {
        let info = BTThreeDSecureAdditionalInformation(productCode: "AIR")

        let threeDSecureRequest = BTThreeDSecureRequest(
            amount: "9.97",
            nonce: "fake-card-nonce",
            additionalInformation: info
        )

        let params = try! ThreeDSecurePOSTBody(request: threeDSecureRequest).toDictionary()
        
        let additionalInfoDict = params["additionalInfo"] as! [String: Any]
            
        XCTAssertNil(additionalInfoDict["shippingMethodIndicator"])
        XCTAssertEqual(additionalInfoDict["productCode"] as? String, "AIR")
    }

}
