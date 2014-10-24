#import "Braintree_Internal.h"

#import "BTClient.h"
#import "BTClient+BTPayPal.h"
#import "BTLogger.h"

#import "BTPayPalButton.h"
#import "BTPaymentProvider.h"

#import "BTDropInViewController.h"

#import "BTAppSwitch.h"
#import "BTVenmoAppSwitchHandler.h"
#import "BTPayPalAppSwitchHandler.h"

@interface Braintree ()
@property (nonatomic, strong) BTClient *client;

@property (nonatomic, strong) NSMutableSet *retainedPaymentProviders;
@end

@implementation Braintree

+ (Braintree *)braintreeWithClientToken:(NSString *)clientToken {
    return [(Braintree *)[self alloc] initWithClientToken:clientToken];
}

- (id)init {
    self =[super init];
    if (self) {
        self.retainedPaymentProviders = [NSMutableSet set];
    }
    return self;
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


- (BTPaymentButton *)paymentButtonWithDelegate:(id<BTPaymentMethodCreationDelegate>)delegate {
    return [self paymentButtonWithDelegate:delegate paymentProviderTypes:nil];
}

- (BTPaymentButton *)paymentButtonWithDelegate:(id<BTPaymentMethodCreationDelegate>)delegate paymentProviderTypes:(NSOrderedSet *)types {
    BTPaymentButton *button = [[BTPaymentButton alloc] initWithPaymentProviderTypes:types];
    button.client = self.client;
    button.delegate = delegate;
    return button;
}

#pragma mark Custom

- (void)tokenizeCard:(BTClientCardTokenizationRequest *)tokenizationRequest
          completion:(void (^)(NSString *, NSError *))completionBlock {
    [self.client postAnalyticsEvent:@"custom.ios.tokenize.call"
                            success:nil
                            failure:nil];

    BTClientCardRequest *cardRequest = [[BTClientCardRequest alloc] initWithTokenizationRequest:tokenizationRequest];

    [self.client saveCardWithRequest:cardRequest
                             success:^(BTCardPaymentMethod *card) {
                                 if (completionBlock) {
                                     completionBlock(card.nonce, nil);
                                 }
                             }
                             failure:^(NSError *error) {
                                 if (completionBlock) {
                                     completionBlock(nil, error);
                                 }
                             }];
    return;
}

- (void)tokenizeCardWithNumber:(NSString *)cardNumber
               expirationMonth:(NSString *)expirationMonth
                expirationYear:(NSString *)expirationYear
                    completion:(void (^)(NSString *nonce, NSError *error))completionBlock {
    BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
    request.number = cardNumber;
    request.expirationMonth = expirationMonth;
    request.expirationYear = expirationYear;

    [self tokenizeCard:request
            completion:completionBlock];
}

- (void)tokenizeApplePayPayment:(PKPayment *)payment
                     completion:(void (^)(NSString *, NSError *))completionBlock {
    [self.client postAnalyticsEvent:@"custom.ios.tokenize.apple-pay"];

    [self.client saveApplePayPayment:payment
                             success:^(BTApplePayPaymentMethod *applePayPaymentMethod) {
                                 if (completionBlock) {
                                     completionBlock(applePayPaymentMethod.nonce, nil);
                                 }
                             }
                             failure:^(NSError *error) {
                                 if (completionBlock) {
                                     completionBlock(nil, error);
                                 }
                             }];
}

- (BTPaymentProvider *)paymentProviderWithDelegate:(id<BTPaymentMethodCreationDelegate>)delegate {
    BTPaymentProvider *paymentProvider = [[BTPaymentProvider alloc] initWithClient:self.client];
    paymentProvider.delegate = delegate;

    [self.retainedPaymentProviders addObject:paymentProvider];

    return paymentProvider;
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
