#import <BraintreeCard/BraintreeCard.h>

@class BTCardCapabilities;

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
   authCodeChallenge:(void (^)(void (^challengeResponse)(NSString * _Nullable authCode)))challenge
          completion:(void (^)(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error))completion;

/// Fetches the capabilities of a card number.
///
/// This should be used to look up a card PAN to see whether it is UnionPay, and if so, what is required to tokenize it.
///
/// @param cardNumber The card number.
/// @param completion A completion block that is invoked when the card capabilities have been fetched.
- (void)fetchCapabilities:(NSString *)cardNumber
               completion:(void (^)(BTCardCapabilities * _Nullable cardCapabilities, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
