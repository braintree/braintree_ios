#import "Braintree_Internal.h"

#import "BTClient.h"
#import "BTClient+BTPayPal.h"
#import "BTPayPalButton.h"
#import "BTPaymentAuthorizer.h"

#import "BTDropInViewController.h"

#import "BTAppSwitch.h"
#import "BTVenmoAppSwitchHandler.h"
#import "BTPayPalAppSwitchHandler.h"

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

#pragma mark UI

- (BTDropInViewController *)dropInViewControllerWithDelegate:(id<BTDropInViewControllerDelegate>)delegate {
    [self.client postAnalyticsEvent:@"custom.ios.dropin.init"
                            success:nil
                            failure:nil];

    BTDropInViewController *dropInViewController = [[BTDropInViewController alloc] initWithClient:self.client];

    dropInViewController.delegate = delegate;
    [dropInViewController fetchPaymentMethods];
    return dropInViewController;
}

- (BTPaymentButton *)paymentButtonWithPaymentAuthorizationTypes:(NSOrderedSet *)types delegate:(id<BTPaymentAuthorizerDelegate>)delegate {
    BTPaymentButton *button = [[BTPaymentButton alloc] initWithPaymentAuthorizationTypes:types];
    button.client = self.client;
    button.delegate = delegate;
    return button;
}

#pragma mark Custom

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

- (void)authorizePayment:(BTPaymentAuthorizationType)type
                delegate:(__unused id<BTPaymentAuthorizerDelegate>)delegate {
    [self.authorizer setDelegate:delegate];
    [self.authorizer authorize:type];
    return;
}

- (BTPaymentAuthorizer *)authorizer {
    return _authorizer ?: [[BTPaymentAuthorizer alloc] initWithClient:self.client];
}

#pragma mark Deprecated

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

- (BTPayPalButton *)payPalButton {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    _payPalButton = _payPalButton ?: [[BTPayPalButton alloc] init];
#pragma clang diagnostic pop
    return _payPalButton;
}

#pragma mark Library

+ (NSString *)libraryVersion {
    return [BTClient libraryVersion];
}

#pragma mark App Switching

+ (void)setReturnURLScheme:(NSString *)scheme {
    [BTAppSwitch sharedInstance].returnURLScheme = scheme;
    [self initAppSwitchingOptions];
}

+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    [self initAppSwitchingOptions];
    return [[BTAppSwitch sharedInstance] handleReturnURL:url sourceApplication:sourceApplication];
}

+ (void)initAppSwitchingOptions {
    [[BTAppSwitch sharedInstance] addAppSwitching:[BTVenmoAppSwitchHandler sharedHandler]];
    [[BTAppSwitch sharedInstance] addAppSwitching:[BTPayPalAppSwitchHandler sharedHandler]];
}

@end
