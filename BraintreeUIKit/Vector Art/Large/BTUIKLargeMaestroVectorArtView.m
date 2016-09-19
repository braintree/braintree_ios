#import "BTUIKLargeMaestroVectorArtView.h"

@implementation BTUIKLargeMaestroVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* fillColor4 = [UIColor colorWithRed: 0.103 green: 0.092 blue: 0.095 alpha: 1];
    UIColor* fillColor11 = [UIColor colorWithRed: 0.894 green: 0 blue: 0.111 alpha: 1];
    UIColor* fillColor12 = [UIColor colorWithRed: 0.069 green: 0.557 blue: 0.867 alpha: 1];
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(32.9, 18.45, 43.1, 43.1)];
    [fillColor11 setFill];
    [ovalPath fill];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(37.82, 53.68)];
    [bezierPath addCurveToPoint: CGPointMake(36.18, 51.4) controlPoint1: CGPointMake(37.23, 52.96) controlPoint2: CGPointMake(36.68, 52.19)];
    [bezierPath addLineToPoint: CGPointMake(43.82, 51.4)];
    [bezierPath addCurveToPoint: CGPointMake(45.06, 49.12) controlPoint1: CGPointMake(44.28, 50.67) controlPoint2: CGPointMake(44.69, 49.9)];
    [bezierPath addLineToPoint: CGPointMake(34.94, 49.12)];
    [bezierPath addCurveToPoint: CGPointMake(34.03, 46.84) controlPoint1: CGPointMake(34.6, 48.38) controlPoint2: CGPointMake(34.29, 47.62)];
    [bezierPath addLineToPoint: CGPointMake(45.97, 46.84)];
    [bezierPath addCurveToPoint: CGPointMake(47.08, 40) controlPoint1: CGPointMake(46.69, 44.69) controlPoint2: CGPointMake(47.08, 42.39)];
    [bezierPath addCurveToPoint: CGPointMake(46.59, 35.44) controlPoint1: CGPointMake(47.08, 38.43) controlPoint2: CGPointMake(46.91, 36.91)];
    [bezierPath addLineToPoint: CGPointMake(33.41, 35.44)];
    [bezierPath addCurveToPoint: CGPointMake(34.03, 33.16) controlPoint1: CGPointMake(33.58, 34.66) controlPoint2: CGPointMake(33.79, 33.9)];
    [bezierPath addLineToPoint: CGPointMake(45.97, 33.16)];
    [bezierPath addCurveToPoint: CGPointMake(45.06, 30.88) controlPoint1: CGPointMake(45.71, 32.38) controlPoint2: CGPointMake(45.4, 31.62)];
    [bezierPath addLineToPoint: CGPointMake(34.95, 30.88)];
    [bezierPath addCurveToPoint: CGPointMake(36.19, 28.6) controlPoint1: CGPointMake(35.31, 30.09) controlPoint2: CGPointMake(35.73, 29.33)];
    [bezierPath addLineToPoint: CGPointMake(43.81, 28.6)];
    [bezierPath addCurveToPoint: CGPointMake(42.17, 26.32) controlPoint1: CGPointMake(43.32, 27.8) controlPoint2: CGPointMake(42.77, 27.04)];
    [bezierPath addLineToPoint: CGPointMake(37.83, 26.32)];
    [bezierPath addCurveToPoint: CGPointMake(40, 24.04) controlPoint1: CGPointMake(38.5, 25.5) controlPoint2: CGPointMake(39.22, 24.74)];
    [bezierPath addCurveToPoint: CGPointMake(25.54, 18.46) controlPoint1: CGPointMake(36.18, 20.57) controlPoint2: CGPointMake(31.1, 18.46)];
    [bezierPath addCurveToPoint: CGPointMake(4, 40) controlPoint1: CGPointMake(13.64, 18.46) controlPoint2: CGPointMake(4, 28.1)];
    [bezierPath addCurveToPoint: CGPointMake(25.54, 61.54) controlPoint1: CGPointMake(4, 51.9) controlPoint2: CGPointMake(13.64, 61.54)];
    [bezierPath addCurveToPoint: CGPointMake(40, 55.96) controlPoint1: CGPointMake(31.1, 61.54) controlPoint2: CGPointMake(36.18, 59.43)];
    [bezierPath addCurveToPoint: CGPointMake(42.18, 53.68) controlPoint1: CGPointMake(40.78, 55.26) controlPoint2: CGPointMake(41.51, 54.49)];
    [bezierPath addLineToPoint: CGPointMake(37.82, 53.68)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    
    [fillColor12 setFill];
    [bezierPath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(73.73, 51.96)];
    [bezier2Path addLineToPoint: CGPointMake(73.81, 51.96)];
    [bezier2Path addCurveToPoint: CGPointMake(73.9, 51.95) controlPoint1: CGPointMake(73.84, 51.96) controlPoint2: CGPointMake(73.87, 51.97)];
    [bezier2Path addCurveToPoint: CGPointMake(73.93, 51.88) controlPoint1: CGPointMake(73.92, 51.94) controlPoint2: CGPointMake(73.93, 51.91)];
    [bezier2Path addCurveToPoint: CGPointMake(73.9, 51.82) controlPoint1: CGPointMake(73.93, 51.86) controlPoint2: CGPointMake(73.92, 51.83)];
    [bezier2Path addCurveToPoint: CGPointMake(73.81, 51.81) controlPoint1: CGPointMake(73.87, 51.81) controlPoint2: CGPointMake(73.83, 51.81)];
    [bezier2Path addLineToPoint: CGPointMake(73.73, 51.81)];
    [bezier2Path addLineToPoint: CGPointMake(73.73, 51.96)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(73.73, 52.31)];
    [bezier2Path addLineToPoint: CGPointMake(73.59, 52.31)];
    [bezier2Path addLineToPoint: CGPointMake(73.59, 51.7)];
    [bezier2Path addLineToPoint: CGPointMake(73.85, 51.7)];
    [bezier2Path addCurveToPoint: CGPointMake(74, 51.73) controlPoint1: CGPointMake(73.9, 51.7) controlPoint2: CGPointMake(73.95, 51.7)];
    [bezier2Path addCurveToPoint: CGPointMake(74.08, 51.88) controlPoint1: CGPointMake(74.05, 51.77) controlPoint2: CGPointMake(74.08, 51.82)];
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
    [bezier3Path moveToPoint: CGPointMake(38.26, 40.52)];
    [bezier3Path addCurveToPoint: CGPointMake(37.01, 38.93) controlPoint1: CGPointMake(38.26, 40.33) controlPoint2: CGPointMake(38.55, 38.96)];
    [bezier3Path addCurveToPoint: CGPointMake(35.3, 40.52) controlPoint1: CGPointMake(36.16, 38.93) controlPoint2: CGPointMake(35.54, 39.5)];
    [bezier3Path addLineToPoint: CGPointMake(38.26, 40.52)];
    [bezier3Path closePath];
    [bezier3Path moveToPoint: CGPointMake(39.69, 45.82)];
    [bezier3Path addCurveToPoint: CGPointMake(36.94, 46.18) controlPoint1: CGPointMake(38.77, 46.06) controlPoint2: CGPointMake(37.88, 46.18)];
    [bezier3Path addCurveToPoint: CGPointMake(32.38, 42.2) controlPoint1: CGPointMake(33.94, 46.18) controlPoint2: CGPointMake(32.38, 44.81)];
    [bezier3Path addCurveToPoint: CGPointMake(37.07, 36.9) controlPoint1: CGPointMake(32.38, 39.14) controlPoint2: CGPointMake(34.37, 36.9)];
    [bezier3Path addCurveToPoint: CGPointMake(40.69, 40.13) controlPoint1: CGPointMake(39.28, 36.9) controlPoint2: CGPointMake(40.69, 38.16)];
    [bezier3Path addCurveToPoint: CGPointMake(40.36, 42.32) controlPoint1: CGPointMake(40.69, 40.78) controlPoint2: CGPointMake(40.59, 41.42)];
    [bezier3Path addLineToPoint: CGPointMake(35.02, 42.32)];
    [bezier3Path addCurveToPoint: CGPointMake(37.35, 44.16) controlPoint1: CGPointMake(34.83, 43.6) controlPoint2: CGPointMake(35.76, 44.16)];
    [bezier3Path addCurveToPoint: CGPointMake(40.11, 43.61) controlPoint1: CGPointMake(38.3, 44.16) controlPoint2: CGPointMake(39.16, 43.99)];
    [bezier3Path addLineToPoint: CGPointMake(39.69, 45.82)];
    [bezier3Path closePath];
    bezier3Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier3Path fill];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(41.5, 39.92)];
    [bezier4Path addCurveToPoint: CGPointMake(43.58, 42.41) controlPoint1: CGPointMake(41.5, 41.05) controlPoint2: CGPointMake(42.14, 41.83)];
    [bezier4Path addCurveToPoint: CGPointMake(44.86, 43.4) controlPoint1: CGPointMake(44.69, 42.86) controlPoint2: CGPointMake(44.86, 43)];
    [bezier4Path addCurveToPoint: CGPointMake(43.29, 44.21) controlPoint1: CGPointMake(44.86, 43.96) controlPoint2: CGPointMake(44.37, 44.22)];
    [bezier4Path addCurveToPoint: CGPointMake(40.86, 43.86) controlPoint1: CGPointMake(42.47, 44.2) controlPoint2: CGPointMake(41.73, 44.1)];
    [bezier4Path addLineToPoint: CGPointMake(40.47, 45.92)];
    [bezier4Path addCurveToPoint: CGPointMake(43.31, 46.18) controlPoint1: CGPointMake(41.25, 46.1) controlPoint2: CGPointMake(42.34, 46.16)];
    [bezier4Path addCurveToPoint: CGPointMake(47.52, 43.2) controlPoint1: CGPointMake(46.19, 46.18) controlPoint2: CGPointMake(47.52, 45.24)];
    [bezier4Path addCurveToPoint: CGPointMake(45.6, 40.71) controlPoint1: CGPointMake(47.52, 41.97) controlPoint2: CGPointMake(46.97, 41.25)];
    [bezier4Path addCurveToPoint: CGPointMake(44.32, 39.74) controlPoint1: CGPointMake(44.45, 40.26) controlPoint2: CGPointMake(44.32, 40.16)];
    [bezier4Path addCurveToPoint: CGPointMake(45.66, 39.01) controlPoint1: CGPointMake(44.32, 39.26) controlPoint2: CGPointMake(44.77, 39.01)];
    [bezier4Path addCurveToPoint: CGPointMake(47.62, 39.14) controlPoint1: CGPointMake(46.19, 39.01) controlPoint2: CGPointMake(46.93, 39.06)];
    [bezier4Path addLineToPoint: CGPointMake(48.01, 37.07)];
    [bezier4Path addCurveToPoint: CGPointMake(45.6, 36.9) controlPoint1: CGPointMake(47.3, 36.98) controlPoint2: CGPointMake(46.23, 36.9)];
    [bezier4Path addCurveToPoint: CGPointMake(41.5, 39.92) controlPoint1: CGPointMake(42.55, 36.9) controlPoint2: CGPointMake(41.49, 38.27)];
    [bezier4Path closePath];
    bezier4Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier4Path fill];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(28.95, 42.05)];
    [bezier5Path addCurveToPoint: CGPointMake(28.35, 42.01) controlPoint1: CGPointMake(28.66, 42.02) controlPoint2: CGPointMake(28.54, 42.01)];
    [bezier5Path addCurveToPoint: CGPointMake(26.04, 43.37) controlPoint1: CGPointMake(26.82, 42.01) controlPoint2: CGPointMake(26.04, 42.47)];
    [bezier5Path addCurveToPoint: CGPointMake(27.01, 44.28) controlPoint1: CGPointMake(26.04, 43.93) controlPoint2: CGPointMake(26.42, 44.28)];
    [bezier5Path addCurveToPoint: CGPointMake(28.95, 42.05) controlPoint1: CGPointMake(28.11, 44.28) controlPoint2: CGPointMake(28.9, 43.36)];
    [bezier5Path closePath];
    [bezier5Path moveToPoint: CGPointMake(30.91, 46.03)];
    [bezier5Path addLineToPoint: CGPointMake(28.67, 46.03)];
    [bezier5Path addLineToPoint: CGPointMake(28.73, 45.1)];
    [bezier5Path addCurveToPoint: CGPointMake(25.9, 46.18) controlPoint1: CGPointMake(28.04, 45.84) controlPoint2: CGPointMake(27.13, 46.18)];
    [bezier5Path addCurveToPoint: CGPointMake(23.44, 43.75) controlPoint1: CGPointMake(24.44, 46.18) controlPoint2: CGPointMake(23.44, 45.18)];
    [bezier5Path addCurveToPoint: CGPointMake(28.17, 40.3) controlPoint1: CGPointMake(23.44, 41.56) controlPoint2: CGPointMake(25.18, 40.3)];
    [bezier5Path addCurveToPoint: CGPointMake(29.27, 40.37) controlPoint1: CGPointMake(28.48, 40.3) controlPoint2: CGPointMake(28.87, 40.32)];
    [bezier5Path addCurveToPoint: CGPointMake(29.37, 39.79) controlPoint1: CGPointMake(29.35, 40.08) controlPoint2: CGPointMake(29.37, 39.95)];
    [bezier5Path addCurveToPoint: CGPointMake(27.65, 38.97) controlPoint1: CGPointMake(29.37, 39.19) controlPoint2: CGPointMake(28.9, 38.97)];
    [bezier5Path addCurveToPoint: CGPointMake(24.79, 39.37) controlPoint1: CGPointMake(26.4, 38.98) controlPoint2: CGPointMake(25.57, 39.16)];
    [bezier5Path addLineToPoint: CGPointMake(25.17, 37.37)];
    [bezier5Path addCurveToPoint: CGPointMake(28.39, 36.89) controlPoint1: CGPointMake(26.52, 37.03) controlPoint2: CGPointMake(27.4, 36.89)];
    [bezier5Path addCurveToPoint: CGPointMake(31.93, 39.51) controlPoint1: CGPointMake(30.71, 36.89) controlPoint2: CGPointMake(31.93, 37.8)];
    [bezier5Path addCurveToPoint: CGPointMake(31.71, 41.28) controlPoint1: CGPointMake(31.95, 39.97) controlPoint2: CGPointMake(31.79, 40.88)];
    [bezier5Path addCurveToPoint: CGPointMake(30.91, 46.03) controlPoint1: CGPointMake(31.62, 41.86) controlPoint2: CGPointMake(30.98, 45.24)];
    [bezier5Path closePath];
    bezier5Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier5Path fill];
    
    
    //// Bezier 6 Drawing
    UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
    [bezier6Path moveToPoint: CGPointMake(52.24, 45.89)];
    [bezier6Path addCurveToPoint: CGPointMake(50.31, 46.18) controlPoint1: CGPointMake(51.51, 46.09) controlPoint2: CGPointMake(50.93, 46.18)];
    [bezier6Path addCurveToPoint: CGPointMake(48.19, 44.23) controlPoint1: CGPointMake(48.94, 46.18) controlPoint2: CGPointMake(48.19, 45.48)];
    [bezier6Path addCurveToPoint: CGPointMake(48.56, 41.86) controlPoint1: CGPointMake(48.15, 43.89) controlPoint2: CGPointMake(48.48, 42.3)];
    [bezier6Path addCurveToPoint: CGPointMake(49.82, 34.96) controlPoint1: CGPointMake(48.64, 41.42) controlPoint2: CGPointMake(49.82, 34.96)];
    [bezier6Path addLineToPoint: CGPointMake(52.49, 34.96)];
    [bezier6Path addLineToPoint: CGPointMake(52.09, 37.1)];
    [bezier6Path addLineToPoint: CGPointMake(53.45, 37.1)];
    [bezier6Path addLineToPoint: CGPointMake(53.08, 39.28)];
    [bezier6Path addLineToPoint: CGPointMake(51.71, 39.28)];
    [bezier6Path addCurveToPoint: CGPointMake(50.96, 43.35) controlPoint1: CGPointMake(51.71, 39.28) controlPoint2: CGPointMake(50.96, 43.06)];
    [bezier6Path addCurveToPoint: CGPointMake(51.87, 44.01) controlPoint1: CGPointMake(50.96, 43.81) controlPoint2: CGPointMake(51.23, 44.01)];
    [bezier6Path addCurveToPoint: CGPointMake(52.6, 43.93) controlPoint1: CGPointMake(52.18, 44.01) controlPoint2: CGPointMake(52.41, 43.98)];
    [bezier6Path addLineToPoint: CGPointMake(52.24, 45.89)];
    [bezier6Path closePath];
    bezier6Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier6Path fill];
    
    
    //// Bezier 7 Drawing
    UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
    [bezier7Path moveToPoint: CGPointMake(63.37, 44.01)];
    [bezier7Path addCurveToPoint: CGPointMake(61.84, 42.04) controlPoint1: CGPointMake(62.42, 44.03) controlPoint2: CGPointMake(61.84, 43.23)];
    [bezier7Path addCurveToPoint: CGPointMake(64.03, 39.02) controlPoint1: CGPointMake(61.84, 40.62) controlPoint2: CGPointMake(62.68, 39.02)];
    [bezier7Path addCurveToPoint: CGPointMake(65.5, 40.81) controlPoint1: CGPointMake(65.12, 39.02) controlPoint2: CGPointMake(65.5, 39.89)];
    [bezier7Path addCurveToPoint: CGPointMake(63.37, 44.01) controlPoint1: CGPointMake(65.5, 42.82) controlPoint2: CGPointMake(64.67, 44.01)];
    [bezier7Path closePath];
    [bezier7Path moveToPoint: CGPointMake(64.15, 36.9)];
    [bezier7Path addCurveToPoint: CGPointMake(59.78, 39.04) controlPoint1: CGPointMake(62.2, 36.9) controlPoint2: CGPointMake(60.67, 37.7)];
    [bezier7Path addLineToPoint: CGPointMake(60.55, 37.05)];
    [bezier7Path addCurveToPoint: CGPointMake(57.39, 38.33) controlPoint1: CGPointMake(59.13, 36.53) controlPoint2: CGPointMake(58.22, 37.27)];
    [bezier7Path addCurveToPoint: CGPointMake(57.12, 38.66) controlPoint1: CGPointMake(57.39, 38.33) controlPoint2: CGPointMake(57.26, 38.5)];
    [bezier7Path addLineToPoint: CGPointMake(57.12, 37.1)];
    [bezier7Path addLineToPoint: CGPointMake(54.61, 37.1)];
    [bezier7Path addCurveToPoint: CGPointMake(53.21, 45.43) controlPoint1: CGPointMake(54.28, 39.86) controlPoint2: CGPointMake(53.68, 42.66)];
    [bezier7Path addLineToPoint: CGPointMake(53.09, 46.03)];
    [bezier7Path addLineToPoint: CGPointMake(55.79, 46.03)];
    [bezier7Path addCurveToPoint: CGPointMake(56.46, 42.58) controlPoint1: CGPointMake(56.04, 44.63) controlPoint2: CGPointMake(56.25, 43.49)];
    [bezier7Path addCurveToPoint: CGPointMake(59.44, 39.66) controlPoint1: CGPointMake(57.03, 40.09) controlPoint2: CGPointMake(58, 39.32)];
    [bezier7Path addCurveToPoint: CGPointMake(58.92, 42.13) controlPoint1: CGPointMake(59.11, 40.38) controlPoint2: CGPointMake(58.92, 41.21)];
    [bezier7Path addCurveToPoint: CGPointMake(63.14, 46.18) controlPoint1: CGPointMake(58.92, 44.36) controlPoint2: CGPointMake(60.13, 46.18)];
    [bezier7Path addCurveToPoint: CGPointMake(68.37, 40.86) controlPoint1: CGPointMake(66.18, 46.18) controlPoint2: CGPointMake(68.37, 44.56)];
    [bezier7Path addCurveToPoint: CGPointMake(64.15, 36.9) controlPoint1: CGPointMake(68.37, 38.63) controlPoint2: CGPointMake(66.91, 36.9)];
    [bezier7Path closePath];
    bezier7Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier7Path fill];
    
    
    //// Bezier 8 Drawing
    UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
    [bezier8Path moveToPoint: CGPointMake(22.18, 46.04)];
    [bezier8Path addLineToPoint: CGPointMake(19.5, 46.04)];
    [bezier8Path addLineToPoint: CGPointMake(21.1, 37.64)];
    [bezier8Path addLineToPoint: CGPointMake(17.43, 46.04)];
    [bezier8Path addLineToPoint: CGPointMake(14.98, 46.04)];
    [bezier8Path addLineToPoint: CGPointMake(14.54, 37.69)];
    [bezier8Path addLineToPoint: CGPointMake(12.94, 46.04)];
    [bezier8Path addLineToPoint: CGPointMake(10.51, 46.04)];
    [bezier8Path addLineToPoint: CGPointMake(12.58, 35.12)];
    [bezier8Path addLineToPoint: CGPointMake(16.77, 35.12)];
    [bezier8Path addLineToPoint: CGPointMake(17.12, 41.2)];
    [bezier8Path addLineToPoint: CGPointMake(19.77, 35.12)];
    [bezier8Path addLineToPoint: CGPointMake(24.3, 35.12)];
    [bezier8Path addLineToPoint: CGPointMake(22.18, 46.04)];
    [bezier8Path closePath];
    bezier8Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier8Path fill];
    
    
    //// Bezier 9 Drawing
    UIBezierPath* bezier9Path = [UIBezierPath bezierPath];
    [bezier9Path moveToPoint: CGPointMake(69.18, 44.63)];
    [bezier9Path addLineToPoint: CGPointMake(69.26, 44.63)];
    [bezier9Path addCurveToPoint: CGPointMake(69.35, 44.61) controlPoint1: CGPointMake(69.29, 44.63) controlPoint2: CGPointMake(69.32, 44.63)];
    [bezier9Path addCurveToPoint: CGPointMake(69.38, 44.54) controlPoint1: CGPointMake(69.37, 44.6) controlPoint2: CGPointMake(69.38, 44.57)];
    [bezier9Path addCurveToPoint: CGPointMake(69.35, 44.48) controlPoint1: CGPointMake(69.38, 44.52) controlPoint2: CGPointMake(69.37, 44.49)];
    [bezier9Path addCurveToPoint: CGPointMake(69.26, 44.47) controlPoint1: CGPointMake(69.32, 44.47) controlPoint2: CGPointMake(69.28, 44.47)];
    [bezier9Path addLineToPoint: CGPointMake(69.18, 44.47)];
    [bezier9Path addLineToPoint: CGPointMake(69.18, 44.63)];
    [bezier9Path closePath];
    [bezier9Path moveToPoint: CGPointMake(69.18, 44.97)];
    [bezier9Path addLineToPoint: CGPointMake(69.04, 44.97)];
    [bezier9Path addLineToPoint: CGPointMake(69.04, 44.36)];
    [bezier9Path addLineToPoint: CGPointMake(69.29, 44.36)];
    [bezier9Path addCurveToPoint: CGPointMake(69.45, 44.39) controlPoint1: CGPointMake(69.35, 44.36) controlPoint2: CGPointMake(69.4, 44.36)];
    [bezier9Path addCurveToPoint: CGPointMake(69.53, 44.54) controlPoint1: CGPointMake(69.5, 44.43) controlPoint2: CGPointMake(69.53, 44.48)];
    [bezier9Path addCurveToPoint: CGPointMake(69.42, 44.7) controlPoint1: CGPointMake(69.53, 44.61) controlPoint2: CGPointMake(69.49, 44.68)];
    [bezier9Path addLineToPoint: CGPointMake(69.54, 44.97)];
    [bezier9Path addLineToPoint: CGPointMake(69.38, 44.97)];
    [bezier9Path addLineToPoint: CGPointMake(69.28, 44.73)];
    [bezier9Path addLineToPoint: CGPointMake(69.18, 44.73)];
    [bezier9Path addLineToPoint: CGPointMake(69.18, 44.97)];
    [bezier9Path closePath];
    [bezier9Path moveToPoint: CGPointMake(69.27, 45.2)];
    [bezier9Path addCurveToPoint: CGPointMake(69.8, 44.67) controlPoint1: CGPointMake(69.57, 45.2) controlPoint2: CGPointMake(69.8, 44.96)];
    [bezier9Path addCurveToPoint: CGPointMake(69.27, 44.14) controlPoint1: CGPointMake(69.8, 44.37) controlPoint2: CGPointMake(69.57, 44.14)];
    [bezier9Path addCurveToPoint: CGPointMake(68.74, 44.67) controlPoint1: CGPointMake(68.98, 44.14) controlPoint2: CGPointMake(68.74, 44.37)];
    [bezier9Path addCurveToPoint: CGPointMake(69.27, 45.2) controlPoint1: CGPointMake(68.74, 44.96) controlPoint2: CGPointMake(68.98, 45.2)];
    [bezier9Path closePath];
    [bezier9Path moveToPoint: CGPointMake(68.58, 44.67)];
    [bezier9Path addCurveToPoint: CGPointMake(69.27, 43.97) controlPoint1: CGPointMake(68.58, 44.28) controlPoint2: CGPointMake(68.89, 43.97)];
    [bezier9Path addCurveToPoint: CGPointMake(69.97, 44.67) controlPoint1: CGPointMake(69.66, 43.97) controlPoint2: CGPointMake(69.97, 44.28)];
    [bezier9Path addCurveToPoint: CGPointMake(69.27, 45.36) controlPoint1: CGPointMake(69.97, 45.05) controlPoint2: CGPointMake(69.66, 45.36)];
    [bezier9Path addCurveToPoint: CGPointMake(68.58, 44.67) controlPoint1: CGPointMake(68.89, 45.36) controlPoint2: CGPointMake(68.58, 45.05)];
    [bezier9Path closePath];
    bezier9Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier9Path fill];
    
    
    //// Bezier 10 Drawing
    UIBezierPath* bezier10Path = [UIBezierPath bezierPath];
    [bezier10Path moveToPoint: CGPointMake(38.93, 39.85)];
    [bezier10Path addCurveToPoint: CGPointMake(37.68, 38.26) controlPoint1: CGPointMake(38.93, 39.66) controlPoint2: CGPointMake(39.23, 38.29)];
    [bezier10Path addCurveToPoint: CGPointMake(35.97, 39.85) controlPoint1: CGPointMake(36.83, 38.26) controlPoint2: CGPointMake(36.22, 38.82)];
    [bezier10Path addLineToPoint: CGPointMake(38.93, 39.85)];
    [bezier10Path closePath];
    [bezier10Path moveToPoint: CGPointMake(40.37, 45.15)];
    [bezier10Path addCurveToPoint: CGPointMake(37.61, 45.51) controlPoint1: CGPointMake(39.45, 45.39) controlPoint2: CGPointMake(38.56, 45.51)];
    [bezier10Path addCurveToPoint: CGPointMake(33.05, 41.52) controlPoint1: CGPointMake(34.61, 45.51) controlPoint2: CGPointMake(33.05, 44.14)];
    [bezier10Path addCurveToPoint: CGPointMake(37.74, 36.22) controlPoint1: CGPointMake(33.05, 38.47) controlPoint2: CGPointMake(35.04, 36.22)];
    [bezier10Path addCurveToPoint: CGPointMake(41.36, 39.46) controlPoint1: CGPointMake(39.95, 36.22) controlPoint2: CGPointMake(41.36, 37.48)];
    [bezier10Path addCurveToPoint: CGPointMake(41.03, 41.65) controlPoint1: CGPointMake(41.36, 40.11) controlPoint2: CGPointMake(41.27, 40.75)];
    [bezier10Path addLineToPoint: CGPointMake(35.69, 41.65)];
    [bezier10Path addCurveToPoint: CGPointMake(38.02, 43.49) controlPoint1: CGPointMake(35.5, 42.93) controlPoint2: CGPointMake(36.44, 43.49)];
    [bezier10Path addCurveToPoint: CGPointMake(40.79, 42.93) controlPoint1: CGPointMake(38.97, 43.49) controlPoint2: CGPointMake(39.83, 43.32)];
    [bezier10Path addLineToPoint: CGPointMake(40.37, 45.15)];
    [bezier10Path closePath];
    bezier10Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier10Path fill];
    
    
    //// Bezier 11 Drawing
    UIBezierPath* bezier11Path = [UIBezierPath bezierPath];
    [bezier11Path moveToPoint: CGPointMake(42.18, 39.25)];
    [bezier11Path addCurveToPoint: CGPointMake(44.25, 41.74) controlPoint1: CGPointMake(42.18, 40.38) controlPoint2: CGPointMake(42.81, 41.16)];
    [bezier11Path addCurveToPoint: CGPointMake(45.53, 42.73) controlPoint1: CGPointMake(45.36, 42.19) controlPoint2: CGPointMake(45.53, 42.32)];
    [bezier11Path addCurveToPoint: CGPointMake(43.96, 43.54) controlPoint1: CGPointMake(45.53, 43.29) controlPoint2: CGPointMake(45.04, 43.54)];
    [bezier11Path addCurveToPoint: CGPointMake(41.53, 43.19) controlPoint1: CGPointMake(43.15, 43.53) controlPoint2: CGPointMake(42.41, 43.43)];
    [bezier11Path addLineToPoint: CGPointMake(41.14, 45.25)];
    [bezier11Path addCurveToPoint: CGPointMake(43.98, 45.51) controlPoint1: CGPointMake(41.92, 45.43) controlPoint2: CGPointMake(43.01, 45.49)];
    [bezier11Path addCurveToPoint: CGPointMake(48.2, 42.53) controlPoint1: CGPointMake(46.86, 45.51) controlPoint2: CGPointMake(48.2, 44.57)];
    [bezier11Path addCurveToPoint: CGPointMake(46.27, 40.04) controlPoint1: CGPointMake(48.2, 41.3) controlPoint2: CGPointMake(47.64, 40.58)];
    [bezier11Path addCurveToPoint: CGPointMake(44.99, 39.07) controlPoint1: CGPointMake(45.13, 39.58) controlPoint2: CGPointMake(44.99, 39.48)];
    [bezier11Path addCurveToPoint: CGPointMake(46.33, 38.34) controlPoint1: CGPointMake(44.99, 38.58) controlPoint2: CGPointMake(45.45, 38.34)];
    [bezier11Path addCurveToPoint: CGPointMake(48.3, 38.47) controlPoint1: CGPointMake(46.87, 38.34) controlPoint2: CGPointMake(47.6, 38.39)];
    [bezier11Path addLineToPoint: CGPointMake(48.69, 36.4)];
    [bezier11Path addCurveToPoint: CGPointMake(46.28, 36.22) controlPoint1: CGPointMake(47.98, 36.3) controlPoint2: CGPointMake(46.9, 36.22)];
    [bezier11Path addCurveToPoint: CGPointMake(42.18, 39.25) controlPoint1: CGPointMake(43.22, 36.22) controlPoint2: CGPointMake(42.17, 37.6)];
    [bezier11Path closePath];
    bezier11Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier11Path fill];
    
    
    //// Bezier 12 Drawing
    UIBezierPath* bezier12Path = [UIBezierPath bezierPath];
    [bezier12Path moveToPoint: CGPointMake(29.62, 41.38)];
    [bezier12Path addCurveToPoint: CGPointMake(29.02, 41.34) controlPoint1: CGPointMake(29.34, 41.35) controlPoint2: CGPointMake(29.21, 41.34)];
    [bezier12Path addCurveToPoint: CGPointMake(26.72, 42.69) controlPoint1: CGPointMake(27.49, 41.34) controlPoint2: CGPointMake(26.72, 41.8)];
    [bezier12Path addCurveToPoint: CGPointMake(27.68, 43.61) controlPoint1: CGPointMake(26.72, 43.26) controlPoint2: CGPointMake(27.1, 43.61)];
    [bezier12Path addCurveToPoint: CGPointMake(29.62, 41.38) controlPoint1: CGPointMake(28.78, 43.61) controlPoint2: CGPointMake(29.57, 42.69)];
    [bezier12Path closePath];
    [bezier12Path moveToPoint: CGPointMake(31.59, 45.36)];
    [bezier12Path addLineToPoint: CGPointMake(29.35, 45.36)];
    [bezier12Path addLineToPoint: CGPointMake(29.4, 44.42)];
    [bezier12Path addCurveToPoint: CGPointMake(26.57, 45.51) controlPoint1: CGPointMake(28.72, 45.16) controlPoint2: CGPointMake(27.81, 45.51)];
    [bezier12Path addCurveToPoint: CGPointMake(24.11, 43.07) controlPoint1: CGPointMake(25.11, 45.51) controlPoint2: CGPointMake(24.11, 44.51)];
    [bezier12Path addCurveToPoint: CGPointMake(28.84, 39.63) controlPoint1: CGPointMake(24.11, 40.89) controlPoint2: CGPointMake(25.85, 39.63)];
    [bezier12Path addCurveToPoint: CGPointMake(29.94, 39.7) controlPoint1: CGPointMake(29.15, 39.63) controlPoint2: CGPointMake(29.54, 39.65)];
    [bezier12Path addCurveToPoint: CGPointMake(30.05, 39.12) controlPoint1: CGPointMake(30.03, 39.4) controlPoint2: CGPointMake(30.05, 39.28)];
    [bezier12Path addCurveToPoint: CGPointMake(28.32, 38.3) controlPoint1: CGPointMake(30.05, 38.52) controlPoint2: CGPointMake(29.58, 38.3)];
    [bezier12Path addCurveToPoint: CGPointMake(25.46, 38.7) controlPoint1: CGPointMake(27.08, 38.31) controlPoint2: CGPointMake(26.24, 38.49)];
    [bezier12Path addLineToPoint: CGPointMake(25.85, 36.7)];
    [bezier12Path addCurveToPoint: CGPointMake(29.07, 36.22) controlPoint1: CGPointMake(27.19, 36.35) controlPoint2: CGPointMake(28.07, 36.22)];
    [bezier12Path addCurveToPoint: CGPointMake(32.61, 38.84) controlPoint1: CGPointMake(31.38, 36.22) controlPoint2: CGPointMake(32.61, 37.13)];
    [bezier12Path addCurveToPoint: CGPointMake(32.39, 40.61) controlPoint1: CGPointMake(32.62, 39.29) controlPoint2: CGPointMake(32.47, 40.21)];
    [bezier12Path addCurveToPoint: CGPointMake(31.59, 45.36) controlPoint1: CGPointMake(32.3, 41.19) controlPoint2: CGPointMake(31.65, 44.57)];
    [bezier12Path closePath];
    bezier12Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier12Path fill];
    
    
    //// Bezier 13 Drawing
    UIBezierPath* bezier13Path = [UIBezierPath bezierPath];
    [bezier13Path moveToPoint: CGPointMake(52.91, 45.22)];
    [bezier13Path addCurveToPoint: CGPointMake(50.99, 45.51) controlPoint1: CGPointMake(52.18, 45.42) controlPoint2: CGPointMake(51.61, 45.51)];
    [bezier13Path addCurveToPoint: CGPointMake(48.87, 43.56) controlPoint1: CGPointMake(49.61, 45.51) controlPoint2: CGPointMake(48.87, 44.81)];
    [bezier13Path addCurveToPoint: CGPointMake(49.23, 41.19) controlPoint1: CGPointMake(48.82, 43.22) controlPoint2: CGPointMake(49.16, 41.63)];
    [bezier13Path addCurveToPoint: CGPointMake(50.5, 34.29) controlPoint1: CGPointMake(49.31, 40.75) controlPoint2: CGPointMake(50.5, 34.29)];
    [bezier13Path addLineToPoint: CGPointMake(53.16, 34.29)];
    [bezier13Path addLineToPoint: CGPointMake(52.76, 36.43)];
    [bezier13Path addLineToPoint: CGPointMake(54.13, 36.43)];
    [bezier13Path addLineToPoint: CGPointMake(53.76, 38.61)];
    [bezier13Path addLineToPoint: CGPointMake(52.38, 38.61)];
    [bezier13Path addCurveToPoint: CGPointMake(51.63, 42.68) controlPoint1: CGPointMake(52.38, 38.61) controlPoint2: CGPointMake(51.63, 42.39)];
    [bezier13Path addCurveToPoint: CGPointMake(52.55, 43.34) controlPoint1: CGPointMake(51.63, 43.14) controlPoint2: CGPointMake(51.91, 43.34)];
    [bezier13Path addCurveToPoint: CGPointMake(53.27, 43.25) controlPoint1: CGPointMake(52.85, 43.34) controlPoint2: CGPointMake(53.09, 43.31)];
    [bezier13Path addLineToPoint: CGPointMake(52.91, 45.22)];
    [bezier13Path closePath];
    bezier13Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier13Path fill];
    
    
    //// Bezier 14 Drawing
    UIBezierPath* bezier14Path = [UIBezierPath bezierPath];
    [bezier14Path moveToPoint: CGPointMake(69.05, 40.19)];
    [bezier14Path addCurveToPoint: CGPointMake(64.82, 36.22) controlPoint1: CGPointMake(69.05, 37.96) controlPoint2: CGPointMake(67.58, 36.22)];
    [bezier14Path addCurveToPoint: CGPointMake(59.6, 41.45) controlPoint1: CGPointMake(61.65, 36.22) controlPoint2: CGPointMake(59.6, 38.34)];
    [bezier14Path addCurveToPoint: CGPointMake(63.81, 45.51) controlPoint1: CGPointMake(59.6, 43.68) controlPoint2: CGPointMake(60.81, 45.51)];
    [bezier14Path addCurveToPoint: CGPointMake(69.05, 40.19) controlPoint1: CGPointMake(66.85, 45.51) controlPoint2: CGPointMake(69.05, 43.89)];
    [bezier14Path closePath];
    [bezier14Path moveToPoint: CGPointMake(66.17, 40.14)];
    [bezier14Path addCurveToPoint: CGPointMake(64.04, 43.34) controlPoint1: CGPointMake(66.17, 42.15) controlPoint2: CGPointMake(65.34, 43.34)];
    [bezier14Path addCurveToPoint: CGPointMake(62.51, 41.36) controlPoint1: CGPointMake(63.09, 43.35) controlPoint2: CGPointMake(62.51, 42.56)];
    [bezier14Path addCurveToPoint: CGPointMake(64.7, 38.35) controlPoint1: CGPointMake(62.51, 39.95) controlPoint2: CGPointMake(63.35, 38.35)];
    [bezier14Path addCurveToPoint: CGPointMake(66.17, 40.14) controlPoint1: CGPointMake(65.79, 38.35) controlPoint2: CGPointMake(66.17, 39.22)];
    [bezier14Path closePath];
    bezier14Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier14Path fill];
    
    
    //// Bezier 15 Drawing
    UIBezierPath* bezier15Path = [UIBezierPath bezierPath];
    [bezier15Path moveToPoint: CGPointMake(55.29, 36.43)];
    [bezier15Path addCurveToPoint: CGPointMake(53.88, 44.76) controlPoint1: CGPointMake(54.95, 39.19) controlPoint2: CGPointMake(54.35, 41.99)];
    [bezier15Path addLineToPoint: CGPointMake(53.77, 45.36)];
    [bezier15Path addLineToPoint: CGPointMake(56.46, 45.36)];
    [bezier15Path addCurveToPoint: CGPointMake(59.79, 39.03) controlPoint1: CGPointMake(57.43, 40.02) controlPoint2: CGPointMake(57.76, 38.49)];
    [bezier15Path addLineToPoint: CGPointMake(60.77, 36.5)];
    [bezier15Path addCurveToPoint: CGPointMake(57.61, 37.78) controlPoint1: CGPointMake(59.35, 35.98) controlPoint2: CGPointMake(58.44, 36.72)];
    [bezier15Path addCurveToPoint: CGPointMake(57.79, 36.43) controlPoint1: CGPointMake(57.68, 37.3) controlPoint2: CGPointMake(57.82, 36.84)];
    [bezier15Path addLineToPoint: CGPointMake(55.29, 36.43)];
    [bezier15Path closePath];
    bezier15Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier15Path fill];
    
    
    //// Bezier 16 Drawing
    UIBezierPath* bezier16Path = [UIBezierPath bezierPath];
    [bezier16Path moveToPoint: CGPointMake(22.86, 45.36)];
    [bezier16Path addLineToPoint: CGPointMake(20.18, 45.36)];
    [bezier16Path addLineToPoint: CGPointMake(21.77, 36.97)];
    [bezier16Path addLineToPoint: CGPointMake(18.1, 45.36)];
    [bezier16Path addLineToPoint: CGPointMake(15.66, 45.36)];
    [bezier16Path addLineToPoint: CGPointMake(15.21, 37.02)];
    [bezier16Path addLineToPoint: CGPointMake(13.61, 45.36)];
    [bezier16Path addLineToPoint: CGPointMake(11.18, 45.36)];
    [bezier16Path addLineToPoint: CGPointMake(13.25, 34.44)];
    [bezier16Path addLineToPoint: CGPointMake(17.44, 34.44)];
    [bezier16Path addLineToPoint: CGPointMake(17.66, 41.2)];
    [bezier16Path addLineToPoint: CGPointMake(20.61, 34.44)];
    [bezier16Path addLineToPoint: CGPointMake(24.97, 34.44)];
    [bezier16Path addLineToPoint: CGPointMake(22.86, 45.36)];
    [bezier16Path closePath];
    bezier16Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier16Path fill];

}
@end
