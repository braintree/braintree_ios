#import "BTCardClient+UnionPay.h"
#import "BTCardClient_Internal.h"
#if __has_include("BraintreeCore.h")
#import "BTAPIClient_Internal.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#endif

@implementation BTCardClient (UnionPay)

+ (void)load {
    if (self == [BTCardClient class]) {
        [[BTTokenizationService sharedService] registerType:@"UnionPayCard" withTokenizationBlock:^(BTAPIClient * _Nonnull apiClient, NSDictionary * _Nullable options, void (^completionBlock)(BTPaymentMethodNonce *paymentMethodNonce, NSError *error)) {
            BTCard *card = [[BTCard alloc] initWithParameters:options];
            BTCardTokenizationRequest *request = [[BTCardTokenizationRequest alloc] initWithCard:card];
            request.mobilePhoneNumber = options[@"mobilePhoneNumber"];
            request.mobileCountryCode = options[@"mobileCountryCode"];
            
            BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
            [client tokenizeCard:request authCodeChallenge:options[@"authCodeChallenge"] completion:completionBlock];
        }];
    }
}

- (void)tokenizeCard:(BTCardTokenizationRequest *)request
   authCodeChallenge:(void (^)(void (^ _Nonnull)(NSString * _Nullable)))challenge
          completion:(void (^)(BTCardNonce * _Nullable, NSError * _Nullable))completion
{
    if (!self.apiClient) {
        NSError *error = [NSError errorWithDomain:BTCardClientErrorDomain
                                             code:BTCardClientErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"BTCardClient tokenization failed because BTAPIClient is nil."}];
        completion(nil, error);
        return;
    }
    if (self.apiClient.tokenizationKey) {
        NSError *error = [NSError errorWithDomain:BTCardClientErrorDomain
                                             code:BTCardClientErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"Cannot use tokenization key with tokenizeCard:authCodeChallenge:completion:",
                                                    NSLocalizedRecoverySuggestionErrorKey: @"Use a client token to initialize BTAPIClient"}];
        completion(nil, error);
        return;
    }
    if (!request.card) {
        NSError *error = [NSError errorWithDomain:BTCardClientErrorDomain
                                             code:BTCardClientErrorTypeIntegration
                                         userInfo:@{NSLocalizedDescriptionKey: @"BTCardClient tokenization failed because the request did not have a card."}];
        completion(nil, error);
        return;
    }
    
    NSMutableDictionary *enrollmentParameters = [NSMutableDictionary dictionary];
    BTCard *card = request.card;
    if (card.number) {
        enrollmentParameters[@"number"] = card.number;
    }
    if (card.expirationMonth) {
        enrollmentParameters[@"expiration_month"] = card.expirationMonth;
    }
    if (card.expirationYear) {
        enrollmentParameters[@"expiration_year"] = card.expirationYear;
    }
    if (request.mobileCountryCode) {
        enrollmentParameters[@"mobile_country_code"] = request.mobileCountryCode;
    }
    if (request.mobilePhoneNumber) {
        enrollmentParameters[@"mobile_number"] = request.mobilePhoneNumber;
    }
    
    [self.apiClient POST:@"v1/union_pay_enrollments" // TODO: enrollment API endpoint
              parameters:@{ @"union_pay_enrollment": enrollmentParameters }
              completion:^(BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, NSError * _Nullable error)
     {
         if (error) {
             NSHTTPURLResponse *response = error.userInfo[BTHTTPURLResponseKey];
             if (response.statusCode == 422) {
                 BTJSON *jsonResponse = error.userInfo[BTHTTPJSONResponseBodyKey];
                 NSDictionary *userInfo = jsonResponse.asDictionary ? @{ BTCustomerInputBraintreeValidationErrorsKey : jsonResponse.asDictionary } : @{};
                 NSError *validationError = [NSError errorWithDomain:BTCardClientErrorDomain
                                                                code:BTErrorCustomerInputInvalid
                                                            userInfo:userInfo];
                 completion(nil, validationError);
             } else {
                 completion(nil, error);
             }
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
             [self tokenizeCard:card options:unionPayEnrollment completion:completion];
         });
     }];
}

@end
