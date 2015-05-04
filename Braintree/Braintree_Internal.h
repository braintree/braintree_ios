#import "Braintree.h"
#import "BTPayPalButton.h"

/// Private header
@interface Braintree ()

// For increasing testability
@property (nonatomic, strong) BTPayPalButton *payPalButton;

/// Begins the setup of Braintree-iOS. Once setup is complete, the supplied completionBlock
/// will be called with either an instance of Braintree or an error.
///
/// *Not used at this time.* Use +braintreeWithClientToken: instead.
///
/// @param clientToken value that is generated on your server using a Braintree server-side
///  client library that authenticates this application to communicate directly to Braintree.
///
/// @see BTClient+Offline.h for offline client tokens that make it easy to test out the SDK without a
///  server-side integration. This is for testing only; production always requires a
///  server-side integration.
///
/// @note You should generate a new client token before each checkout to ensure it has not expired.
+ (void)setupWithClientToken:(NSString *)clientToken
                  completion:(BraintreeCompletionBlock)completionBlock;

@end
