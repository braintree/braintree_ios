#import <UIKit/UIKit.h>
#import "BTKCardType.h"
#import "BTKPaymentOptionType.h"

@class BTKVectorArtView;

/// @class Utilities used by other views to get localized strings, a BTKPaymentOptionType or artwork
@interface BTKViewUtil : NSObject

#pragma mark BTKPaymentOptionType Utilities

/// Get a BTKPaymentOptionType from a string
///
/// @param A string representing a payment option type (e.g `Visa` or `PayPal`)
/// @return The BTKPaymentOptionType associated with the string if it can be found. Otherwise, BTKPaymentOptionTypeUnknown.
+ (BTKPaymentOptionType)paymentOptionTypeForPaymentInfoType:(NSString *)typeString;
/// Get a BTKPaymentOptionType from a BTKCardType
///
/// @param cardType A BTKCardType that represents a card
/// @return The BTKPaymentOptionType associated with the BTKCardType if it can be found. Otherwise, BTKPaymentOptionTypeUnknown.
+ (BTKPaymentOptionType)paymentMethodTypeForCardType:(BTKCardType *)cardType;
/// Get a localized string for a payment option.
///
/// @param A BTKPaymentOptionType
/// @return The localized string for the BTKPaymentOptionType if one can be found. `Card` will be returned in the case of BTKPaymentOptionTypeUnknown.
+ (NSString *)nameForPaymentMethodType:(BTKPaymentOptionType)paymentMethodType;

#pragma mark Helper Utilities

/// Cause the device to vibrate
+ (void)vibrate;

#pragma mark Art Utilities

/// Get a BTKVectorArtView from a string
///
/// @param A string representing a payment option type (e.g `Visa` or `PayPal`)
/// @return The BTKVectorArtView for the string if one can be found. Otherwise the art for a generic card.
+ (BTKVectorArtView *)vectorArtViewForPaymentInfoType:(NSString *)typeString;
/// Get a BTKVectorArtView for a payment option.
///
/// @param A BTKPaymentOptionType
/// @return The BTKVectorArtView for the BTKPaymentOptionType if one can be found. Otherwise the art for a generic card.
+ (BTKVectorArtView *)vectorArtViewForPaymentOptionType:(BTKPaymentOptionType)type;

#pragma mark Right to Left Utilities

/// @return true if the language is right to left
+ (BOOL)isLanguageLayoutDirectionRightToLeft;
/// @return NSTextAlignmentRight if isLanguageLayoutDirectionRightToLeft is true. Ohterwise NSTextAlignmentLeft.
+ (NSTextAlignment)naturalTextAlignment;
/// @return NSTextAlignmentLeft if isLanguageLayoutDirectionRightToLeft is true. Ohterwise NSTextAlignmentRight.
+ (NSTextAlignment)naturalTextAlignmentInverse;
@end
