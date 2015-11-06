#import <Foundation/Foundation.h>
#import "BTClientMetadata.h"
#import "BTConfiguration.h"
#import "BTJSON.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const BTAPIClientErrorDomain;

typedef NS_ENUM(NSInteger, BTAPIClientErrorType) {
    BTAPIClientErrorTypeUnknown = 0,
    BTAPIClientErrorTypeConfigurationUnavailable,
};

/// This class acts as the entry point for accessing the Braintree APIs
/// via common HTTP methods performed on API endpoints. It also manages
/// authentication via tokenization key and provides access to a merchant's
/// gateway configuration.

@interface BTAPIClient : NSObject

/// Initialize a new API client.
///
/// @param authorization Your tokenization key or client token. Passing an invalid value may return `nil`.
/// @return A Braintree API client, or `nil` if initialization failed.
- (nullable instancetype)initWithAuthorization:(NSString *)authorization;

/// Create a copy of an existing API client, but specify a new source and integration type.
/// @discussion This provides a way to override an API client's source and integration metadata, which
/// is captured and sent to Braintree as part of the analytics we track.
- (instancetype)copyWithSource:(BTClientMetadataSourceType)source
                   integration:(BTClientMetadataIntegrationType)integration;

/// Provides configuration data as a `BTJSON` object.
///
/// The configuration data can be used by supported payment options to configure themselves
/// dynamically through the Control Panel. It also contains configuration options for the
/// Braintree SDK Core components.
///
/// @note This method is asynchronous because it requires a network call to fetch the
/// configuration for a merchant account from Braintree servers. This configuration is
/// cached on subsequent calls for better performance.
- (void)fetchOrReturnRemoteConfiguration:(void (^)(BTConfiguration * _Nullable configuration, NSError * _Nullable error))completionBlock;

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
 parameters:(nullable NSDictionary *)parameters
 completion:(nullable void(^)(BTJSON * _Nullable body, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

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
  parameters:(nullable NSDictionary *)parameters
  completion:(nullable void(^)(BTJSON * _Nullable body, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

- (instancetype)init __attribute__((unavailable("Use initWithClientKeyOrToken: instead.")));

@end

NS_ASSUME_NONNULL_END
