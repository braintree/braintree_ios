#pragma mark BTPaymentAuthorization Errors

/// BTVenmoErrorDomain NSError Domain
extern NSString *const BTVenmoErrorDomain;

/// BTVenmo NSError Codes
NS_ENUM(NSInteger, BTVenmoErrorCode) {
    BTVenmoErrorUnknown = 0,

    /// A compatible version of the Venmo App is not available on this device.
    BTVenmoErrorAppSwitchVenmoAppNotAvailable = 1,

    /// Venmo app switch is not enabled.
    ///
    /// This flag is set via the client token and can be configured
    /// in the Braintree control panel. It can also be overridden in certain
    /// cases (see BTPaymentProviderType.)
    BTVenmoErrorAppSwitchDisabled = 2,

    /// Venmo app switch is not configured appropriately.
    ///
    /// For example, you must specify a returnURLScheme via Braintree before attempting an
    /// app switch to Venmo.
    BTVenmoErrorInvalidIntegration = 3,

    /// UIApplication failed to switch to Venmo despite it being available.
    /// `[UIApplication openURL:]` returned `NO` when `YES` was expected.
    BTVenmoErrorAppSwitchFailed = 4,

    /// App switch completed, but the client encountered an error while attempting
    /// to communicate with the Braintree server.
    /// Check for a `NSUnderlyingError` value in the `userInfo` dictionary for information
    /// about the underlying cause.
    BTVenmoErrorFailureFetchingPaymentMethod = 5,
};

