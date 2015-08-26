#import "Braintree.h"
#import "BTAPIClient.h"
#import "BTAppSwitch.h"

@implementation Braintree


+ (BTAPIClient *)clientWithClientKey:(NSString *)clientKey {
    return [[BTAPIClient alloc] initWithClientKey:clientKey];
}


+ (BTAPIClient *)clientWithClientToken:(NSString *)clientToken {
    return [[BTAPIClient alloc] initWithClientToken:clientToken];
}


+ (void)setReturnURLScheme:(NSString *)returnURLScheme {
    [BTAppSwitch sharedInstance].returnURLScheme = returnURLScheme;
}


@end
