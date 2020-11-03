#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTHTTP.h>
#else
#import <BraintreeCore/BTHTTP.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class BTHTTPResponse, BTClientToken;

/**
 Performs HTTP methods on the Braintree Client API
 */
@interface BTGraphQLHTTP : BTHTTP

@end

NS_ASSUME_NONNULL_END
