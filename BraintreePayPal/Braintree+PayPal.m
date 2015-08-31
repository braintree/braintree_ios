#import "Braintree+PayPal.h"
#import "BTPayPalDriver.h"

@implementation Braintree (PayPal)

+ (BTPayPalDriver *)payPalDriverWithClientKey:(NSString *)clientKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:clientKey];
    if (!apiClient) {
        return nil;
    }
    return [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
}

+ (BTPayPalDriver *)payPalDriverWithClientToken:(NSString *)clientToken {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientToken:clientToken];
    if (!apiClient) {
        return nil;
    }
    return [[BTPayPalDriver alloc] initWithAPIClient:apiClient];
}

@end
