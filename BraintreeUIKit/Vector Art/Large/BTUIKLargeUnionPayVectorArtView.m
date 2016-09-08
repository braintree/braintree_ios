#import "BTUIKLargeUnionPayVectorArtView.h"

@implementation BTUIKLargeUnionPayVectorArtView

- (void)drawArt {
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* fillColor17 = [UIColor colorWithRed: 0.847 green: 0 blue: 0.166 alpha: 1];
    UIColor* fillColor18 = [UIColor colorWithRed: 0.019 green: 0.198 blue: 0.406 alpha: 1];
    UIColor* fillColor19 = [UIColor colorWithRed: 0.052 green: 0.41 blue: 0.443 alpha: 1];
    UIColor* fillColor20 = [UIColor colorWithRed: 0.995 green: 0.995 blue: 0.995 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(19.93, 19.36)];
    [bezierPath addLineToPoint: CGPointMake(36.4, 19.36)];
    [bezierPath addCurveToPoint: CGPointMake(39.59, 23.54) controlPoint1: CGPointMake(38.7, 19.36) controlPoint2: CGPointMake(40.13, 21.23)];
    [bezierPath addLineToPoint: CGPointMake(31.92, 56.47)];
    [bezierPath addCurveToPoint: CGPointMake(26.78, 60.64) controlPoint1: CGPointMake(31.38, 58.77) controlPoint2: CGPointMake(29.08, 60.64)];
    [bezierPath addLineToPoint: CGPointMake(10.31, 60.64)];
    [bezierPath addCurveToPoint: CGPointMake(7.11, 56.47) controlPoint1: CGPointMake(8.01, 60.64) controlPoint2: CGPointMake(6.58, 58.77)];
    [bezierPath addLineToPoint: CGPointMake(14.79, 23.54)];
    [bezierPath addCurveToPoint: CGPointMake(19.93, 19.36) controlPoint1: CGPointMake(15.32, 21.23) controlPoint2: CGPointMake(17.62, 19.36)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    
    [fillColor17 setFill];
    [bezierPath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(35.03, 19.36)];
    [bezier2Path addLineToPoint: CGPointMake(53.97, 19.36)];
    [bezier2Path addCurveToPoint: CGPointMake(54.69, 23.54) controlPoint1: CGPointMake(56.27, 19.36) controlPoint2: CGPointMake(55.24, 21.23)];
    [bezier2Path addLineToPoint: CGPointMake(47.03, 56.47)];
    [bezier2Path addCurveToPoint: CGPointMake(44.35, 60.64) controlPoint1: CGPointMake(46.49, 58.77) controlPoint2: CGPointMake(46.66, 60.64)];
    [bezier2Path addLineToPoint: CGPointMake(25.41, 60.64)];
    [bezier2Path addCurveToPoint: CGPointMake(22.22, 56.47) controlPoint1: CGPointMake(23.1, 60.64) controlPoint2: CGPointMake(21.68, 58.77)];
    [bezier2Path addLineToPoint: CGPointMake(29.89, 23.54)];
    [bezier2Path addCurveToPoint: CGPointMake(35.03, 19.36) controlPoint1: CGPointMake(30.43, 21.23) controlPoint2: CGPointMake(32.73, 19.36)];
    [bezier2Path closePath];
    bezier2Path.usesEvenOddFillRule = YES;
    
    [fillColor18 setFill];
    [bezier2Path fill];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(53.22, 19.36)];
    [bezier3Path addLineToPoint: CGPointMake(69.69, 19.36)];
    [bezier3Path addCurveToPoint: CGPointMake(72.89, 23.54) controlPoint1: CGPointMake(72, 19.36) controlPoint2: CGPointMake(73.43, 21.23)];
    [bezier3Path addLineToPoint: CGPointMake(65.22, 56.47)];
    [bezier3Path addCurveToPoint: CGPointMake(60.07, 60.64) controlPoint1: CGPointMake(64.68, 58.77) controlPoint2: CGPointMake(62.38, 60.64)];
    [bezier3Path addLineToPoint: CGPointMake(43.61, 60.64)];
    [bezier3Path addCurveToPoint: CGPointMake(40.41, 56.47) controlPoint1: CGPointMake(41.3, 60.64) controlPoint2: CGPointMake(39.87, 58.77)];
    [bezier3Path addLineToPoint: CGPointMake(48.08, 23.54)];
    [bezier3Path addCurveToPoint: CGPointMake(53.22, 19.36) controlPoint1: CGPointMake(48.62, 21.23) controlPoint2: CGPointMake(50.92, 19.36)];
    [bezier3Path closePath];
    bezier3Path.usesEvenOddFillRule = YES;
    
    [fillColor19 setFill];
    [bezier3Path fill];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(52.86, 45.02)];
    [bezier4Path addCurveToPoint: CGPointMake(51.97, 45.37) controlPoint1: CGPointMake(52.55, 45.11) controlPoint2: CGPointMake(51.97, 45.37)];
    [bezier4Path addLineToPoint: CGPointMake(52.49, 43.67)];
    [bezier4Path addLineToPoint: CGPointMake(54.03, 43.67)];
    [bezier4Path addLineToPoint: CGPointMake(53.66, 44.91)];
    [bezier4Path addCurveToPoint: CGPointMake(52.86, 45.02) controlPoint1: CGPointMake(53.66, 44.91) controlPoint2: CGPointMake(53.18, 44.94)];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(52.89, 47.45)];
    [bezier4Path addCurveToPoint: CGPointMake(52.09, 47.58) controlPoint1: CGPointMake(52.89, 47.45) controlPoint2: CGPointMake(52.41, 47.51)];
    [bezier4Path addCurveToPoint: CGPointMake(51.18, 47.98) controlPoint1: CGPointMake(51.77, 47.67) controlPoint2: CGPointMake(51.18, 47.98)];
    [bezier4Path addLineToPoint: CGPointMake(51.71, 46.21)];
    [bezier4Path addLineToPoint: CGPointMake(53.27, 46.21)];
    [bezier4Path addLineToPoint: CGPointMake(52.89, 47.45)];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(52.02, 50.33)];
    [bezier4Path addLineToPoint: CGPointMake(50.47, 50.33)];
    [bezier4Path addLineToPoint: CGPointMake(50.92, 48.84)];
    [bezier4Path addLineToPoint: CGPointMake(52.47, 48.84)];
    [bezier4Path addLineToPoint: CGPointMake(52.02, 50.33)];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(54.45, 50.31)];
    [bezier4Path addLineToPoint: CGPointMake(53.91, 50.31)];
    [bezier4Path addLineToPoint: CGPointMake(55.92, 43.67)];
    [bezier4Path addLineToPoint: CGPointMake(56.59, 43.67)];
    [bezier4Path addLineToPoint: CGPointMake(56.8, 42.99)];
    [bezier4Path addLineToPoint: CGPointMake(56.82, 43.75)];
    [bezier4Path addCurveToPoint: CGPointMake(58.14, 44.56) controlPoint1: CGPointMake(56.8, 44.22) controlPoint2: CGPointMake(57.16, 44.64)];
    [bezier4Path addLineToPoint: CGPointMake(59.26, 44.56)];
    [bezier4Path addLineToPoint: CGPointMake(59.65, 43.28)];
    [bezier4Path addLineToPoint: CGPointMake(59.23, 43.28)];
    [bezier4Path addCurveToPoint: CGPointMake(58.88, 43.09) controlPoint1: CGPointMake(58.98, 43.28) controlPoint2: CGPointMake(58.87, 43.22)];
    [bezier4Path addLineToPoint: CGPointMake(58.86, 42.32)];
    [bezier4Path addLineToPoint: CGPointMake(56.78, 42.32)];
    [bezier4Path addLineToPoint: CGPointMake(56.78, 42.32)];
    [bezier4Path addCurveToPoint: CGPointMake(53.69, 42.49) controlPoint1: CGPointMake(56.1, 42.33) controlPoint2: CGPointMake(54.1, 42.39)];
    [bezier4Path addCurveToPoint: CGPointMake(52.68, 43) controlPoint1: CGPointMake(53.2, 42.62) controlPoint2: CGPointMake(52.68, 43)];
    [bezier4Path addLineToPoint: CGPointMake(52.88, 42.31)];
    [bezier4Path addLineToPoint: CGPointMake(50.93, 42.31)];
    [bezier4Path addLineToPoint: CGPointMake(50.53, 43.67)];
    [bezier4Path addLineToPoint: CGPointMake(48.49, 50.41)];
    [bezier4Path addLineToPoint: CGPointMake(48.1, 50.41)];
    [bezier4Path addLineToPoint: CGPointMake(47.71, 51.69)];
    [bezier4Path addLineToPoint: CGPointMake(51.59, 51.69)];
    [bezier4Path addLineToPoint: CGPointMake(51.46, 52.11)];
    [bezier4Path addLineToPoint: CGPointMake(53.37, 52.11)];
    [bezier4Path addLineToPoint: CGPointMake(53.5, 51.69)];
    [bezier4Path addLineToPoint: CGPointMake(54.03, 51.69)];
    [bezier4Path addLineToPoint: CGPointMake(54.45, 50.31)];
    [bezier4Path closePath];
    bezier4Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier4Path fill];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(55.76, 46.21)];
    [bezier5Path addLineToPoint: CGPointMake(58, 46.21)];
    [bezier5Path addLineToPoint: CGPointMake(57.68, 47.25)];
    [bezier5Path addLineToPoint: CGPointMake(55.41, 47.25)];
    [bezier5Path addLineToPoint: CGPointMake(55.07, 48.39)];
    [bezier5Path addLineToPoint: CGPointMake(57.05, 48.39)];
    [bezier5Path addLineToPoint: CGPointMake(55.55, 50.5)];
    [bezier5Path addCurveToPoint: CGPointMake(55.25, 50.76) controlPoint1: CGPointMake(55.45, 50.66) controlPoint2: CGPointMake(55.36, 50.71)];
    [bezier5Path addCurveToPoint: CGPointMake(54.85, 50.87) controlPoint1: CGPointMake(55.15, 50.81) controlPoint2: CGPointMake(55, 50.87)];
    [bezier5Path addLineToPoint: CGPointMake(54.29, 50.87)];
    [bezier5Path addLineToPoint: CGPointMake(53.92, 52.12)];
    [bezier5Path addLineToPoint: CGPointMake(55.36, 52.12)];
    [bezier5Path addCurveToPoint: CGPointMake(56.88, 51.34) controlPoint1: CGPointMake(56.11, 52.12) controlPoint2: CGPointMake(56.55, 51.78)];
    [bezier5Path addLineToPoint: CGPointMake(57.91, 49.92)];
    [bezier5Path addLineToPoint: CGPointMake(58.13, 51.36)];
    [bezier5Path addCurveToPoint: CGPointMake(58.5, 51.84) controlPoint1: CGPointMake(58.17, 51.62) controlPoint2: CGPointMake(58.37, 51.78)];
    [bezier5Path addCurveToPoint: CGPointMake(59, 52.06) controlPoint1: CGPointMake(58.64, 51.91) controlPoint2: CGPointMake(58.79, 52.04)];
    [bezier5Path addCurveToPoint: CGPointMake(59.5, 52.08) controlPoint1: CGPointMake(59.23, 52.07) controlPoint2: CGPointMake(59.39, 52.08)];
    [bezier5Path addLineToPoint: CGPointMake(60.2, 52.08)];
    [bezier5Path addLineToPoint: CGPointMake(60.63, 50.68)];
    [bezier5Path addLineToPoint: CGPointMake(60.35, 50.68)];
    [bezier5Path addCurveToPoint: CGPointMake(59.87, 50.6) controlPoint1: CGPointMake(60.19, 50.68) controlPoint2: CGPointMake(59.91, 50.65)];
    [bezier5Path addCurveToPoint: CGPointMake(59.79, 50.3) controlPoint1: CGPointMake(59.82, 50.54) controlPoint2: CGPointMake(59.82, 50.45)];
    [bezier5Path addLineToPoint: CGPointMake(59.57, 48.87)];
    [bezier5Path addLineToPoint: CGPointMake(58.65, 48.87)];
    [bezier5Path addLineToPoint: CGPointMake(59.05, 48.39)];
    [bezier5Path addLineToPoint: CGPointMake(61.32, 48.39)];
    [bezier5Path addLineToPoint: CGPointMake(61.66, 47.25)];
    [bezier5Path addLineToPoint: CGPointMake(59.57, 47.25)];
    [bezier5Path addLineToPoint: CGPointMake(59.9, 46.21)];
    [bezier5Path addLineToPoint: CGPointMake(61.99, 46.21)];
    [bezier5Path addLineToPoint: CGPointMake(62.38, 44.92)];
    [bezier5Path addLineToPoint: CGPointMake(56.15, 44.92)];
    [bezier5Path addLineToPoint: CGPointMake(55.76, 46.21)];
    [bezier5Path closePath];
    bezier5Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier5Path fill];
    
    
    //// Bezier 6 Drawing
    UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
    [bezier6Path moveToPoint: CGPointMake(36.86, 50.62)];
    [bezier6Path addLineToPoint: CGPointMake(37.38, 48.88)];
    [bezier6Path addLineToPoint: CGPointMake(39.53, 48.88)];
    [bezier6Path addLineToPoint: CGPointMake(39.92, 47.59)];
    [bezier6Path addLineToPoint: CGPointMake(37.77, 47.59)];
    [bezier6Path addLineToPoint: CGPointMake(38.1, 46.52)];
    [bezier6Path addLineToPoint: CGPointMake(40.2, 46.52)];
    [bezier6Path addLineToPoint: CGPointMake(40.59, 45.27)];
    [bezier6Path addLineToPoint: CGPointMake(35.34, 45.27)];
    [bezier6Path addLineToPoint: CGPointMake(34.96, 46.52)];
    [bezier6Path addLineToPoint: CGPointMake(36.15, 46.52)];
    [bezier6Path addLineToPoint: CGPointMake(35.83, 47.59)];
    [bezier6Path addLineToPoint: CGPointMake(34.63, 47.59)];
    [bezier6Path addLineToPoint: CGPointMake(34.24, 48.9)];
    [bezier6Path addLineToPoint: CGPointMake(35.43, 48.9)];
    [bezier6Path addLineToPoint: CGPointMake(34.73, 51.21)];
    [bezier6Path addCurveToPoint: CGPointMake(34.86, 51.77) controlPoint1: CGPointMake(34.64, 51.51) controlPoint2: CGPointMake(34.78, 51.62)];
    [bezier6Path addCurveToPoint: CGPointMake(35.25, 52.05) controlPoint1: CGPointMake(34.96, 51.9) controlPoint2: CGPointMake(35.04, 52)];
    [bezier6Path addCurveToPoint: CGPointMake(35.8, 52.12) controlPoint1: CGPointMake(35.46, 52.09) controlPoint2: CGPointMake(35.61, 52.12)];
    [bezier6Path addLineToPoint: CGPointMake(38.22, 52.12)];
    [bezier6Path addLineToPoint: CGPointMake(38.65, 50.69)];
    [bezier6Path addLineToPoint: CGPointMake(37.58, 50.84)];
    [bezier6Path addCurveToPoint: CGPointMake(36.86, 50.62) controlPoint1: CGPointMake(37.37, 50.84) controlPoint2: CGPointMake(36.8, 50.81)];
    [bezier6Path closePath];
    bezier6Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier6Path fill];
    
    
    //// Bezier 7 Drawing
    UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
    [bezier7Path moveToPoint: CGPointMake(37.11, 42.3)];
    [bezier7Path addLineToPoint: CGPointMake(36.57, 43.28)];
    [bezier7Path addCurveToPoint: CGPointMake(36.25, 43.69) controlPoint1: CGPointMake(36.45, 43.5) controlPoint2: CGPointMake(36.34, 43.63)];
    [bezier7Path addCurveToPoint: CGPointMake(35.76, 43.77) controlPoint1: CGPointMake(36.17, 43.75) controlPoint2: CGPointMake(36, 43.77)];
    [bezier7Path addLineToPoint: CGPointMake(35.48, 43.77)];
    [bezier7Path addLineToPoint: CGPointMake(35.1, 45.03)];
    [bezier7Path addLineToPoint: CGPointMake(36.04, 45.03)];
    [bezier7Path addCurveToPoint: CGPointMake(37.01, 44.78) controlPoint1: CGPointMake(36.49, 45.03) controlPoint2: CGPointMake(36.84, 44.86)];
    [bezier7Path addCurveToPoint: CGPointMake(37.37, 44.6) controlPoint1: CGPointMake(37.19, 44.68) controlPoint2: CGPointMake(37.24, 44.74)];
    [bezier7Path addLineToPoint: CGPointMake(37.69, 44.33)];
    [bezier7Path addLineToPoint: CGPointMake(40.63, 44.33)];
    [bezier7Path addLineToPoint: CGPointMake(41.03, 43.02)];
    [bezier7Path addLineToPoint: CGPointMake(38.87, 43.02)];
    [bezier7Path addLineToPoint: CGPointMake(39.25, 42.3)];
    [bezier7Path addLineToPoint: CGPointMake(37.11, 42.3)];
    [bezier7Path closePath];
    bezier7Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier7Path fill];
    
    
    //// Bezier 8 Drawing
    UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
    [bezier8Path moveToPoint: CGPointMake(42.84, 45.72)];
    [bezier8Path addLineToPoint: CGPointMake(45.85, 45.72)];
    [bezier8Path addLineToPoint: CGPointMake(45.65, 46.32)];
    [bezier8Path addCurveToPoint: CGPointMake(45.26, 46.33) controlPoint1: CGPointMake(45.63, 46.33) controlPoint2: CGPointMake(45.56, 46.29)];
    [bezier8Path addLineToPoint: CGPointMake(42.65, 46.33)];
    [bezier8Path addLineToPoint: CGPointMake(42.84, 45.72)];
    [bezier8Path closePath];
    [bezier8Path moveToPoint: CGPointMake(43.44, 43.71)];
    [bezier8Path addLineToPoint: CGPointMake(46.48, 43.71)];
    [bezier8Path addLineToPoint: CGPointMake(46.26, 44.43)];
    [bezier8Path addCurveToPoint: CGPointMake(44.6, 44.46) controlPoint1: CGPointMake(46.26, 44.43) controlPoint2: CGPointMake(44.83, 44.42)];
    [bezier8Path addCurveToPoint: CGPointMake(43, 45.17) controlPoint1: CGPointMake(43.59, 44.64) controlPoint2: CGPointMake(43, 45.17)];
    [bezier8Path addLineToPoint: CGPointMake(43.44, 43.71)];
    [bezier8Path closePath];
    [bezier8Path moveToPoint: CGPointMake(41.45, 50.64)];
    [bezier8Path addCurveToPoint: CGPointMake(41.51, 50.18) controlPoint1: CGPointMake(41.4, 50.57) controlPoint2: CGPointMake(41.44, 50.45)];
    [bezier8Path addLineToPoint: CGPointMake(42.32, 47.52)];
    [bezier8Path addLineToPoint: CGPointMake(45.18, 47.52)];
    [bezier8Path addCurveToPoint: CGPointMake(46.1, 47.49) controlPoint1: CGPointMake(45.6, 47.51) controlPoint2: CGPointMake(45.9, 47.51)];
    [bezier8Path addCurveToPoint: CGPointMake(46.78, 47.26) controlPoint1: CGPointMake(46.31, 47.47) controlPoint2: CGPointMake(46.53, 47.39)];
    [bezier8Path addCurveToPoint: CGPointMake(47.29, 46.8) controlPoint1: CGPointMake(47.04, 47.12) controlPoint2: CGPointMake(47.17, 46.97)];
    [bezier8Path addCurveToPoint: CGPointMake(47.78, 45.68) controlPoint1: CGPointMake(47.41, 46.63) controlPoint2: CGPointMake(47.61, 46.26)];
    [bezier8Path addLineToPoint: CGPointMake(48.79, 42.31)];
    [bezier8Path addLineToPoint: CGPointMake(45.82, 42.32)];
    [bezier8Path addCurveToPoint: CGPointMake(44.5, 42.61) controlPoint1: CGPointMake(45.82, 42.32) controlPoint2: CGPointMake(44.91, 42.46)];
    [bezier8Path addCurveToPoint: CGPointMake(43.52, 43.24) controlPoint1: CGPointMake(44.1, 42.78) controlPoint2: CGPointMake(43.52, 43.24)];
    [bezier8Path addLineToPoint: CGPointMake(43.79, 42.32)];
    [bezier8Path addLineToPoint: CGPointMake(41.95, 42.32)];
    [bezier8Path addLineToPoint: CGPointMake(39.38, 50.84)];
    [bezier8Path addCurveToPoint: CGPointMake(39.21, 51.55) controlPoint1: CGPointMake(39.29, 51.17) controlPoint2: CGPointMake(39.23, 51.41)];
    [bezier8Path addCurveToPoint: CGPointMake(39.54, 51.98) controlPoint1: CGPointMake(39.21, 51.71) controlPoint2: CGPointMake(39.41, 51.86)];
    [bezier8Path addCurveToPoint: CGPointMake(40.14, 52.09) controlPoint1: CGPointMake(39.69, 52.09) controlPoint2: CGPointMake(39.92, 52.08)];
    [bezier8Path addCurveToPoint: CGPointMake(41.14, 52.12) controlPoint1: CGPointMake(40.37, 52.11) controlPoint2: CGPointMake(40.7, 52.12)];
    [bezier8Path addLineToPoint: CGPointMake(42.56, 52.12)];
    [bezier8Path addLineToPoint: CGPointMake(42.99, 50.66)];
    [bezier8Path addLineToPoint: CGPointMake(41.73, 50.78)];
    [bezier8Path addCurveToPoint: CGPointMake(41.45, 50.64) controlPoint1: CGPointMake(41.59, 50.78) controlPoint2: CGPointMake(41.49, 50.71)];
    [bezier8Path closePath];
    bezier8Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier8Path fill];
    
    
    //// Bezier 9 Drawing
    UIBezierPath* bezier9Path = [UIBezierPath bezierPath];
    [bezier9Path moveToPoint: CGPointMake(45.73, 48.32)];
    [bezier9Path addCurveToPoint: CGPointMake(45.6, 48.51) controlPoint1: CGPointMake(45.7, 48.41) controlPoint2: CGPointMake(45.66, 48.47)];
    [bezier9Path addCurveToPoint: CGPointMake(45.3, 48.56) controlPoint1: CGPointMake(45.54, 48.55) controlPoint2: CGPointMake(45.44, 48.56)];
    [bezier9Path addLineToPoint: CGPointMake(44.87, 48.56)];
    [bezier9Path addLineToPoint: CGPointMake(44.89, 47.84)];
    [bezier9Path addLineToPoint: CGPointMake(43.11, 47.84)];
    [bezier9Path addLineToPoint: CGPointMake(43.04, 51.4)];
    [bezier9Path addCurveToPoint: CGPointMake(43.25, 51.93) controlPoint1: CGPointMake(43.04, 51.66) controlPoint2: CGPointMake(43.06, 51.81)];
    [bezier9Path addCurveToPoint: CGPointMake(44.8, 52.09) controlPoint1: CGPointMake(43.44, 52.08) controlPoint2: CGPointMake(44.02, 52.09)];
    [bezier9Path addLineToPoint: CGPointMake(45.92, 52.09)];
    [bezier9Path addLineToPoint: CGPointMake(46.32, 50.76)];
    [bezier9Path addLineToPoint: CGPointMake(45.34, 50.81)];
    [bezier9Path addLineToPoint: CGPointMake(45.02, 50.83)];
    [bezier9Path addCurveToPoint: CGPointMake(44.89, 50.75) controlPoint1: CGPointMake(44.98, 50.81) controlPoint2: CGPointMake(44.94, 50.79)];
    [bezier9Path addCurveToPoint: CGPointMake(44.79, 50.47) controlPoint1: CGPointMake(44.85, 50.71) controlPoint2: CGPointMake(44.78, 50.73)];
    [bezier9Path addLineToPoint: CGPointMake(44.8, 49.56)];
    [bezier9Path addLineToPoint: CGPointMake(45.82, 49.52)];
    [bezier9Path addCurveToPoint: CGPointMake(46.8, 49.17) controlPoint1: CGPointMake(46.37, 49.52) controlPoint2: CGPointMake(46.61, 49.34)];
    [bezier9Path addCurveToPoint: CGPointMake(47.13, 48.56) controlPoint1: CGPointMake(46.99, 49.01) controlPoint2: CGPointMake(47.06, 48.82)];
    [bezier9Path addLineToPoint: CGPointMake(47.3, 47.76)];
    [bezier9Path addLineToPoint: CGPointMake(45.9, 47.76)];
    [bezier9Path addLineToPoint: CGPointMake(45.73, 48.32)];
    [bezier9Path closePath];
    bezier9Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier9Path fill];
    
    
    //// Bezier 10 Drawing
    UIBezierPath* bezier10Path = [UIBezierPath bezierPath];
    [bezier10Path moveToPoint: CGPointMake(24.23, 29.91)];
    [bezier10Path addCurveToPoint: CGPointMake(21.88, 29.88) controlPoint1: CGPointMake(22.53, 29.93) controlPoint2: CGPointMake(22.04, 29.91)];
    [bezier10Path addCurveToPoint: CGPointMake(20.67, 35.44) controlPoint1: CGPointMake(21.81, 30.16) controlPoint2: CGPointMake(20.67, 35.44)];
    [bezier10Path addCurveToPoint: CGPointMake(19.63, 37.76) controlPoint1: CGPointMake(20.42, 36.51) controlPoint2: CGPointMake(20.24, 37.27)];
    [bezier10Path addCurveToPoint: CGPointMake(18.42, 38.18) controlPoint1: CGPointMake(19.29, 38.04) controlPoint2: CGPointMake(18.88, 38.18)];
    [bezier10Path addCurveToPoint: CGPointMake(17.15, 37.1) controlPoint1: CGPointMake(17.67, 38.18) controlPoint2: CGPointMake(17.23, 37.81)];
    [bezier10Path addLineToPoint: CGPointMake(17.14, 36.86)];
    [bezier10Path addCurveToPoint: CGPointMake(17.37, 35.42) controlPoint1: CGPointMake(17.14, 36.86) controlPoint2: CGPointMake(17.37, 35.43)];
    [bezier10Path addCurveToPoint: CGPointMake(18.78, 29.98) controlPoint1: CGPointMake(17.37, 35.42) controlPoint2: CGPointMake(18.57, 30.62)];
    [bezier10Path addCurveToPoint: CGPointMake(18.8, 29.91) controlPoint1: CGPointMake(18.79, 29.95) controlPoint2: CGPointMake(18.8, 29.93)];
    [bezier10Path addCurveToPoint: CGPointMake(16.02, 29.88) controlPoint1: CGPointMake(16.47, 29.93) controlPoint2: CGPointMake(16.05, 29.91)];
    [bezier10Path addCurveToPoint: CGPointMake(15.95, 30.22) controlPoint1: CGPointMake(16.01, 29.92) controlPoint2: CGPointMake(15.95, 30.22)];
    [bezier10Path addLineToPoint: CGPointMake(14.72, 35.64)];
    [bezier10Path addLineToPoint: CGPointMake(14.62, 36.1)];
    [bezier10Path addLineToPoint: CGPointMake(14.42, 37.6)];
    [bezier10Path addCurveToPoint: CGPointMake(14.68, 38.72) controlPoint1: CGPointMake(14.42, 38.04) controlPoint2: CGPointMake(14.5, 38.41)];
    [bezier10Path addCurveToPoint: CGPointMake(17.73, 39.84) controlPoint1: CGPointMake(15.24, 39.69) controlPoint2: CGPointMake(16.83, 39.84)];
    [bezier10Path addCurveToPoint: CGPointMake(20.71, 39.14) controlPoint1: CGPointMake(18.89, 39.84) controlPoint2: CGPointMake(19.98, 39.59)];
    [bezier10Path addCurveToPoint: CGPointMake(22.62, 36.16) controlPoint1: CGPointMake(21.99, 38.39) controlPoint2: CGPointMake(22.32, 37.21)];
    [bezier10Path addLineToPoint: CGPointMake(22.76, 35.63)];
    [bezier10Path addCurveToPoint: CGPointMake(24.21, 29.98) controlPoint1: CGPointMake(22.76, 35.63) controlPoint2: CGPointMake(24, 30.63)];
    [bezier10Path addCurveToPoint: CGPointMake(24.23, 29.91) controlPoint1: CGPointMake(24.21, 29.95) controlPoint2: CGPointMake(24.22, 29.93)];
    [bezier10Path closePath];
    bezier10Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier10Path fill];
    
    
    //// Bezier 11 Drawing
    UIBezierPath* bezier11Path = [UIBezierPath bezierPath];
    [bezier11Path moveToPoint: CGPointMake(28.44, 33.94)];
    [bezier11Path addCurveToPoint: CGPointMake(27.1, 34.25) controlPoint1: CGPointMake(28.14, 33.94) controlPoint2: CGPointMake(27.59, 34.01)];
    [bezier11Path addCurveToPoint: CGPointMake(26.58, 34.55) controlPoint1: CGPointMake(26.92, 34.34) controlPoint2: CGPointMake(26.76, 34.45)];
    [bezier11Path addLineToPoint: CGPointMake(26.74, 33.97)];
    [bezier11Path addLineToPoint: CGPointMake(26.65, 33.87)];
    [bezier11Path addCurveToPoint: CGPointMake(24.42, 34.25) controlPoint1: CGPointMake(25.61, 34.09) controlPoint2: CGPointMake(25.38, 34.11)];
    [bezier11Path addLineToPoint: CGPointMake(24.35, 34.3)];
    [bezier11Path addCurveToPoint: CGPointMake(23.72, 37.73) controlPoint1: CGPointMake(24.23, 35.22) controlPoint2: CGPointMake(24.13, 35.92)];
    [bezier11Path addCurveToPoint: CGPointMake(23.24, 39.74) controlPoint1: CGPointMake(23.57, 38.4) controlPoint2: CGPointMake(23.4, 39.07)];
    [bezier11Path addLineToPoint: CGPointMake(23.28, 39.82)];
    [bezier11Path addCurveToPoint: CGPointMake(25.41, 39.79) controlPoint1: CGPointMake(24.27, 39.78) controlPoint2: CGPointMake(24.56, 39.78)];
    [bezier11Path addLineToPoint: CGPointMake(25.48, 39.71)];
    [bezier11Path addCurveToPoint: CGPointMake(25.85, 37.9) controlPoint1: CGPointMake(25.59, 39.15) controlPoint2: CGPointMake(25.61, 39.03)];
    [bezier11Path addCurveToPoint: CGPointMake(26.31, 35.78) controlPoint1: CGPointMake(25.96, 37.37) controlPoint2: CGPointMake(26.19, 36.2)];
    [bezier11Path addCurveToPoint: CGPointMake(26.93, 35.58) controlPoint1: CGPointMake(26.52, 35.68) controlPoint2: CGPointMake(26.73, 35.58)];
    [bezier11Path addCurveToPoint: CGPointMake(27.34, 36.17) controlPoint1: CGPointMake(27.41, 35.58) controlPoint2: CGPointMake(27.35, 36)];
    [bezier11Path addCurveToPoint: CGPointMake(26.96, 38.14) controlPoint1: CGPointMake(27.32, 36.45) controlPoint2: CGPointMake(27.14, 37.36)];
    [bezier11Path addLineToPoint: CGPointMake(26.84, 38.65)];
    [bezier11Path addCurveToPoint: CGPointMake(26.59, 39.75) controlPoint1: CGPointMake(26.76, 39.02) controlPoint2: CGPointMake(26.67, 39.38)];
    [bezier11Path addLineToPoint: CGPointMake(26.62, 39.82)];
    [bezier11Path addCurveToPoint: CGPointMake(28.71, 39.79) controlPoint1: CGPointMake(27.59, 39.78) controlPoint2: CGPointMake(27.88, 39.78)];
    [bezier11Path addLineToPoint: CGPointMake(28.81, 39.71)];
    [bezier11Path addCurveToPoint: CGPointMake(29.27, 37.35) controlPoint1: CGPointMake(28.96, 38.84) controlPoint2: CGPointMake(29, 38.61)];
    [bezier11Path addLineToPoint: CGPointMake(29.4, 36.77)];
    [bezier11Path addCurveToPoint: CGPointMake(29.59, 34.59) controlPoint1: CGPointMake(29.66, 35.63) controlPoint2: CGPointMake(29.79, 35.06)];
    [bezier11Path addCurveToPoint: CGPointMake(28.44, 33.94) controlPoint1: CGPointMake(29.38, 34.06) controlPoint2: CGPointMake(28.89, 33.94)];
    [bezier11Path closePath];
    bezier11Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier11Path fill];
    
    
    //// Bezier 12 Drawing
    UIBezierPath* bezier12Path = [UIBezierPath bezierPath];
    [bezier12Path moveToPoint: CGPointMake(33.13, 35.13)];
    [bezier12Path addCurveToPoint: CGPointMake(31.96, 35.34) controlPoint1: CGPointMake(32.62, 35.23) controlPoint2: CGPointMake(32.29, 35.29)];
    [bezier12Path addCurveToPoint: CGPointMake(30.83, 35.5) controlPoint1: CGPointMake(31.64, 35.39) controlPoint2: CGPointMake(31.33, 35.43)];
    [bezier12Path addLineToPoint: CGPointMake(30.79, 35.54)];
    [bezier12Path addLineToPoint: CGPointMake(30.75, 35.57)];
    [bezier12Path addCurveToPoint: CGPointMake(30.6, 36.63) controlPoint1: CGPointMake(30.7, 35.94) controlPoint2: CGPointMake(30.66, 36.26)];
    [bezier12Path addCurveToPoint: CGPointMake(30.3, 38.1) controlPoint1: CGPointMake(30.54, 37.02) controlPoint2: CGPointMake(30.44, 37.46)];
    [bezier12Path addCurveToPoint: CGPointMake(30.07, 38.92) controlPoint1: CGPointMake(30.19, 38.58) controlPoint2: CGPointMake(30.13, 38.76)];
    [bezier12Path addCurveToPoint: CGPointMake(29.81, 39.74) controlPoint1: CGPointMake(30, 39.09) controlPoint2: CGPointMake(29.93, 39.26)];
    [bezier12Path addLineToPoint: CGPointMake(29.84, 39.78)];
    [bezier12Path addLineToPoint: CGPointMake(29.86, 39.82)];
    [bezier12Path addCurveToPoint: CGPointMake(30.94, 39.78) controlPoint1: CGPointMake(30.33, 39.8) controlPoint2: CGPointMake(30.63, 39.79)];
    [bezier12Path addCurveToPoint: CGPointMake(32.08, 39.79) controlPoint1: CGPointMake(31.26, 39.78) controlPoint2: CGPointMake(31.58, 39.78)];
    [bezier12Path addLineToPoint: CGPointMake(32.12, 39.75)];
    [bezier12Path addLineToPoint: CGPointMake(32.17, 39.71)];
    [bezier12Path addCurveToPoint: CGPointMake(32.3, 38.95) controlPoint1: CGPointMake(32.24, 39.28) controlPoint2: CGPointMake(32.25, 39.16)];
    [bezier12Path addCurveToPoint: CGPointMake(32.6, 37.58) controlPoint1: CGPointMake(32.34, 38.73) controlPoint2: CGPointMake(32.42, 38.42)];
    [bezier12Path addCurveToPoint: CGPointMake(32.88, 36.4) controlPoint1: CGPointMake(32.69, 37.19) controlPoint2: CGPointMake(32.79, 36.8)];
    [bezier12Path addCurveToPoint: CGPointMake(33.16, 35.22) controlPoint1: CGPointMake(32.97, 36) controlPoint2: CGPointMake(33.07, 35.61)];
    [bezier12Path addLineToPoint: CGPointMake(33.15, 35.17)];
    [bezier12Path addLineToPoint: CGPointMake(33.13, 35.13)];
    [bezier12Path closePath];
    bezier12Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier12Path fill];
    
    
    //// Bezier 13 Drawing
    UIBezierPath* bezier13Path = [UIBezierPath bezierPath];
    [bezier13Path moveToPoint: CGPointMake(35.89, 37.05)];
    [bezier13Path addCurveToPoint: CGPointMake(37.03, 35.27) controlPoint1: CGPointMake(36.11, 36.08) controlPoint2: CGPointMake(36.37, 35.27)];
    [bezier13Path addCurveToPoint: CGPointMake(37.35, 36.84) controlPoint1: CGPointMake(37.54, 35.27) controlPoint2: CGPointMake(37.58, 35.87)];
    [bezier13Path addCurveToPoint: CGPointMake(36.87, 38.2) controlPoint1: CGPointMake(37.31, 37.06) controlPoint2: CGPointMake(37.12, 37.85)];
    [bezier13Path addCurveToPoint: CGPointMake(36.25, 38.6) controlPoint1: CGPointMake(36.69, 38.44) controlPoint2: CGPointMake(36.48, 38.6)];
    [bezier13Path addCurveToPoint: CGPointMake(35.76, 37.99) controlPoint1: CGPointMake(36.18, 38.6) controlPoint2: CGPointMake(35.77, 38.6)];
    [bezier13Path addCurveToPoint: CGPointMake(35.89, 37.05) controlPoint1: CGPointMake(35.76, 37.69) controlPoint2: CGPointMake(35.82, 37.38)];
    [bezier13Path closePath];
    [bezier13Path moveToPoint: CGPointMake(35.97, 39.91)];
    [bezier13Path addCurveToPoint: CGPointMake(38.61, 38.88) controlPoint1: CGPointMake(36.91, 39.91) controlPoint2: CGPointMake(37.88, 39.65)];
    [bezier13Path addCurveToPoint: CGPointMake(39.52, 36.93) controlPoint1: CGPointMake(39.18, 38.25) controlPoint2: CGPointMake(39.43, 37.32)];
    [bezier13Path addCurveToPoint: CGPointMake(39.3, 34.7) controlPoint1: CGPointMake(39.81, 35.66) controlPoint2: CGPointMake(39.59, 35.06)];
    [bezier13Path addCurveToPoint: CGPointMake(37.32, 33.97) controlPoint1: CGPointMake(38.87, 34.15) controlPoint2: CGPointMake(38.11, 33.97)];
    [bezier13Path addCurveToPoint: CGPointMake(34.82, 34.84) controlPoint1: CGPointMake(36.84, 33.97) controlPoint2: CGPointMake(35.71, 34.02)];
    [bezier13Path addCurveToPoint: CGPointMake(33.72, 36.99) controlPoint1: CGPointMake(34.19, 35.42) controlPoint2: CGPointMake(33.9, 36.22)];
    [bezier13Path addCurveToPoint: CGPointMake(34.62, 39.69) controlPoint1: CGPointMake(33.54, 37.77) controlPoint2: CGPointMake(33.33, 39.17)];
    [bezier13Path addCurveToPoint: CGPointMake(35.97, 39.91) controlPoint1: CGPointMake(35.03, 39.86) controlPoint2: CGPointMake(35.6, 39.91)];
    [bezier13Path closePath];
    bezier13Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier13Path fill];
    
    
    //// Bezier 14 Drawing
    UIBezierPath* bezier14Path = [UIBezierPath bezierPath];
    [bezier14Path moveToPoint: CGPointMake(56.62, 37.15)];
    [bezier14Path addCurveToPoint: CGPointMake(57.76, 35.4) controlPoint1: CGPointMake(56.84, 36.2) controlPoint2: CGPointMake(57.1, 35.4)];
    [bezier14Path addCurveToPoint: CGPointMake(58.35, 36.44) controlPoint1: CGPointMake(58.18, 35.4) controlPoint2: CGPointMake(58.39, 35.78)];
    [bezier14Path addCurveToPoint: CGPointMake(58.23, 36.97) controlPoint1: CGPointMake(58.31, 36.6) controlPoint2: CGPointMake(58.28, 36.78)];
    [bezier14Path addCurveToPoint: CGPointMake(58, 37.87) controlPoint1: CGPointMake(58.16, 37.27) controlPoint2: CGPointMake(58.08, 37.57)];
    [bezier14Path addCurveToPoint: CGPointMake(57.78, 38.3) controlPoint1: CGPointMake(57.94, 38.04) controlPoint2: CGPointMake(57.86, 38.19)];
    [bezier14Path addCurveToPoint: CGPointMake(56.98, 38.69) controlPoint1: CGPointMake(57.61, 38.54) controlPoint2: CGPointMake(57.21, 38.69)];
    [bezier14Path addCurveToPoint: CGPointMake(56.49, 38.09) controlPoint1: CGPointMake(56.91, 38.69) controlPoint2: CGPointMake(56.5, 38.69)];
    [bezier14Path addCurveToPoint: CGPointMake(56.62, 37.15) controlPoint1: CGPointMake(56.49, 37.79) controlPoint2: CGPointMake(56.55, 37.48)];
    [bezier14Path closePath];
    [bezier14Path moveToPoint: CGPointMake(54.45, 37.1)];
    [bezier14Path addCurveToPoint: CGPointMake(55.35, 39.78) controlPoint1: CGPointMake(54.27, 37.87) controlPoint2: CGPointMake(54.07, 39.27)];
    [bezier14Path addCurveToPoint: CGPointMake(56.5, 39.98) controlPoint1: CGPointMake(55.76, 39.95) controlPoint2: CGPointMake(56.13, 40)];
    [bezier14Path addCurveToPoint: CGPointMake(57.59, 39.47) controlPoint1: CGPointMake(56.89, 39.96) controlPoint2: CGPointMake(57.26, 39.75)];
    [bezier14Path addCurveToPoint: CGPointMake(57.5, 39.83) controlPoint1: CGPointMake(57.56, 39.59) controlPoint2: CGPointMake(57.53, 39.71)];
    [bezier14Path addLineToPoint: CGPointMake(57.56, 39.9)];
    [bezier14Path addCurveToPoint: CGPointMake(59.77, 39.87) controlPoint1: CGPointMake(58.49, 39.86) controlPoint2: CGPointMake(58.78, 39.86)];
    [bezier14Path addLineToPoint: CGPointMake(59.87, 39.8)];
    [bezier14Path addCurveToPoint: CGPointMake(60.53, 36.46) controlPoint1: CGPointMake(60.01, 38.94) controlPoint2: CGPointMake(60.15, 38.11)];
    [bezier14Path addCurveToPoint: CGPointMake(61.09, 34.11) controlPoint1: CGPointMake(60.71, 35.68) controlPoint2: CGPointMake(60.9, 34.9)];
    [bezier14Path addLineToPoint: CGPointMake(61.06, 34.03)];
    [bezier14Path addCurveToPoint: CGPointMake(58.76, 34.4) controlPoint1: CGPointMake(60.03, 34.22) controlPoint2: CGPointMake(59.75, 34.26)];
    [bezier14Path addLineToPoint: CGPointMake(58.68, 34.46)];
    [bezier14Path addCurveToPoint: CGPointMake(58.65, 34.71) controlPoint1: CGPointMake(58.67, 34.55) controlPoint2: CGPointMake(58.66, 34.63)];
    [bezier14Path addCurveToPoint: CGPointMake(57.93, 34.1) controlPoint1: CGPointMake(58.49, 34.45) controlPoint2: CGPointMake(58.28, 34.23)];
    [bezier14Path addCurveToPoint: CGPointMake(55.55, 34.96) controlPoint1: CGPointMake(57.48, 33.93) controlPoint2: CGPointMake(56.44, 34.15)];
    [bezier14Path addCurveToPoint: CGPointMake(54.45, 37.1) controlPoint1: CGPointMake(54.93, 35.55) controlPoint2: CGPointMake(54.63, 36.34)];
    [bezier14Path closePath];
    bezier14Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier14Path fill];
    
    
    //// Bezier 15 Drawing
    UIBezierPath* bezier15Path = [UIBezierPath bezierPath];
    [bezier15Path moveToPoint: CGPointMake(41.88, 39.79)];
    [bezier15Path addLineToPoint: CGPointMake(41.96, 39.71)];
    [bezier15Path addCurveToPoint: CGPointMake(42.31, 37.9) controlPoint1: CGPointMake(42.06, 39.15) controlPoint2: CGPointMake(42.08, 39.03)];
    [bezier15Path addCurveToPoint: CGPointMake(42.78, 35.78) controlPoint1: CGPointMake(42.43, 37.37) controlPoint2: CGPointMake(42.67, 36.2)];
    [bezier15Path addCurveToPoint: CGPointMake(43.41, 35.58) controlPoint1: CGPointMake(43, 35.68) controlPoint2: CGPointMake(43.2, 35.58)];
    [bezier15Path addCurveToPoint: CGPointMake(43.81, 36.17) controlPoint1: CGPointMake(43.88, 35.58) controlPoint2: CGPointMake(43.82, 36)];
    [bezier15Path addCurveToPoint: CGPointMake(43.43, 38.14) controlPoint1: CGPointMake(43.79, 36.45) controlPoint2: CGPointMake(43.61, 37.36)];
    [bezier15Path addLineToPoint: CGPointMake(43.32, 38.65)];
    [bezier15Path addCurveToPoint: CGPointMake(43.06, 39.75) controlPoint1: CGPointMake(43.23, 39.02) controlPoint2: CGPointMake(43.14, 39.38)];
    [bezier15Path addLineToPoint: CGPointMake(43.09, 39.82)];
    [bezier15Path addCurveToPoint: CGPointMake(45.18, 39.79) controlPoint1: CGPointMake(44.06, 39.77) controlPoint2: CGPointMake(44.35, 39.77)];
    [bezier15Path addLineToPoint: CGPointMake(45.28, 39.71)];
    [bezier15Path addCurveToPoint: CGPointMake(45.74, 37.35) controlPoint1: CGPointMake(45.42, 38.84) controlPoint2: CGPointMake(45.47, 38.61)];
    [bezier15Path addLineToPoint: CGPointMake(45.87, 36.77)];
    [bezier15Path addCurveToPoint: CGPointMake(46.07, 34.59) controlPoint1: CGPointMake(46.13, 35.63) controlPoint2: CGPointMake(46.26, 35.06)];
    [bezier15Path addCurveToPoint: CGPointMake(44.9, 33.94) controlPoint1: CGPointMake(45.85, 34.06) controlPoint2: CGPointMake(45.35, 33.94)];
    [bezier15Path addCurveToPoint: CGPointMake(43.57, 34.25) controlPoint1: CGPointMake(44.61, 33.94) controlPoint2: CGPointMake(44.06, 34.01)];
    [bezier15Path addCurveToPoint: CGPointMake(43.05, 34.55) controlPoint1: CGPointMake(43.4, 34.34) controlPoint2: CGPointMake(43.22, 34.45)];
    [bezier15Path addLineToPoint: CGPointMake(43.2, 33.97)];
    [bezier15Path addLineToPoint: CGPointMake(43.12, 33.87)];
    [bezier15Path addCurveToPoint: CGPointMake(40.89, 34.25) controlPoint1: CGPointMake(42.08, 34.09) controlPoint2: CGPointMake(41.85, 34.11)];
    [bezier15Path addLineToPoint: CGPointMake(40.82, 34.3)];
    [bezier15Path addCurveToPoint: CGPointMake(40.19, 37.73) controlPoint1: CGPointMake(40.7, 35.22) controlPoint2: CGPointMake(40.61, 35.92)];
    [bezier15Path addCurveToPoint: CGPointMake(39.71, 39.74) controlPoint1: CGPointMake(40.04, 38.4) controlPoint2: CGPointMake(39.88, 39.07)];
    [bezier15Path addLineToPoint: CGPointMake(39.76, 39.82)];
    [bezier15Path addCurveToPoint: CGPointMake(41.88, 39.79) controlPoint1: CGPointMake(40.74, 39.77) controlPoint2: CGPointMake(41.03, 39.77)];
    [bezier15Path closePath];
    bezier15Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier15Path fill];
    
    
    //// Bezier 16 Drawing
    UIBezierPath* bezier16Path = [UIBezierPath bezierPath];
    [bezier16Path moveToPoint: CGPointMake(50.21, 34.54)];
    [bezier16Path addCurveToPoint: CGPointMake(50.89, 31.59) controlPoint1: CGPointMake(50.21, 34.54) controlPoint2: CGPointMake(50.89, 31.58)];
    [bezier16Path addLineToPoint: CGPointMake(50.9, 31.43)];
    [bezier16Path addLineToPoint: CGPointMake(50.92, 31.32)];
    [bezier16Path addLineToPoint: CGPointMake(51.19, 31.34)];
    [bezier16Path addCurveToPoint: CGPointMake(52.63, 31.47) controlPoint1: CGPointMake(51.19, 31.34) controlPoint2: CGPointMake(52.6, 31.47)];
    [bezier16Path addCurveToPoint: CGPointMake(53.25, 32.96) controlPoint1: CGPointMake(53.19, 31.68) controlPoint2: CGPointMake(53.42, 32.24)];
    [bezier16Path addCurveToPoint: CGPointMake(52.13, 34.45) controlPoint1: CGPointMake(53.11, 33.62) controlPoint2: CGPointMake(52.68, 34.18)];
    [bezier16Path addCurveToPoint: CGPointMake(50.55, 34.69) controlPoint1: CGPointMake(51.67, 34.67) controlPoint2: CGPointMake(51.12, 34.69)];
    [bezier16Path addLineToPoint: CGPointMake(50.18, 34.69)];
    [bezier16Path addLineToPoint: CGPointMake(50.21, 34.54)];
    [bezier16Path closePath];
    [bezier16Path moveToPoint: CGPointMake(49.02, 39.82)];
    [bezier16Path addCurveToPoint: CGPointMake(49.44, 37.76) controlPoint1: CGPointMake(49.08, 39.53) controlPoint2: CGPointMake(49.44, 37.76)];
    [bezier16Path addCurveToPoint: CGPointMake(49.77, 36.42) controlPoint1: CGPointMake(49.44, 37.76) controlPoint2: CGPointMake(49.75, 36.46)];
    [bezier16Path addCurveToPoint: CGPointMake(49.97, 36.23) controlPoint1: CGPointMake(49.77, 36.42) controlPoint2: CGPointMake(49.87, 36.28)];
    [bezier16Path addLineToPoint: CGPointMake(50.11, 36.23)];
    [bezier16Path addCurveToPoint: CGPointMake(54.17, 35.35) controlPoint1: CGPointMake(51.46, 36.23) controlPoint2: CGPointMake(52.98, 36.23)];
    [bezier16Path addCurveToPoint: CGPointMake(55.79, 32.78) controlPoint1: CGPointMake(54.98, 34.75) controlPoint2: CGPointMake(55.54, 33.86)];
    [bezier16Path addCurveToPoint: CGPointMake(55.9, 31.88) controlPoint1: CGPointMake(55.85, 32.51) controlPoint2: CGPointMake(55.9, 32.2)];
    [bezier16Path addCurveToPoint: CGPointMake(55.58, 30.74) controlPoint1: CGPointMake(55.9, 31.47) controlPoint2: CGPointMake(55.82, 31.06)];
    [bezier16Path addCurveToPoint: CGPointMake(52.36, 29.87) controlPoint1: CGPointMake(54.97, 29.89) controlPoint2: CGPointMake(53.76, 29.88)];
    [bezier16Path addCurveToPoint: CGPointMake(51.67, 29.88) controlPoint1: CGPointMake(52.35, 29.87) controlPoint2: CGPointMake(51.67, 29.88)];
    [bezier16Path addCurveToPoint: CGPointMake(48.86, 29.85) controlPoint1: CGPointMake(49.88, 29.9) controlPoint2: CGPointMake(49.16, 29.89)];
    [bezier16Path addCurveToPoint: CGPointMake(48.79, 30.22) controlPoint1: CGPointMake(48.84, 29.98) controlPoint2: CGPointMake(48.79, 30.22)];
    [bezier16Path addCurveToPoint: CGPointMake(48.15, 33.19) controlPoint1: CGPointMake(48.79, 30.22) controlPoint2: CGPointMake(48.15, 33.19)];
    [bezier16Path addCurveToPoint: CGPointMake(46.54, 39.81) controlPoint1: CGPointMake(48.15, 33.19) controlPoint2: CGPointMake(46.62, 39.52)];
    [bezier16Path addCurveToPoint: CGPointMake(49.02, 39.82) controlPoint1: CGPointMake(48.11, 39.8) controlPoint2: CGPointMake(48.75, 39.8)];
    [bezier16Path closePath];
    bezier16Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier16Path fill];
    
    
    //// Bezier 17 Drawing
    UIBezierPath* bezier17Path = [UIBezierPath bezierPath];
    [bezier17Path moveToPoint: CGPointMake(67.96, 34.02)];
    [bezier17Path addLineToPoint: CGPointMake(67.88, 33.93)];
    [bezier17Path addCurveToPoint: CGPointMake(65.73, 34.29) controlPoint1: CGPointMake(66.86, 34.13) controlPoint2: CGPointMake(66.67, 34.17)];
    [bezier17Path addLineToPoint: CGPointMake(65.66, 34.36)];
    [bezier17Path addCurveToPoint: CGPointMake(65.65, 34.41) controlPoint1: CGPointMake(65.66, 34.38) controlPoint2: CGPointMake(65.66, 34.39)];
    [bezier17Path addLineToPoint: CGPointMake(65.65, 34.39)];
    [bezier17Path addCurveToPoint: CGPointMake(64.4, 36.93) controlPoint1: CGPointMake(64.95, 36.01) controlPoint2: CGPointMake(64.97, 35.66)];
    [bezier17Path addCurveToPoint: CGPointMake(64.39, 36.77) controlPoint1: CGPointMake(64.4, 36.87) controlPoint2: CGPointMake(64.4, 36.83)];
    [bezier17Path addLineToPoint: CGPointMake(64.25, 34.02)];
    [bezier17Path addLineToPoint: CGPointMake(64.16, 33.93)];
    [bezier17Path addCurveToPoint: CGPointMake(62.08, 34.29) controlPoint1: CGPointMake(63.09, 34.13) controlPoint2: CGPointMake(63.07, 34.17)];
    [bezier17Path addLineToPoint: CGPointMake(62, 34.36)];
    [bezier17Path addCurveToPoint: CGPointMake(61.98, 34.47) controlPoint1: CGPointMake(61.99, 34.4) controlPoint2: CGPointMake(61.99, 34.43)];
    [bezier17Path addLineToPoint: CGPointMake(61.99, 34.49)];
    [bezier17Path addCurveToPoint: CGPointMake(62.21, 35.97) controlPoint1: CGPointMake(62.11, 35.12) controlPoint2: CGPointMake(62.09, 34.98)];
    [bezier17Path addCurveToPoint: CGPointMake(62.4, 37.44) controlPoint1: CGPointMake(62.27, 36.46) controlPoint2: CGPointMake(62.34, 36.96)];
    [bezier17Path addCurveToPoint: CGPointMake(62.67, 39.88) controlPoint1: CGPointMake(62.5, 38.25) controlPoint2: CGPointMake(62.55, 38.65)];
    [bezier17Path addCurveToPoint: CGPointMake(61.21, 42.37) controlPoint1: CGPointMake(62, 40.99) controlPoint2: CGPointMake(61.84, 41.4)];
    [bezier17Path addLineToPoint: CGPointMake(61.21, 42.38)];
    [bezier17Path addLineToPoint: CGPointMake(60.75, 43.1)];
    [bezier17Path addCurveToPoint: CGPointMake(60.59, 43.24) controlPoint1: CGPointMake(60.7, 43.17) controlPoint2: CGPointMake(60.65, 43.22)];
    [bezier17Path addCurveToPoint: CGPointMake(60.29, 43.29) controlPoint1: CGPointMake(60.52, 43.28) controlPoint2: CGPointMake(60.42, 43.29)];
    [bezier17Path addLineToPoint: CGPointMake(60.04, 43.29)];
    [bezier17Path addLineToPoint: CGPointMake(59.67, 44.53)];
    [bezier17Path addLineToPoint: CGPointMake(60.95, 44.55)];
    [bezier17Path addCurveToPoint: CGPointMake(62.43, 43.72) controlPoint1: CGPointMake(61.7, 44.55) controlPoint2: CGPointMake(62.17, 44.19)];
    [bezier17Path addLineToPoint: CGPointMake(63.23, 42.35)];
    [bezier17Path addLineToPoint: CGPointMake(63.22, 42.35)];
    [bezier17Path addLineToPoint: CGPointMake(63.3, 42.25)];
    [bezier17Path addCurveToPoint: CGPointMake(67.96, 34.02) controlPoint1: CGPointMake(63.84, 41.08) controlPoint2: CGPointMake(67.96, 34.02)];
    [bezier17Path closePath];
    bezier17Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier17Path fill];
    
    
    //// Oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 32.15, 34.2);
    CGContextRotateCTM(context, -14.65 * M_PI / 180);
    
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(-1.35, -0.8, 2.7, 1.6)];
    [fillColor20 setFill];
    [ovalPath fill];
    
    CGContextRestoreGState(context);
}

@end
