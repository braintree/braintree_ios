#import "BTThreeDSecureRequest.h"
#if __has_include("BTLogger_Internal.h")
#import "BTLogger_Internal.h"
#else
#import <BraintreeCore/BTLogger_Internal.h>
#endif
#if __has_include("BTAPIClient_Internal.h")
#import "BTAPIClient_Internal.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#endif
#import "BTPaymentFlowDriver_Internal.h"
#import "BTThreeDSecureRequest.h"
#import "Braintree-Version.h"
#import <SafariServices/SafariServices.h>
#import "BTThreeDSecureResult.h"
#import "BTThreeDSecureLookup.h"
#import "BTPaymentFlowDriver+ThreeDSecure_Internal.h"
#import "BTThreeDSecurePostalAddress_Internal.h"
#import "BTURLUtils.h"
#import "BTConfiguration+ThreeDSecure.h"
#import <CardinalMobile/CardinalMobile.h>

NSString *const BTThreeDSecureAssetsPath = @"/mobile/three-d-secure-redirect/0.1.5";

@interface BTThreeDSecureRequest () <CardinalValidationDelegate>

@property (nonatomic, weak) id<BTPaymentFlowDriverDelegate> paymentFlowDriverDelegate;
@property (nonnull, strong) BTThreeDSecureLookup *lookupResult;
@property (nonatomic, strong) CardinalSession *cardinalSession;
@property (nonatomic, strong) NSString *dfReferenceId;

@end

@implementation BTThreeDSecureRequest

- (void)handleRequest:(BTPaymentFlowRequest *)request client:(BTAPIClient *)apiClient paymentDriverDelegate:(id<BTPaymentFlowDriverDelegate>)delegate {
    self.paymentFlowDriverDelegate = delegate;

    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable configurationError) {
        if (configurationError) {
            [self.paymentFlowDriverDelegate onPaymentComplete:nil error:configurationError];
            return;
        }

        if (configuration.cardinalAuthenticationJWT) {
            self.cardinalSession = [CardinalSession new];
            // TODO: Switch between staging and production
            CardinalSessionConfig *cardinalConfiguration = [CardinalSessionConfig new];
            cardinalConfiguration.deploymentEnvironment = CardinalSessionEnvironmentStaging;
            [self.cardinalSession configure:cardinalConfiguration];

            [self.cardinalSession setupWithJWT:configuration.cardinalAuthenticationJWT
                                   didComplete:^(NSString * _Nonnull consumerSessionId) {
                                       self.dfReferenceId = consumerSessionId;
                                       [self startRequest:request client:apiClient paymentDriverDelegate:delegate];
                                   } didValidate:^(__unused CardinalResponse * _Nonnull validateResponse) {
                                       // TODO: continue lookup and assume it will be v1?
                                       [self startRequest:request client:apiClient paymentDriverDelegate:delegate];
                                   }];
        }
        else {
            [self startRequest:request client:apiClient paymentDriverDelegate:delegate];
        }
    }];
}

- (void)startRequest:(BTPaymentFlowRequest *)request client:(BTAPIClient *)apiClient paymentDriverDelegate:(id<BTPaymentFlowDriverDelegate>)delegate {
    BTThreeDSecureRequest *threeDSecureRequest = (BTThreeDSecureRequest *)request;
    BTPaymentFlowDriver *paymentFlowDriver = [[BTPaymentFlowDriver alloc] initWithAPIClient:[self.paymentFlowDriverDelegate apiClient]];

    [paymentFlowDriver performThreeDSecureLookup:threeDSecureRequest
                                   dfReferenceId:self.dfReferenceId
                                      completion:^(BTThreeDSecureLookup *lookupResult, NSError *error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              if (error) {
                                                  [self.paymentFlowDriverDelegate onPaymentWithURL:nil error:error];
                                                  return;
                                              }

                                              [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *configurationError) {
                                                  if (configurationError) {
                                                      [self.paymentFlowDriverDelegate onPaymentComplete:nil error:configurationError];
                                                      return;
                                                  }

                                                  self.lookupResult = lookupResult;
                                                  if (lookupResult.requiresUserAuthentication) {
                                                      if (lookupResult.isThreeDSecureVersion2) {
                                                          [self.cardinalSession continueWithTransactionId:lookupResult.transactionId
                                                                                                  payload:lookupResult.PAReq
                                                                                                   acsUrl:[lookupResult.acsURL absoluteString]
                                                                                        directoryServerID:CCADirectoryServerIDEMVCo1
                                                                                      didValidateDelegate:self];
                                                      }
                                                      else {
                                                          NSString *acsurl = [NSString stringWithFormat:@"AcsUrl=%@", [lookupResult.acsURL.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
                                                          NSString *pareq = [NSString stringWithFormat:@"PaReq=%@", [self stringByAddingPercentEncodingForRFC3986:lookupResult.PAReq]];
                                                          NSString *md = [NSString stringWithFormat:@"MD=%@", [lookupResult.MD stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

                                                          NSString *callbackUrl = [NSString stringWithFormat: @"ReturnUrl=%@%@/redirect.html?redirect_url=%@://x-callback-url/braintree/threedsecure?",
                                                                                   [configuration.json[@"assetsUrl"] asString],
                                                                                   BTThreeDSecureAssetsPath,
                                                                                   [delegate returnURLScheme]
                                                                                   ];
                                                          callbackUrl = [callbackUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
                                                          NSString *authUrl = [NSString stringWithFormat:@"%@",
                                                                               [lookupResult.termURL.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]
                                                                               ];

                                                          NSString *termurl = [NSString stringWithFormat: @"TermUrl=%@", authUrl];
                                                          NSURL *redirectUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/index.html?%@&%@&%@&%@&%@", [configuration.json[@"assetsUrl"] asString], BTThreeDSecureAssetsPath, acsurl, pareq, md, termurl, callbackUrl]];
                                                          [self.paymentFlowDriverDelegate onPaymentWithURL:redirectUrl error:error];
                                                      }
                                                  } else {
                                                      [self.paymentFlowDriverDelegate onPaymentComplete:lookupResult.threeDSecureResult error:error];
                                                  }
                                              }];
                                          });
                                      }];
}

- (void)handleOpenURL:(__unused NSURL *)url {
    NSString *jsonAuthResponse = [BTURLUtils dictionaryForQueryString:url.query][@"auth_response"];
    BTJSON *authBody = [[BTJSON alloc] initWithValue:[NSJSONSerialization JSONObjectWithData:[jsonAuthResponse dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL]];
    BTThreeDSecureResult *result = [[BTThreeDSecureResult alloc] initWithJSON:authBody];

    if (!result.success) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
        if (result.errorMessage) {
            userInfo[NSLocalizedDescriptionKey] = result.errorMessage;
        }

        NSError *error = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                             code:BTThreeDSecureFlowErrorTypeFailedAuthentication
                                         userInfo:userInfo];
        [self.paymentFlowDriverDelegate onPaymentComplete:nil error:error];
        return;
    }

    [self.paymentFlowDriverDelegate onPaymentComplete:result error:nil];
}

- (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url sourceApplication:(__unused NSString *)sourceApplication {
    return [url.host isEqualToString:@"x-callback-url"] && [url.path hasPrefix:@"/braintree/threedsecure"];
}

- (NSString *)paymentFlowName {
    return @"three-d-secure";
}

- (NSString *)stringByAddingPercentEncodingForRFC3986:(NSString *)string {
    NSString *unreserved = @"-._~/?";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet
                                      alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    return [string
            stringByAddingPercentEncodingWithAllowedCharacters:
            allowed];
}

- (NSDictionary *)asParameters {
    NSMutableDictionary *parameters = [@{} mutableCopy];
    
    if (self.amount) {
        parameters[@"amount"] = [self.amount stringValue];
    }
    
    NSMutableDictionary *additionalInformation = [@{} mutableCopy];
    
    if (self.mobilePhoneNumber) {
        additionalInformation[@"mobilePhoneNumber"] = self.mobilePhoneNumber;
    }
    
    if (self.email) {
        additionalInformation[@"email"] = self.email;
    }
    
    if (self.shippingMethod) {
        additionalInformation[@"shippingMethod"] = self.shippingMethod;
    }
    
    if (self.billingAddress) {
        [additionalInformation addEntriesFromDictionary:[self.billingAddress asParameters]];
    }

    if (additionalInformation.count) {
        parameters[@"additionalInformation"] = additionalInformation;
    }
    
    return [parameters copy];
}

#pragma mark - Cardinal Delegate

- (void)cardinalSession:(__unused CardinalSession *)session stepUpDidValidateWithResponse:(CardinalResponse *)validateResponse serverJWT:(__unused NSString *)serverJWT{
    switch (validateResponse.actionCode) {
        case CardinalResponseActionCodeSuccess:
        case CardinalResponseActionCodeNoAction:
        case CardinalResponseActionCodeFailure: {
            NSString *urlSafeNonce = [self.lookupResult.threeDSecureResult.tokenizedCard.nonce stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            NSDictionary *requestParameters = @{@"jwt": serverJWT, @"paymentMethodNonce": self.lookupResult.threeDSecureResult.tokenizedCard.nonce};
            [[self.paymentFlowDriverDelegate apiClient] POST:[NSString stringWithFormat:@"v1/payment_methods/%@/three_d_secure/authenticate_from_jwt", urlSafeNonce]
                      parameters:requestParameters
                      completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, __unused NSError *error) {
                          BTThreeDSecureResult *result = [[BTThreeDSecureResult alloc] initWithJSON:body];
                          [self.paymentFlowDriverDelegate onPaymentComplete:result error:nil];
                      }];

            break;
        }

        case CardinalResponseActionCodeError:
            // Handle service level error
            break;
        case CardinalResponseActionCodeCancel:
            // Handle transaction canceled by user
            break;
        case CardinalResponseActionCodeUnknown:
            // Handle unknown error
            break;
    }
}

@end
