#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

#import "BTCard.h"
#import "BTCardNonce.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const BTCardClientErrorDomain;

typedef NS_ENUM(NSInteger, BTCardClientErrorType) {
    BTCardClientErrorTypeUnknown = 0,
    
    /// Braintree SDK is integrated incorrectly
    BTCardClientErrorTypeIntegration,
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
- (void)tokenizeCard:(BTCard *)card completion:(void (^)(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error))completionBlock;

@end

NS_ASSUME_NONNULL_END
