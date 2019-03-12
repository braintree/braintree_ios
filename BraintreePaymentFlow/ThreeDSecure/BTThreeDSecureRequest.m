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
#import "BTThreeDSecureAdditionalInformation_Internal.h"
#import "BTURLUtils.h"
#import "BTConfiguration+ThreeDSecure.h"
#import "BTThreeDSecureV2Provider.h"

NSString *const BTThreeDSecureAssetsPath = @"/mobile/three-d-secure-redirect/0.1.5";

@interface BTThreeDSecureRequest () <BTThreeDSecureRequestDelegate>

@property (nonatomic, weak) id<BTPaymentFlowDriverDelegate> paymentFlowDriverDelegate;
@property (nonatomic, strong) BTThreeDSecureV2Provider *threeDSecureV2Provider;

@end

@implementation BTThreeDSecureRequest

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

        if (configuration.cardinalAuthenticationJWT && self.versionRequested == 2) {
            self.threeDSecureV2Provider = [BTThreeDSecureV2Provider initializeProviderWithConfiguration:configuration
                                                                                              apiClient:apiClient
                                                                                             completion:^(__unused NSDictionary *lookupParameters) {
                                                                                                 //TODO why is this translation layer here? If it is just for the device fingerprint then we should make it clearer and translate our params closer to the request
                                                                                                 [self startRequest:request configuration:configuration];
                                                                                             }];
        }
        else {
            [self startRequest:request configuration:configuration];
        }
    }];
}

- (void)startRequest:(BTPaymentFlowRequest *)request configuration:(BTConfiguration *)configuration {
    BTThreeDSecureRequest *threeDSecureRequest = (BTThreeDSecureRequest *)request;
    BTAPIClient *apiClient = [self.paymentFlowDriverDelegate apiClient];
    BTPaymentFlowDriver *paymentFlowDriver = [[BTPaymentFlowDriver alloc] initWithAPIClient:apiClient];

    if (threeDSecureRequest.versionRequested == 2) {
        if (threeDSecureRequest.threeDSecureRequestDelegate == nil) {
            // TODO: if version 2, 3DSdelegate can't be null
        }
    }
    
    if (threeDSecureRequest.versionRequested != 2 && threeDSecureRequest.threeDSecureRequestDelegate == nil) {
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

                                              [apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.verification-flow.lookup-flow.%@", lookupResult.threeDSecureVersion]];

                                              [self.threeDSecureRequestDelegate onLookupComplete:threeDSecureRequest result:lookupResult next:^{
                                                  [apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.verification-flow.challenge-presented.%@", [self stringForBool:lookupResult.requiresUserAuthentication]]];
                                                  if (lookupResult.requiresUserAuthentication) {
                                                      if (lookupResult.isThreeDSecureVersion2) {
                                                          [self performV2Authentication:lookupResult];
                                                      }
                                                      else {
                                                          NSURL *redirectUrl = [self constructV1PaymentURLForLookup:lookupResult configuration:configuration];
                                                          [self.paymentFlowDriverDelegate onPaymentWithURL:redirectUrl error:error];
                                                      }
                                                  } else {
                                                      [self.paymentFlowDriverDelegate onPaymentComplete:lookupResult.threeDSecureResult error:error];
                                                  }
                                              }];
                                          });
                                      }];
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

- (void)handleOpenURL:(__unused NSURL *)url {
    NSString *jsonAuthResponse = [BTURLUtils dictionaryForQueryString:url.query][@"auth_response"];
    BTJSON *authBody = [[BTJSON alloc] initWithValue:[NSJSONSerialization JSONObjectWithData:[jsonAuthResponse dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL]];
    BTThreeDSecureResult *result = [[BTThreeDSecureResult alloc] initWithJSON:authBody];

    BTAPIClient *apiClient = [self.paymentFlowDriverDelegate apiClient];
    if (!result.success) {
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
