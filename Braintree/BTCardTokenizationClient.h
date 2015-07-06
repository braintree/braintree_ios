#import <Foundation/Foundation.h>
#import "BTNullability.h"
#import "BTCardTokenizationRequest.h"
#import "BTTokenizedCard.h"
#import "BTAPIClient.h"

BT_ASSUME_NONNULL_BEGIN

extern NSString *const BTCardTokenizationClientErrorDomain;

typedef NS_ENUM(NSInteger, BTCardTokenizationClientErrorType) {
    BTCardTokenizationClientErrorTypeUnknown = 0,
    BTCardTokenizationClientErrorTypeInvalidCard,
    BTCardTokenizationClientErrorTypeFatalError,
};

@interface BTCardTokenizationClient : NSObject

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient;

- (void)tokenizeCard:(BTCardTokenizationRequest *)request completion:(void (^)(BTTokenizedCard __BT_NULLABLE *tokenized, NSError __BT_NULLABLE *error))completionBlock;

@end

BT_ASSUME_NONNULL_END
