#import <Foundation/Foundation.h>
#import "BTNullability.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTConfiguration : NSObject

- (instancetype)initWithKey:(NSString *)key;

@property (nonatomic, readonly, copy) NSString *key;

/// The GCD dispatch queue to which completion handlers will be dispatched.
///
/// By default, the application's main queue will be used.
///
/// For more information, please read Grand Central Dispatch programming guide and dispatch_get_main_queue.
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

@end

BT_ASSUME_NONNULL_END
