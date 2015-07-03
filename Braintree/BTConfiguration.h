#import <Foundation/Foundation.h>
#import "BTNullability.h"

BT_ASSUME_NONNULL_BEGIN

extern NSString *const BTConfigurationErrorDomain;

typedef NS_ENUM(NSInteger, BTConfigurationErrorCode) {
    BTConfigurationErrorCodeUnknown = 0,
    BTConfigurationErrorCodeConfigurationUnavailable,
};

@interface BTConfiguration : NSObject

- (BT_NULLABLE instancetype)initWithClientKey:(NSString *)clientKey error:(NSError **)error;

- (BT_NULLABLE instancetype)initWithClientKey:(NSString *)clientKey dispatchQueue:(BT_NULLABLE dispatch_queue_t)dispatchQueue error:(NSError **)error;

@property (nonatomic, readonly, copy) NSString *clientKey;

@property (nonatomic, copy) NSString *returnURLScheme;

/// The GCD dispatch queue to which completion handlers will be dispatched.
///
/// By default, the application's main queue will be used.
///
/// For more information, please read Grand Central Dispatch programming guide and dispatch_get_main_queue.
@property (nonatomic, readonly, strong) dispatch_queue_t dispatchQueue;

@end

BT_ASSUME_NONNULL_END
