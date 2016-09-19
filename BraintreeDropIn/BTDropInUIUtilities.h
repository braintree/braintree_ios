#import <UIKit/UIKit.h>
#if __has_include("BraintreeUIKit.h")
#import "BraintreeUIKit.h"
#else
#import <BraintreeUIKit.h>
#endif

@interface BTDropInUIUtilities : NSObject

+ (UIView *)addSpacerToStackView:(UIStackView*)stackView beforeView:(UIView*)view size:(float)size;
+ (UIStackView *)newStackView;
+ (UIStackView *)newStackViewForError:(NSString*)errorText;

@end
