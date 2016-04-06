#if __has_include("BraintreeCard.h")
#import "BraintreeCard.h"
#else
#import <BraintreeCard/BraintreeCard.h>
#endif

@class BTCardCapabilities, BTCardTokenizationRequest;

NS_ASSUME_NONNULL_BEGIN

@interface BTCardClient (UnionPay)

/// Fetches the capabilities of a card number.
///
/// This should be used to look up a card PAN to see whether it is UnionPay, and if so, what is required to tokenize it.
///
/// @param cardNumber The card number.
/// @param completion A completion block that is invoked when the card capabilities have been fetched.
- (void)fetchCapabilities:(NSString *)cardNumber
               completion:(void (^)(BTCardCapabilities * _Nullable cardCapabilities, NSError * _Nullable error))completion;

/// Enrolls a UnionPay card. Attempting to enroll non-UnionPay cards will cause an error.
///
/// @param request A card tokenization request that contains a card, mobile phone number, and country code. Cannot be `nil`.
/// After successful enrollment, the request's `enrollmentID` parameter is set to a unique ID.
/// @param completion A callback block that will be invoked on the main thread when enrollment has completed. If enrollment
/// succeeds, error` will be `nil`; if it fails, `error` will describe the failure.
- (void)enrollCard:(BTCardTokenizationRequest *)request
        completion:(void (^)(NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
