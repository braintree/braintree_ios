@import OCMock;
@import PassKit;

NS_ASSUME_NONNULL_BEGIN

/** It's not possible to mock PKPaymentMethod through subclassing because its initializer is unavailable,
 *  so we're mocking it with OCMock instead.
 */
@interface BTMockPKPaymentMethod : NSObject

- (instancetype)initWithNetwork:(PKPaymentNetwork)network;

@property(readonly, nonatomic) PKPaymentMethod *mock;

@end

NS_ASSUME_NONNULL_END
