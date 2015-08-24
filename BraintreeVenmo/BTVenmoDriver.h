#import "BraintreeCore.h"
#import "BTVenmoTokenizedCard.h"
#import <Foundation/Foundation.h>

BT_ASSUME_NONNULL_BEGIN

extern NSString * const BTVenmoDriverErrorDomain;

typedef NS_ENUM(NSInteger, BTVenmoDriverErrorType) {
    BTVenmoDriverErrorTypeUnknown = 0,
    /// Venmo is disabled in configuration
    BTVenmoDriverErrorTypeDisabled,
    /// App is not installed on device
    BTVenmoDriverErrorTypeAppNotAvailable,
    /// Bundle display name must be present
    BTVenmoDriverErrorTypeBundleDisplayNameMissing,
    /// UIApplication failed to switch to Venmo app
    BTVenmoDriverErrorTypeAppSwitchFailed,
    /// Return URL was invalid
    BTVenmoDriverErrorTypeInvalidReturnURL,
};

@interface BTVenmoDriver : NSObject <BTAppSwitchHandler>

/// Initialize a new Venmo driver instance.
///
/// @param apiClient The API client
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient NS_DESIGNATED_INITIALIZER;


- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));


/// Initiates Venmo login via app switch, which returns a tokenized card when successful.
///
/// @note If the BTAPIClient was initialized with a JWT, the tokenizedCard will have the card
/// network and the last 2 digits of the card number. With a client key, these properties will be `nil`.
///
/// @param completionBlock This completion will be invoked when app switch is complete or an error occurs.
/// On success, you will receive an instance of `BTVenmoTokenizedCard`; on failure, an error; on user
/// cancellation, you will receive `nil` for both parameters.
- (void)tokenizeVenmoCardWithCompletion:(void (^)(BTVenmoTokenizedCard * __BT_NULLABLE tokenizedCard, NSError * __BT_NULLABLE error))completionBlock;

/// Indicates whether the Venmo app is available for app switch. This should be checked before presenting
/// any UI to pay with Venmo.
///
/// @note This only indicates if the app is installed and available to be launched, not whether Venmo is
/// enabled for your merchant account.
@property (nonatomic, readonly, assign) BOOL isAppSwitchAvailable;

/// An optional delegate for receiving notifications about the lifecycle of a Venmo app switch, as well as updating
/// your UI
@property (nonatomic, weak) id<BTAppSwitchDelegate> delegate;

@end

BT_ASSUME_NONNULL_END
