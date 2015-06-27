#import <Foundation/Foundation.h>
#import "BTNullability.h"
#import "BTConfiguration.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTVenmoDriver : NSObject

- (instancetype)initWithConfiguration:(BTConfiguration *)configuration;

@end

BT_ASSUME_NONNULL_END
