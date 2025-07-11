/**
 Copyright © 2018 Visa. All rights reserved.
 */

/// The closure used to launch Visa Checkout with a loading view or the main UI (if ready)
typedef void (^LaunchHandle)(void);
/// The closure used to pass a `LaunchHandle` back to the merchant, letting them know Visa Checkout can be launched
typedef void (^ManualCheckoutReadyHandler)(LaunchHandle _Nonnull launchHandle);
/// The closure to execute in order to know when the Visa Checkout button has been tapped
typedef void (^ButtonTappedReadyHandler)(void);
