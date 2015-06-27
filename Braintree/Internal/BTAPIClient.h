#import <Foundation/Foundation.h>
#import "BTJSON.h"

typedef void (^BTAPIClientCompletionBlock)(BTJSON *body, NSURLResponse *response, NSError *error);

/// An internal class that encapsulates stateless communication with the client api
@interface BTAPIClient : NSObject

- (instancetype)initWithBaseURL:(NSURL *)baseURL;

- (void)GET:(NSString *)endpoint parameters:(BTJSON *)parameters completion:(BTAPIClientCompletionBlock)completionBlock;

- (void)POST:(NSString *)endpoint parameters:(BTJSON *)parameters completion:(BTAPIClientCompletionBlock)completionBlock;

@end
