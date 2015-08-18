#import <Foundation/Foundation.h>
#import "BTTokenized.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTTokenizedCoinbaseAccount : NSObject <BTTokenized>

@property (nonatomic, copy) NSString *email;

@end

BT_ASSUME_NONNULL_END
