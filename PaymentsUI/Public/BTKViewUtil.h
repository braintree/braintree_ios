#import <UIKit/UIKit.h>

#import "BTKCardType.h"
#import "BTKPaymentOptionType.h"

@class BTKVectorArtView;

/// Utilities used by other views
@interface BTKViewUtil : NSObject

+ (BTKPaymentOptionType)paymentMethodTypeForCardType:(BTKCardType *)cardType;
+ (NSString *)nameForPaymentMethodType:(BTKPaymentOptionType)paymentMethodType;

+ (void)vibrate;

+ (BTKVectorArtView *)vectorArtViewForPaymentInfoType:(NSString *)typeString;
+ (BTKVectorArtView *)vectorArtViewForPaymentOptionType:(BTKPaymentOptionType)type;

#pragma mark Utilities

+ (BTKPaymentOptionType)paymentOptionTypeForPaymentInfoType:(NSString *)typeString;

+ (BOOL)isLanguageLayoutDirectionRightToLeft;
+ (NSTextAlignment)naturalTextAlignment;
+ (NSTextAlignment)naturalTextAlignmentInverse;
@end
