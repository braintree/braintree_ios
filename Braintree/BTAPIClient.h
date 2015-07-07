#import <Foundation/Foundation.h>
#import "BTNullability.h"
#import "BTJSON.h"

BT_ASSUME_NONNULL_BEGIN

extern NSString *const BTAPIClientErrorDomain;

typedef NS_ENUM(NSInteger, BTAPIClientErrorType) {
    BTAPIClientErrorTypeUnknown = 0,
    BTAPIClientErrorTypeInvalidClientKey,
    BTAPIClientErrorTypeConfigurationUnavailable,
};

@interface BTAPIClient : NSObject

///
///
/// @param clientKey The client key. Passing an invalid key will return `nil`.
/// @param error Returns an `NSError` object when an error occurs.
- (BT_NULLABLE instancetype)initWithClientKey:(NSString *)clientKey
                                        error:(NSError **)error;

///
///
/// @param clientKey The client key. Passing an invalid key will return `nil`.
/// @param dispatchQueue The dispatch queue onto which completion handlers are dispatched. Passing
/// `nil` will use the application's main queue.
/// @param error This is set to an `NSError` object when an error occurs.
- (BT_NULLABLE instancetype)initWithClientKey:(NSString *)clientKey
                                dispatchQueue:(BT_NULLABLE dispatch_queue_t)dispatchQueue error:(NSError **)error;

/// The GCD dispatch queue to which completion handlers will be dispatched.
///
/// By default, the application's main queue will be used.
///
/// For more information, please read Grand Central Dispatch programming guide and dispatch_get_main_queue.
@property (nonatomic, readonly, strong) dispatch_queue_t dispatchQueue;

/// Provides configuration data as a `BTJSON` object.
///
/// The configuration data can be used by supported payment options to configure themselves
/// dynamically through the Control Panel. It also contains configuration options for the
/// Braintree SDK Core components.
///
/// @note This method is asynchronous because it requires a network call to fetch the
/// configuration for a merchant account from Braintree servers. This configuration is
/// cached on subsequent calls for better performance.
- (void)fetchOrReturnRemoteConfiguration:(void (^)(__BT_NULLABLE BTJSON *remoteConfiguration, __BT_NULLABLE NSError *error))completionBlock;

/// Perfom an HTTP GET on a URL composed of the configured from environment
/// and the given path.
- (void)GET:(NSString *)path
 parameters:(NSDictionary *)parameters
 completion:(void(^)(__BT_NULLABLE BTJSON *body, __BT_NULLABLE NSHTTPURLResponse *response, __BT_NULLABLE NSError *error))completionBlock;

/// Perfom an HTTP POST on a URL composed of the configured from environment
/// and the given path.
- (void)POST:(NSString *)path
  parameters:(NSDictionary *)parameters
  completion:(void(^)(__BT_NULLABLE BTJSON *body, __BT_NULLABLE NSHTTPURLResponse *response, __BT_NULLABLE NSError *error))completionBlock;

@end

BT_ASSUME_NONNULL_END
