#if __has_include("BraintreeCard.h")
#import "BraintreeCard.h"
#else
#import <BraintreeCard/BraintreeCard.h>
#endif

@class BTCardCapabilities, BTUnionPayRequest;

NS_ASSUME_NONNULL_BEGIN

@interface BTCardClient (UnionPay)

///// Tokenizes a card.
/////
///// @param request A card tokenization request.
///// @param challenge A challenge block. TODO
///// @param completionBlock A completion block that is invoked when card tokenization has completed. If tokenization succeeds,
/////        `tokenizedCard` will contain a nonce and `error` will be `nil`; if it fails, `tokenizedCard` will be `nil` and `error`
/////        will describe the failure.
//- (void)tokenizeCard:(BTCardTokenizationRequest *)request
//   authCodeChallenge:(void (^)(void (^challengeResponse)(NSString * _Nullable authCode)))challenge
//          completion:(void (^)(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error))completion;

/// Fetches the capabilities of a card number.
///
/// This should be used to look up a card PAN to see whether it is UnionPay, and if so, what is required to tokenize it.
///
/// @param cardNumber The card number.
/// @param completion A completion block that is invoked when the card capabilities have been fetched.
- (void)fetchCapabilities:(NSString *)cardNumber
               completion:(void (^)(BTCardCapabilities * _Nullable cardCapabilities, NSError * _Nullable error))completion;

/// Enrolls a UnionPay card.
///
/// @param request A UnionPay request that contains a card, mobile phone number, and country code. Cannot be `nil`.
/// @param completion A callback block that will be invoked on the main thread when enrollment has completed. If enrollment
/// succeeds, `enrollmentID` will contain the enrollment ID and `error` will be `nil`; if it fails, `enrollmentID` will be
/// `nil` and `error` will describe the failure.
- (void)enrollUnionPayCard:(BTUnionPayRequest *)request
                completion:(void (^)(NSString * _Nullable enrollmentID, NSError * _Nullable error))completion;

/// Tokenizes a UnionPay card that has been previously enrolled.
///
/// @param request A UnionPay request that contains an enrolled card, the enrollment ID from `enrollUnionPayCard:completion:`,
/// and the enrollment auth code sent to the mobile phone number.
/// @param options A dictionary containing additional options to send when performing tokenization. Optional.
/// @param completion A completion block that is invoked when card tokenization has completed. If tokenization succeeds,
/// `tokenizedCard` will contain a nonce and `error` will be `nil`; if it fails, `tokenizedCard` will be `nil` and `error`
/// will describe the failure.
- (void)tokenizeUnionPayCard:(BTUnionPayRequest *)request
                     options:(nullable NSDictionary *)options
                  completion:(void (^)(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
