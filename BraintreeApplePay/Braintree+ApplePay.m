#import "Braintree+ApplePay.h"
#import "BTApplePayTokenizationClient.h"

@implementation Braintree (ApplePay)

+ (BTApplePayTokenizationClient *)applePayClientWithClientKey:(NSString *)clientKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:clientKey];
    if (!apiClient) {
        return nil;
    }
    return [[BTApplePayTokenizationClient alloc] initWithAPIClient:apiClient];
}

+ (BTApplePayTokenizationClient *)applePayClientWithClientToken:(NSString *)clientToken {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientToken:clientToken];
    if (!apiClient) {
        return nil;
    }
    return [[BTApplePayTokenizationClient alloc] initWithAPIClient:apiClient];
}

@end
