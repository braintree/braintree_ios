#import "BTUIKLargeJCBVectorArtView.h"

@implementation BTUIKLargeJCBVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor8 = [UIColor colorWithRed: 0.266 green: 0.65 blue: 0.146 alpha: 1];
    UIColor* fillColor9 = [UIColor colorWithRed: 0.04 green: 0.338 blue: 0.664 alpha: 1];
    UIColor* fillColor10 = [UIColor colorWithRed: 0.842 green: 0 blue: 0.166 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(71.94, 16.02)];
    [bezierPath addLineToPoint: CGPointMake(71.97, 16.02)];
    [bezierPath addLineToPoint: CGPointMake(71.97, 16.94)];
    [bezierPath addCurveToPoint: CGPointMake(71.97, 55.98) controlPoint1: CGPointMake(71.97, 17.78) controlPoint2: CGPointMake(71.97, 55.62)];
    [bezierPath addCurveToPoint: CGPointMake(68.74, 62.4) controlPoint1: CGPointMake(71.96, 58.5) controlPoint2: CGPointMake(70.76, 60.9)];
    [bezierPath addCurveToPoint: CGPointMake(63.7, 63.98) controlPoint1: CGPointMake(67.26, 63.51) controlPoint2: CGPointMake(65.52, 63.98)];
    [bezierPath addCurveToPoint: CGPointMake(52.26, 63.97) controlPoint1: CGPointMake(62.67, 63.98) controlPoint2: CGPointMake(52.31, 64.03)];
    [bezierPath addCurveToPoint: CGPointMake(52.26, 63.78) controlPoint1: CGPointMake(52.24, 63.95) controlPoint2: CGPointMake(52.26, 63.81)];
    [bezierPath addLineToPoint: CGPointMake(52.26, 47.81)];
    [bezierPath addCurveToPoint: CGPointMake(52.34, 47.66) controlPoint1: CGPointMake(52.26, 47.72) controlPoint2: CGPointMake(52.27, 47.66)];
    [bezierPath addLineToPoint: CGPointMake(64.71, 47.66)];
    [bezierPath addCurveToPoint: CGPointMake(68.7, 46.23) controlPoint1: CGPointMake(66.76, 47.66) controlPoint2: CGPointMake(67.88, 47.06)];
    [bezierPath addCurveToPoint: CGPointMake(69.39, 42.18) controlPoint1: CGPointMake(69.74, 45.18) controlPoint2: CGPointMake(70.05, 43.51)];
    [bezierPath addCurveToPoint: CGPointMake(66.46, 40.04) controlPoint1: CGPointMake(68.83, 41.04) controlPoint2: CGPointMake(67.66, 40.35)];
    [bezierPath addCurveToPoint: CGPointMake(65.33, 39.85) controlPoint1: CGPointMake(66.09, 39.94) controlPoint2: CGPointMake(65.71, 39.88)];
    [bezierPath addCurveToPoint: CGPointMake(65.16, 39.83) controlPoint1: CGPointMake(65.3, 39.84) controlPoint2: CGPointMake(65.17, 39.85)];
    [bezierPath addCurveToPoint: CGPointMake(65.25, 39.72) controlPoint1: CGPointMake(65.09, 39.75) controlPoint2: CGPointMake(65.21, 39.74)];
    [bezierPath addCurveToPoint: CGPointMake(66, 39.55) controlPoint1: CGPointMake(65.49, 39.65) controlPoint2: CGPointMake(65.76, 39.63)];
    [bezierPath addCurveToPoint: CGPointMake(68.68, 36.97) controlPoint1: CGPointMake(67.26, 39.17) controlPoint2: CGPointMake(68.34, 38.28)];
    [bezierPath addCurveToPoint: CGPointMake(67.45, 33.33) controlPoint1: CGPointMake(69.03, 35.62) controlPoint2: CGPointMake(68.57, 34.17)];
    [bezierPath addCurveToPoint: CGPointMake(64.65, 32.37) controlPoint1: CGPointMake(66.64, 32.73) controlPoint2: CGPointMake(65.64, 32.45)];
    [bezierPath addCurveToPoint: CGPointMake(52.38, 32.32) controlPoint1: CGPointMake(63.64, 32.28) controlPoint2: CGPointMake(53.4, 32.32)];
    [bezierPath addCurveToPoint: CGPointMake(52.26, 32.11) controlPoint1: CGPointMake(52.21, 32.32) controlPoint2: CGPointMake(52.26, 32.27)];
    [bezierPath addLineToPoint: CGPointMake(52.26, 24.5)];
    [bezierPath addCurveToPoint: CGPointMake(52.43, 22.34) controlPoint1: CGPointMake(52.26, 23.78) controlPoint2: CGPointMake(52.28, 23.06)];
    [bezierPath addCurveToPoint: CGPointMake(54.35, 18.62) controlPoint1: CGPointMake(52.73, 20.96) controlPoint2: CGPointMake(53.4, 19.67)];
    [bezierPath addCurveToPoint: CGPointMake(59.44, 16.06) controlPoint1: CGPointMake(55.67, 17.18) controlPoint2: CGPointMake(57.5, 16.26)];
    [bezierPath addCurveToPoint: CGPointMake(71.94, 16.02) controlPoint1: CGPointMake(60.57, 15.95) controlPoint2: CGPointMake(70.97, 16.02)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(62.37, 36.2)];
    [bezierPath addCurveToPoint: CGPointMake(61.89, 38) controlPoint1: CGPointMake(62.51, 36.83) controlPoint2: CGPointMake(62.35, 37.53)];
    [bezierPath addCurveToPoint: CGPointMake(60.37, 38.59) controlPoint1: CGPointMake(61.49, 38.41) controlPoint2: CGPointMake(60.94, 38.58)];
    [bezierPath addCurveToPoint: CGPointMake(56.16, 38.59) controlPoint1: CGPointMake(59.91, 38.6) controlPoint2: CGPointMake(56.31, 38.59)];
    [bezierPath addCurveToPoint: CGPointMake(56.16, 34.75) controlPoint1: CGPointMake(56.16, 38.51) controlPoint2: CGPointMake(56.16, 34.8)];
    [bezierPath addCurveToPoint: CGPointMake(56.3, 34.7) controlPoint1: CGPointMake(56.19, 34.68) controlPoint2: CGPointMake(56.21, 34.7)];
    [bezierPath addCurveToPoint: CGPointMake(60.6, 34.71) controlPoint1: CGPointMake(56.53, 34.7) controlPoint2: CGPointMake(60.34, 34.69)];
    [bezierPath addCurveToPoint: CGPointMake(62.01, 35.43) controlPoint1: CGPointMake(61.15, 34.76) controlPoint2: CGPointMake(61.66, 35)];
    [bezierPath addCurveToPoint: CGPointMake(62.37, 36.2) controlPoint1: CGPointMake(62.19, 35.65) controlPoint2: CGPointMake(62.31, 35.92)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(56.16, 40.97)];
    [bezierPath addCurveToPoint: CGPointMake(60.74, 40.97) controlPoint1: CGPointMake(57.18, 40.97) controlPoint2: CGPointMake(60.23, 40.97)];
    [bezierPath addCurveToPoint: CGPointMake(62.28, 41.5) controlPoint1: CGPointMake(61.31, 40.98) controlPoint2: CGPointMake(61.85, 41.12)];
    [bezierPath addCurveToPoint: CGPointMake(62.94, 43.41) controlPoint1: CGPointMake(62.81, 41.98) controlPoint2: CGPointMake(63.05, 42.71)];
    [bezierPath addCurveToPoint: CGPointMake(61.95, 44.9) controlPoint1: CGPointMake(62.85, 44.03) controlPoint2: CGPointMake(62.49, 44.58)];
    [bezierPath addCurveToPoint: CGPointMake(60.53, 45.19) controlPoint1: CGPointMake(61.51, 45.16) controlPoint2: CGPointMake(61.03, 45.19)];
    [bezierPath addCurveToPoint: CGPointMake(56.16, 45.19) controlPoint1: CGPointMake(60.02, 45.19) controlPoint2: CGPointMake(56.28, 45.19)];
    [bezierPath addCurveToPoint: CGPointMake(56.16, 40.97) controlPoint1: CGPointMake(56.16, 45.11) controlPoint2: CGPointMake(56.16, 41.01)];
    [bezierPath closePath];
    [fillColor8 setFill];
    [bezierPath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(8.2, 43.83)];
    [bezier2Path addCurveToPoint: CGPointMake(8.04, 43.69) controlPoint1: CGPointMake(8.06, 43.77) controlPoint2: CGPointMake(8.06, 43.79)];
    [bezier2Path addCurveToPoint: CGPointMake(8.04, 23.67) controlPoint1: CGPointMake(8.02, 43.63) controlPoint2: CGPointMake(8.03, 24.12)];
    [bezier2Path addCurveToPoint: CGPointMake(10.9, 17.89) controlPoint1: CGPointMake(8.14, 21.44) controlPoint2: CGPointMake(9.19, 19.32)];
    [bezier2Path addCurveToPoint: CGPointMake(15.21, 16.06) controlPoint1: CGPointMake(12.11, 16.87) controlPoint2: CGPointMake(13.63, 16.22)];
    [bezier2Path addCurveToPoint: CGPointMake(18.04, 16.02) controlPoint1: CGPointMake(16.14, 15.97) controlPoint2: CGPointMake(17.1, 16.02)];
    [bezier2Path addCurveToPoint: CGPointMake(27.75, 16.02) controlPoint1: CGPointMake(19.66, 16.02) controlPoint2: CGPointMake(27.72, 15.99)];
    [bezier2Path addCurveToPoint: CGPointMake(27.75, 55.98) controlPoint1: CGPointMake(27.77, 16.04) controlPoint2: CGPointMake(27.75, 55.24)];
    [bezier2Path addCurveToPoint: CGPointMake(25.14, 61.89) controlPoint1: CGPointMake(27.74, 58.22) controlPoint2: CGPointMake(26.8, 60.38)];
    [bezier2Path addCurveToPoint: CGPointMake(20.83, 63.9) controlPoint1: CGPointMake(23.95, 62.98) controlPoint2: CGPointMake(22.43, 63.69)];
    [bezier2Path addCurveToPoint: CGPointMake(8.19, 63.97) controlPoint1: CGPointMake(19.87, 64.03) controlPoint2: CGPointMake(9, 63.97)];
    [bezier2Path addCurveToPoint: CGPointMake(8.04, 63.92) controlPoint1: CGPointMake(8.04, 63.97) controlPoint2: CGPointMake(8.07, 64.01)];
    [bezier2Path addCurveToPoint: CGPointMake(8.04, 47.13) controlPoint1: CGPointMake(8.02, 63.86) controlPoint2: CGPointMake(8.04, 47.54)];
    [bezier2Path addCurveToPoint: CGPointMake(12.82, 47.95) controlPoint1: CGPointMake(9.6, 47.55) controlPoint2: CGPointMake(11.22, 47.79)];
    [bezier2Path addCurveToPoint: CGPointMake(17.52, 48.1) controlPoint1: CGPointMake(14.38, 48.11) controlPoint2: CGPointMake(15.95, 48.17)];
    [bezier2Path addCurveToPoint: CGPointMake(23.91, 46.31) controlPoint1: CGPointMake(19.71, 47.99) controlPoint2: CGPointMake(22.11, 47.65)];
    [bezier2Path addCurveToPoint: CGPointMake(25.63, 44.15) controlPoint1: CGPointMake(24.66, 45.76) controlPoint2: CGPointMake(25.27, 45.02)];
    [bezier2Path addCurveToPoint: CGPointMake(26.11, 41.54) controlPoint1: CGPointMake(25.98, 43.33) controlPoint2: CGPointMake(26.1, 42.43)];
    [bezier2Path addCurveToPoint: CGPointMake(26.07, 32.31) controlPoint1: CGPointMake(26.11, 40.73) controlPoint2: CGPointMake(26.12, 32.35)];
    [bezier2Path addCurveToPoint: CGPointMake(19.23, 32.34) controlPoint1: CGPointMake(26.01, 32.28) controlPoint2: CGPointMake(19.27, 32.28)];
    [bezier2Path addCurveToPoint: CGPointMake(19.23, 41.59) controlPoint1: CGPointMake(19.2, 32.4) controlPoint2: CGPointMake(19.23, 41.4)];
    [bezier2Path addCurveToPoint: CGPointMake(18.02, 44.52) controlPoint1: CGPointMake(19.22, 42.69) controlPoint2: CGPointMake(18.85, 43.77)];
    [bezier2Path addCurveToPoint: CGPointMake(14, 45.51) controlPoint1: CGPointMake(16.92, 45.5) controlPoint2: CGPointMake(15.4, 45.62)];
    [bezier2Path addCurveToPoint: CGPointMake(9.3, 44.32) controlPoint1: CGPointMake(12.38, 45.38) controlPoint2: CGPointMake(10.8, 44.94)];
    [bezier2Path addCurveToPoint: CGPointMake(8.2, 43.83) controlPoint1: CGPointMake(8.93, 44.17) controlPoint2: CGPointMake(8.56, 44)];
    [bezier2Path closePath];
    [fillColor9 setFill];
    [bezier2Path fill];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(30.31, 34.34)];
    [bezier3Path addCurveToPoint: CGPointMake(30.15, 34.48) controlPoint1: CGPointMake(30.26, 34.39) controlPoint2: CGPointMake(30.2, 34.43)];
    [bezier3Path addLineToPoint: CGPointMake(30.15, 25.48)];
    [bezier3Path addCurveToPoint: CGPointMake(30.17, 23.41) controlPoint1: CGPointMake(30.15, 24.8) controlPoint2: CGPointMake(30.12, 24.1)];
    [bezier3Path addCurveToPoint: CGPointMake(37.11, 16.09) controlPoint1: CGPointMake(30.45, 19.68) controlPoint2: CGPointMake(33.41, 16.56)];
    [bezier3Path addCurveToPoint: CGPointMake(49.86, 16.03) controlPoint1: CGPointMake(38.01, 15.97) controlPoint2: CGPointMake(49.83, 15.99)];
    [bezier3Path addCurveToPoint: CGPointMake(49.86, 16.2) controlPoint1: CGPointMake(49.88, 16.05) controlPoint2: CGPointMake(49.86, 16.17)];
    [bezier3Path addCurveToPoint: CGPointMake(49.86, 55.9) controlPoint1: CGPointMake(49.86, 17.19) controlPoint2: CGPointMake(49.86, 55)];
    [bezier3Path addCurveToPoint: CGPointMake(45.41, 63.15) controlPoint1: CGPointMake(49.86, 58.95) controlPoint2: CGPointMake(48.15, 61.79)];
    [bezier3Path addCurveToPoint: CGPointMake(41.62, 63.98) controlPoint1: CGPointMake(44.22, 63.74) controlPoint2: CGPointMake(42.94, 63.98)];
    [bezier3Path addCurveToPoint: CGPointMake(30.23, 63.98) controlPoint1: CGPointMake(40.86, 63.98) controlPoint2: CGPointMake(30.41, 64.01)];
    [bezier3Path addCurveToPoint: CGPointMake(30.15, 63.92) controlPoint1: CGPointMake(30.11, 63.95) controlPoint2: CGPointMake(30.18, 64)];
    [bezier3Path addCurveToPoint: CGPointMake(30.15, 46.51) controlPoint1: CGPointMake(30.13, 63.88) controlPoint2: CGPointMake(30.15, 48.6)];
    [bezier3Path addLineToPoint: CGPointMake(30.15, 45.52)];
    [bezier3Path addCurveToPoint: CGPointMake(34.77, 47.64) controlPoint1: CGPointMake(31.45, 46.64) controlPoint2: CGPointMake(33.11, 47.28)];
    [bezier3Path addCurveToPoint: CGPointMake(38.61, 48.1) controlPoint1: CGPointMake(36.03, 47.92) controlPoint2: CGPointMake(37.32, 48.06)];
    [bezier3Path addCurveToPoint: CGPointMake(42.4, 48.02) controlPoint1: CGPointMake(39.87, 48.15) controlPoint2: CGPointMake(41.14, 48.13)];
    [bezier3Path addCurveToPoint: CGPointMake(46.23, 47.45) controlPoint1: CGPointMake(43.69, 47.9) controlPoint2: CGPointMake(44.97, 47.7)];
    [bezier3Path addCurveToPoint: CGPointMake(47.2, 47.24) controlPoint1: CGPointMake(46.56, 47.38) controlPoint2: CGPointMake(46.88, 47.31)];
    [bezier3Path addCurveToPoint: CGPointMake(47.64, 47.13) controlPoint1: CGPointMake(47.28, 47.22) controlPoint2: CGPointMake(47.6, 47.19)];
    [bezier3Path addCurveToPoint: CGPointMake(47.64, 46.85) controlPoint1: CGPointMake(47.67, 47.09) controlPoint2: CGPointMake(47.64, 46.91)];
    [bezier3Path addLineToPoint: CGPointMake(47.64, 44)];
    [bezier3Path addLineToPoint: CGPointMake(47.64, 43.75)];
    [bezier3Path addCurveToPoint: CGPointMake(43.33, 45.28) controlPoint1: CGPointMake(46.27, 44.44) controlPoint2: CGPointMake(44.83, 44.98)];
    [bezier3Path addCurveToPoint: CGPointMake(37.71, 44.99) controlPoint1: CGPointMake(41.49, 45.64) controlPoint2: CGPointMake(39.46, 45.74)];
    [bezier3Path addCurveToPoint: CGPointMake(34.7, 40.69) controlPoint1: CGPointMake(35.93, 44.23) controlPoint2: CGPointMake(34.88, 42.6)];
    [bezier3Path addCurveToPoint: CGPointMake(36.78, 35.52) controlPoint1: CGPointMake(34.52, 38.73) controlPoint2: CGPointMake(35.11, 36.68)];
    [bezier3Path addCurveToPoint: CGPointMake(42.8, 34.62) controlPoint1: CGPointMake(38.52, 34.31) controlPoint2: CGPointMake(40.79, 34.3)];
    [bezier3Path addCurveToPoint: CGPointMake(47.1, 35.98) controlPoint1: CGPointMake(44.29, 34.86) controlPoint2: CGPointMake(45.73, 35.34)];
    [bezier3Path addCurveToPoint: CGPointMake(47.64, 36.25) controlPoint1: CGPointMake(47.28, 36.07) controlPoint2: CGPointMake(47.46, 36.16)];
    [bezier3Path addLineToPoint: CGPointMake(47.64, 33.77)];
    [bezier3Path addLineToPoint: CGPointMake(47.64, 33.14)];
    [bezier3Path addCurveToPoint: CGPointMake(47.64, 32.87) controlPoint1: CGPointMake(47.64, 33.1) controlPoint2: CGPointMake(47.67, 32.91)];
    [bezier3Path addCurveToPoint: CGPointMake(47.2, 32.76) controlPoint1: CGPointMake(47.59, 32.8) controlPoint2: CGPointMake(47.28, 32.78)];
    [bezier3Path addCurveToPoint: CGPointMake(46.73, 32.66) controlPoint1: CGPointMake(47.04, 32.72) controlPoint2: CGPointMake(46.88, 32.69)];
    [bezier3Path addCurveToPoint: CGPointMake(42.92, 32.03) controlPoint1: CGPointMake(45.47, 32.39) controlPoint2: CGPointMake(44.2, 32.17)];
    [bezier3Path addCurveToPoint: CGPointMake(39.15, 31.88) controlPoint1: CGPointMake(41.67, 31.9) controlPoint2: CGPointMake(40.41, 31.86)];
    [bezier3Path addCurveToPoint: CGPointMake(35.33, 32.24) controlPoint1: CGPointMake(37.87, 31.9) controlPoint2: CGPointMake(36.59, 32.01)];
    [bezier3Path addCurveToPoint: CGPointMake(30.89, 33.92) controlPoint1: CGPointMake(33.77, 32.53) controlPoint2: CGPointMake(32.22, 33.03)];
    [bezier3Path addCurveToPoint: CGPointMake(30.31, 34.34) controlPoint1: CGPointMake(30.69, 34.05) controlPoint2: CGPointMake(30.5, 34.19)];
    [bezier3Path closePath];
    [fillColor10 setFill];
    [bezier3Path fill];
}


@end
