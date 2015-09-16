#import "BTTokenizationService.h"

NSString * const BTTokenizationServiceErrorDomain = @"com.braintreepayments.BTTokenizationServiceErrorDomain";
NSString * const BTTokenizationServiceViewPresentingDelegateOption = @"viewControllerPresentingDelegate";

@interface BTTokenizationService ()
/// Dictionary of tokenization blocks keyed by types as strings. The blocks have the following type:
///
/// `void(^)(BTAPIClient *apiClient, NSDictionary *options, void(^completionBlock)(id <BTTokenized> tokenization, NSError *error))`
@property (nonatomic, strong) NSMutableDictionary *tokenizationBlocks;
@end

@implementation BTTokenizationService

+ (instancetype)sharedService {
    static BTTokenizationService *sharedService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[BTTokenizationService alloc] init];
    });
    return sharedService;
}

- (NSMutableDictionary *)tokenizationBlocks {
    if (!_tokenizationBlocks) {
        _tokenizationBlocks = [NSMutableDictionary dictionary];
    }
    return _tokenizationBlocks;
}

- (void)registerType:(NSString *)type withTokenizationBlock:(void(^)(BTAPIClient *apiClient, NSDictionary *options, void(^)(id <BTTokenized> tokenization, NSError *error)))tokenizationBlock
{
    self.tokenizationBlocks[type] = [tokenizationBlock copy];
}

- (BOOL)isTypeAvailable:(NSString *)type {
    return self.tokenizationBlocks[type] != nil;
}

- (NSArray *)allTypes {
    return [self.tokenizationBlocks allKeys];
}

- (void)tokenizeType:(NSString *)type
       withAPIClient:(BTAPIClient *)apiClient
          completion:(void(^)(id<BTTokenized> tokenization, NSError *error))completion
{
    [self tokenizeType:type options:nil withAPIClient:apiClient completion:completion];
}

- (void)tokenizeType:(NSString *)type
             options:(BT_NULLABLE BT_GENERICS(NSDictionary, NSString *, id) *)options
       withAPIClient:(BTAPIClient *)apiClient
          completion:(void(^)(id<BTTokenized> tokenization, NSError *error))completion
{
    void(^block)(BTAPIClient *, NSDictionary *, void(^)(id<BTTokenized>, NSError *)) = self.tokenizationBlocks[type];
    if (block) {
        block(apiClient, options ?: @{}, completion);
    } else {
        NSError *error = [NSError errorWithDomain:BTTokenizationServiceErrorDomain
                                             code:BTTokenizationServiceErrorTypeNotRegistered
                                         userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@ processing not available", type],
                                                    NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Type '%@' is not registered with BTTokenizationService", type],
                                                    NSLocalizedRecoverySuggestionErrorKey: [NSString stringWithFormat:@"Please link Braintree%@.framework to your app", type]
                                                    }];
        completion(nil, error);
    }
}

@end
