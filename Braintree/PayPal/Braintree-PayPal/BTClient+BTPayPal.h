#import "BTClient.h"

@class PayPalFuturePaymentViewController;
@protocol PayPalFuturePaymentDelegate;

@interface BTClient (BTPayPal)

+ (NSString *)btPayPal_offlineTestClientToken;
- (void)btPayPal_preparePayPalMobileWithError:(NSError * __autoreleasing *)error;
- (BOOL)btPayPal_isPayPalEnabled;
- (PayPalFuturePaymentViewController *)btPayPal_futurePaymentFutureControllerWithDelegate:(id<PayPalFuturePaymentDelegate>)delegate;
- (NSString *)btPayPal_applicationCorrelationId;

@end
