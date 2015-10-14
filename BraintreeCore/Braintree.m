#import "Braintree.h"
#import "BTAPIClient.h"
#import "BTAppSwitch.h"

@implementation Braintree


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
