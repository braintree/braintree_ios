#import <Foundation/Foundation.h>

#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BraintreeCore-Swift.h>
#else
#import <BraintreeCore/BraintreeCore-Swift.h>
#endif

/**
 BTConfiguration category for PayPal.
 */
@interface BTConfiguration (PayPal)

/**
 Indicates whether PayPal is enabled for the merchant account.
*/
@property (nonatomic, readonly, assign) BOOL isPayPalEnabled;

/**
 Indicates whether PayPal billing agreements are enabled for the merchant account.
 */
@property (nonatomic, readonly, assign) BOOL isBillingAgreementsEnabled;

@end
