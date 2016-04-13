#import "BTCardClient+UnionPay.h"
#import "BTCardCapabilities.h"
#if __has_include("BraintreeCore.h")
#import "BTAPIClient_Internal.h"
#import "BTCardClient_Internal.h"
#import "BTCardTokenizationRequest_Internal.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#import <BraintreeCard/BTCardClient_Internal.h>
#import <BraintreeCard/BTCardTokenizationRequest_Internal.h>
#endif

@implementation BTCardClient (UnionPay)

+ (void)load {
    if (self == [BTCardClient class]) {
        [[BTTokenizationService sharedService] registerType:@"UnionPayCard" withTokenizationBlock:^(BTAPIClient * _Nonnull apiClient, NSDictionary * _Nullable options, void (^completion)(BTPaymentMethodNonce *paymentMethodNonce, NSError *error)) {
            BTCardClient *client = [[BTCardClient alloc] initWithAPIClient:apiClient];
            BTCard *card = [[BTCard alloc] initWithParameters:options];
            BTCardTokenizationRequest *request = [[BTCardTokenizationRequest alloc] initWithCard:card];
            request.mobileCountryCode = options[@"mobileCountryCode"];
            request.enrollmentAuthCode = options[@"enrollmentAuthCode"];

            [client tokenizeCard:request options:nil completion:completion];
        }];
    }
}

#pragma mark - Public methods

- (void)fetchCapabilities:(NSString *)cardNumber
               completion:(void (^)(BTCardCapabilities * _Nullable, NSError * _Nullable))completion
{
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        BOOL isUnionPayEnabled = [configuration.json[@"unionPay"][@"enabled"] isTrue];
        if (!isUnionPayEnabled) {
            NSError *error = [NSError errorWithDomain:BTCardClientErrorDomain code:BTCardClientErrorTypePaymentOptionNotEnabled userInfo:@{NSLocalizedDescriptionKey: @"UnionPay is not enabled for this merchant"}];
            completion(nil, error);
            return;
        }
        
        [self.apiClient GET:@"v1/payment_methods/credit_cards/capabilities"
                 parameters:@{@"credit_card[number]" : cardNumber}
                 completion:^(BTJSON * _Nullable body, __unused NSHTTPURLResponse * _Nullable response, NSError * _Nullable error)
         {
             if (error) {
                 [self sendUnionPayEvent:@"capabilities-failed"];
                 completion(nil, error);
             } else {
                 [self sendUnionPayEvent:@"capabilities-received"];

                 BTCardCapabilities *cardCapabilities = [[BTCardCapabilities alloc] init];
                 cardCapabilities.isUnionPay = [body[@"isUnionPay"] isTrue];
                 cardCapabilities.isDebit = [body[@"isDebit"] isTrue];
                 cardCapabilities.supportsTwoStepAuthAndCapture = [body[@"unionPay"][@"supportsTwoStepAuthAndCapture"] isTrue];
                 cardCapabilities.isUnionPayEnrollmentRequired = [body[@"unionPay"][@"isUnionPayEnrollmentRequired"] isTrue];
                 completion(cardCapabilities, nil);
             }
         }];
    }];
}

- (void)enrollCard:(BTCardTokenizationRequest *)request
        completion:(void (^)(NSError * _Nullable))completion
{
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable error) {
        if (error) {
            completion(error);
            return;
        }
        
        BOOL isUnionPayEnabled = [configuration.json[@"unionPay"][@"enabled"] isTrue];
        if (!isUnionPayEnabled) {
            NSError *error = [NSError errorWithDomain:BTCardClientErrorDomain code:BTCardClientErrorTypePaymentOptionNotEnabled userInfo:@{NSLocalizedDescriptionKey: @"UnionPay is not enabled for this merchant"}];
            completion(error);
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
                 [self sendUnionPayEvent:@"enrollment-failed"];

                 NSHTTPURLResponse *response = error.userInfo[BTHTTPURLResponseKey];
                 if (response.statusCode == 422) {
                     BTJSON *jsonResponse = error.userInfo[BTHTTPJSONResponseBodyKey];
                     NSDictionary *userInfo = [jsonResponse asDictionary] ? @{ BTCustomerInputBraintreeValidationErrorsKey : [jsonResponse asDictionary] } : @{};
                     NSError *validationError = [NSError errorWithDomain:BTCardClientErrorDomain
                                                                    code:BTErrorCustomerInputInvalid
                                                                userInfo:userInfo];
                     [self invokeBlock:completion onMainThreadWithError:validationError];
                 } else {
                     [self invokeBlock:completion onMainThreadWithError:error];
                 }
                 return;
             }

             [self sendUnionPayEvent:@"enrollment-succeeded"];
             request.enrollmentID = [body[@"unionPayEnrollmentId"] asString];
             [self invokeBlock:completion onMainThreadWithError:nil];
         }];
    }];
}

#pragma mark - Helper methods

- (void)invokeBlock:(nonnull void (^)(NSError * _Nullable))completion onMainThreadWithError:(nullable NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(error);
    });
}

- (void)sendUnionPayEvent:(nonnull NSString *)event {
    NSString *fullEvent = [NSString stringWithFormat:@"ios.%@.unionpay.%@", self.apiClient.metadata.integrationString, event];
    [self.apiClient sendAnalyticsEvent:fullEvent];
}

@end
