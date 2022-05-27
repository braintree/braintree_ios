#import "BTPaymentFlowClient+ThreeDSecure_Internal.h"
#import "BTThreeDSecureRequest_Internal.h"
#import "BTThreeDSecurePostalAddress_Internal.h"
#import "BTThreeDSecureAdditionalInformation_Internal.h"
#import "BTThreeDSecureV2Provider.h"
#import "BTThreeDSecureV1BrowserSwitchHelper.h"
#import "BTThreeDSecureResult_Internal.h"
#import <SafariServices/SafariServices.h>

#if __has_include(<Braintree/BraintreeThreeDSecure.h>) // CocoaPods
#import <Braintree/BTThreeDSecureRequest.h>
#import <Braintree/BTThreeDSecureResult.h>
#import <Braintree/BTThreeDSecureLookup.h>
#import <Braintree/BTConfiguration+ThreeDSecure.h>
#import <Braintree/BraintreeCard.h>
#import <Braintree/BTLogger_Internal.h>
#import <Braintree/BTAPIClient_Internal.h>
#import <Braintree/Braintree-Version.h>
#import <Braintree/BTPaymentFlowClient_Internal.h>

#elif SWIFT_PACKAGE // SPM
#import <BraintreeThreeDSecure/BTThreeDSecureRequest.h>
#import <BraintreeThreeDSecure/BTThreeDSecureResult.h>
#import <BraintreeThreeDSecure/BTThreeDSecureLookup.h>
#import <BraintreeThreeDSecure/BTConfiguration+ThreeDSecure.h>
#import <BraintreeCard/BraintreeCard.h>
#import "../BraintreeCore/BTLogger_Internal.h"
#import "../BraintreeCore/BTAPIClient_Internal.h"
#import "../BraintreeCore/Braintree-Version.h"
#import "../BraintreePaymentFlow/BTPaymentFlowClient_Internal.h"

#else // Carthage
#import <BraintreeThreeDSecure/BTThreeDSecureRequest.h>
#import <BraintreeThreeDSecure/BTThreeDSecureResult.h>
#import <BraintreeThreeDSecure/BTThreeDSecureLookup.h>
#import <BraintreeThreeDSecure/BTConfiguration+ThreeDSecure.h>
#import <BraintreeCard/BraintreeCard.h>
#import <BraintreeCore/BTLogger_Internal.h>
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <BraintreeCore/Braintree-Version.h>
#import <BraintreePaymentFlow/BTPaymentFlowClient_Internal.h>

#endif

@interface BTThreeDSecureRequest () <BTThreeDSecureRequestDelegate>

@property (nonatomic, strong) BTThreeDSecureV2Provider *threeDSecureV2Provider;
@end

@implementation BTThreeDSecureRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        _versionRequested = BTThreeDSecureVersion2;
    }

    return self;
}

- (NSString *)accountTypeAsString {
    switch (self.accountType) {
        case BTThreeDSecureAccountTypeCredit:
            return @"credit";
        case BTThreeDSecureAccountTypeDebit:
            return @"debit";
        default:
            return nil;
    }
}

- (NSString *)shippingMethodAsString {
    switch (self.shippingMethod) {
        case BTThreeDSecureShippingMethodSameDay:
            return @"01";
        case BTThreeDSecureShippingMethodExpedited:
            return @"02";
        case BTThreeDSecureShippingMethodPriority:
            return @"03";
        case BTThreeDSecureShippingMethodGround:
            return @"04";
        case BTThreeDSecureShippingMethodElectronicDelivery:
            return @"05";
        case BTThreeDSecureShippingMethodShipToStore:
            return @"06";
        default:
            return nil;
    }
}

- (NSString *)versionRequestedAsString {
    switch (self.versionRequested) {
        case BTThreeDSecureVersion1:
            return @"1";
        default:
            return @"2";
    }
}

- (void)handleRequest:(BTPaymentFlowRequest *)request
               client:(BTAPIClient *)apiClient
paymentClientDelegate:(id<BTPaymentFlowClientDelegate>)delegate {
    self.paymentFlowClientDelegate = delegate;

    [apiClient sendAnalyticsEvent:@"ios.three-d-secure.initialized"];

    [apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable configurationError) {
        if (configurationError) {
            [self.paymentFlowClientDelegate onPaymentComplete:nil error:configurationError];
            return;
        }

        NSError *integrationError;

        if (self.versionRequested == BTThreeDSecureVersion2 && !configuration.cardinalAuthenticationJWT) {
            [[BTLogger sharedLogger] critical:@"BTThreeDSecureRequest versionRequested is 2, but merchant account is not setup properly."];
            integrationError = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                   code:BTThreeDSecureFlowErrorTypeConfiguration
                                               userInfo:@{NSLocalizedDescriptionKey: @"BTThreeDSecureRequest versionRequested is 2, but merchant account is not setup properly."}];
        }

        if (!self.amount || [self.amount isEqualToNumber:NSDecimalNumber.notANumber]) {
            [[BTLogger sharedLogger] critical:@"BTThreeDSecureRequest amount can not be nil or NaN."];
            integrationError = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                   code:BTThreeDSecureFlowErrorTypeConfiguration
                                               userInfo:@{NSLocalizedDescriptionKey: @"BTThreeDSecureRequest amount can not be nil or NaN."}];
        }

        if (self.versionRequested == BTThreeDSecureVersion2 && self.threeDSecureRequestDelegate == nil) {
            integrationError = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                   code:BTThreeDSecureFlowErrorTypeConfiguration
                                               userInfo:@{NSLocalizedDescriptionKey: @"Configuration Error: threeDSecureRequestDelegate can not be nil when versionRequested is 2."}];
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
                                                                                                request:self
                                                                                             completion:^(NSDictionary *lookupParameters) {
                                                                                                 if (lookupParameters[@"dfReferenceId"]) {
                                                                                                     self.dfReferenceID = lookupParameters[@"dfReferenceId"];
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
    BTAPIClient *apiClient = [self.paymentFlowClientDelegate apiClient];
    BTPaymentFlowClient *paymentFlowClient = [[BTPaymentFlowClient alloc] initWithAPIClient:apiClient];
    
    if (threeDSecureRequest.versionRequested == BTThreeDSecureVersion1 && threeDSecureRequest.threeDSecureRequestDelegate == nil) {
        threeDSecureRequest.threeDSecureRequestDelegate = self;
    }

    [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.started"];
    [paymentFlowClient performThreeDSecureLookup:threeDSecureRequest
                                      completion:^(BTThreeDSecureResult *lookupResult, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.failed"];
                [self.paymentFlowClientDelegate onPaymentWithURL:nil error:error];
                return;
            }

            [apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.verification-flow.3ds-version.%@", lookupResult.lookup.threeDSecureVersion]];

            [self.threeDSecureRequestDelegate onLookupComplete:threeDSecureRequest lookupResult:lookupResult next:^{
                [apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.verification-flow.challenge-presented.%@",
                                               [self stringForBool:lookupResult.lookup.requiresUserAuthentication]]];
                [self processLookupResult:lookupResult configuration:configuration];
            }];
        });
    }];
}

- (void)processLookupResult:(BTThreeDSecureResult *)lookupResult configuration:(BTConfiguration *)configuration {
    if (!lookupResult.lookup.requiresUserAuthentication) {
        [self.paymentFlowClientDelegate onPaymentComplete:lookupResult error:nil];
        return;
    }
    
    if (lookupResult.lookup.isThreeDSecureVersion2) {
        [self performV2Authentication:lookupResult];
    } else {
        NSURL *browserSwitchURL = [BTThreeDSecureV1BrowserSwitchHelper urlWithScheme:self.paymentFlowClientDelegate.returnURLScheme
                                                                           assetsURL:[configuration.json[@"assetsUrl"] asString]
                                                                 threeDSecureRequest:self
                                                                  threeDSecureLookup:lookupResult.lookup];
        [self.paymentFlowClientDelegate onPaymentWithURL:browserSwitchURL error:nil];
    }
}

- (void)performV2Authentication:(BTThreeDSecureResult *)lookupResult {
    typeof(self) __weak weakSelf = self;
    BTAPIClient *apiClient = [self.paymentFlowClientDelegate apiClient];
    [self.threeDSecureV2Provider processLookupResult:lookupResult
                                             success:^(BTThreeDSecureResult *result) {
                                                 [weakSelf logThreeDSecureCompletedAnalyticsForResult:result withAPIClient:apiClient];
                                                 [weakSelf.paymentFlowClientDelegate onPaymentComplete:result error:nil];
                                             } failure:^(NSError *error) {
                                                 [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.failed"];
                                                 [weakSelf.paymentFlowClientDelegate onPaymentComplete:nil error:error];
                                             }];
}

- (void)handleOpenURL:(NSURL *)url {
    NSString *jsonAuthResponse = [BTURLUtils queryParametersForURL:url][@"auth_response"];
    if (!jsonAuthResponse || jsonAuthResponse.length == 0) {
        [self.paymentFlowClientDelegate.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.missing-auth-response"]];
        [self.paymentFlowClientDelegate onPaymentComplete:nil error:[NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                                                        code:BTThreeDSecureFlowErrorTypeFailedAuthentication
                                                                                    userInfo:@{NSLocalizedDescriptionKey: @"Auth Response missing from URL."}]];
        return;
    }

    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization JSONObjectWithData:[jsonAuthResponse dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];
    if (!jsonData) {
        [self.paymentFlowClientDelegate.apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.invalid-auth-response"]];
        [self.paymentFlowClientDelegate onPaymentComplete:nil error:[NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                                                        code:BTThreeDSecureFlowErrorTypeFailedAuthentication
                                                                                    userInfo:@{NSLocalizedDescriptionKey: @"Auth Response JSON parsing error."}]];
        return;
    }

    BTJSON *authBody = [[BTJSON alloc] initWithValue:jsonData];
    if (!authBody.isObject) {
        [self.paymentFlowClientDelegate onPaymentComplete:nil error:[NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                                                        code:BTThreeDSecureFlowErrorTypeFailedAuthentication
                                                                                    userInfo:@{NSLocalizedDescriptionKey: @"Auth Response is not a valid BTJSON object."}]];
        return;
    }
    
    BTAPIClient *apiClient = [self.paymentFlowClientDelegate apiClient];
    BTThreeDSecureResult *result = [[BTThreeDSecureResult alloc] initWithJSON:authBody];

    if (result.errorMessage || !result.tokenizedCard) {
        [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.failed"];

        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:1];
        if (result.errorMessage) {
            userInfo[NSLocalizedDescriptionKey] = result.errorMessage;
        }
        
        NSError *error = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                             code:BTThreeDSecureFlowErrorTypeFailedAuthentication
                                         userInfo:userInfo];
        [self.paymentFlowClientDelegate onPaymentComplete:nil error:error];
        return;
    }

    [self logThreeDSecureCompletedAnalyticsForResult:result withAPIClient:apiClient];
    [self.paymentFlowClientDelegate onPaymentComplete:result error:nil];
}

- (void)logThreeDSecureCompletedAnalyticsForResult:(BTThreeDSecureResult *)result withAPIClient:(BTAPIClient *)apiClient {
    [apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.verification-flow.liability-shift-possible.%@",
                                   [self stringForBool:result.tokenizedCard.threeDSecureInfo.liabilityShiftPossible]]];
    [apiClient sendAnalyticsEvent:[NSString stringWithFormat:@"ios.three-d-secure.verification-flow.liability-shifted.%@",
                                   [self stringForBool:result.tokenizedCard.threeDSecureInfo.liabilityShifted]]];
    [apiClient sendAnalyticsEvent:@"ios.three-d-secure.verification-flow.completed"];
}

- (BOOL)canHandleAppSwitchReturnURL:(NSURL *)url {
    return [url.host isEqualToString:@"x-callback-url"] && [url.path hasPrefix:@"/braintree/threedsecure"];
}

- (NSString *)paymentFlowName {
    return @"three-d-secure";
}

- (NSString *)stringForBool:(BOOL)boolean {
    if (boolean) {
        return @"true";
    }
    else {
        return @"false";
    }
}

- (void)onLookupComplete:(__unused BTThreeDSecureRequest *)request
            lookupResult:(__unused BTThreeDSecureResult *)result
                    next:(void (^)(void))next {
    next();
}

@end
