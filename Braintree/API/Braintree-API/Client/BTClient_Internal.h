#import "BTClient.h"
#import "BTHTTP.h"
#import "BTClientToken.h"

#import "BTClientDeprecatedApplePayConfiguration.h"

@interface BTClient ()
@property (nonatomic, strong, readwrite) BTHTTP *clientApiHttp;
@property (nonatomic, strong, readwrite) BTHTTP *analyticsHttp;
@property (nonatomic, strong) BTClientToken *clientToken;

@property (nonatomic, strong, readonly) BTClientDeprecatedApplePayConfiguration *applePayConfiguration;

// Internal helpers
// Declared here to make available for testing
+ (BTPayPalPaymentMethod *)payPalPaymentMethodFromAPIResponseDictionary:(NSDictionary *)response;

@end