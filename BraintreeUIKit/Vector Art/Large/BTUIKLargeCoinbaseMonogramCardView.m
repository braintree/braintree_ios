#import "BTUIKLargeCoinbaseMonogramCardView.h"

@implementation BTUIKLargeCoinbaseMonogramCardView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor3 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(5.17, 48.68)];
    [bezierPath addCurveToPoint: CGPointMake(0, 42.55) controlPoint1: CGPointMake(2.55, 48.68) controlPoint2: CGPointMake(0, 46.81)];
    [bezierPath addCurveToPoint: CGPointMake(5.17, 36.44) controlPoint1: CGPointMake(0, 38.3) controlPoint2: CGPointMake(2.55, 36.44)];
    [bezierPath addCurveToPoint: CGPointMake(8.18, 37.25) controlPoint1: CGPointMake(6.46, 36.44) controlPoint2: CGPointMake(7.46, 36.77)];
    [bezierPath addLineToPoint: CGPointMake(7.4, 38.97)];
    [bezierPath addCurveToPoint: CGPointMake(5.48, 38.41) controlPoint1: CGPointMake(6.92, 38.63) controlPoint2: CGPointMake(6.2, 38.41)];
    [bezierPath addCurveToPoint: CGPointMake(2.47, 42.53) controlPoint1: CGPointMake(3.91, 38.41) controlPoint2: CGPointMake(2.47, 39.65)];
    [bezierPath addCurveToPoint: CGPointMake(5.48, 46.68) controlPoint1: CGPointMake(2.47, 45.41) controlPoint2: CGPointMake(3.95, 46.68)];
    [bezierPath addCurveToPoint: CGPointMake(7.4, 46.11) controlPoint1: CGPointMake(6.2, 46.68) controlPoint2: CGPointMake(6.92, 46.46)];
    [bezierPath addLineToPoint: CGPointMake(8.18, 47.88)];
    [bezierPath addCurveToPoint: CGPointMake(5.17, 48.68) controlPoint1: CGPointMake(7.44, 48.38) controlPoint2: CGPointMake(6.46, 48.68)];
    [bezierPath closePath];
    [fillColor3 setFill];
    [bezierPath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(14.18, 38.34)];
    [bezier2Path addCurveToPoint: CGPointMake(11.41, 42.53) controlPoint1: CGPointMake(12.33, 38.34) controlPoint2: CGPointMake(11.41, 40)];
    [bezier2Path addCurveToPoint: CGPointMake(14.18, 46.74) controlPoint1: CGPointMake(11.41, 45.06) controlPoint2: CGPointMake(12.33, 46.74)];
    [bezier2Path addCurveToPoint: CGPointMake(16.95, 42.53) controlPoint1: CGPointMake(16.03, 46.74) controlPoint2: CGPointMake(16.95, 45.06)];
    [bezier2Path addCurveToPoint: CGPointMake(14.18, 38.34) controlPoint1: CGPointMake(16.95, 40) controlPoint2: CGPointMake(16.03, 38.34)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(14.18, 48.68)];
    [bezier2Path addCurveToPoint: CGPointMake(9.01, 42.55) controlPoint1: CGPointMake(10.84, 48.68) controlPoint2: CGPointMake(9.01, 46.04)];
    [bezier2Path addCurveToPoint: CGPointMake(14.18, 36.44) controlPoint1: CGPointMake(9.01, 39.06) controlPoint2: CGPointMake(10.84, 36.44)];
    [bezier2Path addCurveToPoint: CGPointMake(19.35, 42.55) controlPoint1: CGPointMake(17.52, 36.44) controlPoint2: CGPointMake(19.35, 39.06)];
    [bezier2Path addCurveToPoint: CGPointMake(14.18, 48.68) controlPoint1: CGPointMake(19.35, 46.04) controlPoint2: CGPointMake(17.52, 48.68)];
    [bezier2Path closePath];
    [fillColor3 setFill];
    [bezier2Path fill];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(21.36, 36.68)];
    [bezier3Path addLineToPoint: CGPointMake(23.76, 36.68)];
    [bezier3Path addLineToPoint: CGPointMake(23.76, 48.44)];
    [bezier3Path addLineToPoint: CGPointMake(21.36, 48.44)];
    [bezier3Path addLineToPoint: CGPointMake(21.36, 36.68)];
    [bezier3Path closePath];
    [bezier3Path moveToPoint: CGPointMake(22.56, 34.55)];
    [bezier3Path addCurveToPoint: CGPointMake(21.14, 33.19) controlPoint1: CGPointMake(21.77, 34.55) controlPoint2: CGPointMake(21.14, 33.94)];
    [bezier3Path addCurveToPoint: CGPointMake(22.56, 31.84) controlPoint1: CGPointMake(21.14, 32.45) controlPoint2: CGPointMake(21.77, 31.84)];
    [bezier3Path addCurveToPoint: CGPointMake(23.98, 33.19) controlPoint1: CGPointMake(23.34, 31.84) controlPoint2: CGPointMake(23.98, 32.45)];
    [bezier3Path addCurveToPoint: CGPointMake(22.56, 34.55) controlPoint1: CGPointMake(23.98, 33.94) controlPoint2: CGPointMake(23.34, 34.55)];
    [bezier3Path closePath];
    [fillColor3 setFill];
    [bezier3Path fill];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(33.2, 48.44)];
    [bezier4Path addLineToPoint: CGPointMake(33.2, 40.59)];
    [bezier4Path addCurveToPoint: CGPointMake(30.74, 38.36) controlPoint1: CGPointMake(33.2, 39.21) controlPoint2: CGPointMake(32.38, 38.36)];
    [bezier4Path addCurveToPoint: CGPointMake(28.58, 38.71) controlPoint1: CGPointMake(29.87, 38.36) controlPoint2: CGPointMake(29.06, 38.52)];
    [bezier4Path addLineToPoint: CGPointMake(28.58, 48.44)];
    [bezier4Path addLineToPoint: CGPointMake(26.2, 48.44)];
    [bezier4Path addLineToPoint: CGPointMake(26.2, 37.27)];
    [bezier4Path addCurveToPoint: CGPointMake(30.72, 36.44) controlPoint1: CGPointMake(27.38, 36.79) controlPoint2: CGPointMake(28.88, 36.44)];
    [bezier4Path addCurveToPoint: CGPointMake(35.6, 40.37) controlPoint1: CGPointMake(34.01, 36.44) controlPoint2: CGPointMake(35.6, 37.88)];
    [bezier4Path addLineToPoint: CGPointMake(35.6, 48.44)];
    [bezier4Path addLineToPoint: CGPointMake(33.2, 48.44)];
    [bezier4Path closePath];
    [fillColor3 setFill];
    [bezier4Path fill];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(42.24, 38.36)];
    [bezier5Path addCurveToPoint: CGPointMake(40.36, 38.76) controlPoint1: CGPointMake(41.58, 38.36) controlPoint2: CGPointMake(40.82, 38.52)];
    [bezier5Path addLineToPoint: CGPointMake(40.36, 46.48)];
    [bezier5Path addCurveToPoint: CGPointMake(42.06, 46.78) controlPoint1: CGPointMake(40.71, 46.63) controlPoint2: CGPointMake(41.39, 46.78)];
    [bezier5Path addCurveToPoint: CGPointMake(45.36, 42.46) controlPoint1: CGPointMake(43.96, 46.78) controlPoint2: CGPointMake(45.36, 45.48)];
    [bezier5Path addCurveToPoint: CGPointMake(42.24, 38.36) controlPoint1: CGPointMake(45.36, 39.89) controlPoint2: CGPointMake(44.13, 38.36)];
    [bezier5Path closePath];
    [bezier5Path moveToPoint: CGPointMake(41.93, 48.68)];
    [bezier5Path addCurveToPoint: CGPointMake(37.98, 47.85) controlPoint1: CGPointMake(40.4, 48.68) controlPoint2: CGPointMake(38.9, 48.31)];
    [bezier5Path addLineToPoint: CGPointMake(37.98, 31.32)];
    [bezier5Path addLineToPoint: CGPointMake(40.36, 31.32)];
    [bezier5Path addLineToPoint: CGPointMake(40.36, 36.99)];
    [bezier5Path addCurveToPoint: CGPointMake(42.65, 36.51) controlPoint1: CGPointMake(40.93, 36.73) controlPoint2: CGPointMake(41.84, 36.51)];
    [bezier5Path addCurveToPoint: CGPointMake(47.73, 42.29) controlPoint1: CGPointMake(45.68, 36.51) controlPoint2: CGPointMake(47.73, 38.69)];
    [bezier5Path addCurveToPoint: CGPointMake(41.93, 48.68) controlPoint1: CGPointMake(47.73, 46.72) controlPoint2: CGPointMake(45.44, 48.68)];
    [bezier5Path closePath];
    [fillColor3 setFill];
    [bezier5Path fill];
    
    
    //// Bezier 6 Drawing
    UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
    [bezier6Path moveToPoint: CGPointMake(56.18, 42.53)];
    [bezier6Path addCurveToPoint: CGPointMake(51.38, 44.95) controlPoint1: CGPointMake(53.78, 42.66) controlPoint2: CGPointMake(51.38, 42.86)];
    [bezier6Path addCurveToPoint: CGPointMake(54.15, 46.96) controlPoint1: CGPointMake(51.38, 46.2) controlPoint2: CGPointMake(52.34, 46.96)];
    [bezier6Path addCurveToPoint: CGPointMake(56.18, 46.65) controlPoint1: CGPointMake(54.91, 46.96) controlPoint2: CGPointMake(55.81, 46.83)];
    [bezier6Path addLineToPoint: CGPointMake(56.18, 42.53)];
    [bezier6Path closePath];
    [bezier6Path moveToPoint: CGPointMake(54.21, 48.68)];
    [bezier6Path addCurveToPoint: CGPointMake(49.13, 45) controlPoint1: CGPointMake(50.83, 48.68) controlPoint2: CGPointMake(49.13, 47.31)];
    [bezier6Path addCurveToPoint: CGPointMake(56.18, 40.94) controlPoint1: CGPointMake(49.13, 41.72) controlPoint2: CGPointMake(52.62, 41.13)];
    [bezier6Path addLineToPoint: CGPointMake(56.18, 40.2)];
    [bezier6Path addCurveToPoint: CGPointMake(53.69, 38.19) controlPoint1: CGPointMake(56.18, 38.71) controlPoint2: CGPointMake(55.19, 38.19)];
    [bezier6Path addCurveToPoint: CGPointMake(50.44, 38.91) controlPoint1: CGPointMake(52.58, 38.19) controlPoint2: CGPointMake(51.22, 38.54)];
    [bezier6Path addLineToPoint: CGPointMake(49.83, 37.27)];
    [bezier6Path addCurveToPoint: CGPointMake(53.93, 36.44) controlPoint1: CGPointMake(50.77, 36.86) controlPoint2: CGPointMake(52.36, 36.44)];
    [bezier6Path addCurveToPoint: CGPointMake(58.45, 40.44) controlPoint1: CGPointMake(56.74, 36.44) controlPoint2: CGPointMake(58.45, 37.53)];
    [bezier6Path addLineToPoint: CGPointMake(58.45, 47.85)];
    [bezier6Path addCurveToPoint: CGPointMake(54.21, 48.68) controlPoint1: CGPointMake(57.59, 48.31) controlPoint2: CGPointMake(55.87, 48.68)];
    [bezier6Path closePath];
    [fillColor3 setFill];
    [bezier6Path fill];
    
    
    //// Bezier 7 Drawing
    UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
    [bezier7Path moveToPoint: CGPointMake(63.81, 48.68)];
    [bezier7Path addCurveToPoint: CGPointMake(60.15, 47.85) controlPoint1: CGPointMake(62.44, 48.68) controlPoint2: CGPointMake(61, 48.31)];
    [bezier7Path addLineToPoint: CGPointMake(60.95, 46.02)];
    [bezier7Path addCurveToPoint: CGPointMake(63.75, 46.78) controlPoint1: CGPointMake(61.57, 46.39) controlPoint2: CGPointMake(62.85, 46.78)];
    [bezier7Path addCurveToPoint: CGPointMake(65.89, 45.17) controlPoint1: CGPointMake(65.03, 46.78) controlPoint2: CGPointMake(65.89, 46.15)];
    [bezier7Path addCurveToPoint: CGPointMake(63.79, 43.25) controlPoint1: CGPointMake(65.89, 44.1) controlPoint2: CGPointMake(64.99, 43.69)];
    [bezier7Path addCurveToPoint: CGPointMake(60.45, 39.74) controlPoint1: CGPointMake(62.22, 42.66) controlPoint2: CGPointMake(60.45, 41.94)];
    [bezier7Path addCurveToPoint: CGPointMake(64.58, 36.44) controlPoint1: CGPointMake(60.45, 37.8) controlPoint2: CGPointMake(61.96, 36.44)];
    [bezier7Path addCurveToPoint: CGPointMake(68, 37.27) controlPoint1: CGPointMake(65.99, 36.44) controlPoint2: CGPointMake(67.17, 36.79)];
    [bezier7Path addLineToPoint: CGPointMake(67.26, 38.93)];
    [bezier7Path addCurveToPoint: CGPointMake(64.84, 38.23) controlPoint1: CGPointMake(66.74, 38.6) controlPoint2: CGPointMake(65.69, 38.23)];
    [bezier7Path addCurveToPoint: CGPointMake(62.9, 39.74) controlPoint1: CGPointMake(63.59, 38.23) controlPoint2: CGPointMake(62.9, 38.89)];
    [bezier7Path addCurveToPoint: CGPointMake(64.93, 41.61) controlPoint1: CGPointMake(62.9, 40.81) controlPoint2: CGPointMake(63.77, 41.18)];
    [bezier7Path addCurveToPoint: CGPointMake(68.37, 45.19) controlPoint1: CGPointMake(66.56, 42.22) controlPoint2: CGPointMake(68.37, 42.9)];
    [bezier7Path addCurveToPoint: CGPointMake(63.81, 48.68) controlPoint1: CGPointMake(68.37, 47.31) controlPoint2: CGPointMake(66.76, 48.68)];
    [bezier7Path closePath];
    [fillColor3 setFill];
    [bezier7Path fill];
    
    
    //// Bezier 8 Drawing
    UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
    [bezier8Path moveToPoint: CGPointMake(75.09, 38.19)];
    [bezier8Path addCurveToPoint: CGPointMake(72.02, 42.03) controlPoint1: CGPointMake(73.26, 38.19) controlPoint2: CGPointMake(72.06, 39.59)];
    [bezier8Path addLineToPoint: CGPointMake(77.71, 41.24)];
    [bezier8Path addCurveToPoint: CGPointMake(75.09, 38.19) controlPoint1: CGPointMake(77.69, 39.19) controlPoint2: CGPointMake(76.66, 38.19)];
    [bezier8Path closePath];
    [bezier8Path moveToPoint: CGPointMake(79.98, 42.51)];
    [bezier8Path addLineToPoint: CGPointMake(72.17, 43.6)];
    [bezier8Path addCurveToPoint: CGPointMake(75.77, 46.79) controlPoint1: CGPointMake(72.41, 45.72) controlPoint2: CGPointMake(73.78, 46.79)];
    [bezier8Path addCurveToPoint: CGPointMake(79.02, 46.07) controlPoint1: CGPointMake(76.95, 46.79) controlPoint2: CGPointMake(78.21, 46.5)];
    [bezier8Path addLineToPoint: CGPointMake(79.72, 47.85)];
    [bezier8Path addCurveToPoint: CGPointMake(75.62, 48.68) controlPoint1: CGPointMake(78.8, 48.33) controlPoint2: CGPointMake(77.23, 48.68)];
    [bezier8Path addCurveToPoint: CGPointMake(69.83, 42.55) controlPoint1: CGPointMake(71.91, 48.68) controlPoint2: CGPointMake(69.83, 46.31)];
    [bezier8Path addCurveToPoint: CGPointMake(75.14, 36.44) controlPoint1: CGPointMake(69.83, 38.95) controlPoint2: CGPointMake(71.84, 36.44)];
    [bezier8Path addCurveToPoint: CGPointMake(80, 41.61) controlPoint1: CGPointMake(78.19, 36.44) controlPoint2: CGPointMake(80, 38.45)];
    [bezier8Path addCurveToPoint: CGPointMake(79.98, 42.51) controlPoint1: CGPointMake(80, 41.9) controlPoint2: CGPointMake(80, 42.2)];
    [bezier8Path closePath];
    [fillColor3 setFill];
    [bezier8Path fill];

}

@end
