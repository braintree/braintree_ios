#import "BTUIKVenmoMonogramCardView.h"

@implementation BTUIKVenmoMonogramCardView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor21 = [UIColor colorWithRed: 0.194 green: 0.507 blue: 0.764 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(30.82, 4.5)];
    [bezierPath addCurveToPoint: CGPointMake(31.88, 8.5) controlPoint1: CGPointMake(31.55, 5.7) controlPoint2: CGPointMake(31.88, 6.94)];
    [bezierPath addCurveToPoint: CGPointMake(24.17, 24.5) controlPoint1: CGPointMake(31.88, 13.48) controlPoint2: CGPointMake(27.62, 19.95)];
    [bezierPath addLineToPoint: CGPointMake(16.29, 24.5)];
    [bezierPath addLineToPoint: CGPointMake(13.12, 5.59)];
    [bezierPath addLineToPoint: CGPointMake(20.03, 4.94)];
    [bezierPath addLineToPoint: CGPointMake(21.7, 18.39)];
    [bezierPath addCurveToPoint: CGPointMake(25.19, 9.12) controlPoint1: CGPointMake(23.26, 15.85) controlPoint2: CGPointMake(25.19, 11.85)];
    [bezierPath addCurveToPoint: CGPointMake(24.53, 5.77) controlPoint1: CGPointMake(25.19, 7.63) controlPoint2: CGPointMake(24.93, 6.61)];
    [bezierPath addLineToPoint: CGPointMake(30.82, 4.5)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    
    [fillColor21 setFill];
    [bezierPath fill];
}

@end
