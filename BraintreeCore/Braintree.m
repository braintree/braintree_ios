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


+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [BTAppSwitch handleOpenURL:url sourceApplication:sourceApplication];
}


+ (BOOL)handleOpenURL:(NSURL *)url options:(NSDictionary *)options {
    return [BTAppSwitch handleOpenURL:url options:options];
}

@end
