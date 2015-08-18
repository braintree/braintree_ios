#import "BTTokenizationService.h"

@interface BTTokenizationService ()
/// Dictionary of tokenization blocks keyed by types as strings. The blocks have the following type:
///
/// `void(^)(BTAPIClient *apiClient, NSDictionary *options, void(^completionBlock)(id<BTTokenized> tokenization, NSError *error))`
@property (nonatomic, strong) NSMutableDictionary *tokenizationBlocks;
@end

@implementation BTTokenizationService

// TODO: see if +load allows us to circumvent the issue of initialization not occurring until class is loaded into memory
+ (void)initialize {
    /// Ensure that these classes have had their +initialize method called, i.e. the classes are loaded
    /// into memory. Without this, it is not guaranteed that their +initialize method will have been
    /// invoked unless an app explicitly uses these classes.
    [NSClassFromString(@"BTPayPalDriver") class];
    [NSClassFromString(@"BTVenmoDriver") class];
    [NSClassFromString(@"BTCoinbaseDriver") class];
    [NSClassFromString(@"BTCardTokenizationClient") class];
}

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

- (void)registerType:(NSString *)type withTokenizationBlock:(void(^)(BTAPIClient *apiClient, NSDictionary *options, void(^)(id<BTTokenized> tokenization, NSError *error)))tokenizationBlock
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
    }
}

@end
