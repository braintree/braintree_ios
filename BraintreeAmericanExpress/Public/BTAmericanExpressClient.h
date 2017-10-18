#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSString * const BTAmericanExpressErrorDomain;
typedef NS_ENUM(NSInteger, BTAmericanExpressErrorType) {
    BTAmericanExpressErrorTypeUnknown = 0,

    /// Invalid parameters
    BTAmericanExpressErrorTypeInvalidParameters,
};

@interface BTAmericanExpressClient : NSObject

/*!
 @brief Creates an American Express client.

 @param apiClient An API client
*/
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient NS_DESIGNATED_INITIALIZER;


- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));

/*!
 @brief Gets the rewards balance associated with a Braintree nonce
 
 @param options The NSDictionary containing the options. Required options at the top level: `nonce` and `currencyIsoCode`
 @param completionBlock A completion block that is invoked when the request has completed. If the request succeeds,
 `payload` will contain a information about the rewards balance and `error` will be `nil` (see exceptions in note);
 if it fails, `payload` will be `nil` and `error` will describe the failure.
 @note If the nonce is associated with an ineligible card or a card with insufficient points, the payload will contain this information nested under `error` in the payload dictionary.
 */
- (void)getRewardsBalance:(NSDictionary *)options completion:(void (^)(NSDictionary * _Nullable payload, NSError * _Nullable error))completionBlock NS_AVAILABLE_IOS(8_0);

@end

NS_ASSUME_NONNULL_END
