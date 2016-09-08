#import "BTUIKJCBVectorArtView.h"

@implementation BTUIKJCBVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor8 = [UIColor colorWithRed: 0.266 green: 0.65 blue: 0.146 alpha: 1];
    UIColor* fillColor9 = [UIColor colorWithRed: 0.04 green: 0.338 blue: 0.664 alpha: 1];
    UIColor* fillColor10 = [UIColor colorWithRed: 0.842 green: 0 blue: 0.166 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(37.14, 3.51)];
    [bezierPath addLineToPoint: CGPointMake(37.15, 3.51)];
    [bezierPath addLineToPoint: CGPointMake(37.15, 3.93)];
    [bezierPath addCurveToPoint: CGPointMake(37.15, 21.82) controlPoint1: CGPointMake(37.15, 4.32) controlPoint2: CGPointMake(37.15, 21.66)];
    [bezierPath addCurveToPoint: CGPointMake(35.67, 24.77) controlPoint1: CGPointMake(37.15, 22.98) controlPoint2: CGPointMake(36.6, 24.08)];
    [bezierPath addCurveToPoint: CGPointMake(33.36, 25.49) controlPoint1: CGPointMake(34.99, 25.27) controlPoint2: CGPointMake(34.2, 25.49)];
    [bezierPath addCurveToPoint: CGPointMake(28.12, 25.49) controlPoint1: CGPointMake(32.89, 25.49) controlPoint2: CGPointMake(28.14, 25.52)];
    [bezierPath addCurveToPoint: CGPointMake(28.12, 25.4) controlPoint1: CGPointMake(28.11, 25.47) controlPoint2: CGPointMake(28.12, 25.41)];
    [bezierPath addLineToPoint: CGPointMake(28.12, 18.08)];
    [bezierPath addCurveToPoint: CGPointMake(28.16, 18.01) controlPoint1: CGPointMake(28.12, 18.04) controlPoint2: CGPointMake(28.12, 18.01)];
    [bezierPath addLineToPoint: CGPointMake(33.83, 18.01)];
    [bezierPath addCurveToPoint: CGPointMake(35.65, 17.36) controlPoint1: CGPointMake(34.76, 18.01) controlPoint2: CGPointMake(35.28, 17.74)];
    [bezierPath addCurveToPoint: CGPointMake(35.97, 15.5) controlPoint1: CGPointMake(36.13, 16.88) controlPoint2: CGPointMake(36.28, 16.11)];
    [bezierPath addCurveToPoint: CGPointMake(34.63, 14.52) controlPoint1: CGPointMake(35.71, 14.97) controlPoint2: CGPointMake(35.18, 14.66)];
    [bezierPath addCurveToPoint: CGPointMake(34.11, 14.43) controlPoint1: CGPointMake(34.46, 14.47) controlPoint2: CGPointMake(34.28, 14.45)];
    [bezierPath addCurveToPoint: CGPointMake(34.03, 14.42) controlPoint1: CGPointMake(34.1, 14.43) controlPoint2: CGPointMake(34.04, 14.43)];
    [bezierPath addCurveToPoint: CGPointMake(34.07, 14.37) controlPoint1: CGPointMake(34, 14.39) controlPoint2: CGPointMake(34.06, 14.38)];
    [bezierPath addCurveToPoint: CGPointMake(34.42, 14.29) controlPoint1: CGPointMake(34.18, 14.34) controlPoint2: CGPointMake(34.3, 14.33)];
    [bezierPath addCurveToPoint: CGPointMake(35.65, 13.11) controlPoint1: CGPointMake(34.99, 14.12) controlPoint2: CGPointMake(35.49, 13.71)];
    [bezierPath addCurveToPoint: CGPointMake(35.08, 11.44) controlPoint1: CGPointMake(35.81, 12.49) controlPoint2: CGPointMake(35.59, 11.83)];
    [bezierPath addCurveToPoint: CGPointMake(33.8, 11) controlPoint1: CGPointMake(34.71, 11.17) controlPoint2: CGPointMake(34.25, 11.04)];
    [bezierPath addCurveToPoint: CGPointMake(28.17, 10.98) controlPoint1: CGPointMake(33.34, 10.96) controlPoint2: CGPointMake(28.64, 10.98)];
    [bezierPath addCurveToPoint: CGPointMake(28.12, 10.88) controlPoint1: CGPointMake(28.1, 10.98) controlPoint2: CGPointMake(28.12, 10.96)];
    [bezierPath addLineToPoint: CGPointMake(28.12, 7.4)];
    [bezierPath addCurveToPoint: CGPointMake(28.2, 6.41) controlPoint1: CGPointMake(28.12, 7.06) controlPoint2: CGPointMake(28.13, 6.73)];
    [bezierPath addCurveToPoint: CGPointMake(29.08, 4.7) controlPoint1: CGPointMake(28.33, 5.77) controlPoint2: CGPointMake(28.64, 5.18)];
    [bezierPath addCurveToPoint: CGPointMake(31.41, 3.53) controlPoint1: CGPointMake(29.68, 4.04) controlPoint2: CGPointMake(30.52, 3.62)];
    [bezierPath addCurveToPoint: CGPointMake(37.14, 3.51) controlPoint1: CGPointMake(31.93, 3.48) controlPoint2: CGPointMake(36.69, 3.51)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(32.76, 12.76)];
    [bezierPath addCurveToPoint: CGPointMake(32.53, 13.58) controlPoint1: CGPointMake(32.82, 13.05) controlPoint2: CGPointMake(32.74, 13.37)];
    [bezierPath addCurveToPoint: CGPointMake(31.84, 13.86) controlPoint1: CGPointMake(32.35, 13.77) controlPoint2: CGPointMake(32.1, 13.85)];
    [bezierPath addCurveToPoint: CGPointMake(29.91, 13.86) controlPoint1: CGPointMake(31.63, 13.86) controlPoint2: CGPointMake(29.97, 13.86)];
    [bezierPath addCurveToPoint: CGPointMake(29.91, 12.09) controlPoint1: CGPointMake(29.91, 13.82) controlPoint2: CGPointMake(29.91, 12.12)];
    [bezierPath addCurveToPoint: CGPointMake(29.97, 12.07) controlPoint1: CGPointMake(29.92, 12.06) controlPoint2: CGPointMake(29.93, 12.07)];
    [bezierPath addCurveToPoint: CGPointMake(31.94, 12.08) controlPoint1: CGPointMake(30.08, 12.07) controlPoint2: CGPointMake(31.82, 12.07)];
    [bezierPath addCurveToPoint: CGPointMake(32.59, 12.4) controlPoint1: CGPointMake(32.19, 12.1) controlPoint2: CGPointMake(32.43, 12.21)];
    [bezierPath addCurveToPoint: CGPointMake(32.76, 12.76) controlPoint1: CGPointMake(32.67, 12.51) controlPoint2: CGPointMake(32.73, 12.63)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(29.91, 14.94)];
    [bezierPath addCurveToPoint: CGPointMake(32.01, 14.94) controlPoint1: CGPointMake(30.37, 14.94) controlPoint2: CGPointMake(31.77, 14.94)];
    [bezierPath addCurveToPoint: CGPointMake(32.71, 15.19) controlPoint1: CGPointMake(32.27, 14.95) controlPoint2: CGPointMake(32.51, 15.01)];
    [bezierPath addCurveToPoint: CGPointMake(33.02, 16.06) controlPoint1: CGPointMake(32.96, 15.41) controlPoint2: CGPointMake(33.06, 15.74)];
    [bezierPath addCurveToPoint: CGPointMake(32.56, 16.74) controlPoint1: CGPointMake(32.97, 16.35) controlPoint2: CGPointMake(32.81, 16.6)];
    [bezierPath addCurveToPoint: CGPointMake(31.91, 16.88) controlPoint1: CGPointMake(32.36, 16.86) controlPoint2: CGPointMake(32.14, 16.88)];
    [bezierPath addCurveToPoint: CGPointMake(29.91, 16.88) controlPoint1: CGPointMake(31.68, 16.88) controlPoint2: CGPointMake(29.96, 16.88)];
    [bezierPath addCurveToPoint: CGPointMake(29.91, 14.94) controlPoint1: CGPointMake(29.91, 16.84) controlPoint2: CGPointMake(29.91, 14.96)];
    [bezierPath closePath];
    [fillColor8 setFill];
    [bezierPath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(7.93, 16.26)];
    [bezier2Path addCurveToPoint: CGPointMake(7.85, 16.19) controlPoint1: CGPointMake(7.86, 16.23) controlPoint2: CGPointMake(7.86, 16.24)];
    [bezier2Path addCurveToPoint: CGPointMake(7.85, 7.01) controlPoint1: CGPointMake(7.84, 16.17) controlPoint2: CGPointMake(7.85, 7.22)];
    [bezier2Path addCurveToPoint: CGPointMake(9.16, 4.37) controlPoint1: CGPointMake(7.9, 5.99) controlPoint2: CGPointMake(8.38, 5.02)];
    [bezier2Path addCurveToPoint: CGPointMake(11.14, 3.53) controlPoint1: CGPointMake(9.72, 3.9) controlPoint2: CGPointMake(10.41, 3.6)];
    [bezier2Path addCurveToPoint: CGPointMake(12.43, 3.51) controlPoint1: CGPointMake(11.57, 3.49) controlPoint2: CGPointMake(12.01, 3.51)];
    [bezier2Path addCurveToPoint: CGPointMake(16.89, 3.51) controlPoint1: CGPointMake(13.18, 3.51) controlPoint2: CGPointMake(16.87, 3.5)];
    [bezier2Path addCurveToPoint: CGPointMake(16.89, 21.83) controlPoint1: CGPointMake(16.89, 3.52) controlPoint2: CGPointMake(16.89, 21.49)];
    [bezier2Path addCurveToPoint: CGPointMake(15.69, 24.53) controlPoint1: CGPointMake(16.88, 22.85) controlPoint2: CGPointMake(16.45, 23.84)];
    [bezier2Path addCurveToPoint: CGPointMake(13.71, 25.46) controlPoint1: CGPointMake(15.14, 25.03) controlPoint2: CGPointMake(14.45, 25.36)];
    [bezier2Path addCurveToPoint: CGPointMake(7.92, 25.49) controlPoint1: CGPointMake(13.27, 25.51) controlPoint2: CGPointMake(8.29, 25.49)];
    [bezier2Path addCurveToPoint: CGPointMake(7.85, 25.46) controlPoint1: CGPointMake(7.85, 25.49) controlPoint2: CGPointMake(7.86, 25.5)];
    [bezier2Path addCurveToPoint: CGPointMake(7.85, 17.77) controlPoint1: CGPointMake(7.84, 25.43) controlPoint2: CGPointMake(7.85, 17.95)];
    [bezier2Path addCurveToPoint: CGPointMake(10.04, 18.14) controlPoint1: CGPointMake(8.56, 17.96) controlPoint2: CGPointMake(9.31, 18.07)];
    [bezier2Path addCurveToPoint: CGPointMake(12.2, 18.21) controlPoint1: CGPointMake(10.76, 18.22) controlPoint2: CGPointMake(11.48, 18.24)];
    [bezier2Path addCurveToPoint: CGPointMake(15.13, 17.39) controlPoint1: CGPointMake(13.2, 18.16) controlPoint2: CGPointMake(14.3, 18)];
    [bezier2Path addCurveToPoint: CGPointMake(15.91, 16.4) controlPoint1: CGPointMake(15.47, 17.14) controlPoint2: CGPointMake(15.75, 16.8)];
    [bezier2Path addCurveToPoint: CGPointMake(16.13, 15.21) controlPoint1: CGPointMake(16.08, 16.02) controlPoint2: CGPointMake(16.13, 15.61)];
    [bezier2Path addCurveToPoint: CGPointMake(16.11, 10.98) controlPoint1: CGPointMake(16.13, 14.83) controlPoint2: CGPointMake(16.14, 10.99)];
    [bezier2Path addCurveToPoint: CGPointMake(12.98, 10.99) controlPoint1: CGPointMake(16.09, 10.96) controlPoint2: CGPointMake(13, 10.96)];
    [bezier2Path addCurveToPoint: CGPointMake(12.98, 15.23) controlPoint1: CGPointMake(12.97, 11.01) controlPoint2: CGPointMake(12.98, 15.14)];
    [bezier2Path addCurveToPoint: CGPointMake(12.43, 16.57) controlPoint1: CGPointMake(12.98, 15.73) controlPoint2: CGPointMake(12.81, 16.23)];
    [bezier2Path addCurveToPoint: CGPointMake(10.58, 17.02) controlPoint1: CGPointMake(11.92, 17.02) controlPoint2: CGPointMake(11.23, 17.08)];
    [bezier2Path addCurveToPoint: CGPointMake(8.43, 16.48) controlPoint1: CGPointMake(9.84, 16.97) controlPoint2: CGPointMake(9.12, 16.76)];
    [bezier2Path addCurveToPoint: CGPointMake(7.93, 16.26) controlPoint1: CGPointMake(8.26, 16.41) controlPoint2: CGPointMake(8.09, 16.34)];
    [bezier2Path closePath];
    [fillColor9 setFill];
    [bezier2Path fill];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(18.06, 11.91)];
    [bezier3Path addCurveToPoint: CGPointMake(17.98, 11.97) controlPoint1: CGPointMake(18.03, 11.93) controlPoint2: CGPointMake(18.01, 11.95)];
    [bezier3Path addLineToPoint: CGPointMake(17.98, 7.85)];
    [bezier3Path addCurveToPoint: CGPointMake(18, 6.89) controlPoint1: CGPointMake(17.98, 7.53) controlPoint2: CGPointMake(17.97, 7.21)];
    [bezier3Path addCurveToPoint: CGPointMake(21.18, 3.54) controlPoint1: CGPointMake(18.12, 5.19) controlPoint2: CGPointMake(19.48, 3.76)];
    [bezier3Path addCurveToPoint: CGPointMake(27.02, 3.51) controlPoint1: CGPointMake(21.59, 3.49) controlPoint2: CGPointMake(27.01, 3.5)];
    [bezier3Path addCurveToPoint: CGPointMake(27.02, 3.59) controlPoint1: CGPointMake(27.03, 3.52) controlPoint2: CGPointMake(27.02, 3.58)];
    [bezier3Path addCurveToPoint: CGPointMake(27.02, 21.79) controlPoint1: CGPointMake(27.02, 4.05) controlPoint2: CGPointMake(27.02, 21.38)];
    [bezier3Path addCurveToPoint: CGPointMake(24.98, 25.11) controlPoint1: CGPointMake(27.02, 23.18) controlPoint2: CGPointMake(26.24, 24.49)];
    [bezier3Path addCurveToPoint: CGPointMake(23.24, 25.49) controlPoint1: CGPointMake(24.43, 25.38) controlPoint2: CGPointMake(23.85, 25.49)];
    [bezier3Path addCurveToPoint: CGPointMake(18.02, 25.49) controlPoint1: CGPointMake(22.9, 25.49) controlPoint2: CGPointMake(18.11, 25.5)];
    [bezier3Path addCurveToPoint: CGPointMake(17.98, 25.46) controlPoint1: CGPointMake(17.97, 25.48) controlPoint2: CGPointMake(18, 25.5)];
    [bezier3Path addCurveToPoint: CGPointMake(17.98, 17.48) controlPoint1: CGPointMake(17.98, 25.44) controlPoint2: CGPointMake(17.98, 18.44)];
    [bezier3Path addLineToPoint: CGPointMake(17.98, 17.03)];
    [bezier3Path addCurveToPoint: CGPointMake(20.1, 18) controlPoint1: CGPointMake(18.58, 17.54) controlPoint2: CGPointMake(19.34, 17.83)];
    [bezier3Path addCurveToPoint: CGPointMake(21.86, 18.21) controlPoint1: CGPointMake(20.68, 18.13) controlPoint2: CGPointMake(21.27, 18.19)];
    [bezier3Path addCurveToPoint: CGPointMake(23.6, 18.17) controlPoint1: CGPointMake(22.44, 18.24) controlPoint2: CGPointMake(23.02, 18.23)];
    [bezier3Path addCurveToPoint: CGPointMake(25.36, 17.91) controlPoint1: CGPointMake(24.19, 18.12) controlPoint2: CGPointMake(24.78, 18.03)];
    [bezier3Path addCurveToPoint: CGPointMake(25.8, 17.82) controlPoint1: CGPointMake(25.5, 17.88) controlPoint2: CGPointMake(25.65, 17.85)];
    [bezier3Path addCurveToPoint: CGPointMake(26, 17.77) controlPoint1: CGPointMake(25.84, 17.81) controlPoint2: CGPointMake(25.98, 17.8)];
    [bezier3Path addCurveToPoint: CGPointMake(26, 17.64) controlPoint1: CGPointMake(26.02, 17.75) controlPoint2: CGPointMake(26, 17.67)];
    [bezier3Path addLineToPoint: CGPointMake(26, 16.33)];
    [bezier3Path addLineToPoint: CGPointMake(26, 16.22)];
    [bezier3Path addCurveToPoint: CGPointMake(24.03, 16.92) controlPoint1: CGPointMake(25.37, 16.53) controlPoint2: CGPointMake(24.72, 16.78)];
    [bezier3Path addCurveToPoint: CGPointMake(21.45, 16.79) controlPoint1: CGPointMake(23.18, 17.09) controlPoint2: CGPointMake(22.25, 17.13)];
    [bezier3Path addCurveToPoint: CGPointMake(20.07, 14.82) controlPoint1: CGPointMake(20.64, 16.44) controlPoint2: CGPointMake(20.15, 15.69)];
    [bezier3Path addCurveToPoint: CGPointMake(21.03, 12.44) controlPoint1: CGPointMake(19.99, 13.92) controlPoint2: CGPointMake(20.26, 12.98)];
    [bezier3Path addCurveToPoint: CGPointMake(23.78, 12.03) controlPoint1: CGPointMake(21.82, 11.89) controlPoint2: CGPointMake(22.86, 11.89)];
    [bezier3Path addCurveToPoint: CGPointMake(25.75, 12.66) controlPoint1: CGPointMake(24.47, 12.14) controlPoint2: CGPointMake(25.13, 12.36)];
    [bezier3Path addCurveToPoint: CGPointMake(26, 12.78) controlPoint1: CGPointMake(25.84, 12.7) controlPoint2: CGPointMake(25.92, 12.74)];
    [bezier3Path addLineToPoint: CGPointMake(26, 11.65)];
    [bezier3Path addLineToPoint: CGPointMake(26, 11.36)];
    [bezier3Path addCurveToPoint: CGPointMake(26, 11.23) controlPoint1: CGPointMake(26, 11.34) controlPoint2: CGPointMake(26.02, 11.25)];
    [bezier3Path addCurveToPoint: CGPointMake(25.8, 11.18) controlPoint1: CGPointMake(25.98, 11.2) controlPoint2: CGPointMake(25.84, 11.19)];
    [bezier3Path addCurveToPoint: CGPointMake(25.58, 11.13) controlPoint1: CGPointMake(25.73, 11.16) controlPoint2: CGPointMake(25.65, 11.15)];
    [bezier3Path addCurveToPoint: CGPointMake(23.84, 10.85) controlPoint1: CGPointMake(25.01, 11.01) controlPoint2: CGPointMake(24.43, 10.91)];
    [bezier3Path addCurveToPoint: CGPointMake(22.11, 10.78) controlPoint1: CGPointMake(23.27, 10.79) controlPoint2: CGPointMake(22.69, 10.77)];
    [bezier3Path addCurveToPoint: CGPointMake(20.36, 10.94) controlPoint1: CGPointMake(21.52, 10.79) controlPoint2: CGPointMake(20.94, 10.84)];
    [bezier3Path addCurveToPoint: CGPointMake(18.33, 11.71) controlPoint1: CGPointMake(19.65, 11.08) controlPoint2: CGPointMake(18.93, 11.31)];
    [bezier3Path addCurveToPoint: CGPointMake(18.06, 11.91) controlPoint1: CGPointMake(18.23, 11.77) controlPoint2: CGPointMake(18.15, 11.84)];
    [bezier3Path closePath];
    [fillColor10 setFill];
    [bezier3Path fill];
}


@end
