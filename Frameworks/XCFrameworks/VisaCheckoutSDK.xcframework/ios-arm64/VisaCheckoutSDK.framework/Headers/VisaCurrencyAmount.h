/**
 Copyright © 2018 Visa. All rights reserved.
 */

#import <Foundation/Foundation.h>

/**
 A `VisaCurrencyAmount` encapsulates money values. It can be initialized
 with String, NSDecimalNumber, double, and int types.
 */
NS_SWIFT_NAME(CurrencyAmount)
@interface VisaCurrencyAmount: NSObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

/**
 Initialize `VisaCurrencyAmount` with int amount
 
 @param amount the amount as NSInteger
 */
- (instancetype _Nonnull)initWithInt:(NSInteger)amount;

/**
 Initialize `VisaCurrencyAmount` with double amount
 
 @param amount the amount as double
 */
- (instancetype _Nonnull)initWithDouble:(double)amount;

/**
 Initialize `VisaCurrencyAmount` with NSString amount
 
 @param amount the amount as String
 */
- (instancetype _Nonnull)initWithString:(NSString *_Nonnull)amount;

/**
 Initialize `VisaCurrencyAmount` with NSDecimalNumber amount
 
 @param amount the amount as NSDecimalNumber
 */
- (instancetype _Nonnull)initWithDecimalNumber:(NSDecimalNumber *_Nonnull)amount;

/// :nodoc:
- (nonnull instancetype)initWithIntegerLiteral:(NSInteger)value DEPRECATED_MSG_ATTRIBUTE("Might not work as expected");
/// :nodoc:
- (nonnull instancetype)initWithFloatLiteral:(double)value DEPRECATED_MSG_ATTRIBUTE("Might not work as expected");
/// :nodoc:
- (nonnull instancetype)initWithStringLiteral:(NSString * _Nonnull)value DEPRECATED_MSG_ATTRIBUTE("Might not work as expected");
/// :nodoc:
- (nonnull instancetype)initWithExtendedGraphemeClusterLiteral:(NSString * _Nonnull)value DEPRECATED_MSG_ATTRIBUTE("Might not work as expected");
/// :nodoc:
- (nonnull instancetype)initWithUnicodeScalarLiteral:(NSString * _Nonnull)value DEPRECATED_MSG_ATTRIBUTE("Might not work as expected");

@end
