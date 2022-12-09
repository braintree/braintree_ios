#import <Foundation/Foundation.h>

/**
 Contains information about a card's capabilities
 */
DEPRECATED_MSG_ATTRIBUTE("The UnionPay SMS integration is deprecated, as UnionPay can now be processed as a credit card through their partnership with Discover. Use `BTCardClient.tokenizeCard(card: completion:)`.")
@interface BTCardCapabilities : NSObject

/**
 Indicates whether the card is Union Pay.
 */
@property (nonatomic, assign) BOOL isUnionPay;

/**
 Indicates whether the card is debit.
 */
@property (nonatomic, assign) BOOL isDebit;

/**
 Indicates whether the card supports two step authentication and capture.
 */
@property (nonatomic, assign) BOOL supportsTwoStepAuthAndCapture;

/**
 Indicates if the card is supported for this merchant account.
 */
@property (nonatomic, assign) BOOL isSupported;

@end
