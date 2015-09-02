#import "Braintree+UI.h"
#import "BTDropInViewController.h"
#import "BTPaymentButton.h"

@implementation Braintree (UI)

+ (BTDropInViewController *)dropInViewControllerWithClientKey:(NSString *)clientKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:clientKey];
    if (!apiClient) {
        return nil;
    }
    return [[BTDropInViewController alloc] initWithAPIClient:apiClient];
}

+ (BTDropInViewController *)dropInViewControllerWithClientToken:(NSString *)clientToken {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientToken:clientToken];
    if (!apiClient) {
        return nil;
    }
    return [[BTDropInViewController alloc] initWithAPIClient:apiClient];
}

+ (BTPaymentButton *)paymentButtonWithClientKey:(NSString *)clientKey {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientKey:clientKey];
    if (!apiClient) {
        return nil;
    }
    return [[BTPaymentButton alloc] initWithAPIClient:apiClient];
}

+ (BTPaymentButton *)paymentButtonWithClientToken:(NSString *)clientToken {
    BTAPIClient *apiClient = [[BTAPIClient alloc] initWithClientToken:clientToken];
    if (!apiClient) {
        return nil;
    }
    return [[BTPaymentButton alloc] initWithAPIClient:apiClient];
}

@end
