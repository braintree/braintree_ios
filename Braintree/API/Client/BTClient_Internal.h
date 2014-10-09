#import "BTClient.h"
#import "BTHTTP.h"
#import "BTClientToken.h"
#import "BTClientConfiguration.h"

@interface BTClient ()
@property (nonatomic, strong, readwrite) BTHTTP *clientApiHttp;
@property (nonatomic, strong, readwrite) BTHTTP *analyticsHttp;

/// Models the contents of the client token, as it is received from the merchant server
@property (nonatomic, strong) BTClientToken *clientToken;

/// Models the current client configuration
///
/// 1) First, configuration is bootstrapped based on the clientToken
/// 2) In the future, full configuration details will be fetched asynchronously via the Client API
@property (nonatomic, strong) BTClientConfiguration *configuration;

// Internal helpers
// Declared here to make available for testing
+ (BTPayPalPaymentMethod *)payPalPaymentMethodFromAPIResponseDictionary:(NSDictionary *)response;

@end
