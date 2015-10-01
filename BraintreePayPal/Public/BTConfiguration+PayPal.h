#import "BTConfiguration.h"

@interface BTConfiguration (PayPal)

/// Indicates whether PayPal is enabled for the merchant account.
@property (nonatomic, readonly, assign) BOOL isPayPalEnabled;
@property (nonatomic, readonly, assign) BOOL isBillingAgreementsEnabled;

@end
