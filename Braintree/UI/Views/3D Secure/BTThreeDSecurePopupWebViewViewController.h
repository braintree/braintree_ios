@import UIKit;

#import "BTWebViewController.h"

@protocol BTThreeDSecurePopupWebViewViewControllerDelegate;

@interface BTThreeDSecurePopupWebViewViewController : BTWebViewController

- (instancetype)initWithURL:(NSURL *)URL;

@property (nonatomic, weak) id<BTThreeDSecurePopupWebViewViewControllerDelegate> delegate;

@end

@protocol BTThreeDSecurePopupWebViewViewControllerDelegate <NSObject>

- (void)popupWebViewViewControllerDidFinish:(BTThreeDSecurePopupWebViewViewController *)viewController;

@end
