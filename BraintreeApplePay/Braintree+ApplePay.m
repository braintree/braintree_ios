#import "Braintree+ApplePay.h"
#import "BTApplePayClient.h"

@implementation Braintree (ApplePay)

+ (BTApplePayClient *)applePayClientWithClientKey:(NSString *)clientKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:clientKey];
    if (!apiClient) {
        return nil;
    }
    return [[BTApplePayClient alloc] initWithAPIClient:apiClient];
}

+ (BTApplePayClient *)applePayClientWithClientToken:(NSString *)clientToken {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientToken:clientToken];
    if (!apiClient) {
        return nil;
    }
    return [[BTApplePayClient alloc] initWithAPIClient:apiClient];
}

@end
