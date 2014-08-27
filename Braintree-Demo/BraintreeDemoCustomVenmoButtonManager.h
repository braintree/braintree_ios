#import <UIKit/UIKit.h>

@class BTClient;
@protocol BTAppSwitchingDelegate;

@interface BraintreeDemoCustomVenmoButtonManager : NSObject

- (instancetype)initWithClient:(BTClient *)client delegate:(id<BTAppSwitchingDelegate>)delegate;

@property (nonatomic, strong, readonly) UIButton *button;

@end
