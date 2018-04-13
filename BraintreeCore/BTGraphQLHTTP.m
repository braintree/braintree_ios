#import "BTGraphQLHTTP.h"
#import "BTURLUtils.h"
#import "Braintree-Version.h"

@interface BTGraphQLHTTP ()
@property (nonatomic, copy) NSString *tokenizationKey;
@property (nonatomic, copy) NSString *authorizationFingerprint;
@end

@implementation BTGraphQLHTTP

static NSString *BraintreeVersion = @"2018-03-06";

#pragma mark - Overrides

- (void)GET:(__unused NSString *)aPath completion:(__unused void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [NSException raise:@"" format:@"GET is unsupported"];
}

- (void)GET:(__unused NSString *)aPath parameters:(__unused NSDictionary *)parameters completion:(__unused void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [NSException raise:@"" format:@"GET is unsupported"];
}

- (void)POST:(__unused NSString *)aPath completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self httpRequest:@"POST" parameters:nil completion:completionBlock];
}

- (void)POST:(__unused NSString *)aPath parameters:(NSDictionary *)parameters completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [self httpRequest:@"POST" parameters:parameters completion:completionBlock];
}

- (void)PUT:(__unused NSString *)aPath completion:(__unused void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [NSException raise:@"" format:@"PUT is unsupported"];
}

- (void)PUT:(__unused NSString *)aPath parameters:(__unused NSDictionary *)parameters completion:(__unused void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [NSException raise:@"" format:@"PUT is unsupported"];
}

- (void)DELETE:(__unused NSString *)aPath completion:(__unused void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [NSException raise:@"" format:@"DELETE is unsupported"];
}

- (void)DELETE:(__unused NSString *)aPath parameters:(__unused NSDictionary *)parameters completion:(__unused void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock {
    [NSException raise:@"" format:@"DELETE is unsupported"];
}

- (void)handleRequestCompletion:(NSData *)data
                       response:(NSURLResponse *)response
                          error:(NSError *)error
                completionBlock:(void (^)(BTJSON * _Nonnull, NSHTTPURLResponse * _Nonnull, NSError * _Nonnull))completionBlock
{
    // Network error
    if (error) {
        [self callCompletionBlock:completionBlock body:nil response:nil error:error];
        return;
    }

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    BTJSON *body = [[BTJSON alloc] initWithValue:json];

    // Success case
    if ([body asDictionary] && ![body[@"errors"] asArray]) {
        [self callCompletionBlock:completionBlock body:body response:(NSHTTPURLResponse *)response error:nil];
        return;
    }

    BTJSON *errorJSON = body[@"errors"][0];
    NSString *errorType = [errorJSON[@"extensions"][@"errorType"] asString];
    NSInteger statusCode = 0;
    BTHTTPErrorCode errorCode = BTHTTPErrorCodeUnknown;
    NSMutableDictionary *errorBody = [NSMutableDictionary new];

    if ([errorType isEqualToString:@"user_error"]) {
        statusCode = 422;
        errorCode = BTHTTPErrorCodeClientError;
        errorBody[@"error"] = @{@"message": @"Input is invalid"};

        NSMutableArray *errors = [NSMutableArray new];
        NSUInteger errorCount = [body[@"errors"] asArray].count;
        for (NSUInteger i = 0; i < errorCount; i++) {
            BTJSON *error = body[@"errors"][i];
            NSArray *inputPath = [error[@"extensions"][@"inputPath"] asStringArray];
            // Defensive programming
            if (!inputPath) {
                continue;
            }
            [self addErrorForInputPath:[inputPath subarrayWithRange:NSMakeRange(1, inputPath.count - 1)]
                      withGraphQLError:[error asDictionary]
                               toArray:errors];
        }

        if (errors.count > 0) {
            errorBody[@"fieldErrors"] = [errors copy];
        }
    } else if ([errorType isEqualToString:@"developer_error"]) {
        statusCode = 403;
        errorCode = BTHTTPErrorCodeClientError;

        if ([errorJSON[@"message"] asString]) {
            errorBody[@"error"] = @{@"message": [errorJSON[@"message"] asString]};
        }
    } else {
        statusCode = 500;
        errorCode = BTHTTPErrorCodeServerError;
        errorBody[@"error"] = @{@"message": @"An unexpected error occurred"};
    }

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSHTTPURLResponse *nestedErrorResponse = [[NSHTTPURLResponse alloc] initWithURL:response.URL statusCode:statusCode HTTPVersion:@"HTTP/1.1" headerFields:httpResponse.allHeaderFields];

    // Create errors
    NSError *returnedError = [[NSError alloc] initWithDomain:BTHTTPErrorDomain
                                                        code:errorCode
                                                    userInfo:@{
                                                               BTHTTPURLResponseKey: nestedErrorResponse,
                                                               BTHTTPJSONResponseBodyKey: [[BTJSON alloc] initWithValue:[errorBody copy]]
                                                               }];
    [self callCompletionBlock:completionBlock body:[[BTJSON alloc] initWithValue:[errorBody copy]] response:(NSHTTPURLResponse *)response error:returnedError];
}

#pragma mark - Private methods

- (void)httpRequest:(NSString *)method
         parameters:(NSDictionary *)parameters
         completion:(void(^)(BTJSON *body, NSHTTPURLResponse *response, NSError *error))completionBlock
{
    if (!self.baseURL || [self.baseURL.absoluteString isEqualToString:@""]) {
        NSMutableDictionary *errorUserInfo = [NSMutableDictionary new];
        if (method) errorUserInfo[@"method"] = method;
        if (parameters) errorUserInfo[@"parameters"] = parameters;
        completionBlock(nil, nil, [NSError errorWithDomain:BTHTTPErrorDomain code:BTHTTPErrorCodeMissingBaseURL userInfo:errorUserInfo]);
        return;
    }

    NSURLComponents *components = [NSURLComponents componentsWithString:self.baseURL.absoluteString];

    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                   @"User-Agent": [self userAgentString],
                                                                                   @"Braintree-Version": BraintreeVersion
                                                                                   }];
    headers[@"Authorization"] = [NSString stringWithFormat:@"Bearer %@", self.authorizationFingerprint ?: self.tokenizationKey];

    parameters = parameters ? [NSMutableDictionary dictionaryWithDictionary:parameters] : [NSMutableDictionary new];

    NSMutableURLRequest *request;

    headers[@"Content-Type"]  = @"application/json; charset=utf-8";

    NSError *jsonSerializationError;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:parameters
                                                       options:0
                                                         error:&jsonSerializationError];
    if (jsonSerializationError) {
        completionBlock(nil, nil, jsonSerializationError);
        return;
    }

    request = [NSMutableURLRequest requestWithURL:components.URL];
    [request setHTTPBody:bodyData];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPMethod:method];

    // Perform the actual request
    NSURLSessionTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [self callCompletionBlock:completionBlock body:nil response:(NSHTTPURLResponse *)response error:error];
            return;
        }

        [self handleRequestCompletion:data response:response error:error completionBlock:completionBlock];
    }];
    [task resume];
}

/// Walks through the input path recursively and adds field errors to a mutable array
- (void)addErrorForInputPath:(NSArray <NSString *> *)inputPath withGraphQLError:(NSDictionary *)errorJSON toArray:(NSMutableArray <NSDictionary *> *)errors {
    NSString *field = [inputPath firstObject];

    if (inputPath.count == 1) {
        [errors addObject:@{
                            @"field": field,
                            @"message": errorJSON[@"message"],
                            @"code": errorJSON[@"extensions"][@"legacyCode"]
                            }];
        return;
    }

    // Find nested error that matches the field
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(field == %@)", field];
    NSDictionary *nestedFieldError = [[errors filteredArrayUsingPredicate:predicate] firstObject];

    // If the nested error hasn't been created yet, add one
    if (!nestedFieldError) {
        nestedFieldError = @{
                             @"field": field,
                             @"fieldErrors": [NSMutableArray new]
                             };
        [errors addObject:nestedFieldError];
    }

    [self addErrorForInputPath:[inputPath subarrayWithRange:NSMakeRange(1, inputPath.count - 1)]
              withGraphQLError:errorJSON
                       toArray:nestedFieldError[@"fieldErrors"]];
}

@end
