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

/// Creates a card client.
///
/// @param apiClient An API client
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient NS_DESIGNATED_INITIALIZER;

- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));

/// Tokenizes a card.
///
/// @param card The card to tokenize. It must have a valid number and expiration date.
/// @param completionBlock A completion block that is invoked when card tokenization has completed. If tokenization succeeds,
///        `tokenizedCard` will contain a nonce and `error` will be `nil`; if it fails, `tokenizedCard` will be `nil` and `error`
///        will describe the failure.
- (void)tokenizeCard:(BTCard *)card completion:(void (^)(BTTokenizedCard * __BT_NULLABLE tokenizedCard, NSError * __BT_NULLABLE error))completionBlock;

/// The API client used by the card client.
@property (nonatomic, strong, readonly) BTAPIClient *apiClient;

@end

BT_ASSUME_NONNULL_END
