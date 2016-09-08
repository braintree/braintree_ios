#import "BTUIKMaestroVectorArtView.h"

@implementation BTUIKMaestroVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* fillColor4 = [UIColor colorWithRed: 0.103 green: 0.092 blue: 0.095 alpha: 1];
    UIColor* fillColor11 = [UIColor colorWithRed: 0.894 green: 0 blue: 0.111 alpha: 1];
    UIColor* fillColor12 = [UIColor colorWithRed: 0.069 green: 0.557 blue: 0.867 alpha: 1];
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(18.9, 3.5, 22, 22)];
    [fillColor11 setFill];
    [ovalPath fill];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(21.39, 21.49)];
    [bezierPath addCurveToPoint: CGPointMake(20.55, 20.32) controlPoint1: CGPointMake(21.08, 21.12) controlPoint2: CGPointMake(20.81, 20.73)];
    [bezierPath addLineToPoint: CGPointMake(24.45, 20.32)];
    [bezierPath addCurveToPoint: CGPointMake(25.08, 19.16) controlPoint1: CGPointMake(24.68, 19.95) controlPoint2: CGPointMake(24.89, 19.56)];
    [bezierPath addLineToPoint: CGPointMake(19.92, 19.16)];
    [bezierPath addCurveToPoint: CGPointMake(19.45, 17.99) controlPoint1: CGPointMake(19.74, 18.78) controlPoint2: CGPointMake(19.58, 18.39)];
    [bezierPath addLineToPoint: CGPointMake(25.55, 17.99)];
    [bezierPath addCurveToPoint: CGPointMake(26.11, 14.5) controlPoint1: CGPointMake(25.91, 16.89) controlPoint2: CGPointMake(26.11, 15.72)];
    [bezierPath addCurveToPoint: CGPointMake(25.87, 12.17) controlPoint1: CGPointMake(26.11, 13.7) controlPoint2: CGPointMake(26.03, 12.92)];
    [bezierPath addLineToPoint: CGPointMake(19.13, 12.17)];
    [bezierPath addCurveToPoint: CGPointMake(19.45, 11.01) controlPoint1: CGPointMake(19.22, 11.77) controlPoint2: CGPointMake(19.33, 11.39)];
    [bezierPath addLineToPoint: CGPointMake(25.55, 11.01)];
    [bezierPath addCurveToPoint: CGPointMake(25.08, 9.84) controlPoint1: CGPointMake(25.41, 10.61) controlPoint2: CGPointMake(25.26, 10.22)];
    [bezierPath addLineToPoint: CGPointMake(19.92, 9.84)];
    [bezierPath addCurveToPoint: CGPointMake(20.55, 8.68) controlPoint1: CGPointMake(20.11, 9.44) controlPoint2: CGPointMake(20.32, 9.05)];
    [bezierPath addLineToPoint: CGPointMake(24.45, 8.68)];
    [bezierPath addCurveToPoint: CGPointMake(23.61, 7.51) controlPoint1: CGPointMake(24.19, 8.27) controlPoint2: CGPointMake(23.91, 7.88)];
    [bezierPath addLineToPoint: CGPointMake(21.39, 7.51)];
    [bezierPath addCurveToPoint: CGPointMake(22.5, 6.35) controlPoint1: CGPointMake(21.73, 7.1) controlPoint2: CGPointMake(22.1, 6.71)];
    [bezierPath addCurveToPoint: CGPointMake(15.11, 3.5) controlPoint1: CGPointMake(20.55, 4.58) controlPoint2: CGPointMake(17.96, 3.5)];
    [bezierPath addCurveToPoint: CGPointMake(4.12, 14.5) controlPoint1: CGPointMake(9.04, 3.5) controlPoint2: CGPointMake(4.12, 8.43)];
    [bezierPath addCurveToPoint: CGPointMake(15.11, 25.5) controlPoint1: CGPointMake(4.12, 20.58) controlPoint2: CGPointMake(9.04, 25.5)];
    [bezierPath addCurveToPoint: CGPointMake(22.5, 22.65) controlPoint1: CGPointMake(17.96, 25.5) controlPoint2: CGPointMake(20.55, 24.42)];
    [bezierPath addCurveToPoint: CGPointMake(23.61, 21.49) controlPoint1: CGPointMake(22.9, 22.29) controlPoint2: CGPointMake(23.27, 21.9)];
    [bezierPath addLineToPoint: CGPointMake(21.39, 21.49)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    
    [fillColor12 setFill];
    [bezierPath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(39.73, 20.61)];
    [bezier2Path addLineToPoint: CGPointMake(39.77, 20.61)];
    [bezier2Path addCurveToPoint: CGPointMake(39.81, 20.6) controlPoint1: CGPointMake(39.78, 20.61) controlPoint2: CGPointMake(39.8, 20.61)];
    [bezier2Path addCurveToPoint: CGPointMake(39.83, 20.57) controlPoint1: CGPointMake(39.82, 20.6) controlPoint2: CGPointMake(39.83, 20.58)];
    [bezier2Path addCurveToPoint: CGPointMake(39.81, 20.54) controlPoint1: CGPointMake(39.83, 20.56) controlPoint2: CGPointMake(39.82, 20.54)];
    [bezier2Path addCurveToPoint: CGPointMake(39.76, 20.53) controlPoint1: CGPointMake(39.8, 20.53) controlPoint2: CGPointMake(39.78, 20.53)];
    [bezier2Path addLineToPoint: CGPointMake(39.73, 20.53)];
    [bezier2Path addLineToPoint: CGPointMake(39.73, 20.61)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(39.73, 20.79)];
    [bezier2Path addLineToPoint: CGPointMake(39.65, 20.79)];
    [bezier2Path addLineToPoint: CGPointMake(39.65, 20.47)];
    [bezier2Path addLineToPoint: CGPointMake(39.78, 20.47)];
    [bezier2Path addCurveToPoint: CGPointMake(39.86, 20.49) controlPoint1: CGPointMake(39.81, 20.47) controlPoint2: CGPointMake(39.84, 20.48)];
    [bezier2Path addCurveToPoint: CGPointMake(39.9, 20.57) controlPoint1: CGPointMake(39.89, 20.51) controlPoint2: CGPointMake(39.9, 20.54)];
    [bezier2Path addCurveToPoint: CGPointMake(39.85, 20.65) controlPoint1: CGPointMake(39.9, 20.6) controlPoint2: CGPointMake(39.88, 20.64)];
    [bezier2Path addLineToPoint: CGPointMake(39.91, 20.79)];
    [bezier2Path addLineToPoint: CGPointMake(39.83, 20.79)];
    [bezier2Path addLineToPoint: CGPointMake(39.78, 20.66)];
    [bezier2Path addLineToPoint: CGPointMake(39.73, 20.66)];
    [bezier2Path addLineToPoint: CGPointMake(39.73, 20.79)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(39.77, 20.9)];
    [bezier2Path addCurveToPoint: CGPointMake(40.04, 20.63) controlPoint1: CGPointMake(39.92, 20.9) controlPoint2: CGPointMake(40.04, 20.78)];
    [bezier2Path addCurveToPoint: CGPointMake(39.77, 20.36) controlPoint1: CGPointMake(40.04, 20.48) controlPoint2: CGPointMake(39.92, 20.36)];
    [bezier2Path addCurveToPoint: CGPointMake(39.5, 20.63) controlPoint1: CGPointMake(39.62, 20.36) controlPoint2: CGPointMake(39.5, 20.48)];
    [bezier2Path addCurveToPoint: CGPointMake(39.77, 20.9) controlPoint1: CGPointMake(39.5, 20.78) controlPoint2: CGPointMake(39.62, 20.9)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(39.42, 20.63)];
    [bezier2Path addCurveToPoint: CGPointMake(39.77, 20.28) controlPoint1: CGPointMake(39.42, 20.44) controlPoint2: CGPointMake(39.58, 20.28)];
    [bezier2Path addCurveToPoint: CGPointMake(40.13, 20.63) controlPoint1: CGPointMake(39.97, 20.28) controlPoint2: CGPointMake(40.13, 20.44)];
    [bezier2Path addCurveToPoint: CGPointMake(39.77, 20.99) controlPoint1: CGPointMake(40.13, 20.83) controlPoint2: CGPointMake(39.97, 20.99)];
    [bezier2Path addCurveToPoint: CGPointMake(39.42, 20.63) controlPoint1: CGPointMake(39.58, 20.99) controlPoint2: CGPointMake(39.42, 20.83)];
    [bezier2Path closePath];
    bezier2Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier2Path fill];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(21.61, 14.77)];
    [bezier3Path addCurveToPoint: CGPointMake(20.97, 13.95) controlPoint1: CGPointMake(21.61, 14.67) controlPoint2: CGPointMake(21.76, 13.97)];
    [bezier3Path addCurveToPoint: CGPointMake(20.1, 14.77) controlPoint1: CGPointMake(20.54, 13.95) controlPoint2: CGPointMake(20.23, 14.24)];
    [bezier3Path addLineToPoint: CGPointMake(21.61, 14.77)];
    [bezier3Path closePath];
    [bezier3Path moveToPoint: CGPointMake(22.34, 17.47)];
    [bezier3Path addCurveToPoint: CGPointMake(20.94, 17.66) controlPoint1: CGPointMake(21.87, 17.6) controlPoint2: CGPointMake(21.42, 17.66)];
    [bezier3Path addCurveToPoint: CGPointMake(18.61, 15.62) controlPoint1: CGPointMake(19.41, 17.66) controlPoint2: CGPointMake(18.61, 16.96)];
    [bezier3Path addCurveToPoint: CGPointMake(21, 12.91) controlPoint1: CGPointMake(18.61, 14.06) controlPoint2: CGPointMake(19.62, 12.91)];
    [bezier3Path addCurveToPoint: CGPointMake(22.85, 14.57) controlPoint1: CGPointMake(22.13, 12.91) controlPoint2: CGPointMake(22.85, 13.56)];
    [bezier3Path addCurveToPoint: CGPointMake(22.68, 15.69) controlPoint1: CGPointMake(22.85, 14.9) controlPoint2: CGPointMake(22.8, 15.23)];
    [bezier3Path addLineToPoint: CGPointMake(19.96, 15.69)];
    [bezier3Path addCurveToPoint: CGPointMake(21.15, 16.62) controlPoint1: CGPointMake(19.86, 16.34) controlPoint2: CGPointMake(20.34, 16.62)];
    [bezier3Path addCurveToPoint: CGPointMake(22.56, 16.34) controlPoint1: CGPointMake(21.63, 16.62) controlPoint2: CGPointMake(22.07, 16.54)];
    [bezier3Path addLineToPoint: CGPointMake(22.34, 17.47)];
    [bezier3Path closePath];
    bezier3Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier3Path fill];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(23.27, 14.46)];
    [bezier4Path addCurveToPoint: CGPointMake(24.33, 15.73) controlPoint1: CGPointMake(23.27, 15.04) controlPoint2: CGPointMake(23.59, 15.43)];
    [bezier4Path addCurveToPoint: CGPointMake(24.98, 16.24) controlPoint1: CGPointMake(24.89, 15.96) controlPoint2: CGPointMake(24.98, 16.03)];
    [bezier4Path addCurveToPoint: CGPointMake(24.18, 16.65) controlPoint1: CGPointMake(24.98, 16.52) controlPoint2: CGPointMake(24.73, 16.65)];
    [bezier4Path addCurveToPoint: CGPointMake(22.94, 16.47) controlPoint1: CGPointMake(23.76, 16.65) controlPoint2: CGPointMake(23.38, 16.6)];
    [bezier4Path addLineToPoint: CGPointMake(22.74, 17.52)];
    [bezier4Path addCurveToPoint: CGPointMake(24.19, 17.66) controlPoint1: CGPointMake(23.14, 17.61) controlPoint2: CGPointMake(23.69, 17.65)];
    [bezier4Path addCurveToPoint: CGPointMake(26.34, 16.13) controlPoint1: CGPointMake(25.66, 17.66) controlPoint2: CGPointMake(26.34, 17.17)];
    [bezier4Path addCurveToPoint: CGPointMake(25.36, 14.86) controlPoint1: CGPointMake(26.34, 15.51) controlPoint2: CGPointMake(26.06, 15.14)];
    [bezier4Path addCurveToPoint: CGPointMake(24.7, 14.37) controlPoint1: CGPointMake(24.77, 14.63) controlPoint2: CGPointMake(24.7, 14.58)];
    [bezier4Path addCurveToPoint: CGPointMake(25.39, 13.99) controlPoint1: CGPointMake(24.7, 14.12) controlPoint2: CGPointMake(24.94, 13.99)];
    [bezier4Path addCurveToPoint: CGPointMake(26.39, 14.06) controlPoint1: CGPointMake(25.66, 13.99) controlPoint2: CGPointMake(26.04, 14.02)];
    [bezier4Path addLineToPoint: CGPointMake(26.59, 13.01)];
    [bezier4Path addCurveToPoint: CGPointMake(25.36, 12.91) controlPoint1: CGPointMake(26.23, 12.96) controlPoint2: CGPointMake(25.68, 12.91)];
    [bezier4Path addCurveToPoint: CGPointMake(23.27, 14.46) controlPoint1: CGPointMake(23.8, 12.91) controlPoint2: CGPointMake(23.26, 13.62)];
    [bezier4Path closePath];
    bezier4Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier4Path fill];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(16.86, 15.55)];
    [bezier5Path addCurveToPoint: CGPointMake(16.55, 15.53) controlPoint1: CGPointMake(16.71, 15.53) controlPoint2: CGPointMake(16.65, 15.53)];
    [bezier5Path addCurveToPoint: CGPointMake(15.37, 16.22) controlPoint1: CGPointMake(15.77, 15.53) controlPoint2: CGPointMake(15.37, 15.76)];
    [bezier5Path addCurveToPoint: CGPointMake(15.87, 16.69) controlPoint1: CGPointMake(15.37, 16.51) controlPoint2: CGPointMake(15.57, 16.69)];
    [bezier5Path addCurveToPoint: CGPointMake(16.86, 15.55) controlPoint1: CGPointMake(16.43, 16.69) controlPoint2: CGPointMake(16.83, 16.22)];
    [bezier5Path closePath];
    [bezier5Path moveToPoint: CGPointMake(17.86, 17.58)];
    [bezier5Path addLineToPoint: CGPointMake(16.72, 17.58)];
    [bezier5Path addLineToPoint: CGPointMake(16.74, 17.1)];
    [bezier5Path addCurveToPoint: CGPointMake(15.3, 17.66) controlPoint1: CGPointMake(16.39, 17.48) controlPoint2: CGPointMake(15.93, 17.66)];
    [bezier5Path addCurveToPoint: CGPointMake(14.04, 16.41) controlPoint1: CGPointMake(14.55, 17.66) controlPoint2: CGPointMake(14.04, 17.15)];
    [bezier5Path addCurveToPoint: CGPointMake(16.46, 14.65) controlPoint1: CGPointMake(14.04, 15.3) controlPoint2: CGPointMake(14.93, 14.65)];
    [bezier5Path addCurveToPoint: CGPointMake(17.02, 14.69) controlPoint1: CGPointMake(16.62, 14.65) controlPoint2: CGPointMake(16.81, 14.67)];
    [bezier5Path addCurveToPoint: CGPointMake(17.07, 14.39) controlPoint1: CGPointMake(17.06, 14.54) controlPoint2: CGPointMake(17.07, 14.48)];
    [bezier5Path addCurveToPoint: CGPointMake(16.19, 13.98) controlPoint1: CGPointMake(17.07, 14.09) controlPoint2: CGPointMake(16.83, 13.98)];
    [bezier5Path addCurveToPoint: CGPointMake(14.73, 14.18) controlPoint1: CGPointMake(15.56, 13.98) controlPoint2: CGPointMake(15.13, 14.07)];
    [bezier5Path addLineToPoint: CGPointMake(14.93, 13.16)];
    [bezier5Path addCurveToPoint: CGPointMake(16.57, 12.91) controlPoint1: CGPointMake(15.61, 12.98) controlPoint2: CGPointMake(16.06, 12.91)];
    [bezier5Path addCurveToPoint: CGPointMake(18.38, 14.25) controlPoint1: CGPointMake(17.75, 12.91) controlPoint2: CGPointMake(18.38, 13.38)];
    [bezier5Path addCurveToPoint: CGPointMake(18.27, 15.15) controlPoint1: CGPointMake(18.39, 14.48) controlPoint2: CGPointMake(18.31, 14.95)];
    [bezier5Path addCurveToPoint: CGPointMake(17.86, 17.58) controlPoint1: CGPointMake(18.22, 15.45) controlPoint2: CGPointMake(17.89, 17.17)];
    [bezier5Path closePath];
    bezier5Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier5Path fill];
    
    
    //// Bezier 6 Drawing
    UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
    [bezier6Path moveToPoint: CGPointMake(28.75, 17.51)];
    [bezier6Path addCurveToPoint: CGPointMake(27.77, 17.66) controlPoint1: CGPointMake(28.38, 17.61) controlPoint2: CGPointMake(28.08, 17.66)];
    [bezier6Path addCurveToPoint: CGPointMake(26.68, 16.66) controlPoint1: CGPointMake(27.07, 17.66) controlPoint2: CGPointMake(26.68, 17.3)];
    [bezier6Path addCurveToPoint: CGPointMake(26.87, 15.45) controlPoint1: CGPointMake(26.66, 16.49) controlPoint2: CGPointMake(26.83, 15.68)];
    [bezier6Path addCurveToPoint: CGPointMake(27.52, 11.93) controlPoint1: CGPointMake(26.91, 15.23) controlPoint2: CGPointMake(27.52, 11.93)];
    [bezier6Path addLineToPoint: CGPointMake(28.88, 11.93)];
    [bezier6Path addLineToPoint: CGPointMake(28.67, 13.02)];
    [bezier6Path addLineToPoint: CGPointMake(29.37, 13.02)];
    [bezier6Path addLineToPoint: CGPointMake(29.18, 14.13)];
    [bezier6Path addLineToPoint: CGPointMake(28.48, 14.13)];
    [bezier6Path addCurveToPoint: CGPointMake(28.09, 16.21) controlPoint1: CGPointMake(28.48, 14.13) controlPoint2: CGPointMake(28.09, 16.07)];
    [bezier6Path addCurveToPoint: CGPointMake(28.56, 16.55) controlPoint1: CGPointMake(28.09, 16.45) controlPoint2: CGPointMake(28.24, 16.55)];
    [bezier6Path addCurveToPoint: CGPointMake(28.93, 16.51) controlPoint1: CGPointMake(28.72, 16.55) controlPoint2: CGPointMake(28.84, 16.53)];
    [bezier6Path addLineToPoint: CGPointMake(28.75, 17.51)];
    [bezier6Path closePath];
    bezier6Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier6Path fill];
    
    
    //// Bezier 7 Drawing
    UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
    [bezier7Path moveToPoint: CGPointMake(34.43, 16.55)];
    [bezier7Path addCurveToPoint: CGPointMake(33.65, 15.54) controlPoint1: CGPointMake(33.95, 16.56) controlPoint2: CGPointMake(33.65, 16.15)];
    [bezier7Path addCurveToPoint: CGPointMake(34.77, 14) controlPoint1: CGPointMake(33.65, 14.82) controlPoint2: CGPointMake(34.08, 14)];
    [bezier7Path addCurveToPoint: CGPointMake(35.52, 14.91) controlPoint1: CGPointMake(35.33, 14) controlPoint2: CGPointMake(35.52, 14.44)];
    [bezier7Path addCurveToPoint: CGPointMake(34.43, 16.55) controlPoint1: CGPointMake(35.52, 15.94) controlPoint2: CGPointMake(35.1, 16.55)];
    [bezier7Path closePath];
    [bezier7Path moveToPoint: CGPointMake(34.83, 12.91)];
    [bezier7Path addCurveToPoint: CGPointMake(32.6, 14.01) controlPoint1: CGPointMake(33.84, 12.91) controlPoint2: CGPointMake(33.06, 13.33)];
    [bezier7Path addLineToPoint: CGPointMake(33, 12.99)];
    [bezier7Path addCurveToPoint: CGPointMake(31.38, 13.65) controlPoint1: CGPointMake(32.27, 12.73) controlPoint2: CGPointMake(31.8, 13.11)];
    [bezier7Path addCurveToPoint: CGPointMake(31.24, 13.82) controlPoint1: CGPointMake(31.38, 13.65) controlPoint2: CGPointMake(31.31, 13.74)];
    [bezier7Path addLineToPoint: CGPointMake(31.24, 13.02)];
    [bezier7Path addLineToPoint: CGPointMake(29.96, 13.02)];
    [bezier7Path addCurveToPoint: CGPointMake(29.24, 17.27) controlPoint1: CGPointMake(29.79, 14.43) controlPoint2: CGPointMake(29.48, 15.86)];
    [bezier7Path addLineToPoint: CGPointMake(29.19, 17.58)];
    [bezier7Path addLineToPoint: CGPointMake(30.56, 17.58)];
    [bezier7Path addCurveToPoint: CGPointMake(30.91, 15.82) controlPoint1: CGPointMake(30.69, 16.86) controlPoint2: CGPointMake(30.8, 16.28)];
    [bezier7Path addCurveToPoint: CGPointMake(32.43, 14.33) controlPoint1: CGPointMake(31.2, 14.54) controlPoint2: CGPointMake(31.69, 14.15)];
    [bezier7Path addCurveToPoint: CGPointMake(32.16, 15.59) controlPoint1: CGPointMake(32.26, 14.69) controlPoint2: CGPointMake(32.16, 15.12)];
    [bezier7Path addCurveToPoint: CGPointMake(34.32, 17.66) controlPoint1: CGPointMake(32.16, 16.72) controlPoint2: CGPointMake(32.78, 17.66)];
    [bezier7Path addCurveToPoint: CGPointMake(36.99, 14.94) controlPoint1: CGPointMake(35.87, 17.66) controlPoint2: CGPointMake(36.99, 16.83)];
    [bezier7Path addCurveToPoint: CGPointMake(34.83, 12.91) controlPoint1: CGPointMake(36.99, 13.8) controlPoint2: CGPointMake(36.24, 12.91)];
    [bezier7Path closePath];
    bezier7Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier7Path fill];
    
    
    //// Bezier 8 Drawing
    UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
    [bezier8Path moveToPoint: CGPointMake(13.4, 17.58)];
    [bezier8Path addLineToPoint: CGPointMake(12.03, 17.58)];
    [bezier8Path addLineToPoint: CGPointMake(12.85, 13.29)];
    [bezier8Path addLineToPoint: CGPointMake(10.97, 17.58)];
    [bezier8Path addLineToPoint: CGPointMake(9.72, 17.58)];
    [bezier8Path addLineToPoint: CGPointMake(9.5, 13.32)];
    [bezier8Path addLineToPoint: CGPointMake(8.68, 17.58)];
    [bezier8Path addLineToPoint: CGPointMake(7.44, 17.58)];
    [bezier8Path addLineToPoint: CGPointMake(8.5, 12.01)];
    [bezier8Path addLineToPoint: CGPointMake(10.64, 12.01)];
    [bezier8Path addLineToPoint: CGPointMake(10.81, 15.11)];
    [bezier8Path addLineToPoint: CGPointMake(12.17, 12.01)];
    [bezier8Path addLineToPoint: CGPointMake(14.48, 12.01)];
    [bezier8Path addLineToPoint: CGPointMake(13.4, 17.58)];
    [bezier8Path closePath];
    bezier8Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier8Path fill];
    
    
    //// Bezier 9 Drawing
    UIBezierPath* bezier9Path = [UIBezierPath bezierPath];
    [bezier9Path moveToPoint: CGPointMake(37.4, 16.86)];
    [bezier9Path addLineToPoint: CGPointMake(37.44, 16.86)];
    [bezier9Path addCurveToPoint: CGPointMake(37.49, 16.86) controlPoint1: CGPointMake(37.46, 16.86) controlPoint2: CGPointMake(37.47, 16.86)];
    [bezier9Path addCurveToPoint: CGPointMake(37.5, 16.82) controlPoint1: CGPointMake(37.5, 16.85) controlPoint2: CGPointMake(37.5, 16.83)];
    [bezier9Path addCurveToPoint: CGPointMake(37.49, 16.79) controlPoint1: CGPointMake(37.5, 16.81) controlPoint2: CGPointMake(37.5, 16.79)];
    [bezier9Path addCurveToPoint: CGPointMake(37.44, 16.78) controlPoint1: CGPointMake(37.47, 16.78) controlPoint2: CGPointMake(37.45, 16.78)];
    [bezier9Path addLineToPoint: CGPointMake(37.4, 16.78)];
    [bezier9Path addLineToPoint: CGPointMake(37.4, 16.86)];
    [bezier9Path closePath];
    [bezier9Path moveToPoint: CGPointMake(37.4, 17.04)];
    [bezier9Path addLineToPoint: CGPointMake(37.33, 17.04)];
    [bezier9Path addLineToPoint: CGPointMake(37.33, 16.73)];
    [bezier9Path addLineToPoint: CGPointMake(37.46, 16.73)];
    [bezier9Path addCurveToPoint: CGPointMake(37.54, 16.74) controlPoint1: CGPointMake(37.49, 16.73) controlPoint2: CGPointMake(37.52, 16.73)];
    [bezier9Path addCurveToPoint: CGPointMake(37.58, 16.82) controlPoint1: CGPointMake(37.56, 16.76) controlPoint2: CGPointMake(37.58, 16.79)];
    [bezier9Path addCurveToPoint: CGPointMake(37.52, 16.9) controlPoint1: CGPointMake(37.58, 16.86) controlPoint2: CGPointMake(37.56, 16.89)];
    [bezier9Path addLineToPoint: CGPointMake(37.58, 17.04)];
    [bezier9Path addLineToPoint: CGPointMake(37.5, 17.04)];
    [bezier9Path addLineToPoint: CGPointMake(37.45, 16.92)];
    [bezier9Path addLineToPoint: CGPointMake(37.4, 16.92)];
    [bezier9Path addLineToPoint: CGPointMake(37.4, 17.04)];
    [bezier9Path closePath];
    [bezier9Path moveToPoint: CGPointMake(37.45, 17.15)];
    [bezier9Path addCurveToPoint: CGPointMake(37.72, 16.88) controlPoint1: CGPointMake(37.6, 17.15) controlPoint2: CGPointMake(37.72, 17.03)];
    [bezier9Path addCurveToPoint: CGPointMake(37.45, 16.61) controlPoint1: CGPointMake(37.72, 16.73) controlPoint2: CGPointMake(37.6, 16.61)];
    [bezier9Path addCurveToPoint: CGPointMake(37.18, 16.88) controlPoint1: CGPointMake(37.3, 16.61) controlPoint2: CGPointMake(37.18, 16.73)];
    [bezier9Path addCurveToPoint: CGPointMake(37.45, 17.15) controlPoint1: CGPointMake(37.18, 17.03) controlPoint2: CGPointMake(37.3, 17.15)];
    [bezier9Path closePath];
    [bezier9Path moveToPoint: CGPointMake(37.09, 16.88)];
    [bezier9Path addCurveToPoint: CGPointMake(37.45, 16.53) controlPoint1: CGPointMake(37.09, 16.69) controlPoint2: CGPointMake(37.25, 16.53)];
    [bezier9Path addCurveToPoint: CGPointMake(37.8, 16.88) controlPoint1: CGPointMake(37.64, 16.53) controlPoint2: CGPointMake(37.8, 16.69)];
    [bezier9Path addCurveToPoint: CGPointMake(37.45, 17.24) controlPoint1: CGPointMake(37.8, 17.08) controlPoint2: CGPointMake(37.64, 17.24)];
    [bezier9Path addCurveToPoint: CGPointMake(37.09, 16.88) controlPoint1: CGPointMake(37.25, 17.24) controlPoint2: CGPointMake(37.09, 17.08)];
    [bezier9Path closePath];
    bezier9Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier9Path fill];
    
    
    //// Bezier 10 Drawing
    UIBezierPath* bezier10Path = [UIBezierPath bezierPath];
    [bezier10Path moveToPoint: CGPointMake(21.95, 14.42)];
    [bezier10Path addCurveToPoint: CGPointMake(21.32, 13.61) controlPoint1: CGPointMake(21.95, 14.32) controlPoint2: CGPointMake(22.11, 13.62)];
    [bezier10Path addCurveToPoint: CGPointMake(20.44, 14.42) controlPoint1: CGPointMake(20.88, 13.61) controlPoint2: CGPointMake(20.57, 13.9)];
    [bezier10Path addLineToPoint: CGPointMake(21.95, 14.42)];
    [bezier10Path closePath];
    [bezier10Path moveToPoint: CGPointMake(22.69, 17.13)];
    [bezier10Path addCurveToPoint: CGPointMake(21.28, 17.31) controlPoint1: CGPointMake(22.22, 17.25) controlPoint2: CGPointMake(21.76, 17.31)];
    [bezier10Path addCurveToPoint: CGPointMake(18.95, 15.28) controlPoint1: CGPointMake(19.75, 17.31) controlPoint2: CGPointMake(18.95, 16.61)];
    [bezier10Path addCurveToPoint: CGPointMake(21.35, 12.57) controlPoint1: CGPointMake(18.95, 13.72) controlPoint2: CGPointMake(19.97, 12.57)];
    [bezier10Path addCurveToPoint: CGPointMake(23.2, 14.22) controlPoint1: CGPointMake(22.47, 12.57) controlPoint2: CGPointMake(23.2, 13.21)];
    [bezier10Path addCurveToPoint: CGPointMake(23.03, 15.34) controlPoint1: CGPointMake(23.2, 14.56) controlPoint2: CGPointMake(23.15, 14.88)];
    [bezier10Path addLineToPoint: CGPointMake(20.3, 15.34)];
    [bezier10Path addCurveToPoint: CGPointMake(21.49, 16.28) controlPoint1: CGPointMake(20.2, 16) controlPoint2: CGPointMake(20.68, 16.28)];
    [bezier10Path addCurveToPoint: CGPointMake(22.9, 16) controlPoint1: CGPointMake(21.98, 16.28) controlPoint2: CGPointMake(22.42, 16.19)];
    [bezier10Path addLineToPoint: CGPointMake(22.69, 17.13)];
    [bezier10Path closePath];
    bezier10Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier10Path fill];
    
    
    //// Bezier 11 Drawing
    UIBezierPath* bezier11Path = [UIBezierPath bezierPath];
    [bezier11Path moveToPoint: CGPointMake(23.61, 14.12)];
    [bezier11Path addCurveToPoint: CGPointMake(24.67, 15.39) controlPoint1: CGPointMake(23.61, 14.69) controlPoint2: CGPointMake(23.93, 15.09)];
    [bezier11Path addCurveToPoint: CGPointMake(25.32, 15.89) controlPoint1: CGPointMake(25.24, 15.62) controlPoint2: CGPointMake(25.32, 15.69)];
    [bezier11Path addCurveToPoint: CGPointMake(24.52, 16.31) controlPoint1: CGPointMake(25.32, 16.18) controlPoint2: CGPointMake(25.08, 16.31)];
    [bezier11Path addCurveToPoint: CGPointMake(23.28, 16.13) controlPoint1: CGPointMake(24.11, 16.3) controlPoint2: CGPointMake(23.73, 16.25)];
    [bezier11Path addLineToPoint: CGPointMake(23.08, 17.18)];
    [bezier11Path addCurveToPoint: CGPointMake(24.53, 17.31) controlPoint1: CGPointMake(23.48, 17.27) controlPoint2: CGPointMake(24.04, 17.3)];
    [bezier11Path addCurveToPoint: CGPointMake(26.68, 15.79) controlPoint1: CGPointMake(26, 17.31) controlPoint2: CGPointMake(26.68, 16.83)];
    [bezier11Path addCurveToPoint: CGPointMake(25.7, 14.52) controlPoint1: CGPointMake(26.68, 15.16) controlPoint2: CGPointMake(26.4, 14.79)];
    [bezier11Path addCurveToPoint: CGPointMake(25.05, 14.03) controlPoint1: CGPointMake(25.12, 14.29) controlPoint2: CGPointMake(25.05, 14.24)];
    [bezier11Path addCurveToPoint: CGPointMake(25.73, 13.65) controlPoint1: CGPointMake(25.05, 13.78) controlPoint2: CGPointMake(25.28, 13.65)];
    [bezier11Path addCurveToPoint: CGPointMake(26.74, 13.72) controlPoint1: CGPointMake(26.01, 13.65) controlPoint2: CGPointMake(26.38, 13.68)];
    [bezier11Path addLineToPoint: CGPointMake(26.93, 12.66)];
    [bezier11Path addCurveToPoint: CGPointMake(25.71, 12.57) controlPoint1: CGPointMake(26.57, 12.61) controlPoint2: CGPointMake(26.02, 12.57)];
    [bezier11Path addCurveToPoint: CGPointMake(23.61, 14.12) controlPoint1: CGPointMake(24.15, 12.57) controlPoint2: CGPointMake(23.61, 13.27)];
    [bezier11Path closePath];
    bezier11Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier11Path fill];
    
    
    //// Bezier 12 Drawing
    UIBezierPath* bezier12Path = [UIBezierPath bezierPath];
    [bezier12Path moveToPoint: CGPointMake(17.2, 15.2)];
    [bezier12Path addCurveToPoint: CGPointMake(16.89, 15.18) controlPoint1: CGPointMake(17.05, 15.19) controlPoint2: CGPointMake(16.99, 15.18)];
    [bezier12Path addCurveToPoint: CGPointMake(15.72, 15.87) controlPoint1: CGPointMake(16.11, 15.18) controlPoint2: CGPointMake(15.72, 15.42)];
    [bezier12Path addCurveToPoint: CGPointMake(16.21, 16.34) controlPoint1: CGPointMake(15.72, 16.16) controlPoint2: CGPointMake(15.91, 16.34)];
    [bezier12Path addCurveToPoint: CGPointMake(17.2, 15.2) controlPoint1: CGPointMake(16.77, 16.34) controlPoint2: CGPointMake(17.18, 15.87)];
    [bezier12Path closePath];
    [bezier12Path moveToPoint: CGPointMake(18.2, 17.24)];
    [bezier12Path addLineToPoint: CGPointMake(17.06, 17.24)];
    [bezier12Path addLineToPoint: CGPointMake(17.09, 16.76)];
    [bezier12Path addCurveToPoint: CGPointMake(15.64, 17.31) controlPoint1: CGPointMake(16.74, 17.14) controlPoint2: CGPointMake(16.27, 17.31)];
    [bezier12Path addCurveToPoint: CGPointMake(14.39, 16.07) controlPoint1: CGPointMake(14.9, 17.31) controlPoint2: CGPointMake(14.39, 16.8)];
    [bezier12Path addCurveToPoint: CGPointMake(16.8, 14.31) controlPoint1: CGPointMake(14.39, 14.95) controlPoint2: CGPointMake(15.27, 14.31)];
    [bezier12Path addCurveToPoint: CGPointMake(17.36, 14.34) controlPoint1: CGPointMake(16.96, 14.31) controlPoint2: CGPointMake(17.16, 14.32)];
    [bezier12Path addCurveToPoint: CGPointMake(17.42, 14.05) controlPoint1: CGPointMake(17.41, 14.2) controlPoint2: CGPointMake(17.42, 14.13)];
    [bezier12Path addCurveToPoint: CGPointMake(16.53, 13.63) controlPoint1: CGPointMake(17.42, 13.74) controlPoint2: CGPointMake(17.18, 13.63)];
    [bezier12Path addCurveToPoint: CGPointMake(15.08, 13.84) controlPoint1: CGPointMake(15.9, 13.64) controlPoint2: CGPointMake(15.47, 13.73)];
    [bezier12Path addLineToPoint: CGPointMake(15.27, 12.81)];
    [bezier12Path addCurveToPoint: CGPointMake(16.92, 12.57) controlPoint1: CGPointMake(15.96, 12.64) controlPoint2: CGPointMake(16.41, 12.57)];
    [bezier12Path addCurveToPoint: CGPointMake(18.72, 13.91) controlPoint1: CGPointMake(18.1, 12.57) controlPoint2: CGPointMake(18.72, 13.03)];
    [bezier12Path addCurveToPoint: CGPointMake(18.61, 14.81) controlPoint1: CGPointMake(18.73, 14.14) controlPoint2: CGPointMake(18.65, 14.61)];
    [bezier12Path addCurveToPoint: CGPointMake(18.2, 17.24) controlPoint1: CGPointMake(18.57, 15.11) controlPoint2: CGPointMake(18.24, 16.83)];
    [bezier12Path closePath];
    bezier12Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier12Path fill];
    
    
    //// Bezier 13 Drawing
    UIBezierPath* bezier13Path = [UIBezierPath bezierPath];
    [bezier13Path moveToPoint: CGPointMake(29.09, 17.17)];
    [bezier13Path addCurveToPoint: CGPointMake(28.11, 17.31) controlPoint1: CGPointMake(28.72, 17.27) controlPoint2: CGPointMake(28.43, 17.31)];
    [bezier13Path addCurveToPoint: CGPointMake(27.03, 16.32) controlPoint1: CGPointMake(27.41, 17.31) controlPoint2: CGPointMake(27.03, 16.96)];
    [bezier13Path addCurveToPoint: CGPointMake(27.22, 15.11) controlPoint1: CGPointMake(27.01, 16.14) controlPoint2: CGPointMake(27.18, 15.33)];
    [bezier13Path addCurveToPoint: CGPointMake(27.86, 11.58) controlPoint1: CGPointMake(27.25, 14.88) controlPoint2: CGPointMake(27.86, 11.58)];
    [bezier13Path addLineToPoint: CGPointMake(29.22, 11.58)];
    [bezier13Path addLineToPoint: CGPointMake(29.02, 12.68)];
    [bezier13Path addLineToPoint: CGPointMake(29.71, 12.68)];
    [bezier13Path addLineToPoint: CGPointMake(29.52, 13.79)];
    [bezier13Path addLineToPoint: CGPointMake(28.82, 13.79)];
    [bezier13Path addCurveToPoint: CGPointMake(28.44, 15.87) controlPoint1: CGPointMake(28.82, 13.79) controlPoint2: CGPointMake(28.44, 15.72)];
    [bezier13Path addCurveToPoint: CGPointMake(28.91, 16.2) controlPoint1: CGPointMake(28.44, 16.1) controlPoint2: CGPointMake(28.58, 16.2)];
    [bezier13Path addCurveToPoint: CGPointMake(29.28, 16.16) controlPoint1: CGPointMake(29.06, 16.2) controlPoint2: CGPointMake(29.18, 16.19)];
    [bezier13Path addLineToPoint: CGPointMake(29.09, 17.17)];
    [bezier13Path closePath];
    bezier13Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier13Path fill];
    
    
    //// Bezier 14 Drawing
    UIBezierPath* bezier14Path = [UIBezierPath bezierPath];
    [bezier14Path moveToPoint: CGPointMake(37.33, 14.6)];
    [bezier14Path addCurveToPoint: CGPointMake(35.18, 12.57) controlPoint1: CGPointMake(37.33, 13.46) controlPoint2: CGPointMake(36.59, 12.57)];
    [bezier14Path addCurveToPoint: CGPointMake(32.51, 15.24) controlPoint1: CGPointMake(33.56, 12.57) controlPoint2: CGPointMake(32.51, 13.65)];
    [bezier14Path addCurveToPoint: CGPointMake(34.66, 17.31) controlPoint1: CGPointMake(32.51, 16.38) controlPoint2: CGPointMake(33.13, 17.31)];
    [bezier14Path addCurveToPoint: CGPointMake(37.33, 14.6) controlPoint1: CGPointMake(36.21, 17.31) controlPoint2: CGPointMake(37.33, 16.49)];
    [bezier14Path closePath];
    [bezier14Path moveToPoint: CGPointMake(35.86, 14.57)];
    [bezier14Path addCurveToPoint: CGPointMake(34.78, 16.21) controlPoint1: CGPointMake(35.86, 15.6) controlPoint2: CGPointMake(35.44, 16.21)];
    [bezier14Path addCurveToPoint: CGPointMake(34, 15.2) controlPoint1: CGPointMake(34.29, 16.21) controlPoint2: CGPointMake(34, 15.81)];
    [bezier14Path addCurveToPoint: CGPointMake(35.12, 13.66) controlPoint1: CGPointMake(34, 14.47) controlPoint2: CGPointMake(34.43, 13.66)];
    [bezier14Path addCurveToPoint: CGPointMake(35.86, 14.57) controlPoint1: CGPointMake(35.67, 13.66) controlPoint2: CGPointMake(35.86, 14.1)];
    [bezier14Path closePath];
    bezier14Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier14Path fill];
    
    
    //// Bezier 15 Drawing
    UIBezierPath* bezier15Path = [UIBezierPath bezierPath];
    [bezier15Path moveToPoint: CGPointMake(30.31, 12.67)];
    [bezier15Path addCurveToPoint: CGPointMake(29.59, 16.93) controlPoint1: CGPointMake(30.13, 14.09) controlPoint2: CGPointMake(29.83, 15.52)];
    [bezier15Path addLineToPoint: CGPointMake(29.53, 17.24)];
    [bezier15Path addLineToPoint: CGPointMake(30.9, 17.24)];
    [bezier15Path addCurveToPoint: CGPointMake(32.61, 14) controlPoint1: CGPointMake(31.4, 14.51) controlPoint2: CGPointMake(31.57, 13.73)];
    [bezier15Path addLineToPoint: CGPointMake(33.1, 12.71)];
    [bezier15Path addCurveToPoint: CGPointMake(31.49, 13.36) controlPoint1: CGPointMake(32.38, 12.45) controlPoint2: CGPointMake(31.91, 12.82)];
    [bezier15Path addCurveToPoint: CGPointMake(31.58, 12.67) controlPoint1: CGPointMake(31.53, 13.12) controlPoint2: CGPointMake(31.6, 12.89)];
    [bezier15Path addLineToPoint: CGPointMake(30.31, 12.67)];
    [bezier15Path closePath];
    bezier15Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier15Path fill];
    
    
    //// Bezier 16 Drawing
    UIBezierPath* bezier16Path = [UIBezierPath bezierPath];
    [bezier16Path moveToPoint: CGPointMake(13.75, 17.24)];
    [bezier16Path addLineToPoint: CGPointMake(12.38, 17.24)];
    [bezier16Path addLineToPoint: CGPointMake(13.19, 12.95)];
    [bezier16Path addLineToPoint: CGPointMake(11.32, 17.24)];
    [bezier16Path addLineToPoint: CGPointMake(10.07, 17.24)];
    [bezier16Path addLineToPoint: CGPointMake(9.84, 12.98)];
    [bezier16Path addLineToPoint: CGPointMake(9.02, 17.24)];
    [bezier16Path addLineToPoint: CGPointMake(7.78, 17.24)];
    [bezier16Path addLineToPoint: CGPointMake(8.84, 11.66)];
    [bezier16Path addLineToPoint: CGPointMake(10.98, 11.66)];
    [bezier16Path addLineToPoint: CGPointMake(11.09, 15.11)];
    [bezier16Path addLineToPoint: CGPointMake(12.6, 11.66)];
    [bezier16Path addLineToPoint: CGPointMake(14.82, 11.66)];
    [bezier16Path addLineToPoint: CGPointMake(13.75, 17.24)];
    [bezier16Path closePath];
    bezier16Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier16Path fill];
}
@end
