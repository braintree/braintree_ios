#import <Foundation/Foundation.h>

@class BTClient;
@protocol BTPaymentMethodCreationDelegate;

/// Creates, retains and hooks up a simple Apple Pay button.
@interface BraintreeDemoCustomApplePayButtonManager : NSObject

/// Initialize a new manager given a client and delegate.
///
/// @param client
/// @param delegate
///
/// @return a newly initialized Apple Pay button manager
- (instancetype)initWithClient:(BTClient *)client delegate:(id<BTPaymentMethodCreationDelegate>)delegate;

/// A configured Apple Pay button that is ready to be added to the UI.
@property (nonatomic, strong, readonly) UIButton *button;

@end
