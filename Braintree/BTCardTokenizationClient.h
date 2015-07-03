#import <Foundation/Foundation.h>
#import "BTNullability.h"
#import "BTCard.h"
#import "BTTokenizedCard.h"
#import "BTConfiguration.h"

BT_ASSUME_NONNULL_BEGIN

extern NSString *const BTCardTokenizationClientErrorDomain;

typedef NS_ENUM(NSInteger, BTCardTokenizationClientErrorCode) {
    BTCardTokenizationClientErrorCodeUnknown = 0,
    BTCardTokenizationClientErrorCodeFatalError,
};

@interface BTCardTokenizationClient : NSObject

- (instancetype)initWithConfiguration:(BTConfiguration *)configuration;

- (void)tokenizeCard:(BTCard *)card completion:(void (^)(BTTokenizedCard __BT_NULLABLE *card, NSError __BT_NULLABLE *error))completionBlock;

@end

BT_ASSUME_NONNULL_END
