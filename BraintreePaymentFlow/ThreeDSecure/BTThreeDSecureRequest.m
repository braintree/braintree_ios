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
#import "BTURLUtils.h"

NSString *const BTThreeDSecureAssetsPath = @"/mobile/three-d-secure-redirect/0.1.5";

@interface BTThreeDSecureRequest ()

@property (nonatomic, weak) id<BTPaymentFlowDriverDelegate> paymentFlowDriverDelegate;
@property (nonnull, strong) BTThreeDSecureLookup *lookupResult;

@end

@implementation BTThreeDSecureRequest

- (void)handleRequest:(BTPaymentFlowRequest *)request client:(BTAPIClient *)apiClient paymentDriverDelegate:(id<BTPaymentFlowDriverDelegate>)delegate {
    self.paymentFlowDriverDelegate = delegate;
    BTThreeDSecureRequest *threeDSecureRequest = (BTThreeDSecureRequest *)request;

    BTPaymentFlowDriver *paymentFlowDriver = [[BTPaymentFlowDriver alloc] initWithAPIClient:[self.paymentFlowDriverDelegate apiClient]];

    [paymentFlowDriver performThreeDSecureLookup:threeDSecureRequest
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

- (NSString *)stringByAddingPercentEncodingForRFC3986:(NSString *)string
{
    NSString *unreserved = @"-._~/?";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet
                                      alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    return [string
            stringByAddingPercentEncodingWithAllowedCharacters:
            allowed];
}

@end
