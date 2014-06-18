#import <Foundation/Foundation.h>

#import "BTHTTPResponse.h"
#import "BTErrors.h"

@class BTHTTPResponse;

typedef void (^BTHTTPCompletionBlock)(BTHTTPResponse *response, NSError *error);

@interface BTHTTP : NSObject

/// An optional array of pinned certificates, each an NSData instance
/// consisting of DER encoded x509 certificates
@property (nonatomic, strong) NSArray *pinnedCertificates;

- (instancetype)initWithBaseURL:(NSURL *)URL;

/// Set an optional array of subclasses of NSURLProtocol
/// that are registered with the underlying URL handler upon initialization.
- (void)setProtocolClasses:(NSArray *)protocolClasses;

- (void)GET:(NSString *)url completion:(BTHTTPCompletionBlock)completionBlock;
- (void)GET:(NSString *)url parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock;

- (void)POST:(NSString *)url completion:(BTHTTPCompletionBlock)completionBlock;
- (void)POST:(NSString *)url parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock;

- (void)PUT:(NSString *)url completion:(BTHTTPCompletionBlock)completionBlock;
- (void)PUT:(NSString *)url parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock;

- (void)DELETE:(NSString *)url completion:(BTHTTPCompletionBlock)completionBlock;
- (void)DELETE:(NSString *)url parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock;

@end
