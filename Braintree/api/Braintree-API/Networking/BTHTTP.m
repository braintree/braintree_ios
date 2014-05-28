#import "BTHTTP.h"

#include <sys/sysctl.h>
#import <AFNetworking/AFNetworking.h>

#import "BTClient.h"

@interface BTHTTP ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *afnetworkingManager;

- (NSDictionary *)defaultHeaders;
@end

@implementation BTHTTP

- (instancetype)initWithBaseURL:(NSURL *)URL {
    self = [self init];
    if (self) {
        self.afnetworkingManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:URL];

        [self.defaultHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop) {
            [self.afnetworkingManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    return self;
}

- (void)GET:(NSString *)aPath completion:(BTHTTPCompletionBlock)completionBlock {
    [self GET:aPath parameters:nil completion:completionBlock];
}

- (void)GET:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock {
    [self.afnetworkingManager GET:aPath
                       parameters:parameters
                          success:[self AFSuccessCompletionBlockWithBTHTTPCompletionBlock:completionBlock]
                          failure:[self AFFailureCompletionBlockWithBTHTTPCompletionBlock:completionBlock]];
}

- (void)POST:(NSString *)aPath completion:(BTHTTPCompletionBlock)completionBlock {
    [self POST:aPath parameters:nil completion:completionBlock];
}

- (void)POST:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock {
    [self.afnetworkingManager POST:aPath
                        parameters:parameters
                           success:[self AFSuccessCompletionBlockWithBTHTTPCompletionBlock:completionBlock]
                           failure:[self AFFailureCompletionBlockWithBTHTTPCompletionBlock:completionBlock]];
}

- (void)PUT:(NSString *)aPath completion:(BTHTTPCompletionBlock)completionBlock {
    [self PUT:aPath parameters:nil completion:completionBlock];
}

- (void)PUT:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock {
    [self.afnetworkingManager PUT:aPath
                       parameters:parameters
                          success:[self AFSuccessCompletionBlockWithBTHTTPCompletionBlock:completionBlock]
                          failure:[self AFFailureCompletionBlockWithBTHTTPCompletionBlock:completionBlock]];
}

- (void)DELETE:(NSString *)aPath completion:(BTHTTPCompletionBlock)completionBlock {
    [self DELETE:aPath parameters:nil completion:completionBlock];
}

- (void)DELETE:(NSString *)aPath parameters:(NSDictionary *)parameters completion:(BTHTTPCompletionBlock)completionBlock {
    [self.afnetworkingManager DELETE:aPath
                          parameters:parameters
                             success:[self AFSuccessCompletionBlockWithBTHTTPCompletionBlock:completionBlock]
                             failure:[self AFFailureCompletionBlockWithBTHTTPCompletionBlock:completionBlock]];
}


#pragma mark - Response Blocks

- (BTHTTPResponse *)responseFromOperation:(AFHTTPRequestOperation *)operation {
    return [[BTHTTPResponse alloc] initWithStatusCode:operation.response.statusCode
                                       responseObject:operation.responseObject];
}

- (void (^)(AFHTTPRequestOperation *operation, id responseObject))AFSuccessCompletionBlockWithBTHTTPCompletionBlock:(BTHTTPCompletionBlock)completionBlock {
    void (^success)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, __unused id responseObject) {
        if (completionBlock) {
            completionBlock([self responseFromOperation:operation], nil);
        }
    };
    return success;
}

- (void (^)(AFHTTPRequestOperation *operation, NSError *error))AFFailureCompletionBlockWithBTHTTPCompletionBlock:(BTHTTPCompletionBlock)completionBlock {
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completionBlock) {
            completionBlock(operation.responseObject ? [self responseFromOperation:operation] : nil,
                            [self defaultDomainErrorForRequestOperation:operation error:error]);
        }
    };
    return failure;
}

#pragma mark - Error Handling

- (NSError *)defaultDomainErrorForRequestOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error {
    switch (operation.response.statusCode) {
        case 403:
            return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                       code:BTMerchantIntegrationErrorUnknown
                                   userInfo:@{NSUnderlyingErrorKey: error}];
        case 404:
            return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                       code:BTMerchantIntegrationErrorUnknown // TODO: - don't specify domain-specific errors at this level
                                   userInfo:@{NSUnderlyingErrorKey: error}];
        case 422:
            return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                       code:BTCustomerInputErrorInvalid
                                   userInfo:@{NSUnderlyingErrorKey: error}];
        case 400 ... 402:
        case 405 ... 421:
        case 423 ... 499:
            return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                       code:BTCustomerInputErrorUnknown
                                   userInfo:@{NSUnderlyingErrorKey: error}];
        case 503:
            return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                       code:BTServerErrorGatewayUnavailable
                                   userInfo:@{NSUnderlyingErrorKey: error}];
        case 500 ... 502:
        case 504 ... 599:
            return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                       code:BTServerErrorUnknown
                                   userInfo:@{NSUnderlyingErrorKey: error}];
        default:
            if ([error.domain isEqualToString:NSURLErrorDomain]) {
                return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                           code:BTServerErrorNetworkUnavailable
                                       userInfo:@{NSUnderlyingErrorKey: error}];
            } else if ([error.domain isEqualToString:NSCocoaErrorDomain] && error.code == NSPropertyListReadCorruptError) {
                return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                           code:BTServerErrorUnexpectedError
                                       userInfo:@{NSUnderlyingErrorKey: error}];
            } else if ([error.domain isEqualToString:AFNetworkingErrorDomain] && error.code == NSURLErrorCannotDecodeContentData) {
                return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                           code:BTServerErrorUnexpectedError
                                       userInfo:@{NSUnderlyingErrorKey: error}];
            } else {
                return [NSError errorWithDomain:BTBraintreeAPIErrorDomain
                                           code:BTServerErrorUnknown
                                       userInfo:@{NSUnderlyingErrorKey: error}];
            }
    }
}

#pragma mark - Default Headers

- (NSDictionary *)defaultHeaders {
    return @{ @"User-Agent": [self userAgentString],
              @"Accept": [self acceptString],
              @"Accept-Language": [self acceptLanguageString] };
}

- (NSString *)userAgentString {
    // braintree-api-ios/1.0.0 iOS/4.3.2 iPhone2,1
    NSString *userInterfaceIdiom;
    switch ([[UIDevice currentDevice] userInterfaceIdiom]) {
        case UIUserInterfaceIdiomPhone:
            userInterfaceIdiom = @"iPhone";
            break;
        case UIUserInterfaceIdiomPad:
            userInterfaceIdiom = @"iPad";
            break;
        default:
            userInterfaceIdiom = @"unknown";
    }

    return [NSString stringWithFormat:@"braintree-api-ios/%@ %@/%@ %@/%@",
            [BTClient libraryVersion],
            userInterfaceIdiom,
            [[UIDevice currentDevice] systemVersion],
            [self platformString],
            [self architectureString]];
}

- (NSString *)platformString {
    size_t size = 128;
    char *hwModel = alloca(size);

    if (sysctlbyname("hw.model", hwModel, &size, NULL, 0) != 0) {
        return nil;
    }

    NSString *hwModelString = [NSString stringWithCString:hwModel encoding:NSUTF8StringEncoding];
#if TARGET_IPHONE_SIMULATOR
    hwModelString = [hwModelString stringByAppendingString:@"(simulator)"];
#endif
    return hwModelString;
}

- (NSString *)architectureString {
    size_t size = 128;
    char *hwMachine = alloca(size);

    if (sysctlbyname("hw.machine", hwMachine, &size, NULL, 0) != 0) {
        return nil;
    }

    return [NSString stringWithCString:hwMachine encoding:NSUTF8StringEncoding];
}

- (NSString *)acceptString {
    return @"application/json";
}

- (NSString *)acceptLanguageString {
    NSLocale *locale = [NSLocale currentLocale];
    return [NSString stringWithFormat:@"%@-%@",
            [locale objectForKey:NSLocaleLanguageCode],
            [locale objectForKey:NSLocaleCountryCode]];
}

@end
