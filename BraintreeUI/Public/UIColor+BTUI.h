#import <UIKit/UIKit.h>

/**
 UIColor category for BTUI
 */
@interface UIColor (BTUI)

+ (instancetype)bt_colorWithBytesR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b A:(NSInteger)a;
+ (instancetype)bt_colorWithBytesR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b;
+ (instancetype)bt_colorFromHex:(NSString *)hex alpha:(CGFloat)alpha;

- (instancetype)bt_adjustedBrightness:(CGFloat)adjustment;

@end
