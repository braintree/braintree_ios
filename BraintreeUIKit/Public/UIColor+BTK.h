#import <UIKit/UIKit.h>

@interface UIColor (BTK)

/// Color with bytes and alpha
+ (instancetype)BTK_colorWithBytesR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b A:(NSInteger)a;

/// Color with bytes
+ (instancetype)BTK_colorWithBytesR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b;

/// Color from hex string with alpha
+ (instancetype)BTK_colorFromHex:(NSString *)hex alpha:(CGFloat)alpha;

/// Asjusts the brightness of a color
- (instancetype)BTK_adjustedBrightness:(CGFloat)adjustment;

@end
