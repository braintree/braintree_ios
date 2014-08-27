#import <UIKit/UIKit.h>

@class BTClient;

@interface BraintreeDemoCustomVenmoButtonManager : NSObject

- (instancetype)initWithClient:(BTClient *)client;

@property (nonatomic, strong, readonly) UIButton *button;

@end
