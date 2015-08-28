#import "Braintree_Internal.h"

#import "BTClient.h"
#import "BTClient+BTPayPal.h"
#import "BTClient_Internal.h"
#import "BTLogger_Internal.h"

#import "BTPayPalButton.h"
#import "BTPaymentProvider.h"

#import "BTDropInViewController.h"

#import "BTAppSwitch.h"

@interface Braintree ()
@property (nonatomic, strong) BTClient *client;

@property (nonatomic, strong) NSMutableSet *retainedPaymentProviders;
@end

@implementation Braintree

+ (Braintree *)braintreeWithClientToken:(NSString *)clientToken {
    return [[self alloc] initWithClientToken:clientToken];
}

+ (void)setupWithClientToken:(NSString *)clientToken
                  completion:(BraintreeCompletionBlock)completionBlock {
    
    [BTClient setupWithClientToken:clientToken
                        completion:^(BTClient *client, NSError *error)
     {
         Braintree *braintree = [[self alloc] initWithClient:client];
         completionBlock(braintree, error);
     }];
}

- (id)init {
    self = [super init];
    if (self) {
        self.retainedPaymentProviders = [NSMutableSet set];
    }
    return self;
}

- (instancetype)initWithClientToken:(NSString *)clientToken {
    return [self initWithClient:[[BTClient alloc] initWithClientToken:clientToken]];
}

- (instancetype)initWithClient:(BTClient *)client {
    self = [self init];
    if (self) {
        self.client = client;
        [self.client postAnalyticsEvent:@"sdk.ios.braintree.init"];
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

#if BT_ENABLE_APPLE_PAY
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
#else
- (void)tokenizeApplePayPayment:(__unused id)payment
                     completion:(__unused void (^)(NSString *, NSError *))completionBlock {
    NSString *message = @"Apple Pay is not compiled into this integration of Braintree. Please ensure that BT_ENABLE_APPLE_PAY=1 in your framework and app targets.";
    [[BTLogger sharedLogger] warning:message];
#if DEBUG
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:message
                                 userInfo:nil];
#endif
}
#endif

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
}

+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [[BTAppSwitch sharedInstance] handleReturnURL:url sourceApplication:sourceApplication];
}

@end
