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


+ (BOOL)handleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [BTAppSwitch handleReturnURL:url sourceApplication:sourceApplication];
}


+ (BOOL)handleReturnURL:(NSURL *)url options:(NSDictionary *)options {
    return [BTAppSwitch handleReturnURL:url options:options];
}

@end
