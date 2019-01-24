#import "BTPaymentFlowDriver+ThreeDSecure.h"
#if __has_include("BTAPIClient_Internal.h")
#import "BTAPIClient_Internal.h"
#else
#import <BraintreeCore/BTAPIClient_Internal.h>
#endif
#import "BTPaymentFlowDriver_Internal.h"
#import "BTPaymentFlowDriver+ThreeDSecure_Internal.h"
#import "BTThreeDSecureResult.h"
#import "BTThreeDSecureRequest.h"
#import "BTThreeDSecurePostalAddress_Internal.h"
#import <CardinalMobile/CardinalMobile.h>

@implementation BTPaymentFlowDriver (ThreeDSecure)

NSString * const BTThreeDSecureFlowErrorDomain = @"com.braintreepayments.BTThreeDSecureFlowErrorDomain";
NSString * const BTThreeDSecureFlowInfoKey = @"com.braintreepayments.BTThreeDSecureFlowInfoKey";
NSString * const BTThreeDSecureFlowValidationErrorsKey = @"com.braintreepayments.BTThreeDSecureFlowValidationErrorsKey";

#pragma mark - ThreeDSecure Lookup

- (void)performThreeDSecureLookup:(BTThreeDSecureRequest *)request
                       completion:(void (^)(BTThreeDSecureLookup *threeDSecureResult, NSError *error))completionBlock
{
    CardinalSession *cardinalSession = [CardinalSession new];
    cardinalSession.stepUpDelegate = self;
    CardinalSessionConfig *config = [CardinalSessionConfig new];
    config.deploymentEnvironment = CardinalSessionEnvironmentStaging;
    config.timeout = CardinalSessionTimeoutStandard;
    config.uiType = CardinalSessionUITypeBoth;

    UiCustomization *ui = [[UiCustomization alloc] init];

    //Toolbar Customization
    ToolbarCustomization *toolbarCustomization = [[ToolbarCustomization alloc] init];
    [toolbarCustomization setHeaderText:@"My Secure Checkout"];
    [toolbarCustomization setBackgroundColor:@"#a5d6a7"];
    [toolbarCustomization setButtonText:@"Close"];
    [toolbarCustomization setTextColor:@"#222222"];
    [toolbarCustomization setTextFontSize:18];
    [toolbarCustomization setTextFontName:@"Noteworthy"];

    [ui setToolbarCustomization:toolbarCustomization];

    //Label Customization
    LabelCustomization *labelCustomization = [[LabelCustomization alloc] init];
    [labelCustomization setTextFontName:@"Noteworthy"];
    [labelCustomization setTextColor:@"#75a478"];
    [labelCustomization setTextFontSize:18];
    [labelCustomization setHeadingTextColor:@"#75a478"];
    [labelCustomization setHeadingTextFontName:@"Noteworthy"];
    [labelCustomization setHeadingTextFontSize:24];

    [ui setLabelCustomization:labelCustomization];

    //Verify Button Customization
    ButtonCustomization *verifyCustomization = [[ButtonCustomization alloc] init];
    [verifyCustomization setBackgroundColor:@"#a5d6a7"];
    [verifyCustomization setCornerRadius:10];
    [verifyCustomization setTextFontName:@"Noteworthy"];
    [verifyCustomization setTextColor:@"#222222"];
    [verifyCustomization setTextFontSize:12];

    [ui setButtonCustomization:verifyCustomization buttonType:ButtonTypeVerify];

    //Continue Button Customization
    ButtonCustomization *continueCustomization = [[ButtonCustomization alloc] init];
    [continueCustomization setBackgroundColor:@"#FF0000"];
    [continueCustomization setCornerRadius:10];
    [continueCustomization setTextFontName:@"Noteworthy"];
    [continueCustomization setTextColor:@"#FFFFFF"];
    [continueCustomization setTextFontSize:16];

    [ui setButtonCustomization:continueCustomization buttonType:ButtonTypeContinue];

    //Resend Button Customization
    ButtonCustomization *resendCustomization = [[ButtonCustomization alloc] init];
    [resendCustomization setBackgroundColor:@"#d7ffd9"];
    [resendCustomization setCornerRadius:10];
    [resendCustomization setTextFontName:@"Noteworthy"];
    [resendCustomization setTextColor:@"#000000"];
    [resendCustomization setTextFontSize:12];

    [ui setButtonCustomization:resendCustomization buttonType:ButtonTypeResend];

    //Cancel Button Customization
    ButtonCustomization *cancelCustomization = [[ButtonCustomization alloc] init];
    [cancelCustomization setBackgroundColor:@"#d7ffd9"];
    [cancelCustomization setCornerRadius:4];
    [cancelCustomization setTextFontName:@"Noteworthy"];
    [cancelCustomization setTextColor:@"#222222"];
    [cancelCustomization setTextFontSize:16];

    [ui setButtonCustomization:cancelCustomization buttonType:ButtonTypeCancel];

    //TextBox Customization
    TextBoxCustomization *textboxCustomization = [[TextBoxCustomization alloc] init];
    [textboxCustomization setTextFontName:@"Noteworthy"];
    [textboxCustomization setTextColor:@"#8808af"];
    [textboxCustomization setTextFontSize:12];
    [textboxCustomization setBorderWidth:2];
    [textboxCustomization setBorderColor:@"#8808af"];
    [textboxCustomization setCornerRadius:4];

    [ui setTextBoxCustomization:textboxCustomization];

    //Set UICustomizations to Configuration
    config.uiCustomization = ui;
//    UiCustomization *yourCustomUi = [[UiCustomization alloc] init];
//    //Set various customizations here. See "iOS UI Customization" documentation for detail.
//    config.uiCustomization = yourCustomUi;
//
//    CardinalSessionRenderTypeArray *renderType = [[CardinalSessionRenderTypeArray alloc] initWithObjects:
//                                                  CardinalSessionRenderTypeOTP,
//                                                  CardinalSessionRenderTypeHTML,
//                                                  nil];
//    config.renderType = renderType;

    config.enableQuickAuth = false;
    [cardinalSession configure:config];

    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration *configuration, NSError *error) {
        if (error) {
            completionBlock(nil, error);
            return;
        }

        NSString *jwtString = [configuration.json[@"threeDSecure"][@"cardinalAuthenticationJWT"] asString];

        [cardinalSession setupWithJWT:jwtString accountNumber:@"4000000000001000" didComplete:^(NSString * _Nonnull consumerSessionId) {
            NSMutableDictionary *customer = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *requestParameters = [@{ @"amount": request.amount, @"customer": customer, @"df_reference_id": consumerSessionId } mutableCopy];

            if (request.billingAddress) {
                customer[@"billingAddress"] = [request.billingAddress asParameters];
            }

            if (request.mobilePhoneNumber) {
                customer[@"mobilePhoneNumber"] = request.mobilePhoneNumber;
            }

            if (request.email) {
                customer[@"email"] = request.email;
            }

            if (request.shippingMethod) {
                customer[@"shippingMethod"] = request.shippingMethod;
            }

            // TODO: remove hardcoded values
            requestParameters[@"additionalInformation"] = @{
                                                            @"billingGivenName": @"Jill",
                                                            @"billingSurname": @"Doe",
                                                            @"billingPhoneNumber": @"8101234567",
                                                            @"billingAddress": @{
                                                                    @"streetAddress": @"555 Smith St.",
                                                                    //@"extendedAddress": @"#5", // When available
                                                                    @"locality": @"Oakland",
                                                                    @"region": @"CA",
                                                                    @"postalCode": @"12345",
                                                                    @"countryCodeAlpha2": @"US"
                                                                    },
                                                            @"email": @"david@getbraintree.com"
                                                            };

            NSString *urlSafeNonce = [request.nonce stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [self.apiClient POST:[NSString stringWithFormat:@"v1/payment_methods/%@/three_d_secure/lookup", urlSafeNonce]
                      parameters:requestParameters
                      completion:^(BTJSON *body, __unused NSHTTPURLResponse *response, NSError *error) {

                          if (error) {
                              // Provide more context for card validation error when status code 422
                              if ([error.domain isEqualToString:BTHTTPErrorDomain] &&
                                  error.code == BTHTTPErrorCodeClientError &&
                                  ((NSHTTPURLResponse *)error.userInfo[BTHTTPURLResponseKey]).statusCode == 422) {

                                  NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
                                  BTJSON *errorBody = error.userInfo[BTHTTPJSONResponseBodyKey];

                                  if ([errorBody[@"error"][@"message"] isString]) {
                                      userInfo[NSLocalizedDescriptionKey] = [errorBody[@"error"][@"message"] asString];
                                  }
                                  if ([errorBody[@"threeDSecureFlowInfo"] isObject]) {
                                      userInfo[BTThreeDSecureFlowInfoKey] = [errorBody[@"threeDSecureFlowInfo"] asDictionary];
                                  }
                                  if ([errorBody[@"error"] isObject]) {
                                      userInfo[BTThreeDSecureFlowValidationErrorsKey] = [errorBody[@"error"] asDictionary];
                                  }

                                  error = [NSError errorWithDomain:BTThreeDSecureFlowErrorDomain
                                                              code:BTThreeDSecureFlowErrorTypeFailedLookup
                                                          userInfo:userInfo];
                              }

                              completionBlock(nil, error);
                              return;
                          }

                          BTJSON *lookupJSON = body[@"lookup"];

                          BTThreeDSecureLookup *lookup = [[BTThreeDSecureLookup alloc] init];
                          lookup.acsURL = [lookupJSON[@"acsUrl"] asURL];
                          lookup.PAReq = [lookupJSON[@"pareq"] asString];
                          lookup.MD = [lookupJSON[@"md"] asString];
                          lookup.termURL = [lookupJSON[@"termUrl"] asURL];
                          lookup.threeDSecureResult = [[BTThreeDSecureResult alloc] initWithJSON:body];

                          completionBlock(lookup, nil);
                      }];
        } didValidate:^(CardinalResponse * _Nonnull validateResponse) {
            //error fallback?
            NSLog(@"%@", validateResponse);
            // TODO Handle cases
        }];
    }];
}

- (void)cardinalSession:(__unused CardinalSession *)session
stepUpDataDidBecomeReady:(CardinalStepUpData *)stepUpData {
    NSLog(@"%@", stepUpData);
}

- (void)cardinalSession:(__unused CardinalSession *)session
    stepUpDataDidUpdate:(CardinalStepUpData *)stepUpData {
    NSLog(@"%@", stepUpData);
}

-(void)cardinalSession:(__unused CardinalSession *)session stepUpDidValidateWithResponse:(CardinalResponse *)validateResponse serverJWT:(__unused NSString *)serverJWT{
    switch (validateResponse.actionCode) {
        case CardinalResponseActionCodeSuccess:
            // Handle successful transaction, send JWT to backend to verify
            break;

        case CardinalResponseActionCodeNoAction:
            // Handle no actionable outcome
            break;

        case CardinalResponseActionCodeFailure:
            // Handle failed transaction attempt
            break;

        case CardinalResponseActionCodeError:
            // Handle service level error
            break;
        default:

            break;
//        case CardinalResponseActionCodeCancel:
//            // Handle transaction canceled by user
//            break
//
//        case CardinalResponseActionCodeUnknown:
//            // Handle unknown error
//            break;
    }
}

@end

