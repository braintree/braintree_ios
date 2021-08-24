#import <OCMock/OCMock.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** It's not possible to mock UISceneOpenURLOptions through subclassing because its initializer is unavailable,
 *  so we're mocking it with OCMock instead.
 */
API_AVAILABLE(ios(13.0))
@interface BTMockOpenURLOptions : NSObject

- (instancetype)initWithSourceApplication:(NSString *)sourceApplication;

@property(readonly, nonatomic) UISceneOpenURLOptions *mock;

@end

NS_ASSUME_NONNULL_END
