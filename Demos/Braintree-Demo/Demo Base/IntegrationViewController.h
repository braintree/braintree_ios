#import <UIKit/UIKit.h>

@class IntegrationViewController;

@protocol IntegrationViewControllerDelegate <NSObject>

- (void)integrationViewController:(IntegrationViewController *)integrationViewController didChangeAppSetting:(NSDictionary *)appSetting;

@end

@interface IntegrationViewController : UIViewController

@property (nonatomic, weak) id<IntegrationViewControllerDelegate> delegate;

@end
