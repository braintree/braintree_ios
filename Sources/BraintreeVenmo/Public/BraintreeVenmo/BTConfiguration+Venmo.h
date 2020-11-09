#if __has_include(<Braintree/BraintreeVenmo.h>)
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

/**
 BTConfiguration category for Venmo
 */
@interface BTConfiguration (Venmo)

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
