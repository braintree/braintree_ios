#import <Foundation/Foundation.h>

extern NSString *const BTVenmoAppSwitchReturnURLErrorDomain;

typedef NS_ENUM(NSUInteger, BTVenmoAppSwitchReturnURLState) {
    BTVenmoAppSwitchReturnURLStateSucceededWithPaymentContext,
    BTVenmoAppSwitchReturnURLStateSucceeded,
    BTVenmoAppSwitchReturnURLStateFailed,
    BTVenmoAppSwitchReturnURLStateCanceled,
    BTVenmoAppSwitchReturnURLStateUnknown
};

/**
 This class interprets URLs received from the Venmo app via app switch returns.

 Venmo Touch app switch authorization requests should result in success, failure or user-initiated cancelation. These states are communicated in the url.
*/
@interface BTVenmoAppSwitchReturnURL : NSObject

/**
 Evaluates whether the url represents a valid Venmo Touch return.

 @param url               an app switch return URL

 @return YES if the url represents a Venmo Touch app switch return
*/
+ (BOOL)isValidURL:(NSURL *)url;

/**
 Initializes a new BTVenmoAppSwitchReturnURL

 @param url an incoming app switch url

 @return An initialized app switch return url
*/
- (instancetype)initWithURL:(NSURL *)url;

/**
 The overall status of the app switch - success, failure or cancelation
*/
@property (nonatomic, assign, readonly) BTVenmoAppSwitchReturnURLState state;

/**
 The nonce from the return URL.
*/
@property (nonatomic, copy, readonly) NSString *nonce;

/**
 The username from the return URL.
*/
@property (nonatomic, copy, readonly) NSString *username;

/**
 The payment context ID from the return URL.
 */
@property (nonatomic, copy, readonly) NSString *paymentContextID;

/**
 If the return URL's state is BTVenmoAppSwitchReturnURLStateFailed, the error returned from Venmo via the app switch.
*/
@property (nonatomic, strong, readonly) NSError *error;

@end
