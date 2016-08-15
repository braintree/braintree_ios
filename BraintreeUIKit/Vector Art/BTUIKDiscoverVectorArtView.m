#import "BTUIKDiscoverVectorArtView.h"

@implementation BTUIKDiscoverVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor5 = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    UIColor* fillColor6 = [UIColor colorWithRed: 0.936 green: 0.419 blue: 0.115 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(6.63, 16.03)];
    [bezierPath addCurveToPoint: CGPointMake(5.01, 16.51) controlPoint1: CGPointMake(6.26, 16.36) controlPoint2: CGPointMake(5.77, 16.51)];
    [bezierPath addLineToPoint: CGPointMake(4.69, 16.51)];
    [bezierPath addLineToPoint: CGPointMake(4.69, 12.48)];
    [bezierPath addLineToPoint: CGPointMake(5.01, 12.48)];
    [bezierPath addCurveToPoint: CGPointMake(6.63, 12.97) controlPoint1: CGPointMake(5.77, 12.48) controlPoint2: CGPointMake(6.24, 12.62)];
    [bezierPath addCurveToPoint: CGPointMake(7.29, 14.49) controlPoint1: CGPointMake(7.04, 13.34) controlPoint2: CGPointMake(7.29, 13.91)];
    [bezierPath addCurveToPoint: CGPointMake(6.63, 16.03) controlPoint1: CGPointMake(7.29, 15.08) controlPoint2: CGPointMake(7.04, 15.66)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(5.24, 11.45)];
    [bezierPath addLineToPoint: CGPointMake(3.5, 11.45)];
    [bezierPath addLineToPoint: CGPointMake(3.5, 17.54)];
    [bezierPath addLineToPoint: CGPointMake(5.24, 17.54)];
    [bezierPath addCurveToPoint: CGPointMake(7.41, 16.84) controlPoint1: CGPointMake(6.16, 17.54) controlPoint2: CGPointMake(6.83, 17.33)];
    [bezierPath addCurveToPoint: CGPointMake(8.52, 14.5) controlPoint1: CGPointMake(8.11, 16.26) controlPoint2: CGPointMake(8.52, 15.4)];
    [bezierPath addCurveToPoint: CGPointMake(5.24, 11.45) controlPoint1: CGPointMake(8.52, 12.7) controlPoint2: CGPointMake(7.17, 11.45)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    
    [fillColor5 setFill];
    [bezierPath fill];
    
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(9.05, 11.45, 1.2, 6.1)];
    [fillColor5 setFill];
    [rectangle2Path fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(13.16, 13.79)];
    [bezier2Path addCurveToPoint: CGPointMake(12.24, 13.02) controlPoint1: CGPointMake(12.45, 13.52) controlPoint2: CGPointMake(12.24, 13.35)];
    [bezier2Path addCurveToPoint: CGPointMake(13.12, 12.34) controlPoint1: CGPointMake(12.24, 12.64) controlPoint2: CGPointMake(12.61, 12.34)];
    [bezier2Path addCurveToPoint: CGPointMake(14.08, 12.84) controlPoint1: CGPointMake(13.48, 12.34) controlPoint2: CGPointMake(13.77, 12.49)];
    [bezier2Path addLineToPoint: CGPointMake(14.7, 12.02)];
    [bezier2Path addCurveToPoint: CGPointMake(12.91, 11.35) controlPoint1: CGPointMake(14.19, 11.58) controlPoint2: CGPointMake(13.58, 11.35)];
    [bezier2Path addCurveToPoint: CGPointMake(11.01, 13.09) controlPoint1: CGPointMake(11.83, 11.35) controlPoint2: CGPointMake(11.01, 12.1)];
    [bezier2Path addCurveToPoint: CGPointMake(12.51, 14.77) controlPoint1: CGPointMake(11.01, 13.93) controlPoint2: CGPointMake(11.39, 14.36)];
    [bezier2Path addCurveToPoint: CGPointMake(13.33, 15.11) controlPoint1: CGPointMake(12.98, 14.93) controlPoint2: CGPointMake(13.21, 15.04)];
    [bezier2Path addCurveToPoint: CGPointMake(13.69, 15.74) controlPoint1: CGPointMake(13.57, 15.27) controlPoint2: CGPointMake(13.69, 15.49)];
    [bezier2Path addCurveToPoint: CGPointMake(12.76, 16.6) controlPoint1: CGPointMake(13.69, 16.24) controlPoint2: CGPointMake(13.3, 16.6)];
    [bezier2Path addCurveToPoint: CGPointMake(11.47, 15.79) controlPoint1: CGPointMake(12.2, 16.6) controlPoint2: CGPointMake(11.74, 16.32)];
    [bezier2Path addLineToPoint: CGPointMake(10.7, 16.53)];
    [bezier2Path addCurveToPoint: CGPointMake(12.81, 17.69) controlPoint1: CGPointMake(11.25, 17.33) controlPoint2: CGPointMake(11.9, 17.69)];
    [bezier2Path addCurveToPoint: CGPointMake(14.91, 15.69) controlPoint1: CGPointMake(14.04, 17.69) controlPoint2: CGPointMake(14.91, 16.87)];
    [bezier2Path addCurveToPoint: CGPointMake(13.16, 13.79) controlPoint1: CGPointMake(14.91, 14.72) controlPoint2: CGPointMake(14.51, 14.28)];
    [bezier2Path closePath];
    bezier2Path.usesEvenOddFillRule = YES;
    
    [fillColor5 setFill];
    [bezier2Path fill];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(15.29, 14.5)];
    [bezier3Path addCurveToPoint: CGPointMake(18.5, 17.68) controlPoint1: CGPointMake(15.29, 16.29) controlPoint2: CGPointMake(16.69, 17.68)];
    [bezier3Path addCurveToPoint: CGPointMake(19.99, 17.33) controlPoint1: CGPointMake(19.01, 17.68) controlPoint2: CGPointMake(19.45, 17.58)];
    [bezier3Path addLineToPoint: CGPointMake(19.99, 15.93)];
    [bezier3Path addCurveToPoint: CGPointMake(18.56, 16.59) controlPoint1: CGPointMake(19.52, 16.4) controlPoint2: CGPointMake(19.1, 16.59)];
    [bezier3Path addCurveToPoint: CGPointMake(16.51, 14.49) controlPoint1: CGPointMake(17.36, 16.59) controlPoint2: CGPointMake(16.51, 15.73)];
    [bezier3Path addCurveToPoint: CGPointMake(18.5, 12.4) controlPoint1: CGPointMake(16.51, 13.32) controlPoint2: CGPointMake(17.39, 12.4)];
    [bezier3Path addCurveToPoint: CGPointMake(19.99, 13.08) controlPoint1: CGPointMake(19.07, 12.4) controlPoint2: CGPointMake(19.5, 12.6)];
    [bezier3Path addLineToPoint: CGPointMake(19.99, 11.69)];
    [bezier3Path addCurveToPoint: CGPointMake(18.53, 11.31) controlPoint1: CGPointMake(19.47, 11.42) controlPoint2: CGPointMake(19.04, 11.31)];
    [bezier3Path addCurveToPoint: CGPointMake(15.29, 14.5) controlPoint1: CGPointMake(16.73, 11.31) controlPoint2: CGPointMake(15.29, 12.73)];
    [bezier3Path closePath];
    bezier3Path.usesEvenOddFillRule = YES;
    
    [fillColor5 setFill];
    [bezier3Path fill];
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(20.35, 11.25, 6.5, 6.5)];
    [fillColor6 setFill];
    [ovalPath fill];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(29.42, 15.54)];
    [bezier4Path addLineToPoint: CGPointMake(27.79, 11.45)];
    [bezier4Path addLineToPoint: CGPointMake(26.5, 11.45)];
    [bezier4Path addLineToPoint: CGPointMake(29.08, 17.7)];
    [bezier4Path addLineToPoint: CGPointMake(29.72, 17.7)];
    [bezier4Path addLineToPoint: CGPointMake(32.35, 11.45)];
    [bezier4Path addLineToPoint: CGPointMake(31.07, 11.45)];
    [bezier4Path addLineToPoint: CGPointMake(29.42, 15.54)];
    [bezier4Path closePath];
    bezier4Path.usesEvenOddFillRule = YES;
    
    [fillColor5 setFill];
    [bezier4Path fill];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(32.89, 17.54)];
    [bezier5Path addLineToPoint: CGPointMake(36.26, 17.54)];
    [bezier5Path addLineToPoint: CGPointMake(36.26, 16.51)];
    [bezier5Path addLineToPoint: CGPointMake(34.08, 16.51)];
    [bezier5Path addLineToPoint: CGPointMake(34.08, 14.87)];
    [bezier5Path addLineToPoint: CGPointMake(36.18, 14.87)];
    [bezier5Path addLineToPoint: CGPointMake(36.18, 13.83)];
    [bezier5Path addLineToPoint: CGPointMake(34.08, 13.83)];
    [bezier5Path addLineToPoint: CGPointMake(34.08, 12.48)];
    [bezier5Path addLineToPoint: CGPointMake(36.26, 12.48)];
    [bezier5Path addLineToPoint: CGPointMake(36.26, 11.45)];
    [bezier5Path addLineToPoint: CGPointMake(32.89, 11.45)];
    [bezier5Path addLineToPoint: CGPointMake(32.89, 17.54)];
    [bezier5Path closePath];
    bezier5Path.usesEvenOddFillRule = YES;
    
    [fillColor5 setFill];
    [bezier5Path fill];
    
    
    //// Bezier 6 Drawing
    UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
    [bezier6Path moveToPoint: CGPointMake(38.58, 14.25)];
    [bezier6Path addLineToPoint: CGPointMake(38.24, 14.25)];
    [bezier6Path addLineToPoint: CGPointMake(38.24, 12.41)];
    [bezier6Path addLineToPoint: CGPointMake(38.6, 12.41)];
    [bezier6Path addCurveToPoint: CGPointMake(39.75, 13.31) controlPoint1: CGPointMake(39.34, 12.41) controlPoint2: CGPointMake(39.75, 12.72)];
    [bezier6Path addCurveToPoint: CGPointMake(38.58, 14.25) controlPoint1: CGPointMake(39.75, 13.92) controlPoint2: CGPointMake(39.34, 14.25)];
    [bezier6Path closePath];
    [bezier6Path moveToPoint: CGPointMake(40.97, 13.25)];
    [bezier6Path addCurveToPoint: CGPointMake(38.81, 11.45) controlPoint1: CGPointMake(40.97, 12.11) controlPoint2: CGPointMake(40.18, 11.45)];
    [bezier6Path addLineToPoint: CGPointMake(37.05, 11.45)];
    [bezier6Path addLineToPoint: CGPointMake(37.05, 17.54)];
    [bezier6Path addLineToPoint: CGPointMake(38.24, 17.54)];
    [bezier6Path addLineToPoint: CGPointMake(38.24, 15.09)];
    [bezier6Path addLineToPoint: CGPointMake(38.39, 15.09)];
    [bezier6Path addLineToPoint: CGPointMake(40.04, 17.54)];
    [bezier6Path addLineToPoint: CGPointMake(41.5, 17.54)];
    [bezier6Path addLineToPoint: CGPointMake(39.58, 14.98)];
    [bezier6Path addCurveToPoint: CGPointMake(40.97, 13.25) controlPoint1: CGPointMake(40.48, 14.79) controlPoint2: CGPointMake(40.97, 14.18)];
    [bezier6Path closePath];
    bezier6Path.usesEvenOddFillRule = YES;
    
    [fillColor5 setFill];
    [bezier6Path fill];
    
    
    //// Bezier 7 Drawing
    UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
    [bezier7Path moveToPoint: CGPointMake(45, 17.49)];
    [bezier7Path addCurveToPoint: CGPointMake(14, 29) controlPoint1: CGPointMake(45, 17.49) controlPoint2: CGPointMake(34.05, 25.44)];
    [bezier7Path addLineToPoint: CGPointMake(45, 29)];
    [bezier7Path addLineToPoint: CGPointMake(45, 17.49)];
    [bezier7Path closePath];
    bezier7Path.usesEvenOddFillRule = YES;
    
    [fillColor6 setFill];
    [bezier7Path fill];
}
@end
