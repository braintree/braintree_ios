#import <Foundation/Foundation.h>
#import "BTAPIClient.h"
#import "BTNullability.h"
#import "BTTokenized.h"

BT_ASSUME_NONNULL_BEGIN

/// A tokenization service that supports registration of tokenizers at runtime.
///
/// @note `BTTokenizationService` provides access to different payment option tokenizers (e.g.
/// `BTPayPalDriver`) without requiring explicit compile-time dependencies on the frameworks.
/// Classes such as `BTPaymentButton` can use the tokenization service
///
@interface BTTokenizationService : NSObject

+ (instancetype)sharedService;

- (void)registerType:(NSString *)type withTokenizationBlock:(void(^)(BTAPIClient *apiClient, NSDictionary *options, void(^)(id<BTTokenized> tokenization, NSError *error)))tokenizationBlock;

- (BOOL)isTypeAvailable:(NSString *)type;

/// Tokenize with nil options
- (void)tokenizeType:(NSString *)type
       withAPIClient:(BTAPIClient *)apiClient
          completion:(void(^)(id<BTTokenized> tokenization, NSError *error))completion;

- (void)tokenizeType:(NSString *)type
             options:(BT_NULLABLE BT_GENERICS(NSDictionary, NSString *, id) *)options
       withAPIClient:(BTAPIClient *)apiClient
          completion:(void(^)(id<BTTokenized> tokenization, NSError *error))completion;

@property (nonatomic, readonly, strong) NSArray *allTypes;

@end

BT_ASSUME_NONNULL_END
