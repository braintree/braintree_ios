#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

/**
 BTConfiguration category for Venmo
 */
@interface BTConfiguration (Venmo)

/**
 Force Venmo to be enabled. If false, Drop-In will not display the Venmo button and [BTVenmoDriver authorizationWithCompletion:] will return an error.
 When set to true the Venmo button will be visible if it is also setup properly.
 Defaults to false during the limited availability phase.
*/
+ (void)enableVenmo:(BOOL)isEnabled DEPRECATED_MSG_ATTRIBUTE("Venmo no longer relies on a user whitelist, thus this method is not needed");

/**
 Indicates whether Venmo is enabled for the merchant account.
*/
@property (nonatomic, readonly, assign) BOOL isVenmoEnabled;

/**
 Returns the Access Token used by the Venmo app to tokenize on behalf of the merchant.
*/
@property (nonatomic, readonly, strong) NSString *venmoAccessToken;

/**
 Returns the Venmo merchant ID used by the Venmo app to authorize payment.
 */
@property (nonatomic, readonly, strong) NSString *venmoMerchantID;

/**
 Returns the Venmo environment used to handle this payment.
 */
@property (nonatomic, readonly, strong) NSString *venmoEnvironment;

@end
