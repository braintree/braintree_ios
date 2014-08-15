#import "BTClient.h"

@class PayPalFuturePaymentViewController;
@class PayPalConfiguration;

@protocol PayPalFuturePaymentDelegate;

extern NSString *const BTClientPayPalMobileEnvironmentName;

@interface BTClient (BTPayPal)

+ (NSString *)btPayPal_offlineTestClientToken;
- (BOOL)btPayPal_preparePayPalMobileWithError:(NSError * __autoreleasing *)error;
- (BOOL)btPayPal_isPayPalEnabled;
- (PayPalFuturePaymentViewController *)btPayPal_futurePaymentFutureControllerWithDelegate:(id<PayPalFuturePaymentDelegate>)delegate;
- (NSString *)btPayPal_applicationCorrelationId;
- (PayPalConfiguration *)btPayPal_configuration;
- (NSString *)btPayPal_environment;
- (BOOL)btPayPal_isTouchDisabled;
@end
