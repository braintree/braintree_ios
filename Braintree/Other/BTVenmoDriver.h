#import <Foundation/Foundation.h>
#import "BTNullability.h"
#import "BTAPIClient.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTVenmoDriver : NSObject

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient;

@end

BT_ASSUME_NONNULL_END
