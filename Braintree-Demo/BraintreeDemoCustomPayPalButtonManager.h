#import <UIKit/UIKit.h>

@class BTClient;
@protocol BTPayPalAdapterDelegate;

@interface BraintreeDemoCustomPayPalButtonManager : NSObject

- (instancetype)initWithClient:(BTClient *)client;

@property (nonatomic, strong, readonly) UIButton *button;

@property (nonatomic, weak) id<BTPayPalAdapterDelegate> delegate;

@end
