#import <UIKit/UIKit.h>


@protocol BTThreeDSecurePopupWebViewViewControllerDelegate;

@interface BTThreeDSecurePopupWebViewViewController : UIViewController

- (instancetype)initWithURL:(NSURL *)URL;

@property (nonatomic, weak) id<BTThreeDSecurePopupWebViewViewControllerDelegate> delegate;

@end

@protocol BTThreeDSecurePopupWebViewViewControllerDelegate <NSObject>

- (void)popupWebViewViewControllerDidFinish:(BTThreeDSecurePopupWebViewViewController *)viewController;

@end
