#import "BTClient.h"

@class PayPalProfileSharingViewController;
@class PayPalConfiguration;

@protocol PayPalProfileSharingDelegate;

extern NSString *const BTClientPayPalMobileEnvironmentName;

/// Specify this additional scope in order to get the customer's billing address.
/// If this scope is set, the billingAddress property of the returned BTPayPalPaymentMethod should be populated with a BTPostalAddress.
extern NSString *const BTPayPalScopeAddress;

@interface BTClient (BTPayPal)

+ (NSString *)btPayPal_offlineTestClientToken;
- (BOOL)btPayPal_preparePayPalMobileWithError:(NSError * __autoreleasing *)error;
- (BOOL)btPayPal_isPayPalEnabled;
- (PayPalProfileSharingViewController *)btPayPal_profileSharingViewControllerWithDelegate:(id<PayPalProfileSharingDelegate>)delegate;
- (NSString *)btPayPal_applicationCorrelationId;
- (PayPalConfiguration *)btPayPal_configuration;
- (NSString *)btPayPal_environment;
- (BOOL)btPayPal_isTouchDisabled;
- (NSSet *)btPayPal_scopes;
@end
