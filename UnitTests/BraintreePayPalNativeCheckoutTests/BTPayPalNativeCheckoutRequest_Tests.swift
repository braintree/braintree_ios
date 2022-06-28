//
//  BTPayPalNativeCheckoutRequest_Tests.swift
//  BraintreePayPalNativeCheckoutTests
//
//  Created by Jones, Jon on 6/28/22.
//

import XCTest
@testable import BraintreePayPalNativeCheckout
@testable import BraintreeCore

class BTPayPalNativeCheckoutRequest_Tests: XCTestCase {

  private var configuration: BTConfiguration!

  override func setUp() {
      super.setUp()
      let json = BTJSON(value: [
          "paypalEnabled": true,
          "paypal": [
              "environment": "offline"
          ]
      ])
      configuration = BTConfiguration(json: json)
  }

  func testPaymentTypeIsCheckout() {
    let checkoutRequest = BTPayPalNativeCheckoutRequest(amount: "10.00")
    XCTAssertTrue(checkoutRequest.paymentType == .checkout, "Incorrect payment type on CheckoutRequest")
  }

  func testHermesPathIsCorrect() {
    let checkoutRequest = BTPayPalNativeCheckoutRequest(amount: "10.00")
    XCTAssertEqual(checkoutRequest.hermesPath, "v1/paypal_hermes/create_payment_resource")
  }

  func testIntentStringReturnsCorrectValue() {
    let checkoutRequest = BTPayPalNativeCheckoutRequest(amount: "10.00")
    checkoutRequest.intent = .authorize
    XCTAssertEqual(checkoutRequest.intentAsString, "authorize")

    checkoutRequest.intent = .order
    XCTAssertEqual(checkoutRequest.intentAsString, "order")

    checkoutRequest.intent = .sale
    XCTAssertEqual(checkoutRequest.intentAsString, "sale")
  }

  func testParametersWithConfigurationReturnsAllParams() {
      let request = BTPayPalNativeCheckoutRequest(amount: "1")
      request.intent = .sale
      request.offerPayLater = true
      request.currencyCode = "currency-code"
      request.requestBillingAgreement = true
      request.billingAgreementDescription = "description"

      let shippingAddress = BTPostalAddress()
      shippingAddress.streetAddress = "123 Main"
      shippingAddress.extendedAddress = "Unit 1"
      shippingAddress.locality = "Chicago"
      shippingAddress.region = "IL"
      shippingAddress.postalCode = "11111"
      shippingAddress.countryCodeAlpha2 = "US"
      shippingAddress.recipientName = "Recipient"
      request.shippingAddressOverride = shippingAddress
      request.isShippingAddressEditable = true

      let parameters = request.parameters(with: configuration)

      XCTAssertEqual(parameters["intent"] as? String, "sale")
      XCTAssertEqual(parameters["amount"] as? String, "1")
      XCTAssertEqual(parameters["offer_pay_later"] as? Bool, true)
      XCTAssertEqual(parameters["currency_iso_code"] as? String, "currency-code")
      XCTAssertEqual(parameters["line1"] as? String, "123 Main")
      XCTAssertEqual(parameters["line2"] as? String, "Unit 1")
      XCTAssertEqual(parameters["city"] as? String, "Chicago")
      XCTAssertEqual(parameters["state"] as? String, "IL")
      XCTAssertEqual(parameters["postal_code"] as? String, "11111")
      XCTAssertEqual(parameters["country_code"] as? String, "US")
      XCTAssertEqual(parameters["recipient_name"] as? String, "Recipient")
      XCTAssertEqual(parameters["request_billing_agreement"] as? Bool, true)

      guard let billingAgreementDetails = parameters["billing_agreement_details"] as? [String : String] else {
          XCTFail()
          return
      }

      XCTAssertEqual(billingAgreementDetails["description"], "description")
  }
}
