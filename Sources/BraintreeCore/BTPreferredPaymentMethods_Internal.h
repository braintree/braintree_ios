#if SWIFT_PACKAGE
#import "Public/BTPreferredPaymentMethods.h"
#else
#import <BraintreeCore/BTPreferredPaymentMethods.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTPreferredPaymentMethods ()

@property(nonatomic, strong) id application;

@end

NS_ASSUME_NONNULL_END
