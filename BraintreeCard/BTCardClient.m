#import "BTErrors.h"
#import "BTCardClient_Internal.h"
#import "BTCardNonce_Internal.h"
#import "BTCardRequest.h"
#import "BTConfiguration+Card.h"
#import "BTClientMetadata.h"
#import "BTHTTP.h"
#import "BTJSON.h"
#import "BTPaymentMethodNonceParser.h"
#import "BTTokenizationService.h"
#if __has_include("BraintreeCore.h")
#import "BTAPIClient_Internal.h"
#import "BTCard_Internal.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <BraintreeCore/BTCard_Internal.h>
#endif

NSString *const BTCardClientErrorDomain = @"com.braintreepayments.BTCardClientErrorDomain";
NSString *const BTCardClientGraphQLTokenizeFeature = @"tokenize_credit_cards";

@interface BTCardClient ()
@end

@implementation BTCardClient

static Class PayPalDataCollectorClass;
static NSString *PayPalDataCollectorClassString = @"PPDataCollector";

+ (void)load {
    if (self == [BTCardClient class]) {
        [[BTTokenizationService sharedService] registerType:@"Card" withTokenizationBlock:^(BTAPIClient *apiClient, NSDictionary *options, void (^completionBlock)(BTPaymentMethodNonce *paymentMethodNonce, NSError *error)) {
            BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
            [client tokenizeCard:[[BTCard alloc] initWithParameters:options] completion:completionBlock];
        }];
        
        [[BTPaymentMethodNonceParser sharedParser] registerType:@"CreditCard" withParsingBlock:^BTPaymentMethodNonce * _Nullable(BTJSON * _Nonnull creditCard) {
            return [BTCardNonce cardNonceWithJSON:creditCard];
        }];
    }
}

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (!apiClient) {
        return nil;
    }
    if (self = [super init]) {
        self.apiClient = apiClient;
    }
    return self;
}

- (instancetype)init {
    return nil;
}

- (void)tokenizeCard:(BTCard *)card completion:(void (^)(BTCardNonce *tokenizedCard, NSError *error))completion {
    BTCardRequest *request = [[BTCardRequest alloc] initWithCard:card];
    [self tokenizeCard:request options:nil completion:completion];
}


- (void)tokenizeCard:(BTCardRequest *)request options:(NSDictionary *)options completion:(void (^)(BTCardNonce * _Nullable, NSError * _Nullable))completionBlock
{
    if (!self.apiClient) {
        NSError *error = [NSError errorWithDomain:BTCardClientErrorDomain
                                             code:BTCardClientErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"BTCardClient tokenization failed because BTAPIClient is nil."}];
        completionBlock(nil, error);
        return;
    }

    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable error) {
        if (error) {
            completionBlock(nil, error);
            return;
        }

        // Union Pay tokenization requests should not go through the GraphQL API
        if ([self isGraphQLEnabledForCardTokenization:configuration] && !request.enrollmentID) {
            NSDictionary *parameters = [request.card graphQLParameters];
            [self.apiClient POST:@""
                      parameters:parameters
                        httpType:BTAPIClientHTTPTypeGraphQLAPI
                      completion:^(BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, NSError * _Nullable error)
             {
                 if (error) {
                     NSHTTPURLResponse *response = error.userInfo[BTHTTPURLResponseKey];
                     NSError *callbackError = error;

                     if (response.statusCode == 422) {
                             callbackError = [NSError errorWithDomain:BTCardClientErrorDomain
                                                                 code:BTCardClientErrorTypeCustomerInputInvalid
                                                             userInfo:[self.class validationErrorUserInfo:error.userInfo]];
                     }

                     [self sendGraphQLAnalyticsEventWithSuccess:NO];

                     completionBlock(nil, callbackError);
                     return;
                 }

                 BTJSON *cardJSON = body[@"data"][@"tokenizeCreditCard"];
                 [self sendGraphQLAnalyticsEventWithSuccess:YES];

                 BTCardNonce *cardNonce = [BTCardNonce cardNonceWithGraphQLJSON:cardJSON];

                 if (cardNonce && [self isPayPalDataCollectorAvailable] && [configuration collectFraudData]) {
                     [self collectRiskData:cardNonce.nonce configuration:configuration];
                 }

                 completionBlock(cardNonce, cardJSON.asError);
             }];
        } else {
            NSDictionary *parameters = [self clientAPIParametersForCard:request options:options];
            [self.apiClient POST:@"v1/payment_methods/credit_cards"
                      parameters:parameters
                      completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error)
             {
                 if (error != nil) {
                     NSHTTPURLResponse *response = error.userInfo[BTHTTPURLResponseKey];
                     NSError *callbackError = error;

                     if (response.statusCode == 422) {
                         callbackError = [NSError errorWithDomain:BTCardClientErrorDomain
                                                             code:BTCardClientErrorTypeCustomerInputInvalid
                                                         userInfo:[self.class validationErrorUserInfo:error.userInfo]];
                     }

                     if (request.enrollmentID) {
                         [self sendUnionPayAnalyticsEvent:NO];
                     } else {
                         [self sendAnalyticsEventWithSuccess:NO];
                     }

                     completionBlock(nil, callbackError);
                     return;
                 }

                 BTJSON *cardJSON = body[@"creditCards"][0];

                 if (request.enrollmentID) {
                     [self sendUnionPayAnalyticsEvent:!cardJSON.isError];
                 } else {
                     [self sendAnalyticsEventWithSuccess:!cardJSON.isError];
                 }

                 // cardNonceWithJSON returns nil when cardJSON is nil, cardJSON.asError is nil when cardJSON is non-nil
                 BTCardNonce *cardNonce = [BTCardNonce cardNonceWithJSON:cardJSON];

                 if (cardNonce && [self isPayPalDataCollectorAvailable] && [configuration collectFraudData]) {
                     [self collectRiskData:cardNonce.nonce configuration:configuration];
                 }

                 completionBlock(cardNonce, cardJSON.asError);
             }];
        }
    }];
}

#pragma mark - Analytics

- (void)sendAnalyticsEventWithSuccess:(BOOL)success {
    NSString *event = [NSString stringWithFormat:@"ios.%@.card.%@", self.apiClient.metadata.integrationString, success ? @"succeeded" : @"failed"];
    [self.apiClient sendAnalyticsEvent:event];
}

- (void)sendGraphQLAnalyticsEventWithSuccess:(BOOL)success {
    NSString *event = [NSString stringWithFormat:@"ios.card.graphql.tokenization.%@", success ? @"success" : @"failure"];
    [self.apiClient sendAnalyticsEvent:event];
}

- (void)sendUnionPayAnalyticsEvent:(BOOL)success {
    NSString *event = [NSString stringWithFormat:@"ios.%@.unionpay.nonce-%@", self.apiClient.metadata.integrationString, success ? @"received" : @"failed"];
    [self.apiClient sendAnalyticsEvent:event];
}

#pragma mark - Helpers

+ (NSDictionary *)validationErrorUserInfo:(NSDictionary *)userInfo {
    NSMutableDictionary *mutableUserInfo = [userInfo mutableCopy];
    BTJSON *jsonResponse = userInfo[BTHTTPJSONResponseBodyKey];
    if ([jsonResponse asDictionary]) {
        mutableUserInfo[BTCustomerInputBraintreeValidationErrorsKey] = [jsonResponse asDictionary];
        
        BTJSON *fieldError = [[jsonResponse[@"fieldErrors"] asArray] firstObject];
        NSString *errorMessage = [jsonResponse[@"error"][@"message"] asString];
        if (errorMessage) {
            mutableUserInfo[NSLocalizedDescriptionKey] = errorMessage;
        }
        NSString *firstFieldErrorMessage = [fieldError[@"fieldErrors"] firstObject][@"message"];
        if (firstFieldErrorMessage) {
            mutableUserInfo[NSLocalizedFailureReasonErrorKey] = firstFieldErrorMessage;
        }
    }
    return [mutableUserInfo copy];
}

- (NSDictionary *)clientAPIParametersForCard:(BTCardRequest *)request options:(NSDictionary *)options {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    if (request.card.parameters) {
        NSMutableDictionary *mutableCardParameters = [request.card.parameters mutableCopy];

        if (request.enrollmentID) {
            // Convert the immutable options dictionary so to write to it without overwriting any existing options
            NSMutableDictionary *unionPayEnrollment = [NSMutableDictionary new];
            unionPayEnrollment[@"id"] = request.enrollmentID;
            if (request.smsCode) {
                unionPayEnrollment[@"sms_code"] = request.smsCode;
            }
            mutableCardParameters[@"options"] = [mutableCardParameters[@"options"] mutableCopy];
            mutableCardParameters[@"options"][@"union_pay_enrollment"] = unionPayEnrollment;
        }

        parameters[@"credit_card"] = [mutableCardParameters copy];
    }
    parameters[@"_meta"] = @{
                             @"source" : self.apiClient.metadata.sourceString,
                             @"integration" : self.apiClient.metadata.integrationString,
                             @"sessionId" : self.apiClient.metadata.sessionId,
                             };
    if (options) {
        parameters[@"options"] = options;
    }

    return [parameters copy];
}

- (BOOL)isGraphQLEnabledForCardTokenization:(BTConfiguration *)configuration {
    NSArray *graphQLFeatures = [configuration.json[@"graphQL"][@"features"] asArray];

    return graphQLFeatures && [graphQLFeatures containsObject:BTCardClientGraphQLTokenizeFeature];
}

+ (void)setPayPalDataCollectorClassString:(NSString *)payPalDataCollectorClassString {
    PayPalDataCollectorClassString = payPalDataCollectorClassString;
}

+ (void)setPayPalDataCollectorClass:(Class)payPalDataCollectorClass {
    PayPalDataCollectorClass = payPalDataCollectorClass;
}

- (BOOL)isPayPalDataCollectorAvailable {
    Class kPPDataCollector = NSClassFromString(PayPalDataCollectorClassString);
    SEL aSelector = NSSelectorFromString(@"generateClientMetadataIDWithoutBeacon:data:");
    return kPPDataCollector && [kPPDataCollector respondsToSelector:aSelector];
}

- (void)collectRiskData:(NSString *)correlationId configuration:(BTConfiguration *)configuration {
    // Trim to 32 chars to ensure compatibility with PPDataCollector
    NSString *trimmedCorrelationId = [correlationId copy];
    if (trimmedCorrelationId && [trimmedCorrelationId length] > 32) {
        trimmedCorrelationId = [trimmedCorrelationId substringToIndex:32];
    }

    NSMutableDictionary *data = [@{
                           @"mid":[configuration.json[@"merchantId"] asString],
                           @"rda_tenant": @"bt_card"
                           } mutableCopy];

    if (self.apiClient.clientToken != nil) {
        NSString *authorizationFingerprint = self.apiClient.clientToken.authorizationFingerprint;
        NSArray *authorizationComponents = [authorizationFingerprint componentsSeparatedByString:@"&"];
        for (NSString *component in authorizationComponents) {
            if ([component hasPrefix:@"customer_id="]) {
                NSArray *customerIdComponents = [component componentsSeparatedByString:@"="];
                if ([customerIdComponents count] > 1) {
                    data[@"cid"] = [customerIdComponents lastObject];
                }
            }
        }
    }

    Class kPPDataCollector = [self getPPDataCollectorClass];
    SEL aSelector = NSSelectorFromString(@"generateClientMetadataIDWithoutBeacon:data:");
    if(kPPDataCollector != nil && [kPPDataCollector respondsToSelector:aSelector]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[kPPDataCollector methodSignatureForSelector:aSelector]];
        [inv setSelector:aSelector];
        [inv setTarget:kPPDataCollector];

        [inv setArgument:&(trimmedCorrelationId) atIndex:2];
        [inv setArgument:&(data) atIndex:3];
        [inv invoke];
    }
}

- (Class)getPPDataCollectorClass {
    if (PayPalDataCollectorClass != nil) {
        return PayPalDataCollectorClass;
    }
    return NSClassFromString(PayPalDataCollectorClassString);
}

@end
