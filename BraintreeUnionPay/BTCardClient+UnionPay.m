#import "BTCardClient+UnionPay.h"
#import "BTCardCapabilities.h"
#import "BTUnionPayRequest_Internal.h"
#if __has_include("BraintreeCore.h")
#import "BTAPIClient_Internal.h"
#import "BTCardClient_Internal.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <BraintreeCard/BTCardClient_Internal.h>
#endif

@implementation BTCardClient (UnionPay)

+ (void)load {
    if (self == [BTCardClient class]) {
        [[BTTokenizationService sharedService] registerType:@"UnionPayCard" withTokenizationBlock:^(BTAPIClient * _Nonnull apiClient, NSDictionary * _Nullable options, void (^completion)(BTPaymentMethodNonce *paymentMethodNonce, NSError *error)) {
            BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
            BTCard *card = [[BTCard alloc] initWithParameters:options];
            BTUnionPayRequest *request = [[BTUnionPayRequest alloc] initWithCard:card mobilePhoneNumber: options[@"mobilePhoneNumber"]];
            request.mobileCountryCode = options[@"mobileCountryCode"];
            request.enrollmentAuthCode = options[@"authCodeChallenge"];
            
            [client tokenizeUnionPayCard:request options:nil completion:completion];
        }];
    }
}

#pragma mark - Public methods

- (void)fetchCapabilities:(NSString *)cardNumber
               completion:(void (^)(BTCardCapabilities * _Nullable, NSError * _Nullable))completion
{
    [self.apiClient GET:@"v1/credit_cards/capabilities" parameters:@{@"number": cardNumber} completion:^(BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, NSError * _Nullable error) {

        if (error) {
            completion(nil, error);
        } else {
            BTCardCapabilities *cardCapabilities = [[BTCardCapabilities alloc] init]; // new BTCardCapabilities()
            cardCapabilities.isUnionPay = [body[@"isUnionPay"] isTrue];
            cardCapabilities.isDebit = [body[@"isDebit"] isTrue];
            cardCapabilities.supportsTwoStepAuthAndCapture = [body[@"unionPay"][@"supportsTwoStepAuthAndCapture"] isTrue];
            cardCapabilities.isUnionPayEnrollmentRequired = [body[@"unionPay"][@"isUnionPayEnrollmentRequired"] isTrue];
            completion(cardCapabilities, nil);
        }
    }];
}

- (void)enrollUnionPayCard:(BTUnionPayRequest *)request
                completion:(void (^)(NSString * _Nullable, NSError * _Nullable))completion
{
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
    if (card.cvv) {
        enrollmentParameters[@"cvv"] = card.cvv;
    }
    if (request.mobileCountryCode) {
        enrollmentParameters[@"mobile_country_code"] = request.mobileCountryCode;
    }
    if (request.mobilePhoneNumber) {
        enrollmentParameters[@"mobile_number"] = request.mobilePhoneNumber;
    }
    
    [self.apiClient POST:@"v1/union_pay_enrollments"
              parameters:@{ @"union_pay_enrollment": enrollmentParameters }
              completion:^(BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, NSError * _Nullable error)
     {
         if (error) {
             NSHTTPURLResponse *response = error.userInfo[BTHTTPURLResponseKey];
             if (response.statusCode == 422) {
                 BTJSON *jsonResponse = error.userInfo[BTHTTPJSONResponseBodyKey];
                 NSDictionary *userInfo = [jsonResponse asDictionary] ? @{ BTCustomerInputBraintreeValidationErrorsKey : [jsonResponse asDictionary] } : @{};
                 NSError *validationError = [NSError errorWithDomain:BTCardClientErrorDomain
                                                                code:BTErrorCustomerInputInvalid
                                                            userInfo:userInfo];
                 completion(nil, validationError);
             } else {
                 completion(nil, error);
             }
             return;
         }
        
         completion([body[@"unionPayEnrollmentId"] asString], nil);
     }];
}

- (void)tokenizeUnionPayCard:(BTUnionPayRequest *)request
                     options:(NSDictionary *)options
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
                                         userInfo:@{NSLocalizedDescriptionKey: @"Cannot use tokenization key with tokenizeUnionPayCard:options:completion:",
                                                    NSLocalizedRecoverySuggestionErrorKey: @"Use a client token to authorize BTAPIClient"}];
        completion(nil, error);
        return;
    }
    
    NSMutableDictionary *mutableOptions = options ? [options mutableCopy] : [NSMutableDictionary dictionary];

    if (request.enrollmentAuthCode) {
        mutableOptions[@"sms_code"] = request.enrollmentAuthCode;
    }
    if (request.enrollmentID) {
        mutableOptions[@"id"] = request.enrollmentID;
    }
   
    [self tokenizeCard:request.card options:mutableOptions completion:completion];
}

@end
