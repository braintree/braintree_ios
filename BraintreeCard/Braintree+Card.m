#import "Braintree+Card.h"
#import "BTCardTokenizationClient.h"

@implementation Braintree (Card)

+ (BTCardTokenizationClient *)cardClientWithClientKey:(NSString *)clientKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:clientKey];
    if (!apiClient) {
        return nil;
    }
    return [[BTCardTokenizationClient alloc] initWithAPIClient:apiClient];
}

+ (BTCardTokenizationClient *)cardClientWithClientToken:(NSString *)clientToken {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientToken:clientToken];
    if (!apiClient) {
        return nil;
    }
    return [[BTCardTokenizationClient alloc] initWithAPIClient:apiClient];
}

@end
