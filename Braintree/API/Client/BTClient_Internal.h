#import "BTClient.h"
#import "BTHTTP.h"
#import "BTClientToken.h"

@interface BTClient ()
@property (nonatomic, strong, readwrite) BTHTTP *clientApiHttp;
@property (nonatomic, strong, readwrite) BTHTTP *analyticsHttp;

/// Models the contents of the client token, as it is received from the merchant server
@property (nonatomic, strong) BTClientToken *clientToken;

// Internal helpers
// Declared here to make available for testing
// TODO: Delete me
//+ (BTPayPalPaymentMethod *)payPalPaymentMethodFromAPIResponseDictionary:(NSDictionary *)response;

@end
