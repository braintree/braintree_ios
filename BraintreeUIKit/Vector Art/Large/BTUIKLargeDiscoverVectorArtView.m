#import "BTUIKLargeDiscoverVectorArtView.h"

@implementation BTUIKLargeDiscoverVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor5 = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    UIColor* fillColor6 = [UIColor colorWithRed: 0.936 green: 0.419 blue: 0.115 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(6.6, 43.21)];
    [bezierPath addCurveToPoint: CGPointMake(3.17, 44.23) controlPoint1: CGPointMake(5.81, 43.92) controlPoint2: CGPointMake(4.79, 44.23)];
    [bezierPath addLineToPoint: CGPointMake(2.5, 44.23)];
    [bezierPath addLineToPoint: CGPointMake(2.5, 35.75)];
    [bezierPath addLineToPoint: CGPointMake(3.17, 35.75)];
    [bezierPath addCurveToPoint: CGPointMake(6.6, 36.79) controlPoint1: CGPointMake(4.79, 35.75) controlPoint2: CGPointMake(5.77, 36.04)];
    [bezierPath addCurveToPoint: CGPointMake(7.98, 39.98) controlPoint1: CGPointMake(7.46, 37.56) controlPoint2: CGPointMake(7.98, 38.75)];
    [bezierPath addCurveToPoint: CGPointMake(6.6, 43.21) controlPoint1: CGPointMake(7.98, 41.21) controlPoint2: CGPointMake(7.46, 42.44)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(3.67, 33.58)];
    [bezierPath addLineToPoint: CGPointMake(0, 33.58)];
    [bezierPath addLineToPoint: CGPointMake(0, 46.41)];
    [bezierPath addLineToPoint: CGPointMake(3.65, 46.41)];
    [bezierPath addCurveToPoint: CGPointMake(8.23, 44.93) controlPoint1: CGPointMake(5.6, 46.41) controlPoint2: CGPointMake(7, 45.95)];
    [bezierPath addCurveToPoint: CGPointMake(10.56, 40) controlPoint1: CGPointMake(9.7, 43.72) controlPoint2: CGPointMake(10.56, 41.89)];
    [bezierPath addCurveToPoint: CGPointMake(3.67, 33.58) controlPoint1: CGPointMake(10.56, 36.21) controlPoint2: CGPointMake(7.73, 33.58)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    
    [fillColor5 setFill];
    [bezierPath fill];
    
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRect: CGRectMake(11.7, 33.57, 2.5, 12.85)];
    [fillColor5 setFill];
    [rectangle2Path fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(20.33, 38.5)];
    [bezier2Path addCurveToPoint: CGPointMake(18.39, 36.89) controlPoint1: CGPointMake(18.83, 37.94) controlPoint2: CGPointMake(18.39, 37.58)];
    [bezier2Path addCurveToPoint: CGPointMake(20.26, 35.46) controlPoint1: CGPointMake(18.39, 36.08) controlPoint2: CGPointMake(19.18, 35.46)];
    [bezier2Path addCurveToPoint: CGPointMake(22.27, 36.5) controlPoint1: CGPointMake(21.01, 35.46) controlPoint2: CGPointMake(21.62, 35.77)];
    [bezier2Path addLineToPoint: CGPointMake(23.58, 34.79)];
    [bezier2Path addCurveToPoint: CGPointMake(19.81, 33.37) controlPoint1: CGPointMake(22.51, 33.85) controlPoint2: CGPointMake(21.22, 33.37)];
    [bezier2Path addCurveToPoint: CGPointMake(15.81, 37.04) controlPoint1: CGPointMake(17.54, 33.37) controlPoint2: CGPointMake(15.81, 34.94)];
    [bezier2Path addCurveToPoint: CGPointMake(18.97, 40.56) controlPoint1: CGPointMake(15.81, 38.81) controlPoint2: CGPointMake(16.62, 39.71)];
    [bezier2Path addCurveToPoint: CGPointMake(20.7, 41.29) controlPoint1: CGPointMake(19.95, 40.91) controlPoint2: CGPointMake(20.45, 41.14)];
    [bezier2Path addCurveToPoint: CGPointMake(21.45, 42.62) controlPoint1: CGPointMake(21.2, 41.62) controlPoint2: CGPointMake(21.45, 42.08)];
    [bezier2Path addCurveToPoint: CGPointMake(19.51, 44.43) controlPoint1: CGPointMake(21.45, 43.66) controlPoint2: CGPointMake(20.62, 44.43)];
    [bezier2Path addCurveToPoint: CGPointMake(16.77, 42.72) controlPoint1: CGPointMake(18.31, 44.43) controlPoint2: CGPointMake(17.35, 43.83)];
    [bezier2Path addLineToPoint: CGPointMake(15.16, 44.27)];
    [bezier2Path addCurveToPoint: CGPointMake(19.6, 46.72) controlPoint1: CGPointMake(16.31, 45.97) controlPoint2: CGPointMake(17.7, 46.72)];
    [bezier2Path addCurveToPoint: CGPointMake(24.02, 42.5) controlPoint1: CGPointMake(22.2, 46.72) controlPoint2: CGPointMake(24.02, 44.99)];
    [bezier2Path addCurveToPoint: CGPointMake(20.33, 38.5) controlPoint1: CGPointMake(24.02, 40.46) controlPoint2: CGPointMake(23.18, 39.54)];
    [bezier2Path closePath];
    bezier2Path.usesEvenOddFillRule = YES;
    
    [fillColor5 setFill];
    [bezier2Path fill];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(24.81, 40)];
    [bezier3Path addCurveToPoint: CGPointMake(31.59, 46.7) controlPoint1: CGPointMake(24.81, 43.77) controlPoint2: CGPointMake(27.78, 46.7)];
    [bezier3Path addCurveToPoint: CGPointMake(34.72, 45.95) controlPoint1: CGPointMake(32.66, 46.7) controlPoint2: CGPointMake(33.59, 46.48)];
    [bezier3Path addLineToPoint: CGPointMake(34.72, 43)];
    [bezier3Path addCurveToPoint: CGPointMake(31.7, 44.41) controlPoint1: CGPointMake(33.72, 44) controlPoint2: CGPointMake(32.84, 44.41)];
    [bezier3Path addCurveToPoint: CGPointMake(27.39, 39.98) controlPoint1: CGPointMake(29.18, 44.41) controlPoint2: CGPointMake(27.39, 42.58)];
    [bezier3Path addCurveToPoint: CGPointMake(31.59, 35.58) controlPoint1: CGPointMake(27.39, 37.52) controlPoint2: CGPointMake(29.24, 35.58)];
    [bezier3Path addCurveToPoint: CGPointMake(34.72, 37.02) controlPoint1: CGPointMake(32.78, 35.58) controlPoint2: CGPointMake(33.68, 36)];
    [bezier3Path addLineToPoint: CGPointMake(34.72, 34.07)];
    [bezier3Path addCurveToPoint: CGPointMake(31.65, 33.29) controlPoint1: CGPointMake(33.63, 33.52) controlPoint2: CGPointMake(32.72, 33.29)];
    [bezier3Path addCurveToPoint: CGPointMake(24.81, 40) controlPoint1: CGPointMake(27.85, 33.29) controlPoint2: CGPointMake(24.81, 36.27)];
    [bezier3Path closePath];
    bezier3Path.usesEvenOddFillRule = YES;
    
    [fillColor5 setFill];
    [bezier3Path fill];
    
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(35.55, 33.2, 13.6, 13.6)];
    [fillColor6 setFill];
    [ovalPath fill];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(54.57, 42.19)];
    [bezier4Path addLineToPoint: CGPointMake(51.15, 33.58)];
    [bezier4Path addLineToPoint: CGPointMake(48.41, 33.58)];
    [bezier4Path addLineToPoint: CGPointMake(53.86, 46.74)];
    [bezier4Path addLineToPoint: CGPointMake(55.2, 46.74)];
    [bezier4Path addLineToPoint: CGPointMake(60.75, 33.58)];
    [bezier4Path addLineToPoint: CGPointMake(58.03, 33.58)];
    [bezier4Path addLineToPoint: CGPointMake(54.57, 42.19)];
    [bezier4Path closePath];
    bezier4Path.usesEvenOddFillRule = YES;
    
    [fillColor5 setFill];
    [bezier4Path fill];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(61.88, 46.41)];
    [bezier5Path addLineToPoint: CGPointMake(68.97, 46.41)];
    [bezier5Path addLineToPoint: CGPointMake(68.97, 44.23)];
    [bezier5Path addLineToPoint: CGPointMake(64.38, 44.23)];
    [bezier5Path addLineToPoint: CGPointMake(64.38, 40.77)];
    [bezier5Path addLineToPoint: CGPointMake(68.81, 40.77)];
    [bezier5Path addLineToPoint: CGPointMake(68.81, 38.6)];
    [bezier5Path addLineToPoint: CGPointMake(64.38, 38.6)];
    [bezier5Path addLineToPoint: CGPointMake(64.38, 35.75)];
    [bezier5Path addLineToPoint: CGPointMake(68.97, 35.75)];
    [bezier5Path addLineToPoint: CGPointMake(68.97, 33.58)];
    [bezier5Path addLineToPoint: CGPointMake(61.88, 33.58)];
    [bezier5Path addLineToPoint: CGPointMake(61.88, 46.41)];
    [bezier5Path closePath];
    bezier5Path.usesEvenOddFillRule = YES;
    
    [fillColor5 setFill];
    [bezier5Path fill];
    
    
    //// Bezier 6 Drawing
    UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
    [bezier6Path moveToPoint: CGPointMake(73.86, 39.48)];
    [bezier6Path addLineToPoint: CGPointMake(73.13, 39.48)];
    [bezier6Path addLineToPoint: CGPointMake(73.13, 35.6)];
    [bezier6Path addLineToPoint: CGPointMake(73.9, 35.6)];
    [bezier6Path addCurveToPoint: CGPointMake(76.31, 37.5) controlPoint1: CGPointMake(75.46, 35.6) controlPoint2: CGPointMake(76.31, 36.25)];
    [bezier6Path addCurveToPoint: CGPointMake(73.86, 39.48) controlPoint1: CGPointMake(76.31, 38.79) controlPoint2: CGPointMake(75.46, 39.48)];
    [bezier6Path closePath];
    [bezier6Path moveToPoint: CGPointMake(78.88, 37.36)];
    [bezier6Path addCurveToPoint: CGPointMake(74.34, 33.58) controlPoint1: CGPointMake(78.88, 34.96) controlPoint2: CGPointMake(77.23, 33.58)];
    [bezier6Path addLineToPoint: CGPointMake(70.63, 33.58)];
    [bezier6Path addLineToPoint: CGPointMake(70.63, 46.41)];
    [bezier6Path addLineToPoint: CGPointMake(73.13, 46.41)];
    [bezier6Path addLineToPoint: CGPointMake(73.13, 41.25)];
    [bezier6Path addLineToPoint: CGPointMake(73.46, 41.25)];
    [bezier6Path addLineToPoint: CGPointMake(76.92, 46.41)];
    [bezier6Path addLineToPoint: CGPointMake(80, 46.41)];
    [bezier6Path addLineToPoint: CGPointMake(75.96, 41)];
    [bezier6Path addCurveToPoint: CGPointMake(78.88, 37.36) controlPoint1: CGPointMake(77.85, 40.62) controlPoint2: CGPointMake(78.88, 39.33)];
    [bezier6Path closePath];
    bezier6Path.usesEvenOddFillRule = YES;
    
    [fillColor5 setFill];
    [bezier6Path fill];
}
@end
