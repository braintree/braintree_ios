#if __has_include(<Braintree/BraintreeUnionPay.h>)
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

/**
 BTConfiguration category for UnionPay
 */
DEPRECATED_MSG_ATTRIBUTE("The UnionPay SMS integration is deprecated, as UnionPay can now be processed as a credit card through their partnership with Discover. Use `BTCardClient.tokenizeCard(card: completion:)`.")
@interface BTConfiguration (UnionPay)

/**
 Indicates whether UnionPay is enabled for the merchant account.
*/
@property (nonatomic, readonly, assign) BOOL isUnionPayEnabled;

@end
