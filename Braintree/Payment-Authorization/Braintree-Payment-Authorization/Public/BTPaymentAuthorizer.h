#import <Foundation/Foundation.h>

#import "BTClient.h"
#import "BTPaymentAuthorizationDelegate.h"

#pragma mark BTPaymentAuthorization Errors

/// BTPaymentAuthorization NSError Domain
extern NSString *const BTPaymentAuthorizationErrorDomain;

/// BTPaymentAuthorization NSError Codes
NS_ENUM(NSInteger, BTPaymentAuthorizationErrorCode) {
    BTPaymentAuthorizationErrorUnknown = 0,
    BTPaymentAuthorizationErrorOptionNotSupported,
    BTPaymentAuthorizationErrorInitialization,
};

#pragma mark

typedef NS_ENUM(NSInteger, BTPaymentAuthorizationType) {
    BTPaymentAuthorizationTypePayPal,
    BTPaymentAuthorizationTypeVenmo
};


typedef NS_OPTIONS(NSInteger, BTPaymentAuthorizationOptions) {
    BTPaymentAuthorizationOptionMechanismAppSwitch = 1 << 0,
    BTPaymentAuthorizationOptionMechanismViewController = 1 << 1,
    BTPaymentAuthorizationOptionMechanismAny = BTPaymentAuthorizationOptionMechanismViewController | BTPaymentAuthorizationOptionMechanismAppSwitch
};

@interface BTPaymentAuthorizer : NSObject

///  Perform authorization with custom options
///
///  @param type    The type of authorization to perform
///  @param options Authorization options
- (void)authorize:(BTPaymentAuthorizationType)type options:(BTPaymentAuthorizationOptions)options;

///  Perform authorization
///
///  Shorthand for `authorize:type options:BTPaymentAuthorizationOptionMechanismAny`
///
///  @see authorize:options:
///
///  @param type    The type of authorization to perform
- (void)authorize:(BTPaymentAuthorizationType)type;

///  BTClient to use in authorizing
@property (nonatomic, strong) BTClient *client;

///  Delegate to receive messages during payment authorization process
@property (nonatomic, weak) id<BTPaymentAuthorizerDelegate> delegate;

///  The set of available authorization types, represented as NSValues
///  of BTPaymentAuthorizationType.
@property (nonatomic, strong, readonly) NSOrderedSet *supportedAuthorizationTypes;

@end
