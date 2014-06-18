#import "Braintree_Internal.h"

#import "BTClient.h"
#import "BTClient+BTPayPal.h"
#import "BTPayPalButton.h"

#import "BTDropInViewController.h"

@interface Braintree ()
@property (nonatomic, strong) BTClient *client;
@end

@implementation Braintree

+ (Braintree *)braintreeWithClientToken:(NSString *)clientToken {
    return [[self alloc] initWithClientToken:clientToken];
}

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [self init];
    if (self) {
        self.client = [[BTClient alloc] initWithClientToken:clientToken];
    }
    return self;
}

#pragma mark Tokenization

- (void)tokenizeCardWithNumber:(NSString *)cardNumber
               expirationMonth:(NSString *)expirationMonth
                expirationYear:(NSString *)expirationYear
                    completion:(BraintreeNonceCompletionBlock)completionBlock {

    [self.client saveCardWithNumber:cardNumber
                    expirationMonth:expirationMonth
                     expirationYear:expirationYear
                                cvv:nil
                         postalCode:nil
                           validate:NO
                            success:^(BTCardPaymentMethod *card) {
                                if (completionBlock) {
                                    completionBlock(card.nonce, nil);
                                }
                            }
                            failure:^(NSError *error) {
                                completionBlock(nil, error);
                            }];
}

#pragma mark Drop-In

- (BTDropInViewController *)dropInViewControllerWithCompletion:(BraintreeNonceCompletionBlock)completionBlock {
    BTDropInViewController *dropInViewController = [[BTDropInViewController alloc] initWithClient:self.client];
    dropInViewController.paymentMethodCompletionBlock = ^(BTPaymentMethod *paymentMethod, __unused NSError *error){
        completionBlock(paymentMethod.nonce, nil);
    };

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.client fetchPaymentMethodsWithSuccess:^(NSArray *paymentMethods) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        dropInViewController.paymentMethods = paymentMethods;
    } failure:^(NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"Error fetching payment methods: %@", error);
        dropInViewController.paymentMethods = @[];
    }];

    return dropInViewController;
}

#pragma mark Custom: PayPal

- (BTPayPalButton *)payPalButtonWithCompletion:(BraintreeNonceCompletionBlock)completionBlock {
    if (!self.client.btPayPal_isPayPalEnabled){
        return nil;
    }
    BTPayPalButton *button = [self payPalButton];
    button.client = self.client;
    button.completionBlock = ^(BTPaymentMethod *paymentMethod, NSError *error) {
        completionBlock(paymentMethod ? paymentMethod.nonce : nil, error ?: nil);
    };

    return button;
}

#pragma mark -

- (BTPayPalButton *)payPalButton {
    return _payPalButton ?: [[BTPayPalButton alloc] init];
}

#pragma mark Library

+ (NSString *)libraryVersion {
#if defined(COCOAPODS) && defined(COCOAPODS_VERSION_MAJOR_Braintree) &&defined(COCOAPODS_VERSION_MINOR_Braintree) && defined(COCOAPODS_VERSION_PATCH_Braintree)
    return [NSString stringWithFormat:@"%d.%d.%d",
            COCOAPODS_VERSION_MAJOR_Braintree,
            COCOAPODS_VERSION_MINOR_Braintree,
            COCOAPODS_VERSION_PATCH_Braintree];
#else
#ifdef DEBUG
    return @"development";
#else
    return @"unknown";
#endif
#endif
}
@end
