#import <Foundation/Foundation.h>
#import "BTNullability.h"
#import "BTCard.h"
#import "BTTokenizedCard.h"
#import "BTAPIClient.h"

BT_ASSUME_NONNULL_BEGIN

extern NSString * const BTCardClientErrorDomain;

typedef NS_ENUM(NSInteger, BTCardClientErrorType) {
    BTCardClientErrorTypeUnknown = 0,
    BTCardClientErrorTypeInvalidServerResponse,
};

@interface BTCardClient : NSObject

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient NS_DESIGNATED_INITIALIZER;

- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));

- (void)tokenizeCard:(BTCard *)request completion:(void (^)(BTTokenizedCard * __BT_NULLABLE tokenizedCard, NSError * __BT_NULLABLE  error))completionBlock;

@property (nonatomic, strong, readonly) BTAPIClient *apiClient;

@end

BT_ASSUME_NONNULL_END
