#import <UIKit/UIKit.h>

@class BTClient;
@protocol BTPayPalAdapterDelegate;

@interface BraintreeDemoCustomPayPalButtonManager : NSObject

- (instancetype)initWithClient:(BTClient *)client delegate:(id<BTPayPalAdapterDelegate>)delegate;

@property (nonatomic, strong, readonly) UIButton *button;

@property (nonatomic, weak) id<BTPayPalAdapterDelegate> delegate;

@end
