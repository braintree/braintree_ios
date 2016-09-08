#import "BTUIKLargeMasterCardVectorArtView.h"

@implementation BTUIKLargeMasterCardVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* fillColor4 = [UIColor colorWithRed: 0.103 green: 0.092 blue: 0.095 alpha: 1];
    UIColor* fillColor11 = [UIColor colorWithRed: 0.894 green: 0 blue: 0.111 alpha: 1];
    UIColor* fillColor13 = [UIColor colorWithRed: 0.962 green: 0.582 blue: 0.088 alpha: 1];
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(4, 18.45, 43.1, 43.1)];
    [fillColor11 setFill];
    [ovalPath fill];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(54.46, 18.46)];
    [bezierPath addCurveToPoint: CGPointMake(40, 24.04) controlPoint1: CGPointMake(48.89, 18.46) controlPoint2: CGPointMake(43.82, 20.57)];
    [bezierPath addCurveToPoint: CGPointMake(37.82, 26.32) controlPoint1: CGPointMake(39.22, 24.74) controlPoint2: CGPointMake(38.49, 25.5)];
    [bezierPath addLineToPoint: CGPointMake(42.18, 26.32)];
    [bezierPath addCurveToPoint: CGPointMake(43.82, 28.6) controlPoint1: CGPointMake(42.77, 27.04) controlPoint2: CGPointMake(43.32, 27.8)];
    [bezierPath addLineToPoint: CGPointMake(36.18, 28.6)];
    [bezierPath addCurveToPoint: CGPointMake(34.94, 30.88) controlPoint1: CGPointMake(35.73, 29.33) controlPoint2: CGPointMake(35.31, 30.09)];
    [bezierPath addLineToPoint: CGPointMake(45.06, 30.88)];
    [bezierPath addCurveToPoint: CGPointMake(45.97, 33.16) controlPoint1: CGPointMake(45.4, 31.62) controlPoint2: CGPointMake(45.71, 32.38)];
    [bezierPath addLineToPoint: CGPointMake(34.03, 33.16)];
    [bezierPath addCurveToPoint: CGPointMake(33.4, 35.44) controlPoint1: CGPointMake(33.78, 33.9) controlPoint2: CGPointMake(33.57, 34.66)];
    [bezierPath addLineToPoint: CGPointMake(46.6, 35.44)];
    [bezierPath addCurveToPoint: CGPointMake(47.08, 40) controlPoint1: CGPointMake(46.91, 36.91) controlPoint2: CGPointMake(47.08, 38.44)];
    [bezierPath addCurveToPoint: CGPointMake(45.97, 46.84) controlPoint1: CGPointMake(47.08, 42.39) controlPoint2: CGPointMake(46.69, 44.69)];
    [bezierPath addLineToPoint: CGPointMake(34.03, 46.84)];
    [bezierPath addCurveToPoint: CGPointMake(34.94, 49.12) controlPoint1: CGPointMake(34.29, 47.62) controlPoint2: CGPointMake(34.6, 48.38)];
    [bezierPath addLineToPoint: CGPointMake(45.06, 49.12)];
    [bezierPath addCurveToPoint: CGPointMake(43.82, 51.4) controlPoint1: CGPointMake(44.69, 49.91) controlPoint2: CGPointMake(44.28, 50.67)];
    [bezierPath addLineToPoint: CGPointMake(36.18, 51.4)];
    [bezierPath addCurveToPoint: CGPointMake(37.82, 53.68) controlPoint1: CGPointMake(36.68, 52.2) controlPoint2: CGPointMake(37.23, 52.96)];
    [bezierPath addLineToPoint: CGPointMake(42.18, 53.68)];
    [bezierPath addCurveToPoint: CGPointMake(40, 55.97) controlPoint1: CGPointMake(41.51, 54.5) controlPoint2: CGPointMake(40.78, 55.26)];
    [bezierPath addCurveToPoint: CGPointMake(54.46, 61.54) controlPoint1: CGPointMake(43.82, 59.43) controlPoint2: CGPointMake(48.89, 61.54)];
    [bezierPath addCurveToPoint: CGPointMake(76, 40) controlPoint1: CGPointMake(66.36, 61.54) controlPoint2: CGPointMake(76, 51.9)];
    [bezierPath addCurveToPoint: CGPointMake(54.46, 18.46) controlPoint1: CGPointMake(76, 28.1) controlPoint2: CGPointMake(66.36, 18.46)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    
    [fillColor13 setFill];
    [bezierPath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(73.73, 51.97)];
    [bezier2Path addLineToPoint: CGPointMake(73.81, 51.97)];
    [bezier2Path addCurveToPoint: CGPointMake(73.9, 51.95) controlPoint1: CGPointMake(73.84, 51.97) controlPoint2: CGPointMake(73.87, 51.97)];
    [bezier2Path addCurveToPoint: CGPointMake(73.93, 51.88) controlPoint1: CGPointMake(73.92, 51.94) controlPoint2: CGPointMake(73.93, 51.91)];
    [bezier2Path addCurveToPoint: CGPointMake(73.9, 51.82) controlPoint1: CGPointMake(73.93, 51.86) controlPoint2: CGPointMake(73.92, 51.83)];
    [bezier2Path addCurveToPoint: CGPointMake(73.81, 51.81) controlPoint1: CGPointMake(73.87, 51.81) controlPoint2: CGPointMake(73.83, 51.81)];
    [bezier2Path addLineToPoint: CGPointMake(73.73, 51.81)];
    [bezier2Path addLineToPoint: CGPointMake(73.73, 51.97)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(73.73, 52.31)];
    [bezier2Path addLineToPoint: CGPointMake(73.59, 52.31)];
    [bezier2Path addLineToPoint: CGPointMake(73.59, 51.7)];
    [bezier2Path addLineToPoint: CGPointMake(73.85, 51.7)];
    [bezier2Path addCurveToPoint: CGPointMake(74, 51.73) controlPoint1: CGPointMake(73.9, 51.7) controlPoint2: CGPointMake(73.96, 51.7)];
    [bezier2Path addCurveToPoint: CGPointMake(74.08, 51.89) controlPoint1: CGPointMake(74.05, 51.77) controlPoint2: CGPointMake(74.08, 51.82)];
    [bezier2Path addCurveToPoint: CGPointMake(73.97, 52.04) controlPoint1: CGPointMake(74.08, 51.95) controlPoint2: CGPointMake(74.04, 52.02)];
    [bezier2Path addLineToPoint: CGPointMake(74.09, 52.31)];
    [bezier2Path addLineToPoint: CGPointMake(73.93, 52.31)];
    [bezier2Path addLineToPoint: CGPointMake(73.84, 52.07)];
    [bezier2Path addLineToPoint: CGPointMake(73.73, 52.07)];
    [bezier2Path addLineToPoint: CGPointMake(73.73, 52.31)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(73.82, 52.54)];
    [bezier2Path addCurveToPoint: CGPointMake(74.35, 52.01) controlPoint1: CGPointMake(74.12, 52.54) controlPoint2: CGPointMake(74.35, 52.3)];
    [bezier2Path addCurveToPoint: CGPointMake(73.82, 51.48) controlPoint1: CGPointMake(74.35, 51.71) controlPoint2: CGPointMake(74.12, 51.48)];
    [bezier2Path addCurveToPoint: CGPointMake(73.3, 52.01) controlPoint1: CGPointMake(73.53, 51.48) controlPoint2: CGPointMake(73.3, 51.71)];
    [bezier2Path addCurveToPoint: CGPointMake(73.82, 52.54) controlPoint1: CGPointMake(73.3, 52.3) controlPoint2: CGPointMake(73.53, 52.54)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(73.13, 52.01)];
    [bezier2Path addCurveToPoint: CGPointMake(73.82, 51.31) controlPoint1: CGPointMake(73.13, 51.62) controlPoint2: CGPointMake(73.44, 51.31)];
    [bezier2Path addCurveToPoint: CGPointMake(74.52, 52.01) controlPoint1: CGPointMake(74.21, 51.31) controlPoint2: CGPointMake(74.52, 51.62)];
    [bezier2Path addCurveToPoint: CGPointMake(73.82, 52.7) controlPoint1: CGPointMake(74.52, 52.39) controlPoint2: CGPointMake(74.21, 52.7)];
    [bezier2Path addCurveToPoint: CGPointMake(73.13, 52.01) controlPoint1: CGPointMake(73.44, 52.7) controlPoint2: CGPointMake(73.13, 52.39)];
    [bezier2Path closePath];
    bezier2Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier2Path fill];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(18.83, 44.58)];
    [bezier3Path addCurveToPoint: CGPointMake(17.99, 43.67) controlPoint1: CGPointMake(18.32, 44.58) controlPoint2: CGPointMake(17.99, 44.23)];
    [bezier3Path addCurveToPoint: CGPointMake(19.99, 42.32) controlPoint1: CGPointMake(17.99, 42.78) controlPoint2: CGPointMake(18.66, 42.32)];
    [bezier3Path addCurveToPoint: CGPointMake(20.51, 42.36) controlPoint1: CGPointMake(20.16, 42.32) controlPoint2: CGPointMake(20.27, 42.33)];
    [bezier3Path addCurveToPoint: CGPointMake(18.83, 44.58) controlPoint1: CGPointMake(20.47, 43.67) controlPoint2: CGPointMake(19.78, 44.58)];
    [bezier3Path closePath];
    [bezier3Path moveToPoint: CGPointMake(23.1, 39.84)];
    [bezier3Path addCurveToPoint: CGPointMake(20.03, 37.23) controlPoint1: CGPointMake(23.1, 38.13) controlPoint2: CGPointMake(22.04, 37.23)];
    [bezier3Path addCurveToPoint: CGPointMake(17.23, 37.7) controlPoint1: CGPointMake(19.16, 37.23) controlPoint2: CGPointMake(18.4, 37.36)];
    [bezier3Path addCurveToPoint: CGPointMake(16.91, 39.7) controlPoint1: CGPointMake(17.23, 37.7) controlPoint2: CGPointMake(16.93, 39.55)];
    [bezier3Path addCurveToPoint: CGPointMake(19.38, 39.3) controlPoint1: CGPointMake(17.29, 39.57) controlPoint2: CGPointMake(18.24, 39.29)];
    [bezier3Path addCurveToPoint: CGPointMake(20.88, 40.11) controlPoint1: CGPointMake(20.47, 39.3) controlPoint2: CGPointMake(20.88, 39.52)];
    [bezier3Path addCurveToPoint: CGPointMake(20.79, 40.69) controlPoint1: CGPointMake(20.88, 40.27) controlPoint2: CGPointMake(20.86, 40.39)];
    [bezier3Path addCurveToPoint: CGPointMake(19.84, 40.62) controlPoint1: CGPointMake(20.44, 40.64) controlPoint2: CGPointMake(20.1, 40.62)];
    [bezier3Path addCurveToPoint: CGPointMake(15.73, 44.04) controlPoint1: CGPointMake(17.24, 40.62) controlPoint2: CGPointMake(15.73, 41.88)];
    [bezier3Path addCurveToPoint: CGPointMake(17.87, 46.47) controlPoint1: CGPointMake(15.73, 45.48) controlPoint2: CGPointMake(16.6, 46.47)];
    [bezier3Path addCurveToPoint: CGPointMake(20.32, 45.4) controlPoint1: CGPointMake(18.94, 46.47) controlPoint2: CGPointMake(19.73, 46.12)];
    [bezier3Path addLineToPoint: CGPointMake(20.27, 46.32)];
    [bezier3Path addLineToPoint: CGPointMake(22.21, 46.32)];
    [bezier3Path addCurveToPoint: CGPointMake(22.91, 41.6) controlPoint1: CGPointMake(22.27, 45.65) controlPoint2: CGPointMake(22.71, 42.89)];
    [bezier3Path addCurveToPoint: CGPointMake(23.1, 39.84) controlPoint1: CGPointMake(23.03, 40.86) controlPoint2: CGPointMake(23.1, 40.29)];
    [bezier3Path closePath];
    bezier3Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier3Path fill];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(12.82, 35.39)];
    [bezier4Path addLineToPoint: CGPointMake(10.77, 41.51)];
    [bezier4Path addLineToPoint: CGPointMake(10.57, 35.39)];
    [bezier4Path addLineToPoint: CGPointMake(7.2, 35.39)];
    [bezier4Path addLineToPoint: CGPointMake(5.38, 46.32)];
    [bezier4Path addLineToPoint: CGPointMake(7.56, 46.32)];
    [bezier4Path addLineToPoint: CGPointMake(8.97, 37.97)];
    [bezier4Path addLineToPoint: CGPointMake(9.17, 46.32)];
    [bezier4Path addLineToPoint: CGPointMake(10.76, 46.32)];
    [bezier4Path addLineToPoint: CGPointMake(13.75, 37.92)];
    [bezier4Path addLineToPoint: CGPointMake(12.41, 46.32)];
    [bezier4Path addLineToPoint: CGPointMake(14.75, 46.32)];
    [bezier4Path addLineToPoint: CGPointMake(16.56, 35.39)];
    [bezier4Path addLineToPoint: CGPointMake(12.82, 35.39)];
    [bezier4Path closePath];
    bezier4Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier4Path fill];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(55.67, 44.58)];
    [bezier5Path addCurveToPoint: CGPointMake(54.83, 43.67) controlPoint1: CGPointMake(55.16, 44.58) controlPoint2: CGPointMake(54.83, 44.23)];
    [bezier5Path addCurveToPoint: CGPointMake(56.83, 42.32) controlPoint1: CGPointMake(54.83, 42.78) controlPoint2: CGPointMake(55.5, 42.32)];
    [bezier5Path addCurveToPoint: CGPointMake(57.35, 42.36) controlPoint1: CGPointMake(57, 42.32) controlPoint2: CGPointMake(57.1, 42.33)];
    [bezier5Path addCurveToPoint: CGPointMake(55.67, 44.58) controlPoint1: CGPointMake(57.31, 43.67) controlPoint2: CGPointMake(56.62, 44.58)];
    [bezier5Path closePath];
    [bezier5Path moveToPoint: CGPointMake(56.87, 37.23)];
    [bezier5Path addCurveToPoint: CGPointMake(54.07, 37.7) controlPoint1: CGPointMake(56, 37.23) controlPoint2: CGPointMake(55.23, 37.36)];
    [bezier5Path addCurveToPoint: CGPointMake(53.75, 39.7) controlPoint1: CGPointMake(54.07, 37.7) controlPoint2: CGPointMake(53.77, 39.55)];
    [bezier5Path addCurveToPoint: CGPointMake(56.22, 39.3) controlPoint1: CGPointMake(54.13, 39.57) controlPoint2: CGPointMake(55.08, 39.29)];
    [bezier5Path addCurveToPoint: CGPointMake(57.72, 40.11) controlPoint1: CGPointMake(57.31, 39.3) controlPoint2: CGPointMake(57.72, 39.52)];
    [bezier5Path addCurveToPoint: CGPointMake(57.63, 40.69) controlPoint1: CGPointMake(57.72, 40.27) controlPoint2: CGPointMake(57.7, 40.39)];
    [bezier5Path addCurveToPoint: CGPointMake(56.68, 40.62) controlPoint1: CGPointMake(57.28, 40.64) controlPoint2: CGPointMake(56.94, 40.62)];
    [bezier5Path addCurveToPoint: CGPointMake(52.57, 44.04) controlPoint1: CGPointMake(54.08, 40.62) controlPoint2: CGPointMake(52.57, 41.88)];
    [bezier5Path addCurveToPoint: CGPointMake(54.71, 46.47) controlPoint1: CGPointMake(52.57, 45.48) controlPoint2: CGPointMake(53.44, 46.47)];
    [bezier5Path addCurveToPoint: CGPointMake(57.16, 45.4) controlPoint1: CGPointMake(55.78, 46.47) controlPoint2: CGPointMake(56.57, 46.12)];
    [bezier5Path addLineToPoint: CGPointMake(57.11, 46.32)];
    [bezier5Path addLineToPoint: CGPointMake(59.05, 46.32)];
    [bezier5Path addCurveToPoint: CGPointMake(59.75, 41.6) controlPoint1: CGPointMake(59.11, 45.65) controlPoint2: CGPointMake(59.55, 42.89)];
    [bezier5Path addCurveToPoint: CGPointMake(59.94, 39.84) controlPoint1: CGPointMake(59.87, 40.86) controlPoint2: CGPointMake(59.94, 40.29)];
    [bezier5Path addCurveToPoint: CGPointMake(56.87, 37.23) controlPoint1: CGPointMake(59.94, 38.13) controlPoint2: CGPointMake(58.88, 37.23)];
    [bezier5Path closePath];
    bezier5Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier5Path fill];
    
    
    //// Bezier 6 Drawing
    UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
    [bezier6Path moveToPoint: CGPointMake(31.48, 43.64)];
    [bezier6Path addCurveToPoint: CGPointMake(32.14, 39.57) controlPoint1: CGPointMake(31.49, 43.36) controlPoint2: CGPointMake(31.87, 41.26)];
    [bezier6Path addLineToPoint: CGPointMake(33.55, 39.57)];
    [bezier6Path addLineToPoint: CGPointMake(33.87, 37.43)];
    [bezier6Path addLineToPoint: CGPointMake(32.46, 37.43)];
    [bezier6Path addLineToPoint: CGPointMake(32.73, 36.09)];
    [bezier6Path addLineToPoint: CGPointMake(30.41, 36.09)];
    [bezier6Path addCurveToPoint: CGPointMake(29.4, 42.15) controlPoint1: CGPointMake(30.41, 36.09) controlPoint2: CGPointMake(29.53, 41.32)];
    [bezier6Path addCurveToPoint: CGPointMake(29.08, 44.52) controlPoint1: CGPointMake(29.25, 43.09) controlPoint2: CGPointMake(29.06, 44.13)];
    [bezier6Path addCurveToPoint: CGPointMake(30.92, 46.47) controlPoint1: CGPointMake(29.08, 45.78) controlPoint2: CGPointMake(29.73, 46.47)];
    [bezier6Path addCurveToPoint: CGPointMake(32.6, 46.18) controlPoint1: CGPointMake(31.46, 46.47) controlPoint2: CGPointMake(31.96, 46.38)];
    [bezier6Path addLineToPoint: CGPointMake(32.91, 44.22)];
    [bezier6Path addCurveToPoint: CGPointMake(32.28, 44.3) controlPoint1: CGPointMake(32.76, 44.27) controlPoint2: CGPointMake(32.55, 44.3)];
    [bezier6Path addCurveToPoint: CGPointMake(31.48, 43.64) controlPoint1: CGPointMake(31.73, 44.3) controlPoint2: CGPointMake(31.48, 44.1)];
    [bezier6Path closePath];
    bezier6Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier6Path fill];
    
    
    //// Bezier 7 Drawing
    UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
    [bezier7Path moveToPoint: CGPointMake(37.34, 39.26)];
    [bezier7Path addCurveToPoint: CGPointMake(38.42, 40.84) controlPoint1: CGPointMake(38.67, 39.26) controlPoint2: CGPointMake(38.44, 40.66)];
    [bezier7Path addLineToPoint: CGPointMake(35.86, 40.84)];
    [bezier7Path addCurveToPoint: CGPointMake(37.34, 39.26) controlPoint1: CGPointMake(36.07, 39.82) controlPoint2: CGPointMake(36.6, 39.26)];
    [bezier7Path closePath];
    [bezier7Path moveToPoint: CGPointMake(40.31, 42.63)];
    [bezier7Path addCurveToPoint: CGPointMake(40.6, 40.45) controlPoint1: CGPointMake(40.51, 41.74) controlPoint2: CGPointMake(40.6, 41.1)];
    [bezier7Path addCurveToPoint: CGPointMake(37.46, 37.23) controlPoint1: CGPointMake(40.6, 38.49) controlPoint2: CGPointMake(39.37, 37.23)];
    [bezier7Path addCurveToPoint: CGPointMake(33.39, 42.51) controlPoint1: CGPointMake(35.11, 37.23) controlPoint2: CGPointMake(33.39, 39.47)];
    [bezier7Path addCurveToPoint: CGPointMake(37.35, 46.47) controlPoint1: CGPointMake(33.39, 45.11) controlPoint2: CGPointMake(34.74, 46.47)];
    [bezier7Path addCurveToPoint: CGPointMake(39.73, 46.11) controlPoint1: CGPointMake(38.16, 46.47) controlPoint2: CGPointMake(38.93, 46.35)];
    [bezier7Path addLineToPoint: CGPointMake(40.12, 43.9)];
    [bezier7Path addCurveToPoint: CGPointMake(37.7, 44.46) controlPoint1: CGPointMake(39.28, 44.29) controlPoint2: CGPointMake(38.53, 44.46)];
    [bezier7Path addCurveToPoint: CGPointMake(35.68, 42.63) controlPoint1: CGPointMake(36.35, 44.46) controlPoint2: CGPointMake(35.52, 43.92)];
    [bezier7Path addLineToPoint: CGPointMake(40.31, 42.63)];
    [bezier7Path closePath];
    bezier7Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier7Path fill];
    
    
    //// Bezier 8 Drawing
    UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
    [bezier8Path moveToPoint: CGPointMake(27.17, 39.33)];
    [bezier8Path addCurveToPoint: CGPointMake(28.85, 39.47) controlPoint1: CGPointMake(27.63, 39.33) controlPoint2: CGPointMake(28.26, 39.38)];
    [bezier8Path addLineToPoint: CGPointMake(29.19, 37.41)];
    [bezier8Path addCurveToPoint: CGPointMake(27.13, 37.23) controlPoint1: CGPointMake(28.58, 37.31) controlPoint2: CGPointMake(27.66, 37.23)];
    [bezier8Path addCurveToPoint: CGPointMake(23.61, 40.24) controlPoint1: CGPointMake(24.51, 37.23) controlPoint2: CGPointMake(23.61, 38.6)];
    [bezier8Path addCurveToPoint: CGPointMake(25.4, 42.72) controlPoint1: CGPointMake(23.61, 41.36) controlPoint2: CGPointMake(24.16, 42.14)];
    [bezier8Path addCurveToPoint: CGPointMake(26.49, 43.7) controlPoint1: CGPointMake(26.34, 43.17) controlPoint2: CGPointMake(26.49, 43.3)];
    [bezier8Path addCurveToPoint: CGPointMake(25.15, 44.51) controlPoint1: CGPointMake(26.49, 44.26) controlPoint2: CGPointMake(26.07, 44.51)];
    [bezier8Path addCurveToPoint: CGPointMake(23.05, 44.16) controlPoint1: CGPointMake(24.45, 44.51) controlPoint2: CGPointMake(23.8, 44.4)];
    [bezier8Path addCurveToPoint: CGPointMake(22.73, 46.21) controlPoint1: CGPointMake(23.05, 44.16) controlPoint2: CGPointMake(22.74, 46.11)];
    [bezier8Path addCurveToPoint: CGPointMake(25.16, 46.47) controlPoint1: CGPointMake(23.26, 46.32) controlPoint2: CGPointMake(23.73, 46.43)];
    [bezier8Path addCurveToPoint: CGPointMake(28.77, 43.5) controlPoint1: CGPointMake(27.63, 46.47) controlPoint2: CGPointMake(28.77, 45.53)];
    [bezier8Path addCurveToPoint: CGPointMake(27.12, 41.02) controlPoint1: CGPointMake(28.77, 42.28) controlPoint2: CGPointMake(28.29, 41.56)];
    [bezier8Path addCurveToPoint: CGPointMake(26.03, 40.06) controlPoint1: CGPointMake(26.14, 40.57) controlPoint2: CGPointMake(26.03, 40.47)];
    [bezier8Path addCurveToPoint: CGPointMake(27.17, 39.33) controlPoint1: CGPointMake(26.03, 39.58) controlPoint2: CGPointMake(26.42, 39.33)];
    [bezier8Path closePath];
    bezier8Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier8Path fill];
    
    
    //// Bezier 9 Drawing
    UIBezierPath* bezier9Path = [UIBezierPath bezierPath];
    [bezier9Path moveToPoint: CGPointMake(48.13, 41.56)];
    [bezier9Path addCurveToPoint: CGPointMake(51.1, 37.47) controlPoint1: CGPointMake(48.13, 39.15) controlPoint2: CGPointMake(49.36, 37.47)];
    [bezier9Path addCurveToPoint: CGPointMake(53.19, 38.06) controlPoint1: CGPointMake(51.75, 37.47) controlPoint2: CGPointMake(52.36, 37.64)];
    [bezier9Path addLineToPoint: CGPointMake(53.58, 35.69)];
    [bezier9Path addCurveToPoint: CGPointMake(51.01, 34.76) controlPoint1: CGPointMake(53.23, 35.55) controlPoint2: CGPointMake(52.03, 34.76)];
    [bezier9Path addCurveToPoint: CGPointMake(47.19, 36.82) controlPoint1: CGPointMake(49.44, 34.76) controlPoint2: CGPointMake(48.12, 35.54)];
    [bezier9Path addCurveToPoint: CGPointMake(44.59, 38.18) controlPoint1: CGPointMake(45.83, 36.37) controlPoint2: CGPointMake(45.27, 37.28)];
    [bezier9Path addLineToPoint: CGPointMake(43.98, 38.33)];
    [bezier9Path addCurveToPoint: CGPointMake(44.05, 37.43) controlPoint1: CGPointMake(44.03, 38.03) controlPoint2: CGPointMake(44.07, 37.73)];
    [bezier9Path addLineToPoint: CGPointMake(41.91, 37.43)];
    [bezier9Path addCurveToPoint: CGPointMake(40.69, 45.72) controlPoint1: CGPointMake(41.61, 40.18) controlPoint2: CGPointMake(41.09, 42.97)];
    [bezier9Path addLineToPoint: CGPointMake(40.58, 46.32)];
    [bezier9Path addLineToPoint: CGPointMake(42.92, 46.32)];
    [bezier9Path addCurveToPoint: CGPointMake(43.65, 41.06) controlPoint1: CGPointMake(43.31, 43.78) controlPoint2: CGPointMake(43.52, 42.16)];
    [bezier9Path addLineToPoint: CGPointMake(44.54, 40.57)];
    [bezier9Path addCurveToPoint: CGPointMake(45.91, 39.93) controlPoint1: CGPointMake(44.67, 40.08) controlPoint2: CGPointMake(45.08, 39.91)];
    [bezier9Path addCurveToPoint: CGPointMake(45.74, 41.75) controlPoint1: CGPointMake(45.8, 40.51) controlPoint2: CGPointMake(45.74, 41.12)];
    [bezier9Path addCurveToPoint: CGPointMake(49.83, 46.47) controlPoint1: CGPointMake(45.74, 44.66) controlPoint2: CGPointMake(47.31, 46.47)];
    [bezier9Path addCurveToPoint: CGPointMake(51.89, 46.15) controlPoint1: CGPointMake(50.47, 46.47) controlPoint2: CGPointMake(51.03, 46.39)];
    [bezier9Path addLineToPoint: CGPointMake(52.3, 43.66)];
    [bezier9Path addCurveToPoint: CGPointMake(50.32, 44.22) controlPoint1: CGPointMake(51.53, 44.04) controlPoint2: CGPointMake(50.89, 44.22)];
    [bezier9Path addCurveToPoint: CGPointMake(48.13, 41.56) controlPoint1: CGPointMake(48.96, 44.22) controlPoint2: CGPointMake(48.13, 43.22)];
    [bezier9Path closePath];
    bezier9Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier9Path fill];
    
    
    //// Bezier 10 Drawing
    UIBezierPath* bezier10Path = [UIBezierPath bezierPath];
    [bezier10Path moveToPoint: CGPointMake(67.98, 44.26)];
    [bezier10Path addCurveToPoint: CGPointMake(66.78, 42.51) controlPoint1: CGPointMake(67.18, 44.26) controlPoint2: CGPointMake(66.78, 43.68)];
    [bezier10Path addCurveToPoint: CGPointMake(68.59, 39.53) controlPoint1: CGPointMake(66.78, 40.77) controlPoint2: CGPointMake(67.53, 39.53)];
    [bezier10Path addCurveToPoint: CGPointMake(69.83, 41.27) controlPoint1: CGPointMake(69.4, 39.53) controlPoint2: CGPointMake(69.83, 40.14)];
    [bezier10Path addCurveToPoint: CGPointMake(67.98, 44.26) controlPoint1: CGPointMake(69.83, 43.03) controlPoint2: CGPointMake(69.07, 44.26)];
    [bezier10Path closePath];
    [bezier10Path moveToPoint: CGPointMake(70.9, 35.39)];
    [bezier10Path addLineToPoint: CGPointMake(70.38, 38.55)];
    [bezier10Path addCurveToPoint: CGPointMake(68.15, 37.1) controlPoint1: CGPointMake(69.74, 37.71) controlPoint2: CGPointMake(69.06, 37.1)];
    [bezier10Path addCurveToPoint: CGPointMake(65.19, 39.31) controlPoint1: CGPointMake(66.97, 37.1) controlPoint2: CGPointMake(65.9, 37.99)];
    [bezier10Path addCurveToPoint: CGPointMake(63.2, 38.76) controlPoint1: CGPointMake(64.22, 39.11) controlPoint2: CGPointMake(63.2, 38.76)];
    [bezier10Path addCurveToPoint: CGPointMake(63.2, 38.77) controlPoint1: CGPointMake(63.2, 38.76) controlPoint2: CGPointMake(63.2, 38.77)];
    [bezier10Path addLineToPoint: CGPointMake(63.2, 38.76)];
    [bezier10Path addLineToPoint: CGPointMake(63.2, 38.76)];
    [bezier10Path addCurveToPoint: CGPointMake(63.31, 37.43) controlPoint1: CGPointMake(63.28, 38.03) controlPoint2: CGPointMake(63.31, 37.58)];
    [bezier10Path addLineToPoint: CGPointMake(61.16, 37.43)];
    [bezier10Path addCurveToPoint: CGPointMake(59.94, 45.72) controlPoint1: CGPointMake(60.86, 40.18) controlPoint2: CGPointMake(60.34, 42.97)];
    [bezier10Path addLineToPoint: CGPointMake(59.83, 46.32)];
    [bezier10Path addLineToPoint: CGPointMake(62.17, 46.32)];
    [bezier10Path addCurveToPoint: CGPointMake(62.91, 41.21) controlPoint1: CGPointMake(62.49, 44.27) controlPoint2: CGPointMake(62.73, 42.56)];
    [bezier10Path addCurveToPoint: CGPointMake(64.91, 39.9) controlPoint1: CGPointMake(63.71, 40.49) controlPoint2: CGPointMake(64.11, 39.86)];
    [bezier10Path addCurveToPoint: CGPointMake(64.35, 42.78) controlPoint1: CGPointMake(64.56, 40.77) controlPoint2: CGPointMake(64.35, 41.76)];
    [bezier10Path addCurveToPoint: CGPointMake(67.17, 46.47) controlPoint1: CGPointMake(64.35, 45.01) controlPoint2: CGPointMake(65.47, 46.47)];
    [bezier10Path addCurveToPoint: CGPointMake(69.33, 45.49) controlPoint1: CGPointMake(68.03, 46.47) controlPoint2: CGPointMake(68.68, 46.18)];
    [bezier10Path addLineToPoint: CGPointMake(69.22, 46.32)];
    [bezier10Path addLineToPoint: CGPointMake(71.43, 46.32)];
    [bezier10Path addLineToPoint: CGPointMake(73.21, 35.39)];
    [bezier10Path addLineToPoint: CGPointMake(70.9, 35.39)];
    [bezier10Path closePath];
    bezier10Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier10Path fill];
    
    
    //// Bezier 11 Drawing
    UIBezierPath* bezier11Path = [UIBezierPath bezierPath];
    [bezier11Path moveToPoint: CGPointMake(73.73, 44.93)];
    [bezier11Path addLineToPoint: CGPointMake(73.81, 44.93)];
    [bezier11Path addCurveToPoint: CGPointMake(73.9, 44.92) controlPoint1: CGPointMake(73.84, 44.93) controlPoint2: CGPointMake(73.87, 44.93)];
    [bezier11Path addCurveToPoint: CGPointMake(73.93, 44.85) controlPoint1: CGPointMake(73.92, 44.9) controlPoint2: CGPointMake(73.93, 44.88)];
    [bezier11Path addCurveToPoint: CGPointMake(73.9, 44.79) controlPoint1: CGPointMake(73.93, 44.83) controlPoint2: CGPointMake(73.92, 44.8)];
    [bezier11Path addCurveToPoint: CGPointMake(73.81, 44.78) controlPoint1: CGPointMake(73.87, 44.77) controlPoint2: CGPointMake(73.83, 44.78)];
    [bezier11Path addLineToPoint: CGPointMake(73.73, 44.78)];
    [bezier11Path addLineToPoint: CGPointMake(73.73, 44.93)];
    [bezier11Path closePath];
    [bezier11Path moveToPoint: CGPointMake(73.73, 45.28)];
    [bezier11Path addLineToPoint: CGPointMake(73.59, 45.28)];
    [bezier11Path addLineToPoint: CGPointMake(73.59, 44.67)];
    [bezier11Path addLineToPoint: CGPointMake(73.85, 44.67)];
    [bezier11Path addCurveToPoint: CGPointMake(74, 44.7) controlPoint1: CGPointMake(73.9, 44.67) controlPoint2: CGPointMake(73.95, 44.67)];
    [bezier11Path addCurveToPoint: CGPointMake(74.08, 44.85) controlPoint1: CGPointMake(74.05, 44.73) controlPoint2: CGPointMake(74.08, 44.79)];
    [bezier11Path addCurveToPoint: CGPointMake(73.97, 45.01) controlPoint1: CGPointMake(74.08, 44.92) controlPoint2: CGPointMake(74.04, 44.98)];
    [bezier11Path addLineToPoint: CGPointMake(74.09, 45.28)];
    [bezier11Path addLineToPoint: CGPointMake(73.93, 45.28)];
    [bezier11Path addLineToPoint: CGPointMake(73.83, 45.04)];
    [bezier11Path addLineToPoint: CGPointMake(73.73, 45.04)];
    [bezier11Path addLineToPoint: CGPointMake(73.73, 45.28)];
    [bezier11Path closePath];
    [bezier11Path moveToPoint: CGPointMake(73.82, 45.5)];
    [bezier11Path addCurveToPoint: CGPointMake(74.35, 44.97) controlPoint1: CGPointMake(74.12, 45.5) controlPoint2: CGPointMake(74.35, 45.26)];
    [bezier11Path addCurveToPoint: CGPointMake(73.82, 44.44) controlPoint1: CGPointMake(74.35, 44.68) controlPoint2: CGPointMake(74.12, 44.44)];
    [bezier11Path addCurveToPoint: CGPointMake(73.29, 44.97) controlPoint1: CGPointMake(73.53, 44.44) controlPoint2: CGPointMake(73.29, 44.68)];
    [bezier11Path addCurveToPoint: CGPointMake(73.82, 45.5) controlPoint1: CGPointMake(73.29, 45.26) controlPoint2: CGPointMake(73.53, 45.5)];
    [bezier11Path closePath];
    [bezier11Path moveToPoint: CGPointMake(73.13, 44.97)];
    [bezier11Path addCurveToPoint: CGPointMake(73.82, 44.28) controlPoint1: CGPointMake(73.13, 44.59) controlPoint2: CGPointMake(73.44, 44.28)];
    [bezier11Path addCurveToPoint: CGPointMake(74.52, 44.97) controlPoint1: CGPointMake(74.21, 44.28) controlPoint2: CGPointMake(74.52, 44.59)];
    [bezier11Path addCurveToPoint: CGPointMake(73.82, 45.67) controlPoint1: CGPointMake(74.52, 45.36) controlPoint2: CGPointMake(74.21, 45.67)];
    [bezier11Path addCurveToPoint: CGPointMake(73.13, 44.97) controlPoint1: CGPointMake(73.44, 45.67) controlPoint2: CGPointMake(73.13, 45.36)];
    [bezier11Path closePath];
    bezier11Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier11Path fill];
    
    
    //// Bezier 12 Drawing
    UIBezierPath* bezier12Path = [UIBezierPath bezierPath];
    [bezier12Path moveToPoint: CGPointMake(13.6, 34.74)];
    [bezier12Path addLineToPoint: CGPointMake(11.33, 41.51)];
    [bezier12Path addLineToPoint: CGPointMake(11.24, 34.74)];
    [bezier12Path addLineToPoint: CGPointMake(7.88, 34.74)];
    [bezier12Path addLineToPoint: CGPointMake(6.05, 45.67)];
    [bezier12Path addLineToPoint: CGPointMake(8.24, 45.67)];
    [bezier12Path addLineToPoint: CGPointMake(9.64, 37.32)];
    [bezier12Path addLineToPoint: CGPointMake(9.84, 45.67)];
    [bezier12Path addLineToPoint: CGPointMake(11.44, 45.67)];
    [bezier12Path addLineToPoint: CGPointMake(14.43, 37.27)];
    [bezier12Path addLineToPoint: CGPointMake(13.09, 45.67)];
    [bezier12Path addLineToPoint: CGPointMake(15.43, 45.67)];
    [bezier12Path addLineToPoint: CGPointMake(17.23, 34.74)];
    [bezier12Path addLineToPoint: CGPointMake(13.6, 34.74)];
    [bezier12Path closePath];
    bezier12Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier12Path fill];
    
    
    //// Bezier 13 Drawing
    UIBezierPath* bezier13Path = [UIBezierPath bezierPath];
    [bezier13Path moveToPoint: CGPointMake(19.5, 43.93)];
    [bezier13Path addCurveToPoint: CGPointMake(18.67, 43.03) controlPoint1: CGPointMake(18.99, 43.93) controlPoint2: CGPointMake(18.67, 43.58)];
    [bezier13Path addCurveToPoint: CGPointMake(20.66, 41.68) controlPoint1: CGPointMake(18.67, 42.13) controlPoint2: CGPointMake(19.34, 41.68)];
    [bezier13Path addCurveToPoint: CGPointMake(21.18, 41.71) controlPoint1: CGPointMake(20.83, 41.68) controlPoint2: CGPointMake(20.94, 41.68)];
    [bezier13Path addCurveToPoint: CGPointMake(19.5, 43.93) controlPoint1: CGPointMake(21.14, 43.03) controlPoint2: CGPointMake(20.46, 43.93)];
    [bezier13Path closePath];
    [bezier13Path moveToPoint: CGPointMake(23.77, 39.19)];
    [bezier13Path addCurveToPoint: CGPointMake(20.7, 36.59) controlPoint1: CGPointMake(23.77, 37.49) controlPoint2: CGPointMake(22.71, 36.59)];
    [bezier13Path addCurveToPoint: CGPointMake(17.9, 37.06) controlPoint1: CGPointMake(19.84, 36.59) controlPoint2: CGPointMake(19.07, 36.71)];
    [bezier13Path addCurveToPoint: CGPointMake(17.58, 39.05) controlPoint1: CGPointMake(17.9, 37.06) controlPoint2: CGPointMake(17.6, 38.91)];
    [bezier13Path addCurveToPoint: CGPointMake(20.05, 38.66) controlPoint1: CGPointMake(17.97, 38.93) controlPoint2: CGPointMake(18.91, 38.64)];
    [bezier13Path addCurveToPoint: CGPointMake(21.55, 39.46) controlPoint1: CGPointMake(21.15, 38.66) controlPoint2: CGPointMake(21.55, 38.87)];
    [bezier13Path addCurveToPoint: CGPointMake(21.46, 40.04) controlPoint1: CGPointMake(21.55, 39.62) controlPoint2: CGPointMake(21.54, 39.75)];
    [bezier13Path addCurveToPoint: CGPointMake(20.51, 39.97) controlPoint1: CGPointMake(21.11, 40) controlPoint2: CGPointMake(20.77, 39.97)];
    [bezier13Path addCurveToPoint: CGPointMake(16.4, 43.4) controlPoint1: CGPointMake(17.91, 39.97) controlPoint2: CGPointMake(16.4, 41.23)];
    [bezier13Path addCurveToPoint: CGPointMake(18.54, 45.82) controlPoint1: CGPointMake(16.4, 44.83) controlPoint2: CGPointMake(17.27, 45.82)];
    [bezier13Path addCurveToPoint: CGPointMake(20.99, 44.75) controlPoint1: CGPointMake(19.61, 45.82) controlPoint2: CGPointMake(20.4, 45.48)];
    [bezier13Path addLineToPoint: CGPointMake(20.95, 45.67)];
    [bezier13Path addLineToPoint: CGPointMake(22.88, 45.67)];
    [bezier13Path addCurveToPoint: CGPointMake(23.58, 40.95) controlPoint1: CGPointMake(22.94, 45) controlPoint2: CGPointMake(23.38, 42.24)];
    [bezier13Path addCurveToPoint: CGPointMake(23.77, 39.19) controlPoint1: CGPointMake(23.7, 40.21) controlPoint2: CGPointMake(23.78, 39.65)];
    [bezier13Path closePath];
    bezier13Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier13Path fill];
    
    
    //// Bezier 14 Drawing
    UIBezierPath* bezier14Path = [UIBezierPath bezierPath];
    [bezier14Path moveToPoint: CGPointMake(48.81, 40.91)];
    [bezier14Path addCurveToPoint: CGPointMake(51.78, 36.82) controlPoint1: CGPointMake(48.81, 38.51) controlPoint2: CGPointMake(50.03, 36.82)];
    [bezier14Path addCurveToPoint: CGPointMake(53.87, 37.41) controlPoint1: CGPointMake(52.43, 36.82) controlPoint2: CGPointMake(53.03, 36.99)];
    [bezier14Path addLineToPoint: CGPointMake(54.25, 35.04)];
    [bezier14Path addCurveToPoint: CGPointMake(51.68, 34.47) controlPoint1: CGPointMake(53.91, 34.9) controlPoint2: CGPointMake(52.7, 34.47)];
    [bezier14Path addCurveToPoint: CGPointMake(46.41, 41.11) controlPoint1: CGPointMake(48.58, 34.47) controlPoint2: CGPointMake(46.41, 37.2)];
    [bezier14Path addCurveToPoint: CGPointMake(50.5, 45.82) controlPoint1: CGPointMake(46.41, 44.01) controlPoint2: CGPointMake(47.98, 45.82)];
    [bezier14Path addCurveToPoint: CGPointMake(52.57, 45.5) controlPoint1: CGPointMake(51.15, 45.82) controlPoint2: CGPointMake(51.7, 45.74)];
    [bezier14Path addLineToPoint: CGPointMake(52.98, 43.01)];
    [bezier14Path addCurveToPoint: CGPointMake(50.99, 43.57) controlPoint1: CGPointMake(52.2, 43.4) controlPoint2: CGPointMake(51.57, 43.57)];
    [bezier14Path addCurveToPoint: CGPointMake(48.81, 40.91) controlPoint1: CGPointMake(49.63, 43.57) controlPoint2: CGPointMake(48.81, 42.57)];
    [bezier14Path closePath];
    bezier14Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier14Path fill];
    
    
    //// Bezier 15 Drawing
    UIBezierPath* bezier15Path = [UIBezierPath bezierPath];
    [bezier15Path moveToPoint: CGPointMake(56.34, 43.93)];
    [bezier15Path addCurveToPoint: CGPointMake(55.5, 43.03) controlPoint1: CGPointMake(55.83, 43.93) controlPoint2: CGPointMake(55.5, 43.58)];
    [bezier15Path addCurveToPoint: CGPointMake(57.5, 41.68) controlPoint1: CGPointMake(55.5, 42.13) controlPoint2: CGPointMake(56.18, 41.68)];
    [bezier15Path addCurveToPoint: CGPointMake(58.02, 41.71) controlPoint1: CGPointMake(57.67, 41.68) controlPoint2: CGPointMake(57.78, 41.68)];
    [bezier15Path addCurveToPoint: CGPointMake(56.34, 43.93) controlPoint1: CGPointMake(57.98, 43.03) controlPoint2: CGPointMake(57.3, 43.93)];
    [bezier15Path closePath];
    [bezier15Path moveToPoint: CGPointMake(57.54, 36.59)];
    [bezier15Path addCurveToPoint: CGPointMake(54.74, 37.06) controlPoint1: CGPointMake(56.68, 36.59) controlPoint2: CGPointMake(55.91, 36.71)];
    [bezier15Path addCurveToPoint: CGPointMake(54.42, 39.05) controlPoint1: CGPointMake(54.74, 37.06) controlPoint2: CGPointMake(54.44, 38.91)];
    [bezier15Path addCurveToPoint: CGPointMake(56.89, 38.66) controlPoint1: CGPointMake(54.81, 38.93) controlPoint2: CGPointMake(55.75, 38.64)];
    [bezier15Path addCurveToPoint: CGPointMake(58.39, 39.46) controlPoint1: CGPointMake(57.99, 38.66) controlPoint2: CGPointMake(58.39, 38.87)];
    [bezier15Path addCurveToPoint: CGPointMake(58.3, 40.04) controlPoint1: CGPointMake(58.39, 39.62) controlPoint2: CGPointMake(58.37, 39.75)];
    [bezier15Path addCurveToPoint: CGPointMake(57.35, 39.97) controlPoint1: CGPointMake(57.95, 40) controlPoint2: CGPointMake(57.61, 39.97)];
    [bezier15Path addCurveToPoint: CGPointMake(53.24, 43.4) controlPoint1: CGPointMake(54.75, 39.97) controlPoint2: CGPointMake(53.24, 41.23)];
    [bezier15Path addCurveToPoint: CGPointMake(55.38, 45.82) controlPoint1: CGPointMake(53.24, 44.83) controlPoint2: CGPointMake(54.11, 45.82)];
    [bezier15Path addCurveToPoint: CGPointMake(57.83, 44.75) controlPoint1: CGPointMake(56.45, 45.82) controlPoint2: CGPointMake(57.24, 45.48)];
    [bezier15Path addLineToPoint: CGPointMake(57.79, 45.67)];
    [bezier15Path addLineToPoint: CGPointMake(59.72, 45.67)];
    [bezier15Path addCurveToPoint: CGPointMake(60.42, 40.95) controlPoint1: CGPointMake(59.78, 45) controlPoint2: CGPointMake(60.22, 42.24)];
    [bezier15Path addCurveToPoint: CGPointMake(60.61, 39.19) controlPoint1: CGPointMake(60.54, 40.21) controlPoint2: CGPointMake(60.61, 39.65)];
    [bezier15Path addCurveToPoint: CGPointMake(57.54, 36.59) controlPoint1: CGPointMake(60.61, 37.49) controlPoint2: CGPointMake(59.55, 36.59)];
    [bezier15Path closePath];
    bezier15Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier15Path fill];
    
    
    //// Bezier 16 Drawing
    UIBezierPath* bezier16Path = [UIBezierPath bezierPath];
    [bezier16Path moveToPoint: CGPointMake(34.01, 38.92)];
    [bezier16Path addLineToPoint: CGPointMake(34.33, 36.78)];
    [bezier16Path addLineToPoint: CGPointMake(33.14, 36.78)];
    [bezier16Path addLineToPoint: CGPointMake(33.41, 35.44)];
    [bezier16Path addLineToPoint: CGPointMake(31.08, 35.44)];
    [bezier16Path addCurveToPoint: CGPointMake(30.07, 41.5) controlPoint1: CGPointMake(31.08, 35.44) controlPoint2: CGPointMake(30.2, 40.67)];
    [bezier16Path addCurveToPoint: CGPointMake(29.75, 43.87) controlPoint1: CGPointMake(29.92, 42.45) controlPoint2: CGPointMake(29.73, 43.48)];
    [bezier16Path addCurveToPoint: CGPointMake(31.6, 45.82) controlPoint1: CGPointMake(29.75, 45.14) controlPoint2: CGPointMake(30.4, 45.82)];
    [bezier16Path addCurveToPoint: CGPointMake(33.28, 45.53) controlPoint1: CGPointMake(32.14, 45.82) controlPoint2: CGPointMake(32.64, 45.74)];
    [bezier16Path addLineToPoint: CGPointMake(33.59, 43.57)];
    [bezier16Path addCurveToPoint: CGPointMake(32.96, 43.65) controlPoint1: CGPointMake(33.43, 43.63) controlPoint2: CGPointMake(33.22, 43.65)];
    [bezier16Path addCurveToPoint: CGPointMake(32.16, 42.99) controlPoint1: CGPointMake(32.4, 43.65) controlPoint2: CGPointMake(32.16, 43.45)];
    [bezier16Path addCurveToPoint: CGPointMake(32.82, 38.92) controlPoint1: CGPointMake(32.16, 42.71) controlPoint2: CGPointMake(32.55, 40.61)];
    [bezier16Path addLineToPoint: CGPointMake(34.01, 38.92)];
    [bezier16Path closePath];
    bezier16Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier16Path fill];
    
    
    //// Bezier 17 Drawing
    UIBezierPath* bezier17Path = [UIBezierPath bezierPath];
    [bezier17Path moveToPoint: CGPointMake(38.02, 38.61)];
    [bezier17Path addCurveToPoint: CGPointMake(39.1, 40.19) controlPoint1: CGPointMake(39.34, 38.61) controlPoint2: CGPointMake(39.11, 40.01)];
    [bezier17Path addLineToPoint: CGPointMake(36.53, 40.19)];
    [bezier17Path addCurveToPoint: CGPointMake(38.02, 38.61) controlPoint1: CGPointMake(36.75, 39.17) controlPoint2: CGPointMake(37.28, 38.61)];
    [bezier17Path closePath];
    [bezier17Path moveToPoint: CGPointMake(40.98, 41.99)];
    [bezier17Path addCurveToPoint: CGPointMake(41.27, 39.8) controlPoint1: CGPointMake(41.18, 41.09) controlPoint2: CGPointMake(41.27, 40.45)];
    [bezier17Path addCurveToPoint: CGPointMake(38.13, 36.59) controlPoint1: CGPointMake(41.27, 37.84) controlPoint2: CGPointMake(40.04, 36.59)];
    [bezier17Path addCurveToPoint: CGPointMake(34.06, 41.86) controlPoint1: CGPointMake(35.79, 36.59) controlPoint2: CGPointMake(34.06, 38.82)];
    [bezier17Path addCurveToPoint: CGPointMake(38.02, 45.82) controlPoint1: CGPointMake(34.06, 44.46) controlPoint2: CGPointMake(35.42, 45.82)];
    [bezier17Path addCurveToPoint: CGPointMake(40.4, 45.46) controlPoint1: CGPointMake(38.83, 45.82) controlPoint2: CGPointMake(39.61, 45.71)];
    [bezier17Path addLineToPoint: CGPointMake(40.79, 43.25)];
    [bezier17Path addCurveToPoint: CGPointMake(38.37, 43.81) controlPoint1: CGPointMake(39.96, 43.64) controlPoint2: CGPointMake(39.21, 43.81)];
    [bezier17Path addCurveToPoint: CGPointMake(36.35, 41.99) controlPoint1: CGPointMake(37.02, 43.81) controlPoint2: CGPointMake(36.2, 43.28)];
    [bezier17Path addLineToPoint: CGPointMake(40.98, 41.99)];
    [bezier17Path closePath];
    bezier17Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier17Path fill];
    
    
    //// Bezier 18 Drawing
    UIBezierPath* bezier18Path = [UIBezierPath bezierPath];
    [bezier18Path moveToPoint: CGPointMake(27.85, 38.69)];
    [bezier18Path addCurveToPoint: CGPointMake(29.53, 38.82) controlPoint1: CGPointMake(28.3, 38.69) controlPoint2: CGPointMake(28.93, 38.74)];
    [bezier18Path addLineToPoint: CGPointMake(29.86, 36.76)];
    [bezier18Path addCurveToPoint: CGPointMake(27.8, 36.59) controlPoint1: CGPointMake(29.25, 36.66) controlPoint2: CGPointMake(28.34, 36.59)];
    [bezier18Path addCurveToPoint: CGPointMake(24.29, 39.59) controlPoint1: CGPointMake(25.18, 36.59) controlPoint2: CGPointMake(24.28, 37.95)];
    [bezier18Path addCurveToPoint: CGPointMake(26.07, 42.07) controlPoint1: CGPointMake(24.29, 40.72) controlPoint2: CGPointMake(24.83, 41.49)];
    [bezier18Path addCurveToPoint: CGPointMake(27.16, 43.05) controlPoint1: CGPointMake(27.02, 42.52) controlPoint2: CGPointMake(27.16, 42.65)];
    [bezier18Path addCurveToPoint: CGPointMake(25.82, 43.86) controlPoint1: CGPointMake(27.16, 43.61) controlPoint2: CGPointMake(26.74, 43.86)];
    [bezier18Path addCurveToPoint: CGPointMake(23.72, 43.51) controlPoint1: CGPointMake(25.12, 43.86) controlPoint2: CGPointMake(24.47, 43.75)];
    [bezier18Path addCurveToPoint: CGPointMake(23.4, 45.56) controlPoint1: CGPointMake(23.72, 43.51) controlPoint2: CGPointMake(23.42, 45.47)];
    [bezier18Path addCurveToPoint: CGPointMake(25.84, 45.82) controlPoint1: CGPointMake(23.93, 45.68) controlPoint2: CGPointMake(24.41, 45.78)];
    [bezier18Path addCurveToPoint: CGPointMake(29.44, 42.85) controlPoint1: CGPointMake(28.3, 45.82) controlPoint2: CGPointMake(29.44, 44.88)];
    [bezier18Path addCurveToPoint: CGPointMake(27.79, 40.38) controlPoint1: CGPointMake(29.44, 41.63) controlPoint2: CGPointMake(28.97, 40.92)];
    [bezier18Path addCurveToPoint: CGPointMake(26.7, 39.41) controlPoint1: CGPointMake(26.81, 39.93) controlPoint2: CGPointMake(26.7, 39.83)];
    [bezier18Path addCurveToPoint: CGPointMake(27.85, 38.69) controlPoint1: CGPointMake(26.7, 38.93) controlPoint2: CGPointMake(27.09, 38.69)];
    [bezier18Path closePath];
    bezier18Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier18Path fill];
    
    
    //// Bezier 19 Drawing
    UIBezierPath* bezier19Path = [UIBezierPath bezierPath];
    [bezier19Path moveToPoint: CGPointMake(68.65, 43.62)];
    [bezier19Path addCurveToPoint: CGPointMake(67.45, 41.87) controlPoint1: CGPointMake(67.86, 43.62) controlPoint2: CGPointMake(67.45, 43.03)];
    [bezier19Path addCurveToPoint: CGPointMake(69.27, 38.88) controlPoint1: CGPointMake(67.45, 40.12) controlPoint2: CGPointMake(68.21, 38.88)];
    [bezier19Path addCurveToPoint: CGPointMake(70.51, 40.62) controlPoint1: CGPointMake(70.07, 38.88) controlPoint2: CGPointMake(70.51, 39.49)];
    [bezier19Path addCurveToPoint: CGPointMake(68.65, 43.62) controlPoint1: CGPointMake(70.51, 42.38) controlPoint2: CGPointMake(69.74, 43.62)];
    [bezier19Path closePath];
    [bezier19Path moveToPoint: CGPointMake(71.58, 34.74)];
    [bezier19Path addLineToPoint: CGPointMake(71.06, 37.9)];
    [bezier19Path addCurveToPoint: CGPointMake(68.82, 36.69) controlPoint1: CGPointMake(70.42, 37.06) controlPoint2: CGPointMake(69.73, 36.69)];
    [bezier19Path addCurveToPoint: CGPointMake(65.02, 42.14) controlPoint1: CGPointMake(66.76, 36.69) controlPoint2: CGPointMake(65.02, 39.18)];
    [bezier19Path addCurveToPoint: CGPointMake(67.84, 45.82) controlPoint1: CGPointMake(65.02, 44.36) controlPoint2: CGPointMake(66.14, 45.82)];
    [bezier19Path addCurveToPoint: CGPointMake(70, 44.84) controlPoint1: CGPointMake(68.7, 45.82) controlPoint2: CGPointMake(69.36, 45.53)];
    [bezier19Path addLineToPoint: CGPointMake(69.89, 45.67)];
    [bezier19Path addLineToPoint: CGPointMake(72.1, 45.67)];
    [bezier19Path addLineToPoint: CGPointMake(73.88, 34.74)];
    [bezier19Path addLineToPoint: CGPointMake(71.58, 34.74)];
    [bezier19Path closePath];
    bezier19Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier19Path fill];
    
    
    //// Bezier 20 Drawing
    UIBezierPath* bezier20Path = [UIBezierPath bezierPath];
    [bezier20Path moveToPoint: CGPointMake(66.08, 36.73)];
    [bezier20Path addCurveToPoint: CGPointMake(63.84, 38.13) controlPoint1: CGPointMake(65.1, 36.53) controlPoint2: CGPointMake(64.55, 37.08)];
    [bezier20Path addCurveToPoint: CGPointMake(63.98, 36.78) controlPoint1: CGPointMake(63.9, 37.68) controlPoint2: CGPointMake(64, 37.24)];
    [bezier20Path addLineToPoint: CGPointMake(61.83, 36.78)];
    [bezier20Path addCurveToPoint: CGPointMake(60.61, 45.07) controlPoint1: CGPointMake(61.54, 39.53) controlPoint2: CGPointMake(61.02, 42.32)];
    [bezier20Path addLineToPoint: CGPointMake(60.5, 45.67)];
    [bezier20Path addLineToPoint: CGPointMake(62.84, 45.67)];
    [bezier20Path addCurveToPoint: CGPointMake(65.19, 39.31) controlPoint1: CGPointMake(63.68, 40.24) controlPoint2: CGPointMake(63.88, 39.17)];
    [bezier20Path addCurveToPoint: CGPointMake(66.08, 36.73) controlPoint1: CGPointMake(65.4, 38.2) controlPoint2: CGPointMake(65.79, 37.22)];
    [bezier20Path closePath];
    bezier20Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier20Path fill];
    
    
    //// Bezier 21 Drawing
    UIBezierPath* bezier21Path = [UIBezierPath bezierPath];
    [bezier21Path moveToPoint: CGPointMake(44.59, 38.13)];
    [bezier21Path addCurveToPoint: CGPointMake(44.73, 36.78) controlPoint1: CGPointMake(44.64, 37.68) controlPoint2: CGPointMake(44.75, 37.24)];
    [bezier21Path addLineToPoint: CGPointMake(42.58, 36.78)];
    [bezier21Path addCurveToPoint: CGPointMake(41.36, 45.07) controlPoint1: CGPointMake(42.29, 39.53) controlPoint2: CGPointMake(41.77, 42.32)];
    [bezier21Path addLineToPoint: CGPointMake(41.25, 45.67)];
    [bezier21Path addLineToPoint: CGPointMake(43.59, 45.67)];
    [bezier21Path addCurveToPoint: CGPointMake(45.94, 39.31) controlPoint1: CGPointMake(44.43, 40.24) controlPoint2: CGPointMake(44.63, 39.18)];
    [bezier21Path addCurveToPoint: CGPointMake(46.83, 36.73) controlPoint1: CGPointMake(46.15, 38.2) controlPoint2: CGPointMake(46.54, 37.22)];
    [bezier21Path addCurveToPoint: CGPointMake(44.59, 38.13) controlPoint1: CGPointMake(45.85, 36.53) controlPoint2: CGPointMake(45.3, 37.08)];
    [bezier21Path closePath];
    bezier21Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier21Path fill];

}
@end
