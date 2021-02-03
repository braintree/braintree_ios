#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Wrapper for a payment flow request.
 */
@interface BTPaymentFlowRequest : NSObject

/**
 Optional: The window used to present the ASWebAuthenticationSession.

 @note If your app supports multitasking, you must set this property to ensure that the ASWebAuthenticationSession is presented on the correct window.
 */
@property (nonatomic, nullable, strong) UIWindow *activeWindow;

@end

NS_ASSUME_NONNULL_END
