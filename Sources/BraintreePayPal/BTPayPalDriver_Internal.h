#import <BraintreePayPal/BTPayPalDriver.h>

@class BTPayPalCreditFinancing;
@class BTPayPalCreditFinancingAmount;
@class BTJSON;
@class SFAuthenticationSession;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BTPayPalPaymentType) {
    BTPayPalPaymentTypeCheckout,
    BTPayPalPaymentTypeBillingAgreement
};

@interface BTPayPalDriver ()

/**
 Exposed for testing to provide a convenient way to inject custom return URL schemes
*/
@property (nonatomic, copy) NSString *returnURLScheme;

/**
 Exposed for testing the approvalURL construction
*/
@property (nonatomic, strong) NSURL *approvalUrl;

/**
 Exposed for testing to get the instance of BTAPIClient after it has been copied by `copyWithSource:integration:`
*/
@property (nonatomic, strong, nullable) BTAPIClient *apiClient;

/**
 Exposed for testing the clientMetadataId associated with this request
*/
@property (nonatomic, strong) NSString *clientMetadataId;

/**
 Exposed for testing the intent associated with this request
*/
@property (nonatomic, strong) BTPayPalRequest *payPalRequest;

/**
 Exposed for testing, the safariAuthenticationSession instance used for the PayPal flow
 */
@property (nonatomic, strong, nullable) SFAuthenticationSession *safariAuthenticationSession;

/**
 Exposed for testing, for determining if SFAuthenticationSession was started
 */
@property (nonatomic, assign) BOOL isSFAuthenticationSessionStarted;

+ (nullable BTPayPalCreditFinancingAmount *)creditFinancingAmountFromJSON:(BTJSON *)amountJSON;

+ (nullable BTPayPalCreditFinancing *)creditFinancingFromJSON:(BTJSON *)creditFinancingOfferedJSON;

/**
 Exposed for testing the flow after the customer has authorized the payment in the browser
 */
- (void)handleBrowserSwitchReturnURL:(NSURL *)url paymentType:(BTPayPalPaymentType)paymentType completion:(void (^)(BTPayPalAccountNonce * _Nullable tokenizedCheckout, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
