#if __has_include(<Braintree/BraintreeCard.h>)
#import <Braintree/BTCardClient.h>
#else
#import <BraintreeCard/BTCardClient.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTCardClient ()

/**
 Exposed for testing to get the instance of BTAPIClient
*/
@property (nonatomic, strong, readwrite) BTAPIClient *apiClient;

/**
 Convenience helper method for creating friendlier, more human-readable userInfo dictionaries for 422 HTTP errors
*/
+ (NSDictionary *)validationErrorUserInfo:(NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
