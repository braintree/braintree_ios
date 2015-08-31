#import "Braintree+Venmo.h"
#import "BTVenmoDriver.h"

@implementation Braintree (Venmo)

+ (BTVenmoDriver *)venmoDriverWithClientKey:(NSString *)clientKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:clientKey];
    if (!apiClient) {
        return nil;
    }
    return [[BTVenmoDriver alloc] initWithAPIClient:apiClient];
}

+ (BTVenmoDriver *)venmoDriverWithClientToken:(NSString *)clientToken {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientToken:clientToken];
    if (!apiClient) {
        return nil;
    }
    return [[BTVenmoDriver alloc] initWithAPIClient:[[BTAPIClient alloc] initWithClientToken:clientToken]];
}

@end
