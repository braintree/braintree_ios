#import "BTUIKCoinbaseMonogramCardView.h"

@implementation BTUIKCoinbaseMonogramCardView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor3 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(24.44, 25.5)];
    [bezierPath addCurveToPoint: CGPointMake(15.15, 14.48) controlPoint1: CGPointMake(19.74, 25.5) controlPoint2: CGPointMake(15.15, 22.13)];
    [bezierPath addCurveToPoint: CGPointMake(24.44, 3.5) controlPoint1: CGPointMake(15.15, 6.83) controlPoint2: CGPointMake(19.74, 3.5)];
    [bezierPath addCurveToPoint: CGPointMake(29.85, 4.95) controlPoint1: CGPointMake(26.76, 3.5) controlPoint2: CGPointMake(28.56, 4.09)];
    [bezierPath addLineToPoint: CGPointMake(28.44, 8.05)];
    [bezierPath addCurveToPoint: CGPointMake(24.99, 7.03) controlPoint1: CGPointMake(27.58, 7.42) controlPoint2: CGPointMake(26.28, 7.03)];
    [bezierPath addCurveToPoint: CGPointMake(19.58, 14.44) controlPoint1: CGPointMake(22.17, 7.03) controlPoint2: CGPointMake(19.58, 9.27)];
    [bezierPath addCurveToPoint: CGPointMake(24.99, 21.89) controlPoint1: CGPointMake(19.58, 19.62) controlPoint2: CGPointMake(22.25, 21.89)];
    [bezierPath addCurveToPoint: CGPointMake(28.44, 20.87) controlPoint1: CGPointMake(26.28, 21.89) controlPoint2: CGPointMake(27.58, 21.5)];
    [bezierPath addLineToPoint: CGPointMake(29.85, 24.05)];
    [bezierPath addCurveToPoint: CGPointMake(24.44, 25.5) controlPoint1: CGPointMake(28.52, 24.95) controlPoint2: CGPointMake(26.76, 25.5)];
    [bezierPath closePath];
    [fillColor3 setFill];
    [bezierPath fill];
}

@end
