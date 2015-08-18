#import <Foundation/Foundation.h>
#import "BTHTTPErrors.h"
#import "BTJSON.h"
#import "BTNullability.h"

BT_ASSUME_NONNULL_BEGIN

@class BTHTTPResponse;

/// Key for userInfo dictionary that contains the NSHTTPURLResponse from server when it returns an HTTP error
extern NSString * const BTHTTPURLResponseKey;
/// Key for userInfo dictionary that contains the BTJSON body of the HTTP error response
extern NSString * const BTHTTPJSONResponseBodyKey;

@interface BTHTTP : NSObject<NSCopying>

/// An optional array of pinned certificates, each an NSData instance
/// consisting of DER encoded x509 certificates
@property (nonatomic, BT_NULLABLE, strong) BT_GENERICS(NSArray, NSData *) *pinnedCertificates;

- (instancetype)initWithBaseURL:(NSURL *)URL authorizationFingerprint:(NSString *)authorizationFingerprint NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithBaseURL:(nonnull NSURL *)URL clientKey:(nonnull NSString *)clientKey NS_DESIGNATED_INITIALIZER;

- (BT_NULLABLE instancetype)init __attribute__((unavailable("Please use initWithBaseURL:authorizationFingerprint: instead.")));

// For testing
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, readonly, strong) NSURL *baseURL;

/// Queue that callbacks are dispatched onto, main queue if not otherwise specified
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

- (void)GET:(NSString *)endpoint
 completion:(BT_NULLABLE void(^)(BTJSON * __BT_NULLABLE body, NSHTTPURLResponse * __BT_NULLABLE response, NSError * __BT_NULLABLE error))completionBlock;

- (void)GET:(NSString *)endpoint
 parameters:(BT_NULLABLE NSDictionary *)parameters
 completion:(BT_NULLABLE void(^)(BTJSON * __BT_NULLABLE body, NSHTTPURLResponse * __BT_NULLABLE response, NSError * __BT_NULLABLE error))completionBlock;

- (void)POST:(NSString *)endpoint
  completion:(BT_NULLABLE void(^)(BTJSON * __BT_NULLABLE body, NSHTTPURLResponse * __BT_NULLABLE response, NSError * __BT_NULLABLE error))completionBlock;

- (void)POST:(NSString *)endpoint
  parameters:(BT_NULLABLE NSDictionary *)parameters
  completion:(BT_NULLABLE void(^)(BTJSON * __BT_NULLABLE body, NSHTTPURLResponse * __BT_NULLABLE response, NSError * __BT_NULLABLE error))completionBlock;

- (void)PUT:(NSString *)endpoint
 completion:(BT_NULLABLE void(^)(BTJSON * __BT_NULLABLE body, NSHTTPURLResponse * __BT_NULLABLE response, NSError * __BT_NULLABLE error))completionBlock;

- (void)PUT:(NSString *)endpoint
 parameters:(BT_NULLABLE NSDictionary *)parameters
 completion:(BT_NULLABLE void(^)(BTJSON * __BT_NULLABLE body, NSHTTPURLResponse * __BT_NULLABLE response, NSError * __BT_NULLABLE error))completionBlock;

- (void)DELETE:(NSString *)endpoint
    completion:(BT_NULLABLE void(^)(BTJSON * __BT_NULLABLE body, NSHTTPURLResponse * __BT_NULLABLE response, NSError * __BT_NULLABLE error))completionBlock;

- (void)DELETE:(NSString *)endpoint
    parameters:(BT_NULLABLE NSDictionary *)parameters
    completion:(BT_NULLABLE void(^)(BTJSON * __BT_NULLABLE body, NSHTTPURLResponse * __BT_NULLABLE response, NSError * __BT_NULLABLE error))completionBlock;

@end

BT_ASSUME_NONNULL_END
