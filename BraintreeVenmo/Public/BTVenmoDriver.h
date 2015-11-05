#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#if __has_include("BraintreeCard.h")
#import "BTCardNonce.h"
#else
#import <BraintreeCard/BTCardNonce.h>
#endif
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
    /// Braintree SDK is integrated incorrectly
    BTVenmoDriverErrorTypeIntegration,
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
/// network and the last 2 digits of the card number. With a tokenization key, these properties will be `nil`.
///
/// @param completionBlock This completion will be invoked when app switch is complete or an error occurs.
/// On success, you will receive an instance of `BTCardNonce`; on failure, an error; on user
/// cancellation, you will receive `nil` for both parameters.
- (void)authorizeWithCompletion:(void (^)(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error))completionBlock;

/// An optional delegate for receiving notifications about the lifecycle of a Venmo app switch, as well as updating
/// your UI
@property (nonatomic, weak) id<BTAppSwitchDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
