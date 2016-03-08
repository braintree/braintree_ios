#import "BTErrors.h"
#import "BTPaymentMethodNonceParser.h"
#import "BTTokenizationService.h"
#import "BTCardClient_Internal.h"
#import "BTCardNonce_Internal.h"
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
            if (options[@"phone_number"]) {
                NSMutableDictionary *mutableOptions = [options mutableCopy];
                [mutableOptions removeObjectForKey:@"authCodeChallengeBlock"];
                [mutableOptions removeObjectForKey:@"phone_number"];
                BTCard *card = [[BTCard alloc] initWithParameters:mutableOptions];
                [client tokenizeCard:card phoneNumber:options[@"phone_number"] authCodeChallenge:options[@"authCodeChallengeBlock"] completion:completionBlock];
            } else {
                BTCard *card = [[BTCard alloc] initWithParameters:options];
                [client tokenizeCard:card completion:completionBlock];
            }
        }];

        [[BTPaymentMethodNonceParser sharedParser] registerType:@"CreditCard" withParsingBlock:^BTPaymentMethodNonce * _Nullable(BTJSON * _Nonnull creditCard) {
            return [BTCardNonce cardNonceWithJSON:creditCard];
        }];
    }
}

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient {
    if (self = [super init]) {
        self.apiClient = apiClient;
    }
    return self;
}

- (instancetype)init {
    return nil;
}

- (void)tokenizeCard:(BTCard *)card completion:(void (^)(BTCardNonce *tokenizedCard, NSError *error))completionBlock {
    [self tokenizeCard:card options:nil completion:completionBlock];
}

- (void)tokenizeCard:(BTCard *)card
         phoneNumber:(NSString *)phoneNumber
   authCodeChallenge:(void (^)(void (^ _Nonnull)(NSString * _Nullable)))challenge
          completion:(void (^)(BTCardNonce * _Nullable, NSError * _Nullable))completionBlock
{
    if (!self.apiClient) {
        NSError *error = [NSError errorWithDomain:BTCardClientErrorDomain
                                             code:BTCardClientErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"BTCardClient tokenization failed because BTAPIClient is nil."}];
        completionBlock(nil, error);
        return;
    }
    
    if (true) {     // TODO: Check if it's Union Pay
        NSMutableDictionary *enrollmentParameters = [NSMutableDictionary dictionary];
        if (card.number) {
            enrollmentParameters[@"number"] = card.number;
        }
        if (card.expirationMonth) {
            enrollmentParameters[@"expiration_month"] = card.expirationMonth;
        }
        if (card.expirationYear) {
            enrollmentParameters[@"expiration_year"] = card.expirationYear;
        }
        enrollmentParameters[@"mobile_country_code"] = @"1";
        if (phoneNumber) {
            enrollmentParameters[@"mobile_number"] = phoneNumber;
        }
        

        // TODO: Should we check if there's a phone number and error immediately if not, or should
        // we allow this to be handled downstream by the gateway?
        
        [self.apiClient POST:@"v1/union_pay_enrollments" // TODO: enrollment API endpoint
                  parameters:@{ @"union_pay_enrollment": enrollmentParameters }
                  completion:^(BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, NSError * _Nullable error)
         {
             if (error) {
                 completionBlock(nil, [self validationErrorOrError:error]);
                 return;
             }

             // Get the Union Pay enrollment ID
             NSString *enrollmentID = [body[@"unionPayEnrollmentId"] asString];
             
             challenge(^(NSString *authCode) {
                 NSMutableDictionary *unionPayEnrollment = [NSMutableDictionary dictionary];
                 if (authCode) {
                     unionPayEnrollment[@"sms_code"] = authCode;
                 }
                 if (enrollmentID) {
                     unionPayEnrollment[@"id"] = enrollmentID;
                 }
                 [self tokenizeCard:card options:unionPayEnrollment completion:completionBlock];
             });
        }];
    }
}

- (void)tokenizeCard:(BTCard *)card options:(NSDictionary *)options completion:(void (^)(BTCardNonce * _Nullable, NSError * _Nullable))completionBlock
{
    if (!self.apiClient) {
        NSError *error = [NSError errorWithDomain:BTCardClientErrorDomain
                                             code:BTCardClientErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"BTCardClient tokenization failed because BTAPIClient is nil."}];
        completionBlock(nil, error);
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"credit_card"] = card.parameters;
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
    
    [self.apiClient POST:@"v1/payment_methods/credit_cards"
              parameters:parameters
              completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error)
     {
         if (error != nil) {
             completionBlock(nil, [self validationErrorOrError:error]);
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

/// Returns a validation error if the error is a 422, otherwise it just passes back the original error
- (NSError *)validationErrorOrError:(NSError *)error {
    NSHTTPURLResponse *response = error.userInfo[BTHTTPURLResponseKey];
    if (response.statusCode == 422) {
        BTJSON *jsonResponse = error.userInfo[BTHTTPJSONResponseBodyKey];
        NSDictionary *userInfo = jsonResponse.asDictionary ? @{ BTCustomerInputBraintreeValidationErrorsKey : jsonResponse.asDictionary } : @{};
        NSError *validationError = [NSError errorWithDomain:BTCardClientErrorDomain
                                                       code:BTErrorCustomerInputInvalid
                                                   userInfo:userInfo];
        return validationError;
    }
    return error;
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
