#import <UIKit/UIKit.h>

@interface UIColor (BTK)

+ (instancetype)BTK_colorWithBytesR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b A:(NSInteger)a;
+ (instancetype)BTK_colorWithBytesR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b;
+ (instancetype)BTK_colorFromHex:(NSString *)hex alpha:(CGFloat)alpha;
- (instancetype)BTK_adjustedBrightness:(CGFloat)adjustment;

@end
