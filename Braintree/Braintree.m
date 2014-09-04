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
        [self.client postAnalyticsEvent:@"sdk.ios.braintree.init"
                                success:nil
                                failure:nil];
    }
    return self;
}

#pragma mark Tokenization

- (void)tokenizeCardWithNumber:(NSString *)cardNumber
               expirationMonth:(NSString *)expirationMonth
                expirationYear:(NSString *)expirationYear
                    completion:(void (^)(NSString *nonce, NSError *error))completionBlock {
    [self.client postAnalyticsEvent:@"custom.ios.tokenize.call"
                            success:nil
                            failure:nil];

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

- (void)tokenizeCardWithNumber:(NSString *)cardNumber
               expirationMonth:(NSString *)expirationMonth
                expirationYear:(NSString *)expirationYear
                           CVV:(NSString *)CVV
                    postalCode:(NSString *)postalCode
                    completion:(void (^)(NSString *, NSError *))completionBlock {
    [self.client postAnalyticsEvent:@"custom.ios.tokenize.call"
                            success:nil
                            failure:nil];
    
    [self.client saveCardWithNumber:cardNumber
                    expirationMonth:expirationMonth
                     expirationYear:expirationYear
                                cvv:CVV
                         postalCode:postalCode
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

- (BTDropInViewController *)dropInViewControllerWithDelegate:(id<BTDropInViewControllerDelegate>)delegate {
    [self.client postAnalyticsEvent:@"custom.ios.dropin.init"
                            success:nil
                            failure:nil];

    BTDropInViewController *dropInViewController = [[BTDropInViewController alloc] initWithClient:self.client];

    dropInViewController.delegate = delegate;
    [dropInViewController fetchPaymentMethods];
    return dropInViewController;
}

#pragma mark Custom: PayPal

- (BTPayPalButton *)payPalButtonWithDelegate:(id<BTPayPalButtonDelegate>)delegate {
    [self.client postAnalyticsEvent:@"custom.ios.paypal.init"
                            success:nil
                            failure:nil];

    if (!self.client.btPayPal_isPayPalEnabled){
        return nil;
    }

    BTPayPalButton *button = [self payPalButton];
    button.client = self.client;
    button.delegate = delegate;

    return button;
}

#pragma mark -

- (BTPayPalButton *)payPalButton {
    return _payPalButton ?: [[BTPayPalButton alloc] init];
}

#pragma mark Library

+ (NSString *)libraryVersion {
    return [BTClient libraryVersion];
}

@end
