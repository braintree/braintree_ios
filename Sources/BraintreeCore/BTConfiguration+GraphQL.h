#if SWIFT_PACKAGE
#import "Public/BTConfiguration.h"
#else
#import <BraintreeCore/BTConfiguration.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTConfiguration (GraphQL)

@property (nonatomic, readonly, assign) BOOL isGraphQLEnabled;

@end

NS_ASSUME_NONNULL_END
