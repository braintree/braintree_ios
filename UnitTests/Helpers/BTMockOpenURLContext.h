#import <OCMock/OCMock.h>
#import <UIKit/UIKit.h>
#import "BTMockOpenURLOptions.h"

NS_ASSUME_NONNULL_BEGIN

/** It's not possible to mock UIOpenURLContext through subclassing because its initializer is unavailable,
 *  so we're mocking it with OCMock instead.
 */
API_AVAILABLE(ios(13.0))
@interface BTMockOpenURLContext : NSObject

- (instancetype)initWithURL:(NSURL *)url options:(UISceneOpenURLOptions *)options;

@property(readonly, nonatomic) UIOpenURLContext *mock;

@end

NS_ASSUME_NONNULL_END
