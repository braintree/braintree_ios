#import <Foundation/Foundation.h>

/// App Switch NSError Domain
extern NSString *const BTAppSwitchErrorDomain;

/// App Switch NSError Codes
typedef NS_ENUM(NSInteger, BTAppSwitchErrorCode) {
    BTAppSwitchErrorUnknown = 0,

    /// A compatible version of the target app is not available on this device.
    BTAppSwitchErrorAppNotAvailable = 1,

    /// App switch is not enabled.
    BTAppSwitchErrorDisabled = 2,

    /// App switch is not configured appropriately. You must specify a
    /// returnURLScheme via Braintree before attempting an app switch.
    BTAppSwitchErrorIntegrationReturnURLScheme = 3,

    /// The merchant ID field was not valid or present in the client token.
    BTAppSwitchErrorIntegrationMerchantId = 4,

    /// UIApplication failed to switch despite it being available.
    /// `[UIApplication openURL:]` returned `NO` when `YES` was expected.
    BTAppSwitchErrorFailed = 5,

    /// App switch completed, but the client encountered an error while attempting
    /// to communicate with the Braintree server.
    /// Check for a `NSUnderlyingError` value in the `userInfo` dictionary for information
    /// about the underlying cause.
    BTAppSwitchErrorFailureFetchingPaymentMethod = 6,

    /// Parameters used to initiate app switch are invalid
    BTAppSwitchErrorIntegrationInvalidParameters = 7,

    /// Invalid CFBundleDisplayName
    BTAppSwitchErrorIntegrationInvalidBundleDisplayName = 8,
};
