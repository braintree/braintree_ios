#import "BTClient.h"
#import "BTHTTP.h"
#import "BTClientToken.h"

@class BTClientConfiguration;

typedef void (^BTClientConfigurationSuccessBlock)(BTClientConfiguration *configuration);

@interface BTClient ()
@property (nonatomic, strong, readwrite) BTHTTP *clientApiHttp;
@property (nonatomic, strong, readwrite) BTHTTP *analyticsHttp;
@property (nonatomic, strong, readwrite) BTHTTP *configHttp;
@property (nonatomic, strong) BTClientToken *clientToken;

// Internal helpers
// Declared here to make available for testing
+ (BTPayPalPaymentMethod *)payPalPaymentMethodFromAPIResponseDictionary:(NSDictionary *)response;

/// Retrieve client configuration from the Client API based on the config URL in the client token
///
/// @note: Over time, gateway-driven client configuration will gradually move from the client token
/// to the configuration endpoint.
///
/// @param successBlock success callback for handling the returned list of payment methods
/// @param failureBlock failure callback for handling errors
- (void)fetchConfigurationWithSuccess:(BTClientConfigurationSuccessBlock)successBlock
                              failure:(BTClientFailureBlock)failureBlock;

@end