#import <Foundation/Foundation.h>

/**
 Contains information about a card's capabilities
 */
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
