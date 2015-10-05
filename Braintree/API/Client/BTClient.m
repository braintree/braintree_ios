#import <PassKit/PassKit.h>

#import "BTClient_Internal.h"
#import "BTClientToken.h"
#import "BTConfiguration.h"
#import "BTLogger_Internal.h"
#import "BTMutablePaymentMethod.h"
#import "BTMutablePayPalPaymentMethod.h"
#import "BTMutableCardPaymentMethod.h"
#import "BTMutableApplePayPaymentMethod.h"
#import "BTHTTP.h"
#import "BTOfflineModeURLProtocol.h"
#import "BTAnalyticsMetadata.h"
#import "Braintree-Version.h"
#import "BTAPIResponseParser.h"
#import "BTClientPaymentMethodValueTransformer.h"
#import "BTCoinbasePaymentMethod_Internal.h"

@interface BTClient ()
- (void)setMetadata:(BTClientMetadata *)metadata;
@end

@implementation BTClient

+ (void)setupWithClientToken:(NSString *)clientTokenString completion:(BTClientCompletionBlock)completionBlock {
    BTClient *client = [[self alloc] initSyncWithClientTokenString:clientTokenString];

    if (client) {
        [client fetchConfigurationWithCompletion:^(BTClient *client, NSError *error) {
            if (client && !error) {
                client.hasConfiguration = YES;
            }
            completionBlock(client, error);
        }];
    } else {
        completionBlock(nil, [NSError errorWithDomain:BTBraintreeAPIErrorDomain code:BTMerchantIntegrationErrorInvalidClientToken userInfo:@{NSLocalizedDescriptionKey: @"BTClient could not initialize because the provided clientToken was invalid"}]);
    }
}

- (instancetype)initWithClientToken:(NSString *)clientTokenString {
    return [self initSyncWithClientTokenString:clientTokenString];
}

- (instancetype)initSyncWithClientTokenString:(NSString *)clientTokenString {
    if(![clientTokenString isKindOfClass:[NSString class]]){
        NSString *reason = @"BTClient could not initialize because the provided clientToken was invalid";
        [[BTLogger sharedLogger] error:reason];
        return nil;
    }

    self = [self init];
    if (self) {
        NSError *error;
        self.clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenString error:&error];
        // Previously, error was ignored. Now, we at least log it
        if (error) { [[BTLogger sharedLogger] error:[error localizedDescription]]; }
        if (!self.clientToken) {
            NSString *reason = @"BTClient could not initialize because the provided clientToken was invalid";
            [[BTLogger sharedLogger] error:reason];
            return nil;
        }

        // For older integrations
        self.configuration = [[BTConfiguration alloc] initWithResponseParser:[self.clientToken clientTokenParser] error:&error];
        if (error) { [[BTLogger sharedLogger] error:[error localizedDescription]]; }

        self.configHttp = [[BTHTTP alloc] initWithBaseURL:self.clientToken.configURL];
        [self.configHttp setProtocolClasses:@[[BTOfflineModeURLProtocol class]]];

        [self prepareHttpFromConfiguration];

        self.metadata = [[BTClientMetadata alloc] init];
    }
    return self;
}

- (void)prepareHttpFromConfiguration {
    self.clientApiHttp = [[BTHTTP alloc] initWithBaseURL:self.configuration.clientApiURL];
    [self.clientApiHttp setProtocolClasses:@[[BTOfflineModeURLProtocol class]]];

    if (self.configuration.analyticsEnabled) {
        self.analyticsHttp = [[BTHTTP alloc] initWithBaseURL:self.configuration.analyticsURL];
        [self.analyticsHttp setProtocolClasses:@[[BTOfflineModeURLProtocol class]]];
    }
}

- (void)fetchConfigurationWithCompletion:(BTClientCompletionBlock)completionBlock {
    NSDictionary *parameters = @{ @"authorization_fingerprint": self.clientToken.authorizationFingerprint, @"config_version": @3 };
    [self.configHttp GET:nil
              parameters:parameters
              completion:^(BTHTTPResponse *response, NSError *error) {
                  if (response.isSuccess) {
                      NSError *configurationError;
                      self.configuration = [[BTConfiguration alloc] initWithResponseParser:response.object error:&configurationError];

                      [self prepareHttpFromConfiguration];

                      if (completionBlock) {
                          completionBlock(self, configurationError);
                      }
                  } else {
                      if (!error) {
                          error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                                      code:BTServerErrorGatewayUnavailable
                                                  userInfo:@{NSLocalizedDescriptionKey:
                                                                 @"Braintree did not return a successful response, and no underlying error was provided."}];
                      }
                      if (completionBlock) {
                          completionBlock(nil, error);
                      }
                  }
              }];
}

- (id)copyWithZone:(NSZone *)zone {
    BTClient *copiedClient = [[BTClient allocWithZone:zone] init];
    copiedClient.additionalPayPalScopes = [_additionalPayPalScopes copy];
    copiedClient.clientToken = [_clientToken copy];
    copiedClient.configuration = [_configuration copy];
    copiedClient.clientApiHttp = [_clientApiHttp copy];
    copiedClient.analyticsHttp = [_analyticsHttp copy];
    copiedClient.metadata = [self.metadata copy];
    copiedClient.configHttp = [_configHttp copy];
    copiedClient.hasConfiguration = _hasConfiguration;
    return copiedClient;
}

#pragma mark - Configuration

- (NSSet *)challenges {
    return self.configuration.challenges;
}

- (NSString *)merchantId {
    return self.configuration.merchantId;
}

#pragma mark - NSCoding methods

// NB: This is not yet used and has not been fully tested.

- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.clientToken forKey:@"clientToken"];
    [coder encodeObject:self.configuration forKey:@"configuration"];
    [coder encodeObject:@(self.hasConfiguration) forKey:@"hasConfiguration"];
}

- (id)initWithCoder:(NSCoder *)decoder{
    self = [super init];
    if (self){
        self.clientToken = [decoder decodeObjectForKey:@"clientToken"];
        self.configuration = [decoder decodeObjectForKey:@"configuration"];

        self.configHttp = [[BTHTTP alloc] initWithBaseURL:self.clientToken.configURL];
        [self.configHttp setProtocolClasses:@[[BTOfflineModeURLProtocol class]]];

        self.clientApiHttp = [[BTHTTP alloc] initWithBaseURL:self.configuration.clientApiURL];
        [self.clientApiHttp setProtocolClasses:@[[BTOfflineModeURLProtocol class]]];

        if (self.configuration.analyticsEnabled) {
            self.analyticsHttp = [[BTHTTP alloc] initWithBaseURL:self.configuration.analyticsURL];
            [self.analyticsHttp setProtocolClasses:@[[BTOfflineModeURLProtocol class]]];
        }

        self.hasConfiguration = [[decoder decodeObjectForKey:@"hasConfiguration"] boolValue];
    }
    return self;
}

#pragma mark - API Methods

- (void)fetchPaymentMethodsWithSuccess:(BTClientPaymentMethodListSuccessBlock)successBlock
                               failure:(BTClientFailureBlock)failureBlock {
    NSDictionary *parameters = @{
                                 @"authorization_fingerprint": self.clientToken.authorizationFingerprint,
                                 };

    [self.clientApiHttp GET:@"v1/payment_methods" parameters:parameters completion:^(BTHTTPResponse *response, NSError *error) {
        if (response.isSuccess) {
            if (successBlock) {
                NSArray *paymentMethods = [response.object arrayForKey:@"paymentMethods"
                                                  withValueTransformer:[BTClientPaymentMethodValueTransformer sharedInstance]];

                successBlock(paymentMethods);
            }
        } else {
            if (failureBlock) {
                failureBlock(error);
            }
        }
    }];
}

- (void)fetchPaymentMethodWithNonce:(NSString *)nonce
                            success:(BTClientPaymentMethodSuccessBlock)successBlock
                            failure:(BTClientFailureBlock)failureBlock {
    NSDictionary *parameters = @{
                                 @"authorization_fingerprint": self.clientToken.authorizationFingerprint,
                                 };
    [self.clientApiHttp GET:[NSString stringWithFormat:@"v1/payment_methods/%@", nonce]
                 parameters:parameters
                 completion:^(BTHTTPResponse *response, NSError *error) {
                     if (response.isSuccess) {
                         if (successBlock) {
                             NSArray *paymentMethods = [response.object arrayForKey:@"paymentMethods" withValueTransformer:[BTClientPaymentMethodValueTransformer sharedInstance]];

                             successBlock([paymentMethods firstObject]);
                         }
                     } else {
                         if (failureBlock) {
                             failureBlock(error);
                         }
                     }
                 }];
}

- (void)saveCardWithRequest:(BTClientCardRequest *)request
                    success:(BTClientCardSuccessBlock)successBlock
                    failure:(BTClientFailureBlock)failureBlock {

    NSMutableDictionary *requestParameters = [self metaPostParameters];
    NSMutableDictionary *creditCardParams = [request.parameters mutableCopy];

    [requestParameters addEntriesFromDictionary:@{ @"credit_card": creditCardParams,
                                                   @"authorization_fingerprint": self.clientToken.authorizationFingerprint
                                                   }];

    [self.clientApiHttp POST:@"v1/payment_methods/credit_cards" parameters:requestParameters completion:^(BTHTTPResponse *response, NSError *error) {
        if (response.isSuccess) {
            if (successBlock) {
                NSArray *paymentMethods = [response.object arrayForKey:@"creditCards"
                                                  withValueTransformer:[BTClientPaymentMethodValueTransformer sharedInstance]];
                successBlock([paymentMethods firstObject]);
            }
        } else {
            NSError *returnedError = error;
            if (error.domain == BTBraintreeAPIErrorDomain && error.code == BTCustomerInputErrorInvalid) {
                returnedError = [NSError errorWithDomain:error.domain
                                                    code:error.code
                                                userInfo:@{BTCustomerInputBraintreeValidationErrorsKey: response.rawObject}];
            }
            if (failureBlock) {
                failureBlock(returnedError);
            }
        }
    }];
}

// Deprecated
- (void)saveCardWithNumber:(NSString *)creditCardNumber
           expirationMonth:(NSString *)expirationMonth
            expirationYear:(NSString *)expirationYear
                       cvv:(NSString *)cvv
                postalCode:(NSString *)postalCode
                  validate:(BOOL)shouldValidate
                   success:(BTClientCardSuccessBlock)successBlock
                   failure:(BTClientFailureBlock)failureBlock {

    BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
    request.number = creditCardNumber;
    request.expirationMonth = expirationMonth;
    request.expirationYear = expirationYear;
    request.cvv = cvv;
    request.postalCode = postalCode;
    request.shouldValidate = shouldValidate;

    [self saveCardWithRequest:request
                      success:successBlock
                      failure:failureBlock];
}

#if BT_ENABLE_APPLE_PAY
- (void)saveApplePayPayment:(PKPayment *)payment
                    success:(BTClientApplePaySuccessBlock)successBlock
                    failure:(BTClientFailureBlock)failureBlock {

    if (![PKPayment class]) {
        if (failureBlock) {
            failureBlock([NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                             code:BTErrorUnsupported
                                         userInfo:@{NSLocalizedDescriptionKey: @"Apple Pay is not supported on this device"}]);
        }
        return;

    }

    NSString *encodedPaymentData;
    NSError *error;
    switch (self.configuration.applePayStatus) {
        case BTClientApplePayStatusOff:
            error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                        code:BTErrorUnsupported
                                    userInfo:@{ NSLocalizedDescriptionKey: @"Apple Pay is not enabled for this merchant. Please ensure that Apple Pay is enabled in the control panel and then try saving an Apple Pay payment method again." }];
            [[BTLogger sharedLogger] warning:error.localizedDescription];
            break;
        case BTClientApplePayStatusMock: {
            NSDictionary *mockPaymentDataDictionary = @{
                                                        @"version": @"hello-version",
                                                        @"data": @"hello-data",
                                                        @"header": @{
                                                                @"transactionId": @"hello-transaction-id",
                                                                @"ephemeralPublicKey": @"hello-ephemeral-public-key",
                                                                @"publicKeyHash": @"hello-public-key-hash"
                                                                }};
            NSError *error;
            NSData *paymentData = [NSJSONSerialization dataWithJSONObject:mockPaymentDataDictionary options:0 error:&error];
            NSAssert(error == nil, @"Unexpected JSON serialization error: %@", error);
            encodedPaymentData = [paymentData base64EncodedStringWithOptions:0];
            break;
        }

        case BTClientApplePayStatusProduction:
            if (!payment) {
                [[BTLogger sharedLogger] warning:@"-[BTClient saveApplePayPayment:success:failure:] received nil payment."];
                NSError *error = [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                                     code:BTErrorUnsupported
                                                 userInfo:@{NSLocalizedDescriptionKey: @"A valid PKPayment is required in production"}];
                if (failureBlock) {
                    failureBlock(error);
                }
                return;
            }

            encodedPaymentData = [payment.token.paymentData base64EncodedStringWithOptions:0];
            break;
        default:
            return;
    }

    if (error) {
        if (failureBlock) {
            failureBlock(error);
        }
        return;
    }

    NSMutableDictionary *tokenParameterValue = [NSMutableDictionary dictionary];
    if (encodedPaymentData) {
        tokenParameterValue[@"paymentData"] = encodedPaymentData;
    }
	
    // iOS 9 path: PKPaymentToken -paymentMethod is new in iOS 9
	if ([payment.token respondsToSelector:@selector(paymentMethod)]) {
		if (payment.token.paymentMethod.network) {
			tokenParameterValue[@"paymentNetwork"] = payment.token.paymentMethod.network;
		}
		
		if (payment.token.paymentMethod.displayName) {
			tokenParameterValue[@"paymentInstrumentName"] = payment.token.paymentMethod.displayName;
		}
	} else {
        // iOS 8 path: methods were deprecated in iOS 9
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		if (payment.token.paymentInstrumentName) {
			tokenParameterValue[@"paymentInstrumentName"] = payment.token.paymentInstrumentName;
		}
		
		if (payment.token.paymentNetwork) {
			tokenParameterValue[@"paymentNetwork"] = payment.token.paymentNetwork;
		}
#pragma clang diagnostic pop
	}

    if (payment.token.transactionIdentifier) {
        tokenParameterValue[@"transactionIdentifier"] = payment.token.transactionIdentifier;
    }
    
    NSMutableDictionary *requestParameters = [self metaPostParameters];
    [requestParameters addEntriesFromDictionary:@{ @"applePaymentToken": tokenParameterValue,
                                                   @"authorization_fingerprint": self.clientToken.authorizationFingerprint,
                                                   }];

    [self.clientApiHttp POST:@"v1/payment_methods/apple_payment_tokens" parameters:requestParameters completion:^(BTHTTPResponse *response, NSError *error){
        if (response.isSuccess) {
            if (successBlock){
                NSArray *applePayCards = [response.object arrayForKey:@"applePayCards" withValueTransformer:[BTClientPaymentMethodValueTransformer sharedInstance]];

                BTMutableApplePayPaymentMethod *paymentMethod = [applePayCards firstObject];

                paymentMethod.shippingMethod = payment.shippingMethod;
				
                // iOS 9 path: shippingContact and billingContact are new in iOS 9
				if ([payment respondsToSelector:@selector(shippingContact)]) {
					paymentMethod.shippingContact = payment.shippingContact;
                    paymentMethod.billingContact = payment.billingContact;
				}
                
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                // To ensure backwards compatibility with old iOS 8 code, always pass through the deprecated addresses, even on iOS 9 devices
                paymentMethod.shippingAddress = payment.shippingAddress;
                paymentMethod.billingAddress = payment.billingAddress;
#pragma clang diagnostic pop
                
                successBlock([paymentMethod copy]);
            }
        } else {
            if (failureBlock) {
                NSDictionary *userInfo;
                if (error) {
                    userInfo = @{NSUnderlyingErrorKey: error,
                                 @"statusCode": @(response.statusCode)};
                }
                failureBlock([NSError errorWithDomain:BTBraintreeAPIErrorDomain code:BTUnknownError userInfo:userInfo]);
            }
        }
    }];
}
#endif

- (void)savePaypalPaymentMethodWithAuthCode:(NSString *)authCode
                   applicationCorrelationID:(NSString *)correlationId
                                    success:(BTClientPaypalSuccessBlock)successBlock
                                    failure:(BTClientFailureBlock)failureBlock {
    return [self savePaypalPaymentMethodWithAuthCode:authCode
                    optionalApplicationCorrelationID:correlationId
                                             success:successBlock
                                             failure:failureBlock];
}

// Required since correlationId in the signature above is __nonnull
- (void)savePaypalPaymentMethodWithAuthCode:(NSString *)authCode
           optionalApplicationCorrelationID:(NSString *)correlationId
                                    success:(BTClientPaypalSuccessBlock)successBlock
                                    failure:(BTClientFailureBlock)failureBlock {
    NSMutableDictionary *requestParameters = [self metaPostParameters];
    // To preserve backwards compatibility - only set shouldValidate to FALSE when requesting additional scopes
    BOOL shouldValidate = [self.additionalPayPalScopes count] == 0;
    [requestParameters addEntriesFromDictionary:@{ @"paypal_account": @{
                                                           @"consent_code": authCode ?: NSNull.null,
                                                           @"correlation_id": correlationId ?: NSNull.null,
                                                           @"options": @{@"validate": @(shouldValidate)}
                                                           },
                                                   @"authorization_fingerprint": self.clientToken.authorizationFingerprint
                                                   
                                                   }];

    [self.clientApiHttp POST:@"v1/payment_methods/paypal_accounts" parameters:requestParameters completion:^(BTHTTPResponse *response, NSError *error){
        if (response.isSuccess) {
            if (successBlock){
                NSArray *payPalPaymentMethods = [response.object arrayForKey:@"paypalAccounts" withValueTransformer:[BTClientPaymentMethodValueTransformer sharedInstance]];
                BTPayPalPaymentMethod *payPalPaymentMethod = [payPalPaymentMethods firstObject];
                
                successBlock(payPalPaymentMethod);
            }
        } else {
            if (failureBlock) {
                failureBlock([NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                                 code:BTUnknownError // TODO - use a client error code
                                             userInfo:@{NSUnderlyingErrorKey: error}]);
            }
        }
    }];
}

// Deprecated
- (void)savePaypalPaymentMethodWithAuthCode:(NSString *)authCode
                                    success:(BTClientPaypalSuccessBlock)successBlock
                                    failure:(BTClientFailureBlock)failureBlock {
    [self savePaypalPaymentMethodWithAuthCode:authCode
             optionalApplicationCorrelationID:nil
                                      success:successBlock
                                      failure:failureBlock];
}

// Deprecated
- (void)savePaypalPaymentMethodWithAuthCode:(NSString *)authCode
                              correlationId:(NSString *)correlationId
                                    success:(BTClientPaypalSuccessBlock)successBlock
                                    failure:(BTClientFailureBlock)failureBlock {
    [self savePaypalPaymentMethodWithAuthCode:authCode
                     applicationCorrelationID:correlationId
                                      success:successBlock
                                      failure:failureBlock];
}

- (void)postAnalyticsEvent:(NSString *)eventKind
                   success:(BTClientAnalyticsSuccessBlock)successBlock
                   failure:(BTClientFailureBlock)failureBlock {

    if (self.configuration.analyticsEnabled) {
        NSMutableDictionary *requestParameters = [self metaAnalyticsParameters];
        [requestParameters addEntriesFromDictionary:@{ @"analytics": @[@{ @"kind": eventKind }],
                                                       @"authorization_fingerprint": self.clientToken.authorizationFingerprint
                                                       }];

        [[BTLogger sharedLogger] debug:@"BTClient postAnalyticsEvent:%@ session:%@", eventKind, self.metadata.sessionId];

        [self.analyticsHttp POST:@"/"
                      parameters:requestParameters
                      completion:^(BTHTTPResponse *response, NSError *error) {
                          if (response.isSuccess) {
                              if (successBlock) {
                                  successBlock();
                              }
                          } else {
                              if (failureBlock) {
                                  failureBlock(error);
                              }
                          }
                      }];
    } else {
        if (successBlock) {
            successBlock();
        }
    }
}

#pragma mark 3D Secure Lookup

- (void)lookupNonceForThreeDSecure:(NSString *)nonce
                 transactionAmount:(NSDecimalNumber *)amount
                           success:(BTClientThreeDSecureLookupSuccessBlock)successBlock
                           failure:(BTClientFailureBlock)failureBlock {
    NSMutableDictionary *requestParameters = [@{ @"authorization_fingerprint": self.clientToken.authorizationFingerprint,
                                                 @"amount": amount } mutableCopy];
    if (self.configuration.merchantAccountId) {
        requestParameters[@"merchant_account_id"] = self.configuration.merchantAccountId;
    }
    NSString *urlSafeNonce = [nonce stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    [self.clientApiHttp POST:[NSString stringWithFormat:@"v1/payment_methods/%@/three_d_secure/lookup", urlSafeNonce]
                  parameters:requestParameters
                  completion:^(BTHTTPResponse *response, NSError *error){
        if (response.isSuccess) {
            if (successBlock) {
                BTThreeDSecureLookupResult *lookup = [[BTThreeDSecureLookupResult alloc] init];

                BTAPIResponseParser *lookupResponse = [response.object responseParserForKey:@"lookup"];
                lookup.acsURL = [lookupResponse URLForKey:@"acsUrl"];
                lookup.PAReq = [lookupResponse stringForKey:@"pareq"];
                lookup.MD = [lookupResponse stringForKey:@"md"];
                lookup.termURL = [lookupResponse URLForKey:@"termUrl"];
                BTPaymentMethod *paymentMethod = [response.object objectForKey:@"paymentMethod"
                                                          withValueTransformer:[BTClientPaymentMethodValueTransformer sharedInstance]];
                if ([paymentMethod isKindOfClass:[BTCardPaymentMethod class]]) {
                    lookup.card = (BTCardPaymentMethod *)paymentMethod;
                }
                successBlock(lookup);
            }
        } else {
            if (failureBlock) {
                if (response.statusCode == 422) {
                    NSString *errorMessage = [[response.object responseParserForKey:@"error"] stringForKey:@"message"];
                    NSDictionary *threeDSecureInfo = [response.object dictionaryForKey:@"threeDSecureInfo"];
                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                    if (errorMessage) {
                        userInfo[NSLocalizedDescriptionKey] = errorMessage;
                    }
                    if (threeDSecureInfo) {
                        userInfo[BTThreeDSecureInfoKey] = threeDSecureInfo;
                    }
                    NSDictionary *errors = [response.object dictionaryForKey:@"error"];
                    if (errors) {
                        userInfo[BTCustomerInputBraintreeValidationErrorsKey] = errors;
                    }
                    failureBlock([NSError errorWithDomain:error.domain
                                                     code:error.code
                                                 userInfo:userInfo]);
                } else {
                    failureBlock(error);
                }
            }
        }
    }];

}

- (void)saveCoinbaseAccount:(id)coinbaseAuthResponse
               storeInVault:(BOOL)storeInVault
                    success:(BTClientCoinbaseSuccessBlock)successBlock
                    failure:(BTClientFailureBlock)failureBlock {
    if (![coinbaseAuthResponse isKindOfClass:[NSDictionary class]]) {
        if (failureBlock) {
            failureBlock([NSError errorWithDomain:BTBraintreeAPIErrorDomain code:BTCustomerInputErrorInvalid userInfo:@{NSLocalizedDescriptionKey: @"Received an invalid Coinbase response for tokenization, expected an NSDictionary"}]);
        }
        return;
    }

    if (storeInVault) {
        NSMutableDictionary *mutableCoinbaseAuthResponse = [coinbaseAuthResponse mutableCopy];
        mutableCoinbaseAuthResponse[@"options"] = @{ @"store_in_vault": @YES };
        coinbaseAuthResponse = mutableCoinbaseAuthResponse;
    }

    NSMutableDictionary *parameters = [self metaPostParameters];
    parameters[@"coinbase_account"] = coinbaseAuthResponse;
    parameters[@"authorization_fingerprint"] = self.clientToken.authorizationFingerprint;

    [self.clientApiHttp POST:@"v1/payment_methods/coinbase_accounts"
                  parameters:parameters
                  completion:^(BTHTTPResponse *response, NSError *error){
                      if (response.isSuccess) {
                          if (successBlock) {
                              BTCoinbasePaymentMethod *paymentMethod = [[response.object arrayForKey:@"coinbaseAccounts"
                                                                                withValueTransformer:[BTClientPaymentMethodValueTransformer sharedInstance]] firstObject];
                              
                              successBlock(paymentMethod);
                          }
                      } else {
                          if (failureBlock) {
                              NSError *returnedError = error;
                              if (error.domain == BTBraintreeAPIErrorDomain && error.code == BTCustomerInputErrorInvalid) {
                                  returnedError = [NSError errorWithDomain:error.domain
                                                                      code:error.code
                                                                  userInfo:@{BTCustomerInputBraintreeValidationErrorsKey: response.rawObject}];
                              }
                              failureBlock(returnedError);
                          }
                      }
                  }];
}

#pragma mark Braintree Analytics

- (void)postAnalyticsEvent:(NSString *)eventKind {
    [self postAnalyticsEvent:eventKind success:nil failure:nil];
}


#pragma mark -

- (NSMutableDictionary *)metaPostParameters {
    return [self mutableDictionaryCopyWithClientMetadata:nil];
}

- (NSMutableDictionary *)metaAnalyticsParameters {
    return [self mutableDictionaryCopyWithClientMetadata:@{@"_meta": [BTAnalyticsMetadata metadata]}];
}

- (NSMutableDictionary *)mutableDictionaryCopyWithClientMetadata:(NSDictionary *)parameters {
    NSMutableDictionary *result = parameters ? [parameters mutableCopy] : [NSMutableDictionary dictionary];
    NSDictionary *metaValue = result[@"_meta"];
    if (![metaValue isKindOfClass:[NSDictionary class]]) {
        metaValue = @{};
    }
    NSMutableDictionary *mutableMetaValue = [metaValue mutableCopy];
    mutableMetaValue[@"integration"] = self.metadata.integrationString;
    mutableMetaValue[@"source"] = self.metadata.sourceString;
    mutableMetaValue[@"sessionId"] = self.metadata.sessionId;

    result[@"_meta"] = mutableMetaValue;
    return result;
}


#pragma mark - Debug

- (NSString *)description {
    return [NSString stringWithFormat:@"<BTClient:%p clientApiHttp:%@, analyticsHttp:%@>", self, self.clientApiHttp, self.analyticsHttp];
}

#pragma mark - Library Version

+ (NSString *)libraryVersion {
    return BRAINTREE_VERSION;
}

- (BOOL)isEqualToClient:(BTClient *)client {
    return ((self.clientToken == client.clientToken) || [self.clientToken isEqual:client.clientToken]) &&
           ((self.configuration == client.configuration) || [self.configuration isEqual:client.configuration]);
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if ([object isKindOfClass:[BTClient class]]) {
        return [self isEqualToClient:object];
    }

    return NO;
}

#pragma mark - BTClient_Metadata

- (void)setMetadata:(BTClientMetadata *)metadata {
    _metadata = metadata;
}

- (instancetype)copyWithMetadata:(void (^)(BTClientMutableMetadata *metadata))metadataBlock {
    BTClientMutableMetadata *mutableMetadata = [self.metadata mutableCopy];
    if (metadataBlock) {
        metadataBlock(mutableMetadata);
    }
    BTClient *copiedClient = [self copy];
    copiedClient.metadata = mutableMetadata;
    return copiedClient;
}

@end
