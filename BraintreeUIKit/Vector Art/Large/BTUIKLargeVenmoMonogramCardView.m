#import "BTUIKLargeVenmoMonogramCardView.h"

@implementation BTUIKLargeVenmoMonogramCardView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor21 = [UIColor colorWithRed: 0.194 green: 0.507 blue: 0.764 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(13.15, 32.39)];
    [bezierPath addCurveToPoint: CGPointMake(13.93, 35.37) controlPoint1: CGPointMake(13.69, 33.29) controlPoint2: CGPointMake(13.93, 34.21)];
    [bezierPath addCurveToPoint: CGPointMake(8.21, 47.25) controlPoint1: CGPointMake(13.93, 39.07) controlPoint2: CGPointMake(10.77, 43.88)];
    [bezierPath addLineToPoint: CGPointMake(2.35, 47.25)];
    [bezierPath addLineToPoint: CGPointMake(0, 33.21)];
    [bezierPath addLineToPoint: CGPointMake(5.13, 32.72)];
    [bezierPath addLineToPoint: CGPointMake(6.37, 42.71)];
    [bezierPath addCurveToPoint: CGPointMake(8.97, 35.83) controlPoint1: CGPointMake(7.53, 40.82) controlPoint2: CGPointMake(8.97, 37.85)];
    [bezierPath addCurveToPoint: CGPointMake(8.48, 33.34) controlPoint1: CGPointMake(8.97, 34.72) controlPoint2: CGPointMake(8.78, 33.96)];
    [bezierPath addLineToPoint: CGPointMake(13.15, 32.39)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    
    [fillColor21 setFill];
    [bezierPath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(19.69, 41.26)];
    [bezier2Path addCurveToPoint: CGPointMake(21.82, 43.55) controlPoint1: CGPointMake(19.69, 42.9) controlPoint2: CGPointMake(20.61, 43.55)];
    [bezier2Path addCurveToPoint: CGPointMake(26.06, 42.39) controlPoint1: CGPointMake(23.15, 43.55) controlPoint2: CGPointMake(24.41, 43.23)];
    [bezier2Path addLineToPoint: CGPointMake(25.44, 46.6)];
    [bezier2Path addCurveToPoint: CGPointMake(20.71, 47.55) controlPoint1: CGPointMake(24.28, 47.17) controlPoint2: CGPointMake(22.47, 47.55)];
    [bezier2Path addCurveToPoint: CGPointMake(14.67, 41.47) controlPoint1: CGPointMake(16.26, 47.55) controlPoint2: CGPointMake(14.67, 44.85)];
    [bezier2Path addCurveToPoint: CGPointMake(22.61, 32.45) controlPoint1: CGPointMake(14.67, 37.1) controlPoint2: CGPointMake(17.26, 32.45)];
    [bezier2Path addCurveToPoint: CGPointMake(27.2, 36.39) controlPoint1: CGPointMake(25.55, 32.45) controlPoint2: CGPointMake(27.2, 34.1)];
    [bezier2Path addCurveToPoint: CGPointMake(19.69, 41.26) controlPoint1: CGPointMake(27.2, 40.09) controlPoint2: CGPointMake(22.44, 41.23)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(19.8, 38.58)];
    [bezier2Path addCurveToPoint: CGPointMake(23.12, 36.8) controlPoint1: CGPointMake(20.74, 38.58) controlPoint2: CGPointMake(23.12, 38.15)];
    [bezier2Path addCurveToPoint: CGPointMake(22.12, 35.83) controlPoint1: CGPointMake(23.12, 36.15) controlPoint2: CGPointMake(22.66, 35.83)];
    [bezier2Path addCurveToPoint: CGPointMake(19.8, 38.58) controlPoint1: CGPointMake(21.17, 35.83) controlPoint2: CGPointMake(19.93, 36.96)];
    [bezier2Path closePath];
    bezier2Path.usesEvenOddFillRule = YES;
    
    [fillColor21 setFill];
    [bezier2Path fill];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(42, 35.69)];
    [bezier3Path addCurveToPoint: CGPointMake(41.84, 37.53) controlPoint1: CGPointMake(42, 36.23) controlPoint2: CGPointMake(41.92, 37.02)];
    [bezier3Path addLineToPoint: CGPointMake(40.3, 47.25)];
    [bezier3Path addLineToPoint: CGPointMake(35.3, 47.25)];
    [bezier3Path addLineToPoint: CGPointMake(36.7, 38.34)];
    [bezier3Path addCurveToPoint: CGPointMake(36.81, 37.34) controlPoint1: CGPointMake(36.73, 38.1) controlPoint2: CGPointMake(36.81, 37.61)];
    [bezier3Path addCurveToPoint: CGPointMake(35.92, 36.53) controlPoint1: CGPointMake(36.81, 36.69) controlPoint2: CGPointMake(36.41, 36.53)];
    [bezier3Path addCurveToPoint: CGPointMake(34.19, 37.04) controlPoint1: CGPointMake(35.27, 36.53) controlPoint2: CGPointMake(34.63, 36.83)];
    [bezier3Path addLineToPoint: CGPointMake(32.6, 47.25)];
    [bezier3Path addLineToPoint: CGPointMake(27.58, 47.25)];
    [bezier3Path addLineToPoint: CGPointMake(29.87, 32.69)];
    [bezier3Path addLineToPoint: CGPointMake(34.22, 32.69)];
    [bezier3Path addLineToPoint: CGPointMake(34.28, 33.85)];
    [bezier3Path addCurveToPoint: CGPointMake(38.57, 32.45) controlPoint1: CGPointMake(35.3, 33.18) controlPoint2: CGPointMake(36.65, 32.45)];
    [bezier3Path addCurveToPoint: CGPointMake(42, 35.69) controlPoint1: CGPointMake(41.11, 32.45) controlPoint2: CGPointMake(42, 33.75)];
    [bezier3Path closePath];
    bezier3Path.usesEvenOddFillRule = YES;
    
    [fillColor21 setFill];
    [bezier3Path fill];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(56.83, 34.04)];
    [bezier4Path addCurveToPoint: CGPointMake(61.47, 32.45) controlPoint1: CGPointMake(58.26, 33.02) controlPoint2: CGPointMake(59.61, 32.45)];
    [bezier4Path addCurveToPoint: CGPointMake(64.93, 35.69) controlPoint1: CGPointMake(64.04, 32.45) controlPoint2: CGPointMake(64.93, 33.74)];
    [bezier4Path addCurveToPoint: CGPointMake(64.77, 37.53) controlPoint1: CGPointMake(64.93, 36.23) controlPoint2: CGPointMake(64.85, 37.01)];
    [bezier4Path addLineToPoint: CGPointMake(63.23, 47.25)];
    [bezier4Path addLineToPoint: CGPointMake(58.23, 47.25)];
    [bezier4Path addLineToPoint: CGPointMake(59.66, 38.15)];
    [bezier4Path addCurveToPoint: CGPointMake(59.74, 37.42) controlPoint1: CGPointMake(59.69, 37.91) controlPoint2: CGPointMake(59.74, 37.61)];
    [bezier4Path addCurveToPoint: CGPointMake(58.85, 36.53) controlPoint1: CGPointMake(59.74, 36.69) controlPoint2: CGPointMake(59.34, 36.53)];
    [bezier4Path addCurveToPoint: CGPointMake(57.15, 37.04) controlPoint1: CGPointMake(58.23, 36.53) controlPoint2: CGPointMake(57.61, 36.8)];
    [bezier4Path addLineToPoint: CGPointMake(55.56, 47.25)];
    [bezier4Path addLineToPoint: CGPointMake(50.56, 47.25)];
    [bezier4Path addLineToPoint: CGPointMake(51.99, 38.15)];
    [bezier4Path addCurveToPoint: CGPointMake(52.07, 37.42) controlPoint1: CGPointMake(52.02, 37.91) controlPoint2: CGPointMake(52.07, 37.61)];
    [bezier4Path addCurveToPoint: CGPointMake(51.18, 36.53) controlPoint1: CGPointMake(52.07, 36.69) controlPoint2: CGPointMake(51.67, 36.53)];
    [bezier4Path addCurveToPoint: CGPointMake(49.46, 37.04) controlPoint1: CGPointMake(50.53, 36.53) controlPoint2: CGPointMake(49.89, 36.82)];
    [bezier4Path addLineToPoint: CGPointMake(47.86, 47.25)];
    [bezier4Path addLineToPoint: CGPointMake(42.84, 47.25)];
    [bezier4Path addLineToPoint: CGPointMake(45.13, 32.69)];
    [bezier4Path addLineToPoint: CGPointMake(49.43, 32.69)];
    [bezier4Path addLineToPoint: CGPointMake(49.56, 33.91)];
    [bezier4Path addCurveToPoint: CGPointMake(53.72, 32.45) controlPoint1: CGPointMake(50.56, 33.18) controlPoint2: CGPointMake(51.91, 32.45)];
    [bezier4Path addCurveToPoint: CGPointMake(56.83, 34.04) controlPoint1: CGPointMake(55.29, 32.45) controlPoint2: CGPointMake(56.31, 33.12)];
    [bezier4Path closePath];
    bezier4Path.usesEvenOddFillRule = YES;
    
    [fillColor21 setFill];
    [bezier4Path fill];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(66.23, 41.34)];
    [bezier5Path addCurveToPoint: CGPointMake(74.25, 32.45) controlPoint1: CGPointMake(66.23, 36.75) controlPoint2: CGPointMake(68.66, 32.45)];
    [bezier5Path addCurveToPoint: CGPointMake(80, 38.37) controlPoint1: CGPointMake(78.46, 32.45) controlPoint2: CGPointMake(80, 34.93)];
    [bezier5Path addCurveToPoint: CGPointMake(71.87, 47.61) controlPoint1: CGPointMake(80, 42.91) controlPoint2: CGPointMake(77.6, 47.61)];
    [bezier5Path addCurveToPoint: CGPointMake(66.23, 41.34) controlPoint1: CGPointMake(67.63, 47.61) controlPoint2: CGPointMake(66.23, 44.82)];
    [bezier5Path closePath];
    [bezier5Path moveToPoint: CGPointMake(74.87, 38.28)];
    [bezier5Path addCurveToPoint: CGPointMake(73.68, 36.28) controlPoint1: CGPointMake(74.87, 37.1) controlPoint2: CGPointMake(74.57, 36.28)];
    [bezier5Path addCurveToPoint: CGPointMake(71.3, 41.55) controlPoint1: CGPointMake(71.71, 36.28) controlPoint2: CGPointMake(71.3, 39.77)];
    [bezier5Path addCurveToPoint: CGPointMake(72.57, 43.74) controlPoint1: CGPointMake(71.3, 42.91) controlPoint2: CGPointMake(71.68, 43.74)];
    [bezier5Path addCurveToPoint: CGPointMake(74.87, 38.28) controlPoint1: CGPointMake(74.44, 43.74) controlPoint2: CGPointMake(74.87, 40.07)];
    [bezier5Path closePath];
    bezier5Path.usesEvenOddFillRule = YES;
    
    [fillColor21 setFill];
    [bezier5Path fill];
}

@end
