#import <BraintreeCore/BTAPIClient_Internal.h>
#import "BTHTTP.h"
#import "BTThreeDSecureAuthenticationViewController.h"
#import "BTThreeDSecureDriver.h"
#import "BTThreeDSecureLookupResult.h"
#import "BTThreeDSecureTokenizedCard.h"
#import "BTTokenizedCard_Internal.h"

@interface BTThreeDSecureDriver ()<BTThreeDSecureAuthenticationViewControllerDelegate>

@property (nonatomic, strong) BTAPIClient *apiClient;
@property (nonatomic, strong) BTTokenizedCard *upgradedTokenizedCard;

@end

@implementation BTThreeDSecureDriver

- (instancetype)init {
    return nil;
}

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        _apiClient = apiClient;
    }
    return self;
}

- (void)verifyCardWithNonce:(NSString *)nonce amount:(NSDecimalNumber *)amount {
    [self lookupThreeDSecureForNonce:nonce
                   transactionAmount:amount
                          completion:^(BTThreeDSecureLookupResult *lookupResult, NSError *error) {
                              if (error) {
                                  [self informDelegateDidFailWithError:error];
                                  return;
                              }
                              if (lookupResult.requiresUserAuthentication) {
                                  BTThreeDSecureAuthenticationViewController *authenticationViewController = [[BTThreeDSecureAuthenticationViewController alloc] initWithLookupResult:lookupResult];
                                  authenticationViewController.delegate = self;
                                  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:authenticationViewController];
                                  [self informDelegateRequestsPresentationOfViewController:navigationController];
                                  [self.apiClient postAnalyticsEvent:@"ios.threedsecure.authentication-start"];
                              } else {
                                  [self informDelegateDidVerifyCard:lookupResult.tokenizedCard];
                              }
                          }];
}

- (void)lookupThreeDSecureForNonce:(NSString *)nonce
                 transactionAmount:(NSDecimalNumber *)amount
                        completion:(void (^)(BTThreeDSecureLookupResult *lookupResult, NSError *error))completionBlock
{
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        NSMutableDictionary *requestParameters = [@{ @"amount": amount } mutableCopy];

        if (configuration.json[@"merchantAccountId"]) {
            requestParameters[@"merchant_account_id"] = configuration.json[@"merchantAccountId"];
        }
        NSString *urlSafeNonce = [nonce stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [self.apiClient POST:[NSString stringWithFormat:@"v1/payment_methods/%@/three_d_secure/lookup", urlSafeNonce]
                  parameters:requestParameters
                  completion:^(BTJSON *body, NSHTTPURLResponse *response, NSError *error) {

                      if (error) {
                          // Provide more context for card validation error when status code 422
                          if ([error.domain isEqualToString:BTHTTPErrorDomain] &&
                              error.code == BTHTTPErrorCodeClientError &&
                              ((NSHTTPURLResponse *)error.userInfo[BTHTTPURLResponseKey]).statusCode == 422) {

                              NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
                              BTJSON *errorBody = error.userInfo[BTHTTPJSONResponseBodyKey];

                              if (errorBody[@"error"][@"message"].isString) {
                                  userInfo[NSLocalizedDescriptionKey] = errorBody[@"error"][@"message"].asString;
                              }
                              if (errorBody[@"threeDSecureInfo"].isObject) {
                                  userInfo[BTThreeDSecureInfoKey] = errorBody[@"threeDSecureInfo"].asDictionary;
                              }
                              if (errorBody[@"error"].isObject) {
                                  userInfo[BTThreeDSecureValidationErrorsKey] = errorBody[@"error"].asDictionary;
                              }

                              error = [NSError errorWithDomain:BTThreeDSecureErrorDomain
                                                         code:BTThreeDSecureErrorCodeFailedLookup
                                                     userInfo:userInfo];
                          }

                          completionBlock(nil, error);
                          return;
                      }

                      BTJSON *lookupJSON = body[@"lookup"];

                      BTThreeDSecureLookupResult *lookup = [[BTThreeDSecureLookupResult alloc] init];
                      lookup.acsURL = lookupJSON[@"acsUrl"].asURL;
                      lookup.PAReq = lookupJSON[@"pareq"].asString;
                      lookup.MD = lookupJSON[@"md"].asString;
                      lookup.termURL = lookupJSON[@"termUrl"].asURL;
                      lookup.tokenizedCard = [BTThreeDSecureTokenizedCard cardWithJSON:body[@"paymentMethod"]];

                      completionBlock(lookup, nil);
                  }];
    }];
}

#pragma mark BTThreeDSecureAuthenticationViewControllerDelegate

- (void)threeDSecureViewController:(__unused BTThreeDSecureAuthenticationViewController *)viewController
               didAuthenticateCard:(BTTokenizedCard *)card
                        completion:(void (^)(BTThreeDSecureViewControllerCompletionStatus))completionBlock
{
    self.upgradedTokenizedCard = card;
    completionBlock(BTThreeDSecureViewControllerCompletionStatusSuccess);
    [self.apiClient postAnalyticsEvent:@"ios.threedsecure.authenticated"];
}

- (void)threeDSecureViewController:(__unused BTThreeDSecureAuthenticationViewController *)viewController
                  didFailWithError:(NSError *)error {
    if ([error.domain isEqualToString:BTThreeDSecureErrorDomain] && error.code == BTThreeDSecureErrorCodeFailedAuthentication) {
        [self.apiClient postAnalyticsEvent:@"ios.threedsecure.error.auth-failure"];
    } else {
        [self.apiClient postAnalyticsEvent:@"ios.threedsecure.error.unrecognized-error"];
    }

    self.upgradedTokenizedCard = nil;
    [self informDelegateDidFailWithError:error];
}

- (void)threeDSecureViewControllerDidFinish:(BTThreeDSecureAuthenticationViewController *)viewController {
    if (self.upgradedTokenizedCard) {
        [self informDelegateDidVerifyCard:self.upgradedTokenizedCard];
    } else {
        [self informDelegateDidCancel];
        [self.apiClient postAnalyticsEvent:@"ios.threedsecure.canceled"];
    }
    [self informDelegateRequestsDismissalOfViewController:viewController];
}

- (void)threeDSecureViewController:(__unused BTThreeDSecureAuthenticationViewController *)viewController
      didPresentErrorForURLRequest:(NSURLRequest *)request {
    [self.apiClient postAnalyticsEvent:[NSString stringWithFormat:@"ios.threedsecure.error.webview-error.%@", request.URL.host]];
}

#pragma mark Delegate informer helpers

- (void)informDelegateRequestsPresentationOfViewController:(UIViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(threeDSecureDriver:requestsPresentationOfViewController:)]) {
        [self.delegate threeDSecureDriver:self requestsPresentationOfViewController:viewController];
    }
}

- (void)informDelegateRequestsDismissalOfViewController:(UIViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(threeDSecureDriver:requestsDismissalOfViewController:)]) {
        [self.delegate threeDSecureDriver:self requestsDismissalOfViewController:viewController];
    }
}

- (void)informDelegateDidVerifyCard:(BTTokenizedCard *)tokenizedCard {
    if ([self.delegate respondsToSelector:@selector(threeDSecureDriver:didVerifyCard:)]) {
        [self.delegate threeDSecureDriver:self didVerifyCard:tokenizedCard];
    }
}

- (void)informDelegateDidCancel {
    if ([self.delegate respondsToSelector:@selector(threeDSecureDriverDidCancel:)]) {
        [self.delegate threeDSecureDriverDidCancel:self];
    }
}

- (void)informDelegateDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(threeDSecureDriver:didFailWithError:)]) {
        [self.delegate threeDSecureDriver:self didFailWithError:error];
    }
}

@end
