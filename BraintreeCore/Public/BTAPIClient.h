#import <Foundation/Foundation.h>
#import "BTClientMetadata.h"
#import "BTConfiguration.h"
#import "BTNullability.h"
#import "BTJSON.h"

BT_ASSUME_NONNULL_BEGIN

extern NSString *const BTAPIClientErrorDomain;

typedef NS_ENUM(NSInteger, BTAPIClientErrorType) {
    BTAPIClientErrorTypeUnknown = 0,
    BTAPIClientErrorTypeConfigurationUnavailable,
};

/// This class acts as the entry point for accessing the Braintree APIs
/// via common HTTP methods performed on API endpoints. It also manages
/// authentication via client key and provides access to a merchant's
/// gateway configuration.

@interface BTAPIClient : NSObject

/// Initialize a new API client.
///
/// @note Malformed or invalid client keys may not cause this method to return `nil`.
/// Client keys are designed for Braintree to initialize itself without requiring an initial
/// network call, so the only validation that occurs is a basic syntax check.
///
/// @param clientKey The client key. Passing an invalid key will return `nil`.
/// @return An API client, or `nil` if the client key is invalid.
- (BT_NULLABLE instancetype)initWithClientKey:(NSString *)clientKey;

/// Initialize a new API client.
///
/// @param clientKey The client key. Passing an invalid key will return `nil`.
/// @param dispatchQueue The dispatch queue onto which completion handlers are dispatched. Passing
/// `nil` will use the application's main queue.
/// @return An API client, or `nil` if the client key is invalid.
- (BT_NULLABLE instancetype)initWithClientKey:(NSString *)clientKey
                                dispatchQueue:(BT_NULLABLE dispatch_queue_t)dispatchQueue;

/// Initialize a new API client.
///
/// @param clientToken The client token retrieved from your server. Passing an invalid client token will return `nil`.
/// @return An API client, or `nil` if the client token is invalid.
- (BT_NULLABLE instancetype)initWithClientToken:(NSString *)clientToken;

/// Initialize a new API client.
///
/// @param clientToken The client token retrieved from your server. Passing an invalid client token will return `nil`.
/// @param dispatchQueue The dispatch queue onto which completion handlers are dispatched. Passing
/// `nil` will use the application's main queue.
/// @return An API client, or `nil` if the client token is invalid.
- (BT_NULLABLE instancetype)initWithClientToken:(NSString *)clientToken
                                  dispatchQueue:(BT_NULLABLE dispatch_queue_t)dispatchQueue;

/// Create a copy of an existing API client, but specify a new source and integration type.
/// @discussion This provides a way to override an API client's source and integration metadata, which
/// is captured and sent to Braintree as part of the analytics we track.
- (instancetype)copyWithSource:(BTClientMetadataSourceType)source
                   integration:(BTClientMetadataIntegrationType)integration;


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
- (void)fetchOrReturnRemoteConfiguration:(void (^)(BTConfiguration * __BT_NULLABLE configuration, NSError * __BT_NULLABLE error))completionBlock;

/// Perfom an HTTP GET on a URL composed of the configured from environment
/// and the given path.
///
/// @param path The endpoint URI path.
/// @param parameters Optional set of query parameters to be encoded with the request.
/// @param completionBlock A block object to be executed when the request finishes.
/// On success, `body` and `response` will contain the JSON body response and the
/// HTTP response and `error` will be `nil`; on failure, `body` and `response` will be
/// `nil` and `error` will contain the error that occurred.
- (void)GET:(NSString *)path
 parameters:(BT_NULLABLE NSDictionary *)parameters
 completion:(BT_NULLABLE void(^)(BTJSON * __BT_NULLABLE body, NSHTTPURLResponse * __BT_NULLABLE response, NSError * __BT_NULLABLE error))completionBlock;

/// Perfom an HTTP POST on a URL composed of the configured from environment
/// and the given path.
///
/// @param path The endpoint URI path.
/// @param parameters Optional set of parameters to be JSON encoded and sent in the
/// body of the request.
/// @param completionBlock A block object to be executed when the request finishes.
/// On success, `body` and `response` will contain the JSON body response and the
/// HTTP response and `error` will be `nil`; on failure, `body` and `response` will be
/// `nil` and `error` will contain the error that occurred.
- (void)POST:(NSString *)path
  parameters:(BT_NULLABLE NSDictionary *)parameters
  completion:(BT_NULLABLE void(^)(BTJSON * __BT_NULLABLE body, NSHTTPURLResponse * __BT_NULLABLE response, NSError * __BT_NULLABLE error))completionBlock;

@end

BT_ASSUME_NONNULL_END
