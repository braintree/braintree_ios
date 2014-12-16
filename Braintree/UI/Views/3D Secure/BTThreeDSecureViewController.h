@import UIKit;

#import "BTThreeDSecureLookup.h"

typedef NS_ENUM(NSInteger, BTThreeDSecureViewControllerCompletionStatus) {
    BTThreeDSecureViewControllerCompletionStatusFailure = 0,
    BTThreeDSecureViewControllerCompletionStatusSuccess,
};

@protocol BTThreeDSecureViewControllerDelegate;

@interface BTThreeDSecureViewController : UIViewController

- (instancetype)initWithLookup:(BTThreeDSecureLookup *)lookup;

@property (nonatomic, weak) id <BTThreeDSecureViewControllerDelegate>delegate;

@end

@protocol BTThreeDSecureViewControllerDelegate <NSObject>

///  The delegate will receive this message after the user has successfully authenticated with 3D Secure
///
///  This implementation is responsible for receiving the 3D Secure payment method nonce, possibly transmitting
///  it to your server for server-side operations. Upon completion, you must call the completionBlock.
///
///  Do *not* dismiss the view controller in this method. See threeDSecureViewControllerDidFinish:.
///
///  @param viewController  The 3D Secure view controller
///  @param nonce           The new payment method nonce that should be used for creating a 3D Secure transaction
///  @param completionBlock A required
- (void)threeDSecureViewController:(BTThreeDSecureViewController *)viewController
              didAuthenticateNonce:(NSString *)nonce
                        completion:(void (^)(BTThreeDSecureViewControllerCompletionStatus success))completionBlock;

///  The delegate will receive this message upon completion of the 3D Secure flow, possibly including async work
///  that happens in your implementation of threeDSecureViewController:didAuthenticateNonce:completion:
///
///  You should dismiss the provided view controller in your implementation.
///
///  @param viewController The 3D Secure view controller
- (void)threeDSecureViewControllerDidFinish:(BTThreeDSecureViewController *)viewController;

@end
