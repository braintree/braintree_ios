#if __has_include("BraintreeCore.h")
#import "BTConfiguration.h"
#else
#import <BraintreeCore/BTConfiguration.h>
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
