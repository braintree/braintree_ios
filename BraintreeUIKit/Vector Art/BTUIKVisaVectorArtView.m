#import "BTUIKVisaVectorArtView.h"

@implementation BTUIKVisaVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor22 = [UIColor colorWithRed: 0.955 green: 0.661 blue: 0.034 alpha: 1];
    UIColor* fillColor23 = [UIColor colorWithRed: 0.123 green: 0.11 blue: 0.351 alpha: 1];
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(4.82, 22.33, 35.35, 3.15)];
    [fillColor22 setFill];
    [rectangle2Path fill];
    
    
    //// Rectangle 3 Drawing
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRect: CGRectMake(4.82, 3.52, 35.35, 3.15)];
    [fillColor23 setFill];
    [rectangle3Path fill];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(22.2, 10.16)];
    [bezierPath addLineToPoint: CGPointMake(20.33, 18.86)];
    [bezierPath addLineToPoint: CGPointMake(18.08, 18.86)];
    [bezierPath addLineToPoint: CGPointMake(19.94, 10.16)];
    [bezierPath addLineToPoint: CGPointMake(22.2, 10.16)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(31.67, 15.78)];
    [bezierPath addLineToPoint: CGPointMake(32.86, 12.51)];
    [bezierPath addLineToPoint: CGPointMake(33.54, 15.78)];
    [bezierPath addLineToPoint: CGPointMake(31.67, 15.78)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(34.18, 18.86)];
    [bezierPath addLineToPoint: CGPointMake(36.27, 18.86)];
    [bezierPath addLineToPoint: CGPointMake(34.45, 10.16)];
    [bezierPath addLineToPoint: CGPointMake(32.53, 10.16)];
    [bezierPath addCurveToPoint: CGPointMake(31.57, 10.79) controlPoint1: CGPointMake(32.09, 10.16) controlPoint2: CGPointMake(31.73, 10.41)];
    [bezierPath addLineToPoint: CGPointMake(28.19, 18.86)];
    [bezierPath addLineToPoint: CGPointMake(30.55, 18.86)];
    [bezierPath addLineToPoint: CGPointMake(31.02, 17.56)];
    [bezierPath addLineToPoint: CGPointMake(33.91, 17.56)];
    [bezierPath addLineToPoint: CGPointMake(34.18, 18.86)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(28.3, 16.02)];
    [bezierPath addCurveToPoint: CGPointMake(25.15, 12.57) controlPoint1: CGPointMake(28.31, 13.72) controlPoint2: CGPointMake(25.13, 13.6)];
    [bezierPath addCurveToPoint: CGPointMake(26.11, 11.84) controlPoint1: CGPointMake(25.16, 12.26) controlPoint2: CGPointMake(25.45, 11.92)];
    [bezierPath addCurveToPoint: CGPointMake(28.33, 12.23) controlPoint1: CGPointMake(26.43, 11.8) controlPoint2: CGPointMake(27.32, 11.76)];
    [bezierPath addLineToPoint: CGPointMake(28.72, 10.38)];
    [bezierPath addCurveToPoint: CGPointMake(26.61, 10) controlPoint1: CGPointMake(28.18, 10.19) controlPoint2: CGPointMake(27.48, 10)];
    [bezierPath addCurveToPoint: CGPointMake(22.81, 12.87) controlPoint1: CGPointMake(24.39, 10) controlPoint2: CGPointMake(22.82, 11.18)];
    [bezierPath addCurveToPoint: CGPointMake(24.78, 15.24) controlPoint1: CGPointMake(22.79, 14.13) controlPoint2: CGPointMake(23.93, 14.83)];
    [bezierPath addCurveToPoint: CGPointMake(25.95, 16.33) controlPoint1: CGPointMake(25.66, 15.67) controlPoint2: CGPointMake(25.95, 15.94)];
    [bezierPath addCurveToPoint: CGPointMake(24.6, 17.18) controlPoint1: CGPointMake(25.94, 16.91) controlPoint2: CGPointMake(25.25, 17.17)];
    [bezierPath addCurveToPoint: CGPointMake(22.29, 16.63) controlPoint1: CGPointMake(23.47, 17.2) controlPoint2: CGPointMake(22.81, 16.87)];
    [bezierPath addLineToPoint: CGPointMake(21.88, 18.54)];
    [bezierPath addCurveToPoint: CGPointMake(24.38, 19) controlPoint1: CGPointMake(22.41, 18.78) controlPoint2: CGPointMake(23.38, 18.99)];
    [bezierPath addCurveToPoint: CGPointMake(28.3, 16.02) controlPoint1: CGPointMake(26.75, 19) controlPoint2: CGPointMake(28.3, 17.83)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(18.98, 10.16)];
    [bezierPath addLineToPoint: CGPointMake(15.33, 18.86)];
    [bezierPath addLineToPoint: CGPointMake(12.95, 18.86)];
    [bezierPath addLineToPoint: CGPointMake(11.15, 11.91)];
    [bezierPath addCurveToPoint: CGPointMake(10.62, 11.15) controlPoint1: CGPointMake(11.04, 11.49) controlPoint2: CGPointMake(10.95, 11.33)];
    [bezierPath addCurveToPoint: CGPointMake(8.4, 10.41) controlPoint1: CGPointMake(10.08, 10.86) controlPoint2: CGPointMake(9.18, 10.58)];
    [bezierPath addLineToPoint: CGPointMake(8.45, 10.16)];
    [bezierPath addLineToPoint: CGPointMake(12.28, 10.16)];
    [bezierPath addCurveToPoint: CGPointMake(13.32, 11.04) controlPoint1: CGPointMake(12.77, 10.16) controlPoint2: CGPointMake(13.21, 10.48)];
    [bezierPath addLineToPoint: CGPointMake(14.27, 16.08)];
    [bezierPath addLineToPoint: CGPointMake(16.61, 10.16)];
    [bezierPath addLineToPoint: CGPointMake(18.98, 10.16)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    
    [fillColor23 setFill];
    [bezierPath fill];
}
@end
