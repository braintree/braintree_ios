#import "BTErrors.h"
#import "BTPaymentMethodNonceParser.h"
#import "BTTokenizationService.h"
#import "BTCardClient_Internal.h"
#import "BTCardNonce_Internal.h"
#import "BTCardTokenizationRequest_Internal.h"
#import "BTHTTP.h"
#import "BTJSON.h"
#import "BTClientMetadata.h"
#if __has_include("BraintreeCore.h")
#import "BTAPIClient_Internal.h"
#import "BTCard_Internal.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <BraintreeCore/BTCard_Internal.h>
#endif

NSString *const BTCardClientErrorDomain = @"com.braintreepayments.BTCardClientErrorDomain";

@interface BTCardClient ()
@end

@implementation BTCardClient

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
    BTCardTokenizationRequest *request = [[BTCardTokenizationRequest alloc] initWithCard:card];
    [self tokenizeCard:request options:nil completion:completion];
}


- (void)tokenizeCard:(BTCardTokenizationRequest *)request options:(NSDictionary *)options completion:(void (^)(BTCardNonce * _Nullable, NSError * _Nullable))completionBlock
{
    if (!self.apiClient) {
        NSError *error = [NSError errorWithDomain:BTCardClientErrorDomain
                                             code:BTCardClientErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"BTCardClient tokenization failed because BTAPIClient is nil."}];
        completionBlock(nil, error);
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    if (request.card.parameters) {
        parameters[@"credit_card"] = request.card.parameters;
    }
    parameters[@"_meta"] = @{
                             @"source" : self.apiClient.metadata.sourceString,
                             @"integration" : self.apiClient.metadata.integrationString,
                             @"sessionId" : self.apiClient.metadata.sessionId,
                             };
    if (options) {
        if (!parameters[@"options"]) {
            parameters[@"options"] = options;
        } else {
            NSMutableDictionary *mutableOptions = [options mutableCopy];
            [mutableOptions addEntriesFromDictionary:parameters[@"options"]];
            parameters[@"options"] = mutableOptions;
        }
    }
    if (request.enrollmentAuthCode && request.enrollmentID) {
        NSDictionary *enrollmentDictionary = @{
                                               @"sms_code": request.enrollmentAuthCode,
                                               @"id": request.enrollmentID
                                               };
        if (!parameters[@"options"]) {
            parameters[@"options"] = enrollmentDictionary;
        } else {
            NSMutableDictionary *mutableOptions = [parameters[@"options"] mutableCopy];
            [mutableOptions addEntriesFromDictionary:enrollmentDictionary];
            parameters[@"options"] = mutableOptions;
        }
    }

    [self.apiClient POST:@"v1/payment_methods/credit_cards"
              parameters:parameters
              completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error)
     {
         if (error != nil) {
             
             NSHTTPURLResponse *response = error.userInfo[BTHTTPURLResponseKey];
             if (response.statusCode == 422) {
                 BTJSON *jsonResponse = error.userInfo[BTHTTPJSONResponseBodyKey];
                 NSDictionary *userInfo = jsonResponse.asDictionary ? @{ BTCustomerInputBraintreeValidationErrorsKey : jsonResponse.asDictionary } : @{};
                 NSError *validationError = [NSError errorWithDomain:BTCardClientErrorDomain
                                                                code:BTErrorCustomerInputInvalid
                                                            userInfo:userInfo];
                 completionBlock(nil, validationError);
             } else {
                 completionBlock(nil, error);
             }
             [self sendAnalyticsEventWithSuccess:NO];
             return;
         }
         
         BTJSON *creditCard = body[@"creditCards"][0];
         if (creditCard.isError) {
             completionBlock(nil, creditCard.asError);
             [self sendAnalyticsEventWithSuccess:NO];
         } else {
             completionBlock([BTCardNonce cardNonceWithJSON:creditCard], nil);
             [self sendAnalyticsEventWithSuccess:YES];
         }
     }];
}

#pragma mark - Analytics

- (void)sendAnalyticsEventWithSuccess:(BOOL)success {
    BOOL isDropIn = self.apiClient.metadata.source == BTClientMetadataIntegrationDropIn;
    if (success) {
        [self.apiClient sendAnalyticsEvent:(isDropIn ? @"ios.dropin.card.failed" : @"ios.custom.card.failed")];
    } else {
        [self.apiClient sendAnalyticsEvent:(isDropIn ? @"ios.dropin.card.succeeded" : @"ios.custom.card.succeeded")];
    }
}

@end
