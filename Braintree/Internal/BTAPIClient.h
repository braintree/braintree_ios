#import <Foundation/Foundation.h>
@class BTJSON;

typedef void (^BTAPIClientCompletionBlock)(BTJSON *body, NSHTTPURLResponse *response, NSError *error);

/// An internal class that encapsulates stateless communication with the client api
@interface BTAPIClient : NSObject

- (instancetype)initWithBaseURL:(NSURL *)baseURL authorizationFingerprint:(NSString *)authorizationFingerprint NS_DESIGNATED_INITIALIZER;

- (void)GET:(NSString *)endpoint parameters:(BTJSON *)parameters completion:(BTAPIClientCompletionBlock)completionBlock;

- (void)POST:(NSString *)endpoint parameters:(BTJSON *)parameters completion:(BTAPIClientCompletionBlock)completionBlock;

@end
