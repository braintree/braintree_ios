//
//  BTPayPalNativeCheckoutDriver.swift
//  BraintreePayPalNativeCheckout
//
//  Created by Jones, Jon on 6/8/22.
//

import Foundation
import BraintreeCore

public class BTPayPalNativeCheckoutDriver {

  public func requestBillingAgreement(
    _ request: BTPayPalNativeCheckoutRequest,
    completion: @escaping((BTPayPalNativeCheckoutNonce?, Error?) -> Void)) {
//      [self tokenizePayPalAccountWithPayPalRequest:request completion:completionBlock];
  }

  public func requestOneTimePayment(
    _ request: BTPayPalNativeCheckoutRequest,
    completion: @escaping((BTPayPalNativeCheckoutNonce?, Error?) -> Void)) {
//      [self tokenizePayPalAccountWithPayPalRequest:request completion:completionBlock];
  }
}
