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
#import "BTThreeDSecureRequest_Internal.h"
#import "BTThreeDSecurePostalAddress_Internal.h"
#import "BTThreeDSecureAdditionalInformation_Internal.h"
#import "BTURLUtils.h"
#import "BTConfiguration+ThreeDSecure.h"
#import "BTThreeDSecureV2Provider.h"

NSString *const BTThreeDSecureAssetsPath = @"/mobile/three-d-secure-redirect/0.1.6";

@interface BTThreeDSecureRequest () <BTThreeDSecureRequestDelegate>

@property (nonatomic, strong) BTThreeDSecureV2Provider *threeDSecureV2Provider;
@end

@implementation BTThreeDSecureRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        _versionRequested = BTThreeDSecureVersion1;
    }

    return self;
}

- (void)handleRequest:(BTPaymentFlowRequest *)request
               client:(BTAPIClient *)apiClient
paymentDriverDelegate:(id<BTPaymentFlowDriverDelegate>)delegate {
    self.paymentFlowDriverDelegate = delegate;

    [apiClient sendAnalyticsEvent:@"ios.three-d-secure.initialized"];

    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable configurationError) {
        if (configurationError) {
            [self.paymentFlowDriverDelegate onPaymentComplete:nil error:configurationError];
            return;
        }

        NSError *integrationError;

        if (self.versionRequested == BTThreeDSecureVersion2) {
            if (!configuration.cardinalAuthenticationJWT) {
                [[BTLogger sharedLogger] critical:@"BTThreeDSecureRequest versionRequested is 2, but merchant account is not setup properly."];
                integrationError = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                       code:BTThreeDSecureFlowErrorTypeConfiguration
                                                   userInfo:@{NSLocalizedDescriptionKey: @"BTThreeDSecureRequest versionRequested is 2, but merchant account is not setup properly."}];
            } else if (!self.amount) {
            [[BTLogger sharedLogger] critical:@"BTThreeDSecureRequest amount can not be nil."];
            integrationError = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                   code:BTThreeDSecureFlowErrorTypeConfiguration
                                               userInfo:@{NSLocalizedDescriptionKey: @"BTThreeDSecureRequest amount can not be nil."}];
            }
        }

        if (integrationError != nil) {
            [delegate onPaymentComplete:nil error:integrationError];
            return;
        }

        if (configuration.cardinalAuthenticationJWT && self.versionRequested == BTThreeDSecureVersion2) {
            [self prepareLookup:apiClient completion:^(NSError * _Nullable error) {
                if (error != nil) {
                    [delegate onPaymentComplete:nil error:error];
                } else {
                    [self startRequest:request configuration:configuration];
                }
            }];
        } else {
            [self startRequest:request configuration:configuration];
        }
    }];
}

- (void)prepareLookup:(BTAPIClient *)apiClient completion:(void (^)(NSError * _Nullable))completionBlock {
    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable configurationError) {
        if (configurationError) {
            completionBlock(configurationError);
            return;
        }

        if (configuration.cardinalAuthenticationJWT) {
            self.threeDSecureV2Provider = [BTThreeDSecureV2Provider initializeProviderWithConfiguration:configuration
                                                                                              apiClient:apiClient
                                                                                             completion:^(NSDictionary *lookupParameters) {
                                                                                                 if (lookupParameters[@"dfReferenceId"]) {
                                                                                                     self.dfReferenceId = lookupParameters[@"dfReferenceId"];
                                                                                                 }
                                                                                                 completionBlock(nil);
                                                                                             }];
        } else {
            NSError *error = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                 code:BTThreeDSecureFlowErrorTypeConfiguration
                                             userInfo:@{NSLocalizedDescriptionKey: @"Merchant is not configured for 3SD 2."}];
            completionBlock(error);
        }
    }];
}

- (void)startRequest:(BTPaymentFlowRequest *)request configuration:(BTConfiguration *)configuration {
    BTThreeDSecureRequest *threeDSecureRequest = (BTThreeDSecureRequest *)request;
    BTAPIClient *apiClient = [self.paymentFlowDriverDelegate apiClient];
    BTPaymentFlowDriver *paymentFlowDriver = [[BTPaymentFlowDriver alloc] initWithAPIClient:apiClient];

    if (threeDSecureRequest.versionRequested == BTThreeDSecureVersion2) {
        if (threeDSecureRequest.threeDSecureRequestDelegate == nil) {
            NSError *error = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                 code:BTThreeDSecureFlowErrorTypeConfiguration
                                             userInfo:@{NSLocalizedDescriptionKey: @"Configuration Error: threeDSecureRequestDelegate can not be nil when versionRequested is 2."}];
            [self.paymentFlowDriverDelegate onPaymentComplete:nil error:error];
            return;
        }
    }
    
    if (threeDSecureRequest.versionRequested == BTThreeDSecureVersion1 && threeDSecureRequest.threeDSecureRequestDelegate == nil) {
        threeDSecureRequest.threeDSecureRequestDelegate = self;
    }

    [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.started"];
    [paymentFlowDriver performThreeDSecureLookup:threeDSecureRequest
                                      completion:^(BTThreeDSecureLookup *lookupResult, NSError *error) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              if (error) {
                                                  [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.failed"];
                                                  [self.paymentFlowDriverDelegate onPaymentWithURL:nil error:error];
                                                  return;
                                              }

                                              [apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.verification-flow.3ds-version.%@", lookupResult.threeDSecureVersion]];

                                              [self.threeDSecureRequestDelegate onLookupComplete:threeDSecureRequest result:lookupResult next:^{
                                                  [apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.verification-flow.challenge-presented.%@", [self stringForBool:lookupResult.requiresUserAuthentication]]];
                                                  [self processLookupResult:lookupResult configuration:configuration];
                                              }];
                                          });
                                      }];
}

- (void)processLookupResult:(BTThreeDSecureLookup *)lookupResult configuration:(BTConfiguration *)configuration {
    if (lookupResult.requiresUserAuthentication) {
        if (lookupResult.isThreeDSecureVersion2) {
            [self performV2Authentication:lookupResult];
        } else {
            NSURL *redirectUrl = [self constructV1PaymentURLForLookup:lookupResult configuration:configuration];
            [self.paymentFlowDriverDelegate onPaymentWithURL:redirectUrl error:nil];
        }
    } else {
        [self.paymentFlowDriverDelegate onPaymentComplete:lookupResult.threeDSecureResult error:nil];
    }
}

- (void)performV2Authentication:(BTThreeDSecureLookup *)lookupResult {
    typeof(self) __weak weakSelf = self;
    BTAPIClient *apiClient = [self.paymentFlowDriverDelegate apiClient];
    [self.threeDSecureV2Provider processLookupResult:lookupResult
                                             success:^(BTThreeDSecureResult *result) {
                                                 [weakSelf logThreeDSecureCompletedAnalyticsForResult:result withAPIClient:apiClient];
                                                 [weakSelf.paymentFlowDriverDelegate onPaymentComplete:result error:nil];
                                             } failure:^(NSError *error) {
                                                 [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.failed"];
                                                 [weakSelf.paymentFlowDriverDelegate onPaymentComplete:nil error:error];
                                             }];
}

- (NSURL *)constructV1PaymentURLForLookup:(BTThreeDSecureLookup *)lookupResult configuration:(BTConfiguration *)configuration {
    NSString *acsurl = [NSString stringWithFormat:@"AcsUrl=%@", [lookupResult.acsURL.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    NSString *pareq = [NSString stringWithFormat:@"PaReq=%@", [self stringByAddingPercentEncodingForRFC3986:lookupResult.PAReq]];
    NSString *md = [NSString stringWithFormat:@"MD=%@", [lookupResult.MD stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    NSString *callbackUrl = [NSString stringWithFormat: @"ReturnUrl=%@%@/redirect.html?redirect_url=%@://x-callback-url/braintree/threedsecure?",
                             [configuration.json[@"assetsUrl"] asString],
                             BTThreeDSecureAssetsPath,
                             [self.paymentFlowDriverDelegate returnURLScheme]
                             ];
    callbackUrl = [callbackUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *authUrl = [NSString stringWithFormat:@"%@",
                         [lookupResult.termURL.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]
                         ];

    NSString *termurl = [NSString stringWithFormat: @"TermUrl=%@", authUrl];
    NSURL *redirectUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/index.html?%@&%@&%@&%@&%@", [configuration.json[@"assetsUrl"] asString], BTThreeDSecureAssetsPath, acsurl, pareq, md, termurl, callbackUrl]];

    return redirectUrl;
}

- (void)handleOpenURL:(NSURL *)url {
    NSString *jsonAuthResponse = [BTURLUtils dictionaryForQueryString:url.absoluteString][@"auth_response"];
    if (!jsonAuthResponse || jsonAuthResponse.length == 0) {
        [self.paymentFlowDriverDelegate.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.missing-auth-response"]];
        [self.paymentFlowDriverDelegate onPaymentComplete:nil error:[NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                                                        code:BTThreeDSecureFlowErrorTypeFailedAuthentication
                                                                                    userInfo:@{NSLocalizedDescriptionKey: @"Auth Response missing from URL."}]];
        return;
    }

    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization JSONObjectWithData:[jsonAuthResponse dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];
    if (!jsonData) {
        [self.paymentFlowDriverDelegate.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.invalid-auth-response"]];
        [self.paymentFlowDriverDelegate onPaymentComplete:nil error:[NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                                                        code:BTThreeDSecureFlowErrorTypeFailedAuthentication
                                                                                    userInfo:@{NSLocalizedDescriptionKey: @"Auth Response JSON parsing error."}]];
        return;
    }

    BTJSON *authBody = [[BTJSON alloc] initWithValue:jsonData];
    if (!authBody.isObject) {
        [self.paymentFlowDriverDelegate onPaymentComplete:nil error:[NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                                                        code:BTThreeDSecureFlowErrorTypeFailedAuthentication
                                                                                    userInfo:@{NSLocalizedDescriptionKey: @"Auth Response is not a valid BTJSON object."}]];
        return;
    }

    BTThreeDSecureResult *result = [[BTThreeDSecureResult alloc] initWithJSON:authBody];

    BTAPIClient *apiClient = [self.paymentFlowDriverDelegate apiClient];
    if ((self.versionRequested == BTThreeDSecureVersion1 && ![authBody[@"success"] isTrue]) || !result.tokenizedCard) {
        [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.failed"];

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

    [self logThreeDSecureCompletedAnalyticsForResult:result withAPIClient:apiClient];

    [self.paymentFlowDriverDelegate onPaymentComplete:result error:nil];
}

- (void)logThreeDSecureCompletedAnalyticsForResult:(BTThreeDSecureResult *)result withAPIClient:(BTAPIClient *)apiClient {
    [apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.verification-flow.liability-shift-possible.%@", [self stringForBool:result.liabilityShiftPossible]]];
    [apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.verification-flow.liability-shifted.%@", [self stringForBool:result.liabilityShifted]]];
    [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.completed"];
}

- (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url sourceApplication:(__unused NSString *)sourceApplication {
    return [url.host isEqualToString:@"x-callback-url"] && [url.path hasPrefix:@"/braintree/threedsecure"];
}

- (NSString *)paymentFlowName {
    return @"three-d-secure";
}

- (NSString *)stringByAddingPercentEncodingForRFC3986:(NSString *)string {
    NSString *unreserved = @"-._~/?";
    NSMutableCharacterSet *allowed = NSMutableCharacterSet.alphanumericCharacterSet;
    [allowed addCharactersInString:unreserved];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowed];
}

- (NSString *)stringForBool:(BOOL)boolean {
    if (boolean) {
        return @"true";
    }
    else {
        return @"false";
    }
}

- (void)onLookupComplete:(__unused BTThreeDSecureRequest *)request result:(__unused BTThreeDSecureLookup *)result next:(void (^)(void))next {
    next();
}

@end
