#import <BraintreeCard/BraintreeCard.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTCardClient (UnionPay)

/// Tokenizes a card.
///
/// @param request A card tokenization request.
/// @param challenge A challenge block. TODO
/// @param completionBlock A completion block that is invoked when card tokenization has completed. If tokenization succeeds,
///        `tokenizedCard` will contain a nonce and `error` will be `nil`; if it fails, `tokenizedCard` will be `nil` and `error`
///        will describe the failure.
- (void)tokenizeCard:(BTCardTokenizationRequest *)request
   authCodeChallenge:(void (^)(void (^challenge)(NSString * _Nullable authCode)))challenge
          completion:(void (^)(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
