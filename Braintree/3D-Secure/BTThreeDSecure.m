#import "BTThreeDSecure.h"

#import "BTClient_Internal.h"
#import "BTThreeDSecureAuthenticationViewController.h"
#import "BTThreeDSecureLocalizedString.h"

@interface BTThreeDSecure () <BTThreeDSecureAuthenticationViewControllerDelegate>
@property (nonatomic, strong) BTClient *client;
@property (nonatomic, strong) BTCardPaymentMethod *upgradedPaymentMethod;
@end

@implementation BTThreeDSecure

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"init is not available for BTThreeDSecure, please use initWithClient" userInfo:nil];
    return [self initWithClient:nil delegate:nil];
}

- (instancetype)initWithClient:(BTClient *)client delegate:(id<BTPaymentMethodCreationDelegate>)delegate {
    if (client == nil || delegate == nil) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.client = client;
        self.delegate = delegate;
    }
    return self;
}

- (void)verifyCardWithNonce:(NSString *)nonce amount:(NSDecimalNumber *)amount {
    NSAssert(self.delegate, @"BTThreeDSecure must have a delegate before verifying a card (delegate is nil)");

    [self.client lookupNonceForThreeDSecure:nonce
                          transactionAmount:amount
                                    success:^(BTThreeDSecureLookupResult *lookupResult) {
                                        if (lookupResult.requiresUserAuthentication) {
                                            BTThreeDSecureAuthenticationViewController *authenticationViewController = [[BTThreeDSecureAuthenticationViewController alloc] initWithLookupResult:lookupResult];
                                            authenticationViewController.delegate = self;
                                            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:authenticationViewController];
                                            [self informDelegateRequestsPresentationOfViewController:navigationController];
                                            [self.client postAnalyticsEvent:@"ios.threedsecure.authentication-start"];
                                        } else {
                                            NSDictionary *threeDSecureInfo = lookupResult.card.threeDSecureInfo;
                                            if ([threeDSecureInfo[@"liabilityShiftPossible"] boolValue] && [threeDSecureInfo[@"liabilityShifted"] boolValue]) {
                                                [self informDelegateDidCreatePaymentMethod:lookupResult.card];
                                            } else {
                                                [self informDelegateDidFailWithError:[NSError errorWithDomain:BTThreeDSecureErrorDomain
                                                                                                         code:BTThreeDSecureFailedLookupErrorCode
                                                                                                     userInfo:@{ NSLocalizedDescriptionKey: @"3D Secure authentication was attempted but liability shift is not possible",
                                                                                                                 BTThreeDSecureInfoKey: lookupResult.card.threeDSecureInfo, }]];
                                            }
                                        }
                                    }
                                    failure:^(NSError *error) {
                                        [self informDelegateDidFailWithError:error];
                                    }];
}

- (void)verifyCard:(BTCardPaymentMethod *)card amount:(NSDecimalNumber *)amount {
    [self verifyCardWithNonce:card.nonce amount:amount];
}

- (void)verifyCardWithDetails:(BTClientCardRequest *)details amount:(NSDecimalNumber *)amount {
    [self.client saveCardWithRequest:details
                             success:^(BTCardPaymentMethod *card) {
                                 [self verifyCard:card amount:amount];
                             } failure:^(NSError *error) {
                                 [self informDelegateDidFailWithError:error];
                             }];
}

#pragma mark BTThreeDSecureAuthenticationViewControllerDelegate

- (void)threeDSecureViewController:(__unused BTThreeDSecureAuthenticationViewController *)viewController
              didAuthenticateCard:(BTCardPaymentMethod *)card
                        completion:(void (^)(BTThreeDSecureViewControllerCompletionStatus))completionBlock {
    self.upgradedPaymentMethod = card;
    completionBlock(BTThreeDSecureViewControllerCompletionStatusSuccess);
    [self.client postAnalyticsEvent:@"ios.threedsecure.authenticated"];
}

- (void)threeDSecureViewController:(__unused BTThreeDSecureAuthenticationViewController *)viewController
                  didFailWithError:(NSError *)error {
    if ([error.domain isEqualToString:BTThreeDSecureErrorDomain] && error.code == BTThreeDSecureFailedAuthenticationErrorCode) {
        [self.client postAnalyticsEvent:@"ios.threedsecure.error.auth-failure"];
    } else {
        [self.client postAnalyticsEvent:@"ios.threedsecure.error.unrecognized-error"];
    }

    self.upgradedPaymentMethod = nil;
    [self informDelegateDidFailWithError:error];
}

- (void)threeDSecureViewControllerDidFinish:(BTThreeDSecureAuthenticationViewController *)viewController {
    if (self.upgradedPaymentMethod) {
        [self informDelegateDidCreatePaymentMethod:self.upgradedPaymentMethod];
    } else {
        [self informDelegateDidCancel];
        [self.client postAnalyticsEvent:@"ios.threedsecure.canceled"];
    }
    [self informDelegateRequestsDismissalOfAuthorizationViewController:viewController];
}

- (void)threeDSecureViewController:(__unused BTThreeDSecureAuthenticationViewController *)viewController
      didPresentErrorForURLRequest:(NSURLRequest *)request {
    [self.client postAnalyticsEvent:[NSString stringWithFormat:@"ios.threedsecure.error.webview-error.%@", request.URL.host]];
}

#pragma mark - Delegate Informers

- (void)informDelegateWillPerformAppSwitch {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorWillPerformAppSwitch:)]) {
        [self.delegate paymentMethodCreatorWillPerformAppSwitch:self];
    }
}

- (void)informDelegateWillProcess {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorWillProcess:)]) {
        [self.delegate paymentMethodCreatorWillProcess:self];
    }
}

- (void)informDelegateRequestsPresentationOfViewController:(UIViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:requestsPresentationOfViewController:)]) {
        [self.delegate paymentMethodCreator:self requestsPresentationOfViewController:viewController];
    }
}

- (void)informDelegateRequestsDismissalOfAuthorizationViewController:(UIViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:requestsDismissalOfViewController:)]) {
        [self.delegate paymentMethodCreator:self requestsDismissalOfViewController:viewController];
    }
}

- (void)informDelegateDidCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:didCreatePaymentMethod:)]) {
        [self.delegate paymentMethodCreator:self didCreatePaymentMethod:paymentMethod];
    }
}

- (void)informDelegateDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:didFailWithError:)]) {
        [self.delegate paymentMethodCreator:self didFailWithError:error];
    }
}

- (void)informDelegateDidCancel {
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorDidCancel:)]) {
        [self.delegate paymentMethodCreatorDidCancel:self];
    }
}

@end
