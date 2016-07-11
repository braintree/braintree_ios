#import <UIKit/UIKit.h>

@interface UIColor (BTUIK)

/// Color with bytes and alpha
+ (instancetype)BTUIK_colorWithBytesR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b A:(NSInteger)a;

/// Color with bytes
+ (instancetype)BTUIK_colorWithBytesR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b;

/// Color from hex string with alpha
+ (instancetype)BTUIK_colorFromHex:(NSString *)hex alpha:(CGFloat)alpha;

/// Asjusts the brightness of a color
- (instancetype)BTUIK_adjustedBrightness:(CGFloat)adjustment;

@end
