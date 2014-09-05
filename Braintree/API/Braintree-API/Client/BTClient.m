#import "BTClient.h"
#import "BTClient_Metadata.h"
#import "BTClient_Internal.h"
#import "BTClientToken.h"
#import "BTLogger.h"
#import "BTMutablePaymentMethod.h"
#import "BTMutablePayPalPaymentMethod.h"
#import "BTMutableCardPaymentMethod.h"
#import "BTHTTP.h"
#import "BTOfflineModeURLProtocol.h"
#import "BTAnalyticsMetadata.h"
#import "Braintree-Version.h"

NSString *const BTClientChallengeResponseKeyPostalCode = @"postal_code";
NSString *const BTClientChallengeResponseKeyCVV = @"cvv";

@interface BTClient ()
- (void)setMetadata:(BTClientMetadata *)metadata;
@end

@implementation BTClient

- (instancetype)initWithClientToken:(NSString *)clientTokenString {
    if(![clientTokenString isKindOfClass: NSString.class]){
        NSString *reason = @"BTClient could not initialize because the provided clientToken was of an invalid type";
        [[BTLogger sharedLogger] log:reason];

        return nil;
    }
    self = [self init];
    if (self) {
        NSError *error;
        self.clientToken = [[BTClientToken alloc] initWithClientTokenString:clientTokenString error:&error];
        if (!self.clientToken) {
            NSString *reason = @"BTClient could not initialize because the provided clientToken was invalid";
            [[BTLogger sharedLogger] log:reason];
#ifdef DEBUG
            @throw [NSException exceptionWithName:NSInvalidArgumentException
                                           reason:reason
                                         userInfo:nil];
#endif
            return nil;
        }

        self.clientApiHttp = [[BTHTTP alloc] initWithBaseURL:self.clientToken.clientApiURL];
        [self.clientApiHttp setProtocolClasses:@[[BTOfflineModeURLProtocol class]]];

        if (self.clientToken.analyticsEnabled) {
            self.analyticsHttp = [[BTHTTP alloc] initWithBaseURL:self.clientToken.analyticsURL];
        }
        self.metadata = [[BTClientMetadata alloc] init];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    BTClient *copiedClient = [[BTClient allocWithZone:zone] init];
    copiedClient.clientToken = [_clientToken copy];
    copiedClient.clientApiHttp = [_clientApiHttp copy];
    copiedClient.analyticsHttp = [_analyticsHttp copy];
    copiedClient.metadata = [self.metadata copy];
    return copiedClient;
}

#pragma mark - Configuration

- (NSSet *)challenges {
    return self.clientToken.challenges;
}

- (NSString *)merchantId {
    return self.clientToken.merchantId;
}

#pragma mark - NSCoding methods

- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.clientToken forKey:@"clientToken"];
}

- (id)initWithCoder:(NSCoder *)decoder{
    self = [super init];
    if (self){
        self.clientToken = [decoder decodeObjectForKey:@"clientToken"];

        self.clientApiHttp = [[BTHTTP alloc] initWithBaseURL:self.clientToken.clientApiURL];
        [self.clientApiHttp setProtocolClasses:@[[BTOfflineModeURLProtocol class]]];

        if (self.clientToken.analyticsEnabled) {
            self.analyticsHttp = [[BTHTTP alloc] initWithBaseURL:self.clientToken.analyticsURL];
        }
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
                NSArray *responsePaymentMethods = response.object[@"paymentMethods"];

                NSMutableArray *paymentMethods = [NSMutableArray array];
                for (NSDictionary *paymentMethodDictionary in responsePaymentMethods) {
                    BTPaymentMethod *paymentMethod = [[self class] paymentMethodFromAPIResponseDictionary:paymentMethodDictionary];
                    if (paymentMethod == nil) {
                        NSLog(@"Unable to create payment method from %@", paymentMethodDictionary);
                    } else {
                        [paymentMethods addObject:paymentMethod];
                    }
                }

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
                             NSArray *paymentMethods = response.object[@"paymentMethods"];
                             
                             BTPaymentMethod *paymentMethod = [[self class] paymentMethodFromAPIResponseDictionary:[paymentMethods firstObject]];
                             successBlock(paymentMethod);
                         }
                     } else {
                         if (failureBlock) {
                             failureBlock(error);
                         }
                     }
                 }];
}

- (void)saveCardWithNumber:(NSString *)creditCardNumber
           expirationMonth:(NSString *)expirationMonth
            expirationYear:(NSString *)expirationYear
                       cvv:(NSString *)cvv
                postalCode:(NSString *)postalCode
                  validate:(BOOL)shouldValidate
                   success:(BTClientCardSuccessBlock)successBlock
                   failure:(BTClientFailureBlock)failureBlock {

    NSMutableDictionary *requestParameters = [self metaPostParameters];
    NSMutableDictionary *creditCardParams = [@{ @"number": creditCardNumber,
                                                @"expiration_month": expirationMonth,
                                                @"expiration_year": expirationYear,
                                                @"options": @{
                                                        @"validate": @(shouldValidate)
                                                        }
                                                } mutableCopy];
    [requestParameters addEntriesFromDictionary:@{ @"credit_card": creditCardParams,
                                                   @"authorization_fingerprint": self.clientToken.authorizationFingerprint
                                                   }];

    if (cvv) {
        requestParameters[@"credit_card"][@"cvv"] = cvv;
    }

    if (postalCode) {
        requestParameters[@"credit_card"][@"billing_address"] = @{ @"postal_code": postalCode };
    }

    [self.clientApiHttp POST:@"v1/payment_methods/credit_cards" parameters:requestParameters completion:^(BTHTTPResponse *response, NSError *error) {
        if (response.isSuccess) {
            NSDictionary *creditCardResponse = response.object[@"creditCards"][0];
            BTCardPaymentMethod *paymentMethod = [[self class] cardFromAPIResponseDictionary:creditCardResponse];

            if (successBlock) {
                successBlock(paymentMethod);
            }
        } else {
            NSError *returnedError = error;
            if (error.domain == BTBraintreeAPIErrorDomain && error.code == BTCustomerInputErrorInvalid) {
                returnedError = [NSError errorWithDomain:error.domain
                                                    code:error.code
                                                userInfo:@{BTCustomerInputBraintreeValidationErrorsKey: response.object}];
            }
            if (failureBlock) {
                failureBlock(returnedError);
            }
        }
    }];
}

- (void)savePaypalPaymentMethodWithAuthCode:(NSString*)authCode
                   applicationCorrelationID:(NSString *)correlationId
                                    success:(BTClientPaypalSuccessBlock)successBlock
                                    failure:(BTClientFailureBlock)failureBlock {

    NSMutableDictionary *requestParameters = [self metaPostParameters];
    [requestParameters addEntriesFromDictionary:@{ @"paypal_account": @{
                                                           @"consent_code": authCode ?: NSNull.null,
                                                           @"correlation_id": correlationId ?: NSNull.null
                                                           },
                                                   @"authorization_fingerprint": self.clientToken.authorizationFingerprint,
                                                   }];

    [self.clientApiHttp POST:@"v1/payment_methods/paypal_accounts" parameters:requestParameters completion:^(BTHTTPResponse *response, NSError *error){
        if (response.isSuccess) {
            if (successBlock){
                NSDictionary *paypalPaymentMethodResponse = response.object[@"paypalAccounts"][0];
                BTPayPalPaymentMethod *payPalPaymentMethod = [[self class] payPalPaymentMethodFromAPIResponseDictionary:paypalPaymentMethodResponse];
                successBlock(payPalPaymentMethod);
            }
        } else {
            if (failureBlock) {
                failureBlock([NSError errorWithDomain:error.domain code:BTUnknownError userInfo:nil]);
            }
        }
    }];
}

// Deprecated
- (void)savePaypalPaymentMethodWithAuthCode:(NSString *)authCode
                                    success:(BTClientPaypalSuccessBlock)successBlock
                                    failure:(BTClientFailureBlock)failureBlock {
    [self savePaypalPaymentMethodWithAuthCode:authCode
                     applicationCorrelationID:nil
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

    if (self.clientToken.analyticsEnabled) {
        NSMutableDictionary *requestParameters = [self metaAnalyticsParameters];
        [requestParameters addEntriesFromDictionary:@{ @"analytics": @[@{ @"kind": eventKind }],
                                                       @"authorization_fingerprint": self.clientToken.authorizationFingerprint
                                                       }];

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

- (void)postAnalyticsEvent:(NSString *)eventKind {
    [self postAnalyticsEvent:eventKind success:nil failure:nil];
}

#pragma mark - Response Parsing

+ (BTPaymentMethod *)paymentMethodFromAPIResponseDictionary:(NSDictionary *)response {
    if ([response[@"type"] isEqual:@"CreditCard"]) {
        return [self cardFromAPIResponseDictionary:response];
    } else if ([response[@"type"] isEqual:@"PayPalAccount"]) {
        return [self payPalPaymentMethodFromAPIResponseDictionary:response];
    } else {
        return nil;
    }
}

+ (BTPayPalPaymentMethod *)payPalPaymentMethodFromAPIResponseDictionary:(NSDictionary *)response {
    BTMutablePayPalPaymentMethod *payPalPaymentMethod;
    if ([response respondsToSelector:@selector(objectForKeyedSubscript:)]) {
        payPalPaymentMethod             = [BTMutablePayPalPaymentMethod new];
        payPalPaymentMethod.nonce       = response[@"nonce"];
        payPalPaymentMethod.locked      = [response[@"isLocked"] boolValue];
        id email = response[@"details"][@"email"];
        payPalPaymentMethod.email = [email isKindOfClass:[NSString class]] ? email : nil;
        id description = response[@"description"];
        if ([description isKindOfClass:[NSString class]]) {
            // Braintree gateway has some inconsistent behavior depending on
            // the type of nonce, and sometimes returns "PayPal" for description,
            // and sometimes returns a real identifying string. The former is not
            // desirable for display. The latter is.
            // As a workaround, we ignore descriptions that look like "PayPal".
            if (![[description lowercaseString] isEqualToString:@"paypal"]) {
                payPalPaymentMethod.description = description;
            }
        }
    }
    return payPalPaymentMethod;
}

+ (BTCardPaymentMethod *)cardFromAPIResponseDictionary:(NSDictionary *)responseObject {
    BTMutableCardPaymentMethod *card = [[BTMutableCardPaymentMethod alloc] init];

    card.description        = responseObject[@"description"];
    card.typeString         = responseObject[@"details"][@"cardType"];
    card.lastTwo            = responseObject[@"details"][@"lastTwo"];
    card.locked             = [responseObject[@"isLocked"] boolValue];
    card.nonce              = responseObject[@"nonce"];
    card.challengeQuestions = [NSSet setWithArray:responseObject[@"securityQuestions"]];

    return card;
}

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
    return (self.clientToken == client.clientToken) || [self.clientToken isEqual:client.clientToken];
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
