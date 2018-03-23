#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTCard.h"
#import "BTCardNonce.h"

@class BTCardRequest;

NS_ASSUME_NONNULL_BEGIN

/**
 Domain for card errors.
 */
extern NSString * const BTCardClientErrorDomain;

/**
 Error codes associated with cards.
 */
typedef NS_ENUM(NSInteger, BTCardClientErrorType) {
    /// Unknown error
    BTCardClientErrorTypeUnknown = 0,
    
    /// Braintree SDK is integrated incorrectly
    BTCardClientErrorTypeIntegration,
   
    /// Payment option (e.g. UnionPay) is not enabled for this merchant account
    BTCardClientErrorTypePaymentOptionNotEnabled,

    /// Customer provided invalid input
    BTCardClientErrorTypeCustomerInputInvalid,
};

/**
 Used to process cards
 */
@interface BTCardClient : NSObject

/**
 Creates a card client.

 @param apiClient An API client
*/
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient NS_DESIGNATED_INITIALIZER;

/**
 Base initializer - do not use.
 */
- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));

/**
 Tokenizes a card.

 @param card The card to tokenize.
 @param completion A completion block that is invoked when card tokenization has completed. If tokenization succeeds,
        `tokenizedCard` will contain a nonce and `error` will be `nil`; if it fails, `tokenizedCard` will be `nil` and `error`
        will describe the failure.
*/
- (void)tokenizeCard:(BTCard *)card completion:(void (^)(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error))completion;

/**
 Tokenizes a card.

 @param request A card tokenization request that contains an enrolled card, the enrollment ID from `enrollUnionPayCard:completion:`,
 and the enrollment auth code sent to the mobile phone number.
 @param options A dictionary containing additional options to send when performing tokenization. Optional.
 @param completion A completion block that is invoked when card tokenization has completed. If tokenization succeeds, `tokenizedCard` will contain a nonce and `error` will be `nil`; if it fails, `tokenizedCard` will be `nil` and `error` will describe the failure.
*/
- (void)tokenizeCard:(BTCardRequest *)request
             options:(nullable NSDictionary *)options
          completion:(void (^)(BTCardNonce * _Nullable tokenizedCard, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
