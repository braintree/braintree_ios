#import <Foundation/Foundation.h>
#import "BTJSON.h"
#import "BTNullability.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTConfiguration : NSObject

- (instancetype)initWithJSON:(BTJSON *)json NS_DESIGNATED_INITIALIZER;

/// The merchant account's configuration as a `BTJSON` object
@property (nonatomic, readonly, strong) BTJSON *json;

#pragma mark - Undesignated initializers (do not use)

- (BT_NULLABLE instancetype)init __attribute__((unavailable("Please use initWithJSON: instead.")));

@end

BT_ASSUME_NONNULL_END
