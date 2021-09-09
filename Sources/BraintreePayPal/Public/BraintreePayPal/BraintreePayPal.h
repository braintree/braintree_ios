#import <Foundation/Foundation.h>

/// Project version number for BraintreePayPal.
FOUNDATION_EXPORT double BraintreePayPalVersionNumber;

/// Project version string for BraintreePayPal.
FOUNDATION_EXPORT const unsigned char BraintreePayPalVersionString[];

#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BraintreeCore.h>
#import <Braintree/BTConfiguration+PayPal.h>
#import <Braintree/BTPayPalRequest.h>
#import <Braintree/BTPayPalDriver.h>
#import <Braintree/BTPayPalAccountNonce.h>
#import <Braintree/BTPayPalCreditFinancing.h>
#import <Braintree/BTPayPalCreditFinancingAmount.h>
#import <Braintree/BTPayPalLineItem.h>
#import <Braintree/BTPayPalCheckoutRequest.h>
#import <Braintree/BTPayPalVaultRequest.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreePayPal/BTConfiguration+PayPal.h>
#import <BraintreePayPal/BTPayPalRequest.h>
#import <BraintreePayPal/BTPayPalDriver.h>
#import <BraintreePayPal/BTPayPalAccountNonce.h>
#import <BraintreePayPal/BTPayPalCreditFinancing.h>
#import <BraintreePayPal/BTPayPalCreditFinancingAmount.h>
#import <BraintreePayPal/BTPayPalLineItem.h>
#import <BraintreePayPal/BTPayPalCheckoutRequest.h>
#import <BraintreePayPal/BTPayPalVaultRequest.h>
#endif
