@import OCMock;
@import PassKit;
#import "BTMockPKPaymentMethod.h"

NS_ASSUME_NONNULL_BEGIN

/** It's not possible to mock PKPaymentToken through subclassing because its initializer is unavailable,
 *  so we're mocking it with OCMock instead.
 */
@interface BTMockPKPaymentToken : NSObject

- (instancetype)initWithPaymentMethod:(BTMockPKPaymentMethod)paymentMethod;

@property(readonly, nonatomic) PKPaymentToken *mock;

@end

NS_ASSUME_NONNULL_END
