#import "BTUIKApplePayMarkVectorArtView.h"

@implementation BTUIKApplePayMarkVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* fillColor5 = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: CGRectMake(0, 0, 45, 29)];
    [fillColor5 setFill];
    [rectanglePath fill];
    
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0.5, 0.5, 44, 28) cornerRadius: 3.4];
    [fillColor2 setFill];
    [rectangle2Path fill];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(13.17, 8.87)];
    [bezierPath addCurveToPoint: CGPointMake(13.8, 7) controlPoint1: CGPointMake(13.59, 8.37) controlPoint2: CGPointMake(13.87, 7.68)];
    [bezierPath addCurveToPoint: CGPointMake(12.02, 7.89) controlPoint1: CGPointMake(13.19, 7.02) controlPoint2: CGPointMake(12.45, 7.39)];
    [bezierPath addCurveToPoint: CGPointMake(11.38, 9.69) controlPoint1: CGPointMake(11.63, 8.32) controlPoint2: CGPointMake(11.29, 9.02)];
    [bezierPath addCurveToPoint: CGPointMake(13.17, 8.87) controlPoint1: CGPointMake(12.06, 9.75) controlPoint2: CGPointMake(12.75, 9.36)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(14.69, 13.21)];
    [bezierPath addCurveToPoint: CGPointMake(16.31, 15.58) controlPoint1: CGPointMake(14.71, 14.98) controlPoint2: CGPointMake(16.29, 15.57)];
    [bezierPath addCurveToPoint: CGPointMake(15.47, 17.24) controlPoint1: CGPointMake(16.3, 15.62) controlPoint2: CGPointMake(16.06, 16.42)];
    [bezierPath addCurveToPoint: CGPointMake(13.63, 18.68) controlPoint1: CGPointMake(14.97, 17.95) controlPoint2: CGPointMake(14.45, 18.66)];
    [bezierPath addCurveToPoint: CGPointMake(11.63, 18.21) controlPoint1: CGPointMake(12.82, 18.69) controlPoint2: CGPointMake(12.56, 18.21)];
    [bezierPath addCurveToPoint: CGPointMake(9.66, 18.69) controlPoint1: CGPointMake(10.71, 18.21) controlPoint2: CGPointMake(10.42, 18.66)];
    [bezierPath addCurveToPoint: CGPointMake(7.75, 17.21) controlPoint1: CGPointMake(8.86, 18.72) controlPoint2: CGPointMake(8.26, 17.92)];
    [bezierPath addCurveToPoint: CGPointMake(6.98, 11.32) controlPoint1: CGPointMake(6.71, 15.76) controlPoint2: CGPointMake(5.92, 13.11)];
    [bezierPath addCurveToPoint: CGPointMake(9.48, 9.86) controlPoint1: CGPointMake(7.51, 10.43) controlPoint2: CGPointMake(8.46, 9.87)];
    [bezierPath addCurveToPoint: CGPointMake(11.47, 10.36) controlPoint1: CGPointMake(10.26, 9.84) controlPoint2: CGPointMake(11, 10.36)];
    [bezierPath addCurveToPoint: CGPointMake(13.79, 9.83) controlPoint1: CGPointMake(11.95, 10.36) controlPoint2: CGPointMake(12.85, 9.73)];
    [bezierPath addCurveToPoint: CGPointMake(15.99, 10.99) controlPoint1: CGPointMake(14.18, 9.84) controlPoint2: CGPointMake(15.28, 9.98)];
    [bezierPath addCurveToPoint: CGPointMake(14.69, 13.21) controlPoint1: CGPointMake(15.94, 11.02) controlPoint2: CGPointMake(14.67, 11.73)];
    [bezierPath closePath];
    [fillColor5 setFill];
    [bezierPath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(20.03, 13.32)];
    [bezier2Path addCurveToPoint: CGPointMake(20.64, 13.43) controlPoint1: CGPointMake(20.21, 13.37) controlPoint2: CGPointMake(20.42, 13.41)];
    [bezier2Path addCurveToPoint: CGPointMake(21.37, 13.46) controlPoint1: CGPointMake(20.87, 13.45) controlPoint2: CGPointMake(21.11, 13.46)];
    [bezier2Path addCurveToPoint: CGPointMake(23.62, 12.8) controlPoint1: CGPointMake(22.34, 13.46) controlPoint2: CGPointMake(23.09, 13.24)];
    [bezier2Path addCurveToPoint: CGPointMake(24.42, 10.86) controlPoint1: CGPointMake(24.16, 12.36) controlPoint2: CGPointMake(24.42, 11.71)];
    [bezier2Path addCurveToPoint: CGPointMake(24.21, 9.79) controlPoint1: CGPointMake(24.42, 10.45) controlPoint2: CGPointMake(24.35, 10.09)];
    [bezier2Path addCurveToPoint: CGPointMake(23.62, 9.04) controlPoint1: CGPointMake(24.07, 9.48) controlPoint2: CGPointMake(23.87, 9.23)];
    [bezier2Path addCurveToPoint: CGPointMake(22.7, 8.6) controlPoint1: CGPointMake(23.36, 8.84) controlPoint2: CGPointMake(23.05, 8.7)];
    [bezier2Path addCurveToPoint: CGPointMake(21.52, 8.45) controlPoint1: CGPointMake(22.34, 8.5) controlPoint2: CGPointMake(21.95, 8.45)];
    [bezier2Path addCurveToPoint: CGPointMake(20.63, 8.49) controlPoint1: CGPointMake(21.17, 8.45) controlPoint2: CGPointMake(20.88, 8.46)];
    [bezier2Path addCurveToPoint: CGPointMake(20.03, 8.57) controlPoint1: CGPointMake(20.38, 8.51) controlPoint2: CGPointMake(20.18, 8.54)];
    [bezier2Path addLineToPoint: CGPointMake(20.03, 13.32)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(19.27, 8.02)];
    [bezier2Path addCurveToPoint: CGPointMake(20.31, 7.88) controlPoint1: CGPointMake(19.58, 7.97) controlPoint2: CGPointMake(19.93, 7.92)];
    [bezier2Path addCurveToPoint: CGPointMake(21.55, 7.82) controlPoint1: CGPointMake(20.68, 7.84) controlPoint2: CGPointMake(21.1, 7.82)];
    [bezier2Path addCurveToPoint: CGPointMake(23.22, 8.04) controlPoint1: CGPointMake(22.2, 7.82) controlPoint2: CGPointMake(22.75, 7.89)];
    [bezier2Path addCurveToPoint: CGPointMake(24.38, 8.7) controlPoint1: CGPointMake(23.69, 8.2) controlPoint2: CGPointMake(24.07, 8.42)];
    [bezier2Path addCurveToPoint: CGPointMake(24.98, 9.6) controlPoint1: CGPointMake(24.63, 8.95) controlPoint2: CGPointMake(24.84, 9.25)];
    [bezier2Path addCurveToPoint: CGPointMake(25.2, 10.8) controlPoint1: CGPointMake(25.13, 9.95) controlPoint2: CGPointMake(25.2, 10.35)];
    [bezier2Path addCurveToPoint: CGPointMake(24.9, 12.23) controlPoint1: CGPointMake(25.2, 11.34) controlPoint2: CGPointMake(25.1, 11.82)];
    [bezier2Path addCurveToPoint: CGPointMake(24.08, 13.27) controlPoint1: CGPointMake(24.7, 12.64) controlPoint2: CGPointMake(24.43, 12.99)];
    [bezier2Path addCurveToPoint: CGPointMake(22.86, 13.89) controlPoint1: CGPointMake(23.74, 13.55) controlPoint2: CGPointMake(23.33, 13.75)];
    [bezier2Path addCurveToPoint: CGPointMake(21.31, 14.1) controlPoint1: CGPointMake(22.38, 14.03) controlPoint2: CGPointMake(21.87, 14.1)];
    [bezier2Path addCurveToPoint: CGPointMake(20.03, 13.98) controlPoint1: CGPointMake(20.8, 14.1) controlPoint2: CGPointMake(20.37, 14.06)];
    [bezier2Path addLineToPoint: CGPointMake(20.03, 18.53)];
    [bezier2Path addLineToPoint: CGPointMake(19.27, 18.53)];
    [bezier2Path addLineToPoint: CGPointMake(19.27, 8.02)];
    [bezier2Path closePath];
    [fillColor5 setFill];
    [bezier2Path fill];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(30.48, 14.47)];
    [bezier3Path addCurveToPoint: CGPointMake(29.19, 14.52) controlPoint1: CGPointMake(30.07, 14.46) controlPoint2: CGPointMake(29.64, 14.48)];
    [bezier3Path addCurveToPoint: CGPointMake(27.96, 14.8) controlPoint1: CGPointMake(28.75, 14.56) controlPoint2: CGPointMake(28.34, 14.66)];
    [bezier3Path addCurveToPoint: CGPointMake(27.02, 15.42) controlPoint1: CGPointMake(27.58, 14.94) controlPoint2: CGPointMake(27.27, 15.15)];
    [bezier3Path addCurveToPoint: CGPointMake(26.65, 16.51) controlPoint1: CGPointMake(26.77, 15.69) controlPoint2: CGPointMake(26.65, 16.06)];
    [bezier3Path addCurveToPoint: CGPointMake(27.12, 17.69) controlPoint1: CGPointMake(26.65, 17.05) controlPoint2: CGPointMake(26.81, 17.44)];
    [bezier3Path addCurveToPoint: CGPointMake(28.17, 18.07) controlPoint1: CGPointMake(27.43, 17.95) controlPoint2: CGPointMake(27.78, 18.07)];
    [bezier3Path addCurveToPoint: CGPointMake(29.01, 17.95) controlPoint1: CGPointMake(28.48, 18.07) controlPoint2: CGPointMake(28.76, 18.03)];
    [bezier3Path addCurveToPoint: CGPointMake(29.65, 17.61) controlPoint1: CGPointMake(29.26, 17.86) controlPoint2: CGPointMake(29.47, 17.75)];
    [bezier3Path addCurveToPoint: CGPointMake(30.11, 17.13) controlPoint1: CGPointMake(29.84, 17.46) controlPoint2: CGPointMake(29.99, 17.3)];
    [bezier3Path addCurveToPoint: CGPointMake(30.4, 16.57) controlPoint1: CGPointMake(30.24, 16.95) controlPoint2: CGPointMake(30.33, 16.76)];
    [bezier3Path addCurveToPoint: CGPointMake(30.48, 16.11) controlPoint1: CGPointMake(30.45, 16.36) controlPoint2: CGPointMake(30.48, 16.21)];
    [bezier3Path addLineToPoint: CGPointMake(30.48, 14.47)];
    [bezier3Path closePath];
    [bezier3Path moveToPoint: CGPointMake(31.24, 16.73)];
    [bezier3Path addCurveToPoint: CGPointMake(31.25, 17.65) controlPoint1: CGPointMake(31.24, 17.04) controlPoint2: CGPointMake(31.24, 17.34)];
    [bezier3Path addCurveToPoint: CGPointMake(31.35, 18.53) controlPoint1: CGPointMake(31.26, 17.95) controlPoint2: CGPointMake(31.3, 18.25)];
    [bezier3Path addLineToPoint: CGPointMake(30.64, 18.53)];
    [bezier3Path addLineToPoint: CGPointMake(30.53, 17.46)];
    [bezier3Path addLineToPoint: CGPointMake(30.49, 17.46)];
    [bezier3Path addCurveToPoint: CGPointMake(30.12, 17.9) controlPoint1: CGPointMake(30.4, 17.6) controlPoint2: CGPointMake(30.27, 17.75)];
    [bezier3Path addCurveToPoint: CGPointMake(29.6, 18.3) controlPoint1: CGPointMake(29.97, 18.05) controlPoint2: CGPointMake(29.8, 18.18)];
    [bezier3Path addCurveToPoint: CGPointMake(28.92, 18.59) controlPoint1: CGPointMake(29.4, 18.42) controlPoint2: CGPointMake(29.17, 18.52)];
    [bezier3Path addCurveToPoint: CGPointMake(28.09, 18.7) controlPoint1: CGPointMake(28.67, 18.67) controlPoint2: CGPointMake(28.39, 18.7)];
    [bezier3Path addCurveToPoint: CGPointMake(27.09, 18.52) controlPoint1: CGPointMake(27.71, 18.7) controlPoint2: CGPointMake(27.38, 18.64)];
    [bezier3Path addCurveToPoint: CGPointMake(26.39, 18.05) controlPoint1: CGPointMake(26.81, 18.4) controlPoint2: CGPointMake(26.57, 18.24)];
    [bezier3Path addCurveToPoint: CGPointMake(25.98, 17.38) controlPoint1: CGPointMake(26.21, 17.85) controlPoint2: CGPointMake(26.07, 17.63)];
    [bezier3Path addCurveToPoint: CGPointMake(25.84, 16.62) controlPoint1: CGPointMake(25.89, 17.13) controlPoint2: CGPointMake(25.84, 16.87)];
    [bezier3Path addCurveToPoint: CGPointMake(27, 14.55) controlPoint1: CGPointMake(25.84, 15.73) controlPoint2: CGPointMake(26.23, 15.04)];
    [bezier3Path addCurveToPoint: CGPointMake(30.48, 13.86) controlPoint1: CGPointMake(27.77, 14.07) controlPoint2: CGPointMake(28.93, 13.84)];
    [bezier3Path addLineToPoint: CGPointMake(30.48, 13.65)];
    [bezier3Path addCurveToPoint: CGPointMake(30.42, 12.97) controlPoint1: CGPointMake(30.48, 13.45) controlPoint2: CGPointMake(30.46, 13.22)];
    [bezier3Path addCurveToPoint: CGPointMake(30.17, 12.23) controlPoint1: CGPointMake(30.38, 12.71) controlPoint2: CGPointMake(30.3, 12.46)];
    [bezier3Path addCurveToPoint: CGPointMake(29.59, 11.65) controlPoint1: CGPointMake(30.04, 12) controlPoint2: CGPointMake(29.85, 11.81)];
    [bezier3Path addCurveToPoint: CGPointMake(28.54, 11.41) controlPoint1: CGPointMake(29.33, 11.49) controlPoint2: CGPointMake(28.98, 11.41)];
    [bezier3Path addCurveToPoint: CGPointMake(27.55, 11.56) controlPoint1: CGPointMake(28.21, 11.41) controlPoint2: CGPointMake(27.88, 11.46)];
    [bezier3Path addCurveToPoint: CGPointMake(26.65, 11.98) controlPoint1: CGPointMake(27.22, 11.66) controlPoint2: CGPointMake(26.92, 11.8)];
    [bezier3Path addLineToPoint: CGPointMake(26.41, 11.43)];
    [bezier3Path addCurveToPoint: CGPointMake(27.47, 10.93) controlPoint1: CGPointMake(26.75, 11.2) controlPoint2: CGPointMake(27.11, 11.03)];
    [bezier3Path addCurveToPoint: CGPointMake(28.62, 10.78) controlPoint1: CGPointMake(27.84, 10.83) controlPoint2: CGPointMake(28.22, 10.78)];
    [bezier3Path addCurveToPoint: CGPointMake(29.94, 11.05) controlPoint1: CGPointMake(29.16, 10.78) controlPoint2: CGPointMake(29.6, 10.87)];
    [bezier3Path addCurveToPoint: CGPointMake(30.74, 11.74) controlPoint1: CGPointMake(30.28, 11.23) controlPoint2: CGPointMake(30.54, 11.46)];
    [bezier3Path addCurveToPoint: CGPointMake(31.13, 12.7) controlPoint1: CGPointMake(30.93, 12.03) controlPoint2: CGPointMake(31.06, 12.35)];
    [bezier3Path addCurveToPoint: CGPointMake(31.24, 13.75) controlPoint1: CGPointMake(31.2, 13.05) controlPoint2: CGPointMake(31.24, 13.4)];
    [bezier3Path addLineToPoint: CGPointMake(31.24, 16.73)];
    [bezier3Path addLineToPoint: CGPointMake(31.24, 16.73)];
    [bezier3Path closePath];
    [fillColor5 setFill];
    [bezier3Path fill];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(32.72, 10.96)];
    [bezier4Path addLineToPoint: CGPointMake(34.69, 15.88)];
    [bezier4Path addCurveToPoint: CGPointMake(35, 16.72) controlPoint1: CGPointMake(34.8, 16.15) controlPoint2: CGPointMake(34.9, 16.43)];
    [bezier4Path addCurveToPoint: CGPointMake(35.26, 17.52) controlPoint1: CGPointMake(35.1, 17.01) controlPoint2: CGPointMake(35.18, 17.28)];
    [bezier4Path addLineToPoint: CGPointMake(35.29, 17.52)];
    [bezier4Path addCurveToPoint: CGPointMake(35.55, 16.74) controlPoint1: CGPointMake(35.37, 17.29) controlPoint2: CGPointMake(35.45, 17.03)];
    [bezier4Path addCurveToPoint: CGPointMake(35.87, 15.85) controlPoint1: CGPointMake(35.65, 16.45) controlPoint2: CGPointMake(35.75, 16.15)];
    [bezier4Path addLineToPoint: CGPointMake(37.71, 10.96)];
    [bezier4Path addLineToPoint: CGPointMake(38.52, 10.96)];
    [bezier4Path addLineToPoint: CGPointMake(36.28, 16.51)];
    [bezier4Path addCurveToPoint: CGPointMake(35.64, 18.11) controlPoint1: CGPointMake(36.05, 17.1) controlPoint2: CGPointMake(35.84, 17.63)];
    [bezier4Path addCurveToPoint: CGPointMake(35.03, 19.4) controlPoint1: CGPointMake(35.44, 18.59) controlPoint2: CGPointMake(35.24, 19.02)];
    [bezier4Path addCurveToPoint: CGPointMake(34.41, 20.42) controlPoint1: CGPointMake(34.83, 19.79) controlPoint2: CGPointMake(34.62, 20.13)];
    [bezier4Path addCurveToPoint: CGPointMake(33.71, 21.2) controlPoint1: CGPointMake(34.2, 20.72) controlPoint2: CGPointMake(33.97, 20.97)];
    [bezier4Path addCurveToPoint: CGPointMake(32.88, 21.77) controlPoint1: CGPointMake(33.41, 21.46) controlPoint2: CGPointMake(33.13, 21.65)];
    [bezier4Path addCurveToPoint: CGPointMake(32.37, 22) controlPoint1: CGPointMake(32.62, 21.89) controlPoint2: CGPointMake(32.45, 21.97)];
    [bezier4Path addLineToPoint: CGPointMake(32.11, 21.38)];
    [bezier4Path addCurveToPoint: CGPointMake(32.75, 21.05) controlPoint1: CGPointMake(32.3, 21.3) controlPoint2: CGPointMake(32.52, 21.19)];
    [bezier4Path addCurveToPoint: CGPointMake(33.45, 20.52) controlPoint1: CGPointMake(32.99, 20.92) controlPoint2: CGPointMake(33.22, 20.74)];
    [bezier4Path addCurveToPoint: CGPointMake(34.09, 19.77) controlPoint1: CGPointMake(33.64, 20.33) controlPoint2: CGPointMake(33.86, 20.08)];
    [bezier4Path addCurveToPoint: CGPointMake(34.71, 18.64) controlPoint1: CGPointMake(34.32, 19.46) controlPoint2: CGPointMake(34.53, 19.08)];
    [bezier4Path addCurveToPoint: CGPointMake(34.81, 18.31) controlPoint1: CGPointMake(34.77, 18.47) controlPoint2: CGPointMake(34.81, 18.36)];
    [bezier4Path addCurveToPoint: CGPointMake(34.71, 17.98) controlPoint1: CGPointMake(34.81, 18.23) controlPoint2: CGPointMake(34.77, 18.12)];
    [bezier4Path addLineToPoint: CGPointMake(31.91, 10.96)];
    [bezier4Path addLineToPoint: CGPointMake(32.72, 10.96)];
    [bezier4Path closePath];
    [fillColor5 setFill];
    [bezier4Path fill];
}

@end
