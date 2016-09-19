#import "BTUIKLargeVisaVectorArtView.h"

@implementation BTUIKLargeVisaVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor22 = [UIColor colorWithRed: 0.955 green: 0.661 blue: 0.034 alpha: 1];
    UIColor* fillColor23 = [UIColor colorWithRed: 0.123 green: 0.11 blue: 0.351 alpha: 1];
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(7, 55.15, 66, 5.9)];
    [fillColor22 setFill];
    [rectangle2Path fill];
    
    
    //// Rectangle 3 Drawing
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(7, 19.95, 66, 5.9)];
    [fillColor23 setFill];
    [rectangle3Path fill];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(39.43, 32.38)];
    [bezierPath addLineToPoint: CGPointMake(35.95, 48.65)];
    [bezierPath addLineToPoint: CGPointMake(31.74, 48.65)];
    [bezierPath addLineToPoint: CGPointMake(35.22, 32.38)];
    [bezierPath addLineToPoint: CGPointMake(39.43, 32.38)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(57.13, 42.89)];
    [bezierPath addLineToPoint: CGPointMake(59.35, 36.78)];
    [bezierPath addLineToPoint: CGPointMake(60.62, 42.89)];
    [bezierPath addLineToPoint: CGPointMake(57.13, 42.89)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(61.83, 48.65)];
    [bezierPath addLineToPoint: CGPointMake(65.72, 48.65)];
    [bezierPath addLineToPoint: CGPointMake(62.32, 32.38)];
    [bezierPath addLineToPoint: CGPointMake(58.73, 32.38)];
    [bezierPath addCurveToPoint: CGPointMake(56.94, 33.58) controlPoint1: CGPointMake(57.92, 32.38) controlPoint2: CGPointMake(57.24, 32.85)];
    [bezierPath addLineToPoint: CGPointMake(50.63, 48.65)];
    [bezierPath addLineToPoint: CGPointMake(55.04, 48.65)];
    [bezierPath addLineToPoint: CGPointMake(55.92, 46.22)];
    [bezierPath addLineToPoint: CGPointMake(61.32, 46.22)];
    [bezierPath addLineToPoint: CGPointMake(61.83, 48.65)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(50.84, 43.34)];
    [bezierPath addCurveToPoint: CGPointMake(44.95, 36.89) controlPoint1: CGPointMake(50.86, 39.05) controlPoint2: CGPointMake(44.91, 38.81)];
    [bezierPath addCurveToPoint: CGPointMake(46.74, 35.53) controlPoint1: CGPointMake(44.96, 36.31) controlPoint2: CGPointMake(45.52, 35.69)];
    [bezierPath addCurveToPoint: CGPointMake(50.88, 36.26) controlPoint1: CGPointMake(47.34, 35.45) controlPoint2: CGPointMake(49, 35.39)];
    [bezierPath addLineToPoint: CGPointMake(51.62, 32.81)];
    [bezierPath addCurveToPoint: CGPointMake(47.69, 32.09) controlPoint1: CGPointMake(50.61, 32.44) controlPoint2: CGPointMake(49.31, 32.09)];
    [bezierPath addCurveToPoint: CGPointMake(40.58, 37.46) controlPoint1: CGPointMake(43.53, 32.09) controlPoint2: CGPointMake(40.6, 34.3)];
    [bezierPath addCurveToPoint: CGPointMake(44.26, 41.89) controlPoint1: CGPointMake(40.55, 39.81) controlPoint2: CGPointMake(42.67, 41.11)];
    [bezierPath addCurveToPoint: CGPointMake(46.44, 43.91) controlPoint1: CGPointMake(45.9, 42.69) controlPoint2: CGPointMake(46.45, 43.2)];
    [bezierPath addCurveToPoint: CGPointMake(43.93, 45.5) controlPoint1: CGPointMake(46.43, 45) controlPoint2: CGPointMake(45.13, 45.49)];
    [bezierPath addCurveToPoint: CGPointMake(39.6, 44.48) controlPoint1: CGPointMake(41.81, 45.54) controlPoint2: CGPointMake(40.58, 44.93)];
    [bezierPath addLineToPoint: CGPointMake(38.84, 48.04)];
    [bezierPath addCurveToPoint: CGPointMake(43.52, 48.9) controlPoint1: CGPointMake(39.82, 48.49) controlPoint2: CGPointMake(41.64, 48.88)];
    [bezierPath addCurveToPoint: CGPointMake(50.84, 43.34) controlPoint1: CGPointMake(47.94, 48.9) controlPoint2: CGPointMake(50.83, 46.72)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(33.42, 32.38)];
    [bezierPath addLineToPoint: CGPointMake(26.6, 48.65)];
    [bezierPath addLineToPoint: CGPointMake(22.15, 48.65)];
    [bezierPath addLineToPoint: CGPointMake(18.8, 35.67)];
    [bezierPath addCurveToPoint: CGPointMake(17.8, 34.24) controlPoint1: CGPointMake(18.59, 34.87) controlPoint2: CGPointMake(18.42, 34.58)];
    [bezierPath addCurveToPoint: CGPointMake(13.65, 32.86) controlPoint1: CGPointMake(16.79, 33.69) controlPoint2: CGPointMake(15.12, 33.18)];
    [bezierPath addLineToPoint: CGPointMake(13.75, 32.38)];
    [bezierPath addLineToPoint: CGPointMake(20.91, 32.38)];
    [bezierPath addCurveToPoint: CGPointMake(22.85, 34.04) controlPoint1: CGPointMake(21.82, 32.38) controlPoint2: CGPointMake(22.64, 32.99)];
    [bezierPath addLineToPoint: CGPointMake(24.62, 43.45)];
    [bezierPath addLineToPoint: CGPointMake(29, 32.38)];
    [bezierPath addLineToPoint: CGPointMake(33.42, 32.38)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    
    [fillColor23 setFill];
    [bezierPath fill];
}
@end
