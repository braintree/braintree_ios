#import <Foundation/Foundation.h>
@class BTClientToken;
@class BTHTTPErrors;
@class BTHTTPResponse;
@class BTJSON;
@class BTCacheDateValidator;

NS_ASSUME_NONNULL_BEGIN

/**
 Performs HTTP methods on the Braintree Client API
*/
@interface BTHTTP : NSObject<NSCopying>

/**
 An optional array of pinned certificates, each an NSData instance consisting of DER encoded x509 certificates
*/
@property (nonatomic, nullable, strong) NSArray<NSData *> *pinnedCertificates;

/// internal date cache validator for testing
@property (nonatomic) BTCacheDateValidator *cacheDateValidator;

/**
 Initialize `BTHTTP` with the URL for the Braintree API
 
 @param URL The base URL for the Braintree Client API
 */
- (instancetype)initWithBaseURL:(NSURL *)URL NS_DESIGNATED_INITIALIZER;

/**
 Initialize `BTHTTP` with the authorization fingerprint from a client token

 @param URL The base URL for the Braintree Client API
 @param authorizationFingerprint The authorization fingerprint HMAC from a client token
*/
- (instancetype)initWithBaseURL:(NSURL *)URL
       authorizationFingerprint:(NSString *)authorizationFingerprint;

/**
 Initialize `BTHTTP` with a tokenization key

 @param URL The base URL for the Braintree Client API
 @param tokenizationKey A tokenization key
*/
- (instancetype)initWithBaseURL:(NSURL *)URL tokenizationKey:(NSString *)tokenizationKey;

/**
 A convenience initializer to initialize `BTHTTP` with a client token

 @param clientToken A client token
*/
- (instancetype)initWithClientToken:(BTClientToken *)clientToken;

- (NSString *)userAgentString;
- (NSString *)acceptString;
- (NSString *)acceptLanguageString;

- (instancetype)init __attribute__((unavailable("Please use initWithBaseURL:authorizationFingerprint: instead.")));

// For testing
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, readonly, strong) NSURL *baseURL;

/**
 Queue that callbacks are dispatched onto, main queue if not otherwise specified
*/
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

- (void)GET:(NSString *)endpoint
 completion:(nullable void(^)(BTJSON * _Nullable body, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

- (void)GET:(NSString *)endpoint
 parameters:(nullable NSDictionary <NSString *, NSString *> *)parameters
shouldCache:(BOOL)shouldCache
 completion:(nullable void(^)(BTJSON * _Nullable body, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

- (void)GET:(NSString *)endpoint
 parameters:(nullable NSDictionary <NSString *, NSString *> *)parameters
 completion:(nullable void(^)(BTJSON * _Nullable body, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

- (void)POST:(NSString *)endpoint
  completion:(nullable void(^)(BTJSON * _Nullable body, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

- (void)POST:(NSString *)endpoint
  parameters:(nullable NSDictionary *)parameters
  completion:(nullable void(^)(BTJSON * _Nullable body, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

- (void)PUT:(NSString *)endpoint
 completion:(nullable void(^)(BTJSON * _Nullable body, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

- (void)PUT:(NSString *)endpoint
 parameters:(nullable NSDictionary *)parameters
 completion:(nullable void(^)(BTJSON * _Nullable body, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

- (void)DELETE:(NSString *)endpoint
    completion:(nullable void(^)(BTJSON * _Nullable body, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

- (void)DELETE:(NSString *)endpoint
    parameters:(nullable NSDictionary *)parameters
    completion:(nullable void(^)(BTJSON * _Nullable body, NSHTTPURLResponse * _Nullable response, NSError * _Nullable error))completionBlock;

- (void)handleRequestCompletion:(nullable NSData *)data
                        request:(nullable NSURLRequest *)request
                    shouldCache:(BOOL)shouldCache
                       response:(nullable NSURLResponse *)response
                          error:(nullable NSError *)error
                completionBlock:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock;

- (void)callCompletionBlock:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock
                       body:(nullable BTJSON *)jsonBody
                   response:(nullable NSHTTPURLResponse *)response
                      error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
