#import "Braintree+Card.h"
#import "BTCardClient.h"

@implementation Braintree (Card)

+ (BTCardClient *)cardClientWithClientKey:(NSString *)clientKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:clientKey];
    if (!apiClient) {
        return nil;
    }
    return [[BTCardClient alloc] initWithAPIClient:apiClient];
}

+ (BTCardClient *)cardClientWithClientToken:(NSString *)clientToken {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientToken:clientToken];
    if (!apiClient) {
        return nil;
    }
    return [[BTCardClient alloc] initWithAPIClient:apiClient];
}

@end
