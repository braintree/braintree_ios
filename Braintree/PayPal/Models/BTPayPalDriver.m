#import "BTPayPalDriver.h"

#import "PayPalOneTouchRequest.h"
#import "PayPalOneTouchCore.h"

#import "BTPayPalPaymentMethod_Mutable.h"
#import "BTClient_Internal.h"
#import "BTLogger_Internal.h"

#import "BTAppSwitchErrors.h"
#import "BTErrors+BTPayPal.h"

#import "BTAppSwitch.h"
#import "BTClient+BTPayPal.h"

static void (^BTPayPalHandleURLContinuation)(NSURL *url);

NS_ASSUME_NONNULL_BEGIN

@interface BTPayPalDriver ()
@property (nonatomic, strong) BTClient *client;
@property (nonatomic, copy) NSString *returnURLScheme;
@end

@implementation BTPayPalDriver

+ (nullable instancetype)driverWithClient:(BTClient * __nonnull)client {
    return [[self alloc] initWithClient:client returnURLScheme:[BTAppSwitch sharedInstance].returnURLScheme];
}

- (nullable instancetype)initWithClient:(BTClient * __nonnull)client returnURLScheme:(NSString * __nonnull)returnURLScheme {
    NSError *initializationError;
    if (![BTPayPalDriver verifyAppSwitchConfigurationForClient:client
                                               returnURLScheme:returnURLScheme
                                                         error:&initializationError]) {
        [[BTLogger sharedLogger] log:@"Failed to initialize BTPayPalDriver: %@", initializationError];
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.client = client;
        self.returnURLScheme = returnURLScheme;
    }
    return self;
}

#pragma mark - PayPal Lifecycle

- (BTClient *)copyClientForPayPal:(BTClient *)client error:(NSError * __autoreleasing *)error {
    client = [client copyWithMetadata:^(BTClientMutableMetadata *metadata) {
        if ([PayPalOneTouchCore isWalletAppInstalled]) {
            metadata.source = BTClientMetadataSourcePayPalApp;
        } else {
            metadata.source = BTClientMetadataSourcePayPalBrowser;
        }
    }];
    
    if (![BTPayPalDriver verifyAppSwitchConfigurationForClient:client returnURLScheme:self.returnURLScheme error:error]) {
        return nil;
    }
    return client;
}

- (void)startAuthorizationWithCompletion:(nullable void (^)(BTPayPalPaymentMethod *__nullable paymentMethod, NSError *__nullable error))completionBlock {
    if (_client.configuration.payPalUseBillingAgreement) {
        BTPayPalCheckout *checkout = [BTPayPalCheckout checkoutWithAmount:[NSDecimalNumber decimalNumberWithString:@"0.0"]];
        checkout.isSingleUse = false;
        [self startCheckout:checkout completion:completionBlock];
    } else {
        [self startAuthorizationWithAdditionalScopes:nil completion:completionBlock];
    }
}

- (void)startAuthorizationWithAdditionalScopes:(NSSet * __nullable)additionalScopes completion:(nullable void (^)(BTPayPalPaymentMethod *__nullable paymentMethod, NSError *__nullable error))completionBlock {
    NSError *error;
    BTClient *client = [self copyClientForPayPal:self.client error:&error];

    if (error) {
        if (completionBlock) {
            completionBlock(nil, error);
        }
        return;
    }
    
    NSSet *requestScopes = [self.defaultOAuth2Scopes setByAddingObjectsFromSet:(additionalScopes ? additionalScopes : [NSSet set])];
    
    
    PayPalOneTouchAuthorizationRequest *request =
    [PayPalOneTouchAuthorizationRequest requestWithScopeValues:requestScopes
                                                    privacyURL:client.configuration.payPalPrivacyPolicyURL
                                                  agreementURL:client.configuration.payPalMerchantUserAgreementURL
                                                      clientID:[self paypalClientIdForClient:client]
                                                   environment:[self payPalEnvironmentForClient:client]
                                             callbackURLScheme:[self returnURLScheme]];
    
    __block NSString *__block__clientMetadataId = nil;
    
    // At this time, the Braintree client_token is required by the temporary Braintree Future Payments consent webpage.
    request.additionalPayloadAttributes = @{ @"client_token": client.clientToken.originalValue };
    
    BTPayPalHandleURLContinuation = ^(NSURL *url){
        [self informDelegateWillProcessAppSwitchResult];
        
        [PayPalOneTouchCore parseResponseURL:url
                             completionBlock:^(PayPalOneTouchCoreResult *result) {
                                 BTClient *client = [self clientWithMetadataForResult:result];
                                 
                                 [self postAnalyticsEventWithClient:client forHandlingOneTouchResult:result];
                                 
                                 switch (result.type) {
                                     case PayPalOneTouchResultTypeError:
                                         if (completionBlock) {
                                             completionBlock(nil, result.error);
                                         }
                                         break;
                                     case PayPalOneTouchResultTypeCancel:
                                         if (result.error) {
                                             [[BTLogger sharedLogger] error:@"PayPal error: %@", result.error];
                                             return;
                                         }
                                         if (completionBlock) {
                                             completionBlock(nil, nil);
                                         }
                                         break;
                                     case PayPalOneTouchResultTypeSuccess: {
                                         if (__block__clientMetadataId == nil) {
                                             [client postAnalyticsEvent:@"ios.paypal-future-payments.tokenize.missing-cmid"];
                                             completionBlock(nil, [NSError errorWithDomain:BTBraintreePayPalErrorDomain code:BTPayPalErrorOther userInfo:@{NSLocalizedDescriptionKey: @"PayPal is in an invalid state."}]);
                                             break;
                                         }
                                         
                                         NSString *userDisplayStringFromAppSwitchResponse = result.response[@"user"][@"display_string"];
                                         
                                         // Modify payload in 'mock' mode to scope the response
                                         NSMutableDictionary* mutableResponse = [result.response mutableCopy];
                                         if ([PayPalEnvironmentMock isEqualToString:mutableResponse[@"client"][@"environment"]]
                                             && mutableResponse[@"response"][@"code"] != nil) {
                                             mutableResponse[@"response"] = @{@"code": [NSString stringWithFormat:@"fake-code:%@", [[requestScopes allObjects] componentsJoinedByString:@" "]]};
                                         }
                                         
                                         [client savePaypalAccount:mutableResponse
                                                  clientMetadataID:__block__clientMetadataId
                                                           success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                               [self postAnalyticsEventForTokenizationSuccessWithClient:client];
                                                               
                                                               if ([userDisplayStringFromAppSwitchResponse isKindOfClass:[NSString class]]) {
                                                                   if (paypalPaymentMethod.email == nil) {
                                                                       paypalPaymentMethod.email = userDisplayStringFromAppSwitchResponse;
                                                                   }
                                                                   if (paypalPaymentMethod.description == nil) {
                                                                       paypalPaymentMethod.description = userDisplayStringFromAppSwitchResponse;
                                                                   }
                                                               }
                                                               if (completionBlock) {
                                                                   completionBlock(paypalPaymentMethod, nil);
                                                               }
                                                           } failure:^(NSError *error) {
                                                               [self postAnalyticsEventForTokenizationFailureWithClient:client];
                                                               if (completionBlock) {
                                                                   completionBlock(nil, error);
                                                               }
                                                           }];
                                         
                                     }
                                         break;
                                 }
                                 BTPayPalHandleURLContinuation = nil;
                             }];
    };
    
    [self informDelegateWillPerformAppSwitch];
    [request performWithCompletionBlock:^(BOOL success, PayPalOneTouchRequestTarget target, NSString *clientMetadataId, NSError *error) {
        __block__clientMetadataId = clientMetadataId;
        [self postAnalyticsEventWithClient:client forInitiatingOneTouchWithSuccess:success target:target];
        if (success) {
            [self informDelegateDidPerformAppSwitchToTarget:target];
        } else {
            if (completionBlock) {
                completionBlock(nil, error);
            }
        }
    }];
}

- (void)startCheckout:(__unused BTPayPalCheckout * __nonnull)checkout completion:(nullable __unused void (^)(BTPayPalPaymentMethod * __nullable paymentMethod, NSError * __nullable error))completionBlock {
    NSError *error;
    BTClient *client = [self copyClientForPayPal:self.client error:&error];
    
    if (error) {
        if (completionBlock) {
            completionBlock(nil, error);
        }
        return;
    }
    
    if (checkout == nil) {
        [[BTLogger sharedLogger] log:@"BTPayPalDriver failed to start checkout - checkout must not be nil."];
        return;
    }
    
    NSString *redirectUri;
    NSString *cancelUri;
    [PayPalOneTouchCore redirectURLsForCallbackURLScheme:self.returnURLScheme
                                           withReturnURL:&redirectUri
                                           withCancelURL:&cancelUri];
    
    [client createPayPalPaymentResourceWithCheckout:checkout
                                      redirectUri:redirectUri
                                        cancelUri:cancelUri
                                          success:^(BTClientPayPalPaymentResource *paymentResource) {
                                              
                                              NSString *token = [PayPalOneTouchRequest tokenFromApprovalURL:paymentResource.redirectURL];
                                              
                                              NSString *payPalClientId = client.configuration.payPalClientId;
                                              if (!payPalClientId && [self payPalEnvironmentForClient:client] == PayPalEnvironmentMock) {
                                                  payPalClientId = @"FAKE-PAYPAL-CLIENT-ID";
                                              }
                                              
                                              PayPalOneTouchCheckoutRequest *request = [PayPalOneTouchCheckoutRequest requestWithApprovalURL:paymentResource.redirectURL
                                                                                                                                   pairingId:token
                                                                                                                                    clientID:payPalClientId
                                                                                                                                 environment:[self payPalEnvironmentForClient:client]
                                                                                                                           callbackURLScheme:self.returnURLScheme];
                                              
                                              __block NSString *__block__clientMetadataId = nil;
                                              
                                              BTPayPalHandleURLContinuation = ^(NSURL *url) {
                                                  [self informDelegateWillProcessAppSwitchResult];
                                                
                                                  [PayPalOneTouchCore parseResponseURL:url
                                                                       completionBlock:^(PayPalOneTouchCoreResult *result) {
                                                                           BTClient *client = [self clientWithMetadataForResult:result];
                                                                           
                                                                           [self postAnalyticsEventWithClientForSinglePayment:client forHandlingOneTouchResult:result];
                                                                           switch (result.type) {
                                                                               case PayPalOneTouchResultTypeError:
                                                                                   if (completionBlock) {
                                                                                       completionBlock(nil, result.error);
                                                                                   }
                                                                                   break;
                                                                               case PayPalOneTouchResultTypeCancel:
                                                                                   if (result.error) {
                                                                                       [[BTLogger sharedLogger] error:@"PayPal error: %@", result.error];
                                                                                       return;
                                                                                   }
                                                                                   if (completionBlock) {
                                                                                       completionBlock(nil, nil);
                                                                                   }
                                                                                   break;
                                                                               case PayPalOneTouchResultTypeSuccess: {
                                                                                   if (__block__clientMetadataId == nil) {
                                                                                       [client postAnalyticsEvent:@"ios.paypal-single-payment.tokenize.missing-cmid"];
                                                                                       completionBlock(nil, [NSError errorWithDomain:BTBraintreePayPalErrorDomain code:BTPayPalErrorOther userInfo:@{NSLocalizedDescriptionKey: @"PayPal is in an invalid state."}]);
                                                                                       break;
                                                                                   }
                                                                                   
                                                                                   [client savePaypalAccount:result.response
                                                                                            clientMetadataID:__block__clientMetadataId
                                                                                                     success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                                                                         [self postAnalyticsEventForTokenizationSuccessWithClientForSinglePayment:client];
                                                                                                         
                                                                                                         if (completionBlock) {
                                                                                                             completionBlock(paypalPaymentMethod, nil);
                                                                                                         }
                                                                                                     } failure:^(NSError *error) {
                                                                                                         [self postAnalyticsEventForTokenizationFailureWithClientForSinglePayment:client];
                                                                                                         if (completionBlock) {
                                                                                                             completionBlock(nil, error);
                                                                                                         }
                                                                                                     }];
                                                                                   
                                                                               }
                                                                                   break;
                                                                           }
                                                                           BTPayPalHandleURLContinuation = nil;
                                                                       }];
                                              };
                                              
                                              [self informDelegateWillPerformAppSwitch];
                                              [request performWithCompletionBlock:^(BOOL success, PayPalOneTouchRequestTarget target, NSString *clientMetadataId, NSError *error) {
                                                  __block__clientMetadataId = clientMetadataId;
                                                  [self postAnalyticsEventWithClientForSinglePayment:client forInitiatingOneTouchWithSuccess:success target:target];
                                                  if (success) {
                                                      [self informDelegateDidPerformAppSwitchToTarget:target];
                                                  } else {
                                                      if (completionBlock) {
                                                          completionBlock(nil, error);
                                                      }
                                                  }
                                              }];
                                          }
                                          failure:^(NSError *error) {
                                              completionBlock(nil, error);
                                          }];
}

+ (BOOL)canHandleAppSwitchReturnURL:(NSURL * __nonnull)url sourceApplication:(NSString * __nonnull)sourceApplication {
    return BTPayPalHandleURLContinuation != nil && [PayPalOneTouchCore canParseURL:url sourceApplication:sourceApplication];
}

+ (void)handleAppSwitchReturnURL:(NSURL * __nonnull)url {
    if (BTPayPalHandleURLContinuation) {
        BTPayPalHandleURLContinuation(url);
    }
}


#pragma mark - Delegate Informers

- (void)informDelegateWillPerformAppSwitch {
    if ([self.delegate respondsToSelector:@selector(payPalDriverWillPerformAppSwitch:)]) {
        [self.delegate payPalDriverWillPerformAppSwitch:self];
    }
}

- (void)informDelegateDidPerformAppSwitchToTarget:(PayPalOneTouchRequestTarget)target {
    if ([self.delegate respondsToSelector:@selector(payPalDriver:didPerformAppSwitchToTarget:)]) {
        switch (target) {
            case PayPalOneTouchRequestTargetBrowser:
                [self.delegate payPalDriver:self didPerformAppSwitchToTarget:BTPayPalDriverAppSwitchTargetBrowser];
                break;
            case PayPalOneTouchRequestTargetOnDeviceApplication:
                [self.delegate payPalDriver:self didPerformAppSwitchToTarget:BTPayPalDriverAppSwitchTargetPayPalApp];
                break;
            default:
                // Should never happen.
                break;
        }
    }
    
}

- (void)informDelegateWillProcessAppSwitchResult {
    if ([self.delegate respondsToSelector:@selector(payPalDriverWillProcessAppSwitchResult:)]) {
        [self.delegate payPalDriverWillProcessAppSwitchResult:self];
    }
}


#pragma mark -

+ (BOOL)verifyAppSwitchConfigurationForClient:(BTClient *)client returnURLScheme:(NSString *)returnURLScheme error:(NSError * __autoreleasing *)error {
    if (client == nil) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTAppSwitchErrorDomain
                                         code:BTAppSwitchErrorIntegrationInvalidParameters
                                     userInfo:@{ NSLocalizedDescriptionKey: @"PayPal app switch is missing a BTClient." }];
        }
        return NO;
    }
    
    if (!client.configuration.payPalEnabled) {
        [client postAnalyticsEvent:@"ios.paypal-otc.preflight.disabled"];
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                         code:BTPayPalErrorPayPalDisabled
                                     userInfo:@{ NSLocalizedDescriptionKey: @"PayPal is not enabled for this merchant." }];
        }
        return NO;
    }
    
    if (returnURLScheme == nil) {
        [client postAnalyticsEvent:@"ios.paypal-otc.preflight.nil-return-url-scheme"];
        if (error != NULL) {
            *error = [NSError errorWithDomain:BTAppSwitchErrorDomain
                                         code:BTAppSwitchErrorIntegrationReturnURLScheme
                                     userInfo:@{ NSLocalizedDescriptionKey: @"PayPal app switch is missing a returnURLScheme. See +[Braintree setReturnURLScheme:]." }];
        }
        return NO;
    }
    
    if (![PayPalOneTouchCore doesApplicationSupportOneTouchCallbackURLScheme:returnURLScheme]) {
        [client postAnalyticsEvent:@"ios.paypal-otc.preflight.invalid-return-url-scheme"];
        if (error != NULL) {
            NSString *errorMessage = [NSString stringWithFormat:@"Cannot app switch to PayPal. Verify that the return URL scheme (%@) starts with this app's bundle id, and that the PayPal app is installed.", returnURLScheme];
            *error = [NSError errorWithDomain:BTAppSwitchErrorDomain
                                         code:BTAppSwitchErrorIntegrationReturnURLScheme
                                     userInfo:@{ NSLocalizedDescriptionKey: errorMessage }];
        }
        return NO;
    }
    
    return YES;
}

- (NSString *)payPalEnvironmentForClient:(BTClient *)client {
    NSString *btPayPalEnvironmentName = client.configuration.payPalEnvironment;
    if ([btPayPalEnvironmentName isEqualToString:@"offline"]) {
        return PayPalEnvironmentMock;
    } else if ([btPayPalEnvironmentName isEqualToString:@"live"]) {
        return PayPalEnvironmentProduction;
    } else {
        return btPayPalEnvironmentName;
    }
}

- (NSString *)paypalClientIdForClient:(BTClient *)client {
    if ([client.configuration.payPalEnvironment isEqualToString:@"offline"] && client.configuration.payPalClientId == nil) {
        return @"mock-paypal-client-id";
    } else {
        return client.configuration.payPalClientId;
    }
}

- (BTClient *)clientWithMetadataForResult:(PayPalOneTouchCoreResult *)result {
    return [self.client copyWithMetadata:^(BTClientMutableMetadata *metadata) {
        switch (result.target) {
            case PayPalOneTouchRequestTargetNone:
            case PayPalOneTouchRequestTargetUnknown:
                metadata.source = BTClientMetadataSourceUnknown;
                break;
            case PayPalOneTouchRequestTargetBrowser:
                metadata.source = BTClientMetadataSourcePayPalBrowser;
                break;
            case PayPalOneTouchRequestTargetOnDeviceApplication:
                metadata.source = BTClientMetadataSourcePayPalBrowser;
                break;
        }
    }];
}

- (NSSet *)defaultOAuth2Scopes {
    return [NSSet setWithObjects:@"https://uri.paypal.com/services/payments/futurepayments", @"email", nil];
}


#pragma mark Analytics Helpers

- (void)postAnalyticsEventWithClient:(BTClient *)client forInitiatingOneTouchWithSuccess:(BOOL)success target:(PayPalOneTouchRequestTarget)target {
    if (success) {
        switch (target) {
            case PayPalOneTouchRequestTargetNone:
                return [client postAnalyticsEvent:@"ios.paypal-future-payments.none.initiate.started"];
            case PayPalOneTouchRequestTargetUnknown:
                return [client postAnalyticsEvent:@"ios.paypal-future-payments.unknown.initiate.started"];
            case PayPalOneTouchRequestTargetOnDeviceApplication:
                return [client postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.initiate.started"];
            case PayPalOneTouchRequestTargetBrowser:
                return [client postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.initiate.started"];
        }
    } else {
        switch (target) {
            case PayPalOneTouchRequestTargetNone:
                return [client postAnalyticsEvent:@"ios.paypal-future-payments.none.initiate.failed"];
            case PayPalOneTouchRequestTargetUnknown:
                return [client postAnalyticsEvent:@"ios.paypal-future-payments.unknown.initiate.failed"];
            case PayPalOneTouchRequestTargetOnDeviceApplication:
                return [client postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.initiate.failed"];
            case PayPalOneTouchRequestTargetBrowser:
                return [client postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.initiate.failed"];
        }
    }
}

- (void)postAnalyticsEventWithClient:(BTClient *)client forHandlingOneTouchResult:(PayPalOneTouchCoreResult *)result {
    switch (result.type) {
        case PayPalOneTouchResultTypeError:
            switch (result.target) {
                case PayPalOneTouchRequestTargetNone:
                case PayPalOneTouchRequestTargetUnknown:
                    return [client postAnalyticsEvent:@"ios.paypal-future-payments.unknown.failed"];
                case PayPalOneTouchRequestTargetOnDeviceApplication:
                    return [client postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.failed"];
                case PayPalOneTouchRequestTargetBrowser:
                    return [client postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.failed"];
            }
        case PayPalOneTouchResultTypeCancel:
            if (result.error) {
                switch (result.target) {
                    case PayPalOneTouchRequestTargetNone:
                    case PayPalOneTouchRequestTargetUnknown:
                        return [client postAnalyticsEvent:@"ios.paypal-future-payments.unknown.canceled-with-error"];
                    case PayPalOneTouchRequestTargetOnDeviceApplication:
                        return [client postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.canceled-with-error"];
                    case PayPalOneTouchRequestTargetBrowser:
                        return [client postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.canceled-with-error"];
                }
            } else {
                switch (result.target) {
                    case PayPalOneTouchRequestTargetNone:
                    case PayPalOneTouchRequestTargetUnknown:
                        return [client postAnalyticsEvent:@"ios.paypal-future-payments.unknown.canceled"];
                    case PayPalOneTouchRequestTargetOnDeviceApplication:
                        return [client postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.canceled"];
                    case PayPalOneTouchRequestTargetBrowser:
                        return [client postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.canceled"];
                }
            }
        case PayPalOneTouchResultTypeSuccess:
            switch (result.target) {
                case PayPalOneTouchRequestTargetNone:
                case PayPalOneTouchRequestTargetUnknown:
                    return [client postAnalyticsEvent:@"ios.paypal-future-payments.unknown.succeeded"];
                case PayPalOneTouchRequestTargetOnDeviceApplication:
                    return [client postAnalyticsEvent:@"ios.paypal-future-payments.appswitch.succeeded"];
                case PayPalOneTouchRequestTargetBrowser:
                    return [client postAnalyticsEvent:@"ios.paypal-future-payments.webswitch.succeeded"];
            }
    }
}

- (void)postAnalyticsEventForTokenizationSuccessWithClient:(BTClient *)client {
    return [client postAnalyticsEvent:@"ios.paypal-future-payments.tokenize.succeeded"];
}

- (void)postAnalyticsEventForTokenizationFailureWithClient:(BTClient *)client {
    return [client postAnalyticsEvent:@"ios.paypal-future-payments.tokenize.failed"];
}

- (void)postAnalyticsEventForTokenizationSuccessWithClientForSinglePayment:(BTClient *)client {
    return [client postAnalyticsEvent:@"ios.paypal-single-payment.tokenize.succeeded"];
}

- (void)postAnalyticsEventForTokenizationFailureWithClientForSinglePayment:(BTClient *)client {
    return [client postAnalyticsEvent:@"ios.paypal-single-payment.tokenize.failed"];
}

- (void)postAnalyticsEventWithClientForSinglePayment:(BTClient *)client forInitiatingOneTouchWithSuccess:(BOOL)success target:(PayPalOneTouchRequestTarget)target {
    if (success) {
        switch (target) {
            case PayPalOneTouchRequestTargetNone:
                return [client postAnalyticsEvent:@"ios.paypal-single-payment.none.initiate.started"];
            case PayPalOneTouchRequestTargetUnknown:
                return [client postAnalyticsEvent:@"ios.paypal-single-payment.unknown.initiate.started"];
            case PayPalOneTouchRequestTargetOnDeviceApplication:
                return [client postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.initiate.started"];
            case PayPalOneTouchRequestTargetBrowser:
                return [client postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.initiate.started"];
        }
    } else {
        switch (target) {
            case PayPalOneTouchRequestTargetNone:
                return [client postAnalyticsEvent:@"ios.paypal-single-payment.none.initiate.failed"];
            case PayPalOneTouchRequestTargetUnknown:
                return [client postAnalyticsEvent:@"ios.paypal-single-payment.unknown.initiate.failed"];
            case PayPalOneTouchRequestTargetOnDeviceApplication:
                return [client postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.initiate.failed"];
            case PayPalOneTouchRequestTargetBrowser:
                return [client postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.initiate.failed"];
        }
    }
}

- (void)postAnalyticsEventWithClientForSinglePayment:(BTClient *)client forHandlingOneTouchResult:(PayPalOneTouchCoreResult *)result {
    switch (result.type) {
        case PayPalOneTouchResultTypeError:
            switch (result.target) {
                case PayPalOneTouchRequestTargetNone:
                case PayPalOneTouchRequestTargetUnknown:
                    return [client postAnalyticsEvent:@"ios.paypal-single-payment.unknown.failed"];
                case PayPalOneTouchRequestTargetOnDeviceApplication:
                    return [client postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.failed"];
                case PayPalOneTouchRequestTargetBrowser:
                    return [client postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.failed"];
            }
        case PayPalOneTouchResultTypeCancel:
            if (result.error) {
                switch (result.target) {
                    case PayPalOneTouchRequestTargetNone:
                    case PayPalOneTouchRequestTargetUnknown:
                        return [client postAnalyticsEvent:@"ios.paypal-single-payment.unknown.canceled-with-error"];
                    case PayPalOneTouchRequestTargetOnDeviceApplication:
                        return [client postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.canceled-with-error"];
                    case PayPalOneTouchRequestTargetBrowser:
                        return [client postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.canceled-with-error"];
                }
            } else {
                switch (result.target) {
                    case PayPalOneTouchRequestTargetNone:
                    case PayPalOneTouchRequestTargetUnknown:
                        return [client postAnalyticsEvent:@"ios.paypal-single-payment.unknown.canceled"];
                    case PayPalOneTouchRequestTargetOnDeviceApplication:
                        return [client postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.canceled"];
                    case PayPalOneTouchRequestTargetBrowser:
                        return [client postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.canceled"];
                }
            }
        case PayPalOneTouchResultTypeSuccess:
            switch (result.target) {
                case PayPalOneTouchRequestTargetNone:
                case PayPalOneTouchRequestTargetUnknown:
                    return [client postAnalyticsEvent:@"ios.paypal-single-payment.unknown.succeeded"];
                case PayPalOneTouchRequestTargetOnDeviceApplication:
                    return [client postAnalyticsEvent:@"ios.paypal-single-payment.appswitch.succeeded"];
                case PayPalOneTouchRequestTargetBrowser:
                    return [client postAnalyticsEvent:@"ios.paypal-single-payment.webswitch.succeeded"];
            }
    }
}

+ (void)resetSharedState {
    BTPayPalHandleURLContinuation = nil;
}

@end

NS_ASSUME_NONNULL_END
