#import "BTUIKMasterCardVectorArtView.h"

@implementation BTUIKMasterCardVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor2 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* fillColor4 = [UIColor colorWithRed: 0.103 green: 0.092 blue: 0.095 alpha: 1];
    UIColor* fillColor11 = [UIColor colorWithRed: 0.894 green: 0 blue: 0.111 alpha: 1];
    UIColor* fillColor13 = [UIColor colorWithRed: 0.962 green: 0.582 blue: 0.088 alpha: 1];
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(4.1, 3.5, 22, 22)];
    [fillColor11 setFill];
    [ovalPath fill];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(29.88, 3.5)];
    [bezierPath addCurveToPoint: CGPointMake(22.5, 6.35) controlPoint1: CGPointMake(27.04, 3.5) controlPoint2: CGPointMake(24.45, 4.58)];
    [bezierPath addCurveToPoint: CGPointMake(21.39, 7.51) controlPoint1: CGPointMake(22.1, 6.71) controlPoint2: CGPointMake(21.73, 7.1)];
    [bezierPath addLineToPoint: CGPointMake(23.61, 7.51)];
    [bezierPath addCurveToPoint: CGPointMake(24.45, 8.68) controlPoint1: CGPointMake(23.91, 7.88) controlPoint2: CGPointMake(24.19, 8.27)];
    [bezierPath addLineToPoint: CGPointMake(20.55, 8.68)];
    [bezierPath addCurveToPoint: CGPointMake(19.92, 9.84) controlPoint1: CGPointMake(20.32, 9.05) controlPoint2: CGPointMake(20.1, 9.44)];
    [bezierPath addLineToPoint: CGPointMake(25.08, 9.84)];
    [bezierPath addCurveToPoint: CGPointMake(25.55, 11.01) controlPoint1: CGPointMake(25.26, 10.22) controlPoint2: CGPointMake(25.42, 10.61)];
    [bezierPath addLineToPoint: CGPointMake(19.45, 11.01)];
    [bezierPath addCurveToPoint: CGPointMake(19.13, 12.17) controlPoint1: CGPointMake(19.32, 11.39) controlPoint2: CGPointMake(19.22, 11.77)];
    [bezierPath addLineToPoint: CGPointMake(25.87, 12.17)];
    [bezierPath addCurveToPoint: CGPointMake(26.12, 14.5) controlPoint1: CGPointMake(26.03, 12.92) controlPoint2: CGPointMake(26.12, 13.7)];
    [bezierPath addCurveToPoint: CGPointMake(25.55, 17.99) controlPoint1: CGPointMake(26.12, 15.72) controlPoint2: CGPointMake(25.92, 16.9)];
    [bezierPath addLineToPoint: CGPointMake(19.45, 17.99)];
    [bezierPath addCurveToPoint: CGPointMake(19.92, 19.16) controlPoint1: CGPointMake(19.58, 18.39) controlPoint2: CGPointMake(19.74, 18.78)];
    [bezierPath addLineToPoint: CGPointMake(25.08, 19.16)];
    [bezierPath addCurveToPoint: CGPointMake(24.45, 20.32) controlPoint1: CGPointMake(24.89, 19.56) controlPoint2: CGPointMake(24.68, 19.95)];
    [bezierPath addLineToPoint: CGPointMake(20.55, 20.32)];
    [bezierPath addCurveToPoint: CGPointMake(21.39, 21.49) controlPoint1: CGPointMake(20.8, 20.73) controlPoint2: CGPointMake(21.09, 21.12)];
    [bezierPath addLineToPoint: CGPointMake(23.61, 21.49)];
    [bezierPath addCurveToPoint: CGPointMake(22.5, 22.65) controlPoint1: CGPointMake(23.27, 21.9) controlPoint2: CGPointMake(22.9, 22.29)];
    [bezierPath addCurveToPoint: CGPointMake(29.88, 25.5) controlPoint1: CGPointMake(24.45, 24.42) controlPoint2: CGPointMake(27.04, 25.5)];
    [bezierPath addCurveToPoint: CGPointMake(40.88, 14.5) controlPoint1: CGPointMake(35.96, 25.5) controlPoint2: CGPointMake(40.88, 20.58)];
    [bezierPath addCurveToPoint: CGPointMake(29.88, 3.5) controlPoint1: CGPointMake(40.88, 8.43) controlPoint2: CGPointMake(35.96, 3.5)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    
    [fillColor13 setFill];
    [bezierPath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(39.72, 20.61)];
    [bezier2Path addLineToPoint: CGPointMake(39.76, 20.61)];
    [bezier2Path addCurveToPoint: CGPointMake(39.81, 20.6) controlPoint1: CGPointMake(39.78, 20.61) controlPoint2: CGPointMake(39.8, 20.61)];
    [bezier2Path addCurveToPoint: CGPointMake(39.83, 20.57) controlPoint1: CGPointMake(39.82, 20.6) controlPoint2: CGPointMake(39.83, 20.58)];
    [bezier2Path addCurveToPoint: CGPointMake(39.81, 20.54) controlPoint1: CGPointMake(39.83, 20.56) controlPoint2: CGPointMake(39.82, 20.54)];
    [bezier2Path addCurveToPoint: CGPointMake(39.76, 20.53) controlPoint1: CGPointMake(39.8, 20.53) controlPoint2: CGPointMake(39.78, 20.53)];
    [bezier2Path addLineToPoint: CGPointMake(39.72, 20.53)];
    [bezier2Path addLineToPoint: CGPointMake(39.72, 20.61)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(39.72, 20.79)];
    [bezier2Path addLineToPoint: CGPointMake(39.65, 20.79)];
    [bezier2Path addLineToPoint: CGPointMake(39.65, 20.48)];
    [bezier2Path addLineToPoint: CGPointMake(39.78, 20.48)];
    [bezier2Path addCurveToPoint: CGPointMake(39.86, 20.49) controlPoint1: CGPointMake(39.81, 20.48) controlPoint2: CGPointMake(39.84, 20.48)];
    [bezier2Path addCurveToPoint: CGPointMake(39.9, 20.57) controlPoint1: CGPointMake(39.89, 20.51) controlPoint2: CGPointMake(39.9, 20.54)];
    [bezier2Path addCurveToPoint: CGPointMake(39.85, 20.65) controlPoint1: CGPointMake(39.9, 20.6) controlPoint2: CGPointMake(39.88, 20.64)];
    [bezier2Path addLineToPoint: CGPointMake(39.91, 20.79)];
    [bezier2Path addLineToPoint: CGPointMake(39.83, 20.79)];
    [bezier2Path addLineToPoint: CGPointMake(39.78, 20.66)];
    [bezier2Path addLineToPoint: CGPointMake(39.72, 20.66)];
    [bezier2Path addLineToPoint: CGPointMake(39.72, 20.79)];
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
    [bezier3Path moveToPoint: CGPointMake(11.69, 16.84)];
    [bezier3Path addCurveToPoint: CGPointMake(11.26, 16.38) controlPoint1: CGPointMake(11.43, 16.84) controlPoint2: CGPointMake(11.26, 16.66)];
    [bezier3Path addCurveToPoint: CGPointMake(12.28, 15.69) controlPoint1: CGPointMake(11.26, 15.92) controlPoint2: CGPointMake(11.6, 15.69)];
    [bezier3Path addCurveToPoint: CGPointMake(12.55, 15.7) controlPoint1: CGPointMake(12.37, 15.69) controlPoint2: CGPointMake(12.42, 15.69)];
    [bezier3Path addCurveToPoint: CGPointMake(11.69, 16.84) controlPoint1: CGPointMake(12.53, 16.38) controlPoint2: CGPointMake(12.18, 16.84)];
    [bezier3Path closePath];
    [bezier3Path moveToPoint: CGPointMake(13.87, 14.42)];
    [bezier3Path addCurveToPoint: CGPointMake(12.3, 13.09) controlPoint1: CGPointMake(13.87, 13.55) controlPoint2: CGPointMake(13.33, 13.09)];
    [bezier3Path addCurveToPoint: CGPointMake(10.87, 13.33) controlPoint1: CGPointMake(11.86, 13.09) controlPoint2: CGPointMake(11.47, 13.15)];
    [bezier3Path addCurveToPoint: CGPointMake(10.71, 14.35) controlPoint1: CGPointMake(10.87, 13.33) controlPoint2: CGPointMake(10.72, 14.27)];
    [bezier3Path addCurveToPoint: CGPointMake(11.97, 14.14) controlPoint1: CGPointMake(10.9, 14.28) controlPoint2: CGPointMake(11.39, 14.14)];
    [bezier3Path addCurveToPoint: CGPointMake(12.74, 14.56) controlPoint1: CGPointMake(12.53, 14.14) controlPoint2: CGPointMake(12.74, 14.26)];
    [bezier3Path addCurveToPoint: CGPointMake(12.69, 14.85) controlPoint1: CGPointMake(12.74, 14.64) controlPoint2: CGPointMake(12.73, 14.7)];
    [bezier3Path addCurveToPoint: CGPointMake(12.2, 14.82) controlPoint1: CGPointMake(12.51, 14.83) controlPoint2: CGPointMake(12.34, 14.82)];
    [bezier3Path addCurveToPoint: CGPointMake(10.11, 16.56) controlPoint1: CGPointMake(10.88, 14.82) controlPoint2: CGPointMake(10.11, 15.46)];
    [bezier3Path addCurveToPoint: CGPointMake(11.2, 17.8) controlPoint1: CGPointMake(10.11, 17.3) controlPoint2: CGPointMake(10.55, 17.8)];
    [bezier3Path addCurveToPoint: CGPointMake(12.45, 17.26) controlPoint1: CGPointMake(11.74, 17.8) controlPoint2: CGPointMake(12.15, 17.63)];
    [bezier3Path addLineToPoint: CGPointMake(12.43, 17.73)];
    [bezier3Path addLineToPoint: CGPointMake(13.42, 17.73)];
    [bezier3Path addCurveToPoint: CGPointMake(13.77, 15.32) controlPoint1: CGPointMake(13.45, 17.38) controlPoint2: CGPointMake(13.67, 15.97)];
    [bezier3Path addCurveToPoint: CGPointMake(13.87, 14.42) controlPoint1: CGPointMake(13.83, 14.94) controlPoint2: CGPointMake(13.87, 14.65)];
    [bezier3Path closePath];
    bezier3Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier3Path fill];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(8.62, 12.15)];
    [bezier4Path addLineToPoint: CGPointMake(7.57, 15.27)];
    [bezier4Path addLineToPoint: CGPointMake(7.47, 12.15)];
    [bezier4Path addLineToPoint: CGPointMake(5.75, 12.15)];
    [bezier4Path addLineToPoint: CGPointMake(4.82, 17.73)];
    [bezier4Path addLineToPoint: CGPointMake(5.94, 17.73)];
    [bezier4Path addLineToPoint: CGPointMake(6.65, 13.46)];
    [bezier4Path addLineToPoint: CGPointMake(6.76, 17.73)];
    [bezier4Path addLineToPoint: CGPointMake(7.57, 17.73)];
    [bezier4Path addLineToPoint: CGPointMake(9.1, 13.44)];
    [bezier4Path addLineToPoint: CGPointMake(8.41, 17.73)];
    [bezier4Path addLineToPoint: CGPointMake(9.61, 17.73)];
    [bezier4Path addLineToPoint: CGPointMake(10.53, 12.15)];
    [bezier4Path addLineToPoint: CGPointMake(8.62, 12.15)];
    [bezier4Path closePath];
    bezier4Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier4Path fill];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(30.5, 16.84)];
    [bezier5Path addCurveToPoint: CGPointMake(30.07, 16.38) controlPoint1: CGPointMake(30.24, 16.84) controlPoint2: CGPointMake(30.07, 16.66)];
    [bezier5Path addCurveToPoint: CGPointMake(31.09, 15.69) controlPoint1: CGPointMake(30.07, 15.92) controlPoint2: CGPointMake(30.42, 15.69)];
    [bezier5Path addCurveToPoint: CGPointMake(31.36, 15.7) controlPoint1: CGPointMake(31.18, 15.69) controlPoint2: CGPointMake(31.23, 15.69)];
    [bezier5Path addCurveToPoint: CGPointMake(30.5, 16.84) controlPoint1: CGPointMake(31.34, 16.38) controlPoint2: CGPointMake(30.99, 16.84)];
    [bezier5Path closePath];
    [bezier5Path moveToPoint: CGPointMake(31.11, 13.09)];
    [bezier5Path addCurveToPoint: CGPointMake(29.68, 13.33) controlPoint1: CGPointMake(30.67, 13.09) controlPoint2: CGPointMake(30.28, 13.15)];
    [bezier5Path addCurveToPoint: CGPointMake(29.52, 14.35) controlPoint1: CGPointMake(29.68, 13.33) controlPoint2: CGPointMake(29.53, 14.27)];
    [bezier5Path addCurveToPoint: CGPointMake(30.78, 14.14) controlPoint1: CGPointMake(29.72, 14.28) controlPoint2: CGPointMake(30.2, 14.14)];
    [bezier5Path addCurveToPoint: CGPointMake(31.55, 14.56) controlPoint1: CGPointMake(31.34, 14.14) controlPoint2: CGPointMake(31.55, 14.26)];
    [bezier5Path addCurveToPoint: CGPointMake(31.5, 14.85) controlPoint1: CGPointMake(31.55, 14.64) controlPoint2: CGPointMake(31.54, 14.7)];
    [bezier5Path addCurveToPoint: CGPointMake(31.02, 14.82) controlPoint1: CGPointMake(31.32, 14.83) controlPoint2: CGPointMake(31.15, 14.82)];
    [bezier5Path addCurveToPoint: CGPointMake(28.92, 16.56) controlPoint1: CGPointMake(29.69, 14.82) controlPoint2: CGPointMake(28.92, 15.46)];
    [bezier5Path addCurveToPoint: CGPointMake(30.01, 17.8) controlPoint1: CGPointMake(28.92, 17.3) controlPoint2: CGPointMake(29.36, 17.8)];
    [bezier5Path addCurveToPoint: CGPointMake(31.26, 17.26) controlPoint1: CGPointMake(30.56, 17.8) controlPoint2: CGPointMake(30.96, 17.63)];
    [bezier5Path addLineToPoint: CGPointMake(31.24, 17.73)];
    [bezier5Path addLineToPoint: CGPointMake(32.23, 17.73)];
    [bezier5Path addCurveToPoint: CGPointMake(32.59, 15.32) controlPoint1: CGPointMake(32.26, 17.38) controlPoint2: CGPointMake(32.48, 15.97)];
    [bezier5Path addCurveToPoint: CGPointMake(32.68, 14.42) controlPoint1: CGPointMake(32.64, 14.94) controlPoint2: CGPointMake(32.68, 14.65)];
    [bezier5Path addCurveToPoint: CGPointMake(31.11, 13.09) controlPoint1: CGPointMake(32.68, 13.55) controlPoint2: CGPointMake(32.14, 13.09)];
    [bezier5Path closePath];
    bezier5Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier5Path fill];
    
    
    //// Bezier 6 Drawing
    UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
    [bezier6Path moveToPoint: CGPointMake(18.15, 16.36)];
    [bezier6Path addCurveToPoint: CGPointMake(18.49, 14.28) controlPoint1: CGPointMake(18.15, 16.22) controlPoint2: CGPointMake(18.35, 15.14)];
    [bezier6Path addLineToPoint: CGPointMake(19.21, 14.28)];
    [bezier6Path addLineToPoint: CGPointMake(19.37, 13.19)];
    [bezier6Path addLineToPoint: CGPointMake(18.65, 13.19)];
    [bezier6Path addLineToPoint: CGPointMake(18.79, 12.5)];
    [bezier6Path addLineToPoint: CGPointMake(17.6, 12.5)];
    [bezier6Path addCurveToPoint: CGPointMake(17.09, 15.6) controlPoint1: CGPointMake(17.6, 12.5) controlPoint2: CGPointMake(17.15, 15.17)];
    [bezier6Path addCurveToPoint: CGPointMake(16.92, 16.81) controlPoint1: CGPointMake(17.01, 16.08) controlPoint2: CGPointMake(16.91, 16.61)];
    [bezier6Path addCurveToPoint: CGPointMake(17.87, 17.8) controlPoint1: CGPointMake(16.92, 17.45) controlPoint2: CGPointMake(17.25, 17.8)];
    [bezier6Path addCurveToPoint: CGPointMake(18.72, 17.66) controlPoint1: CGPointMake(18.14, 17.8) controlPoint2: CGPointMake(18.4, 17.76)];
    [bezier6Path addLineToPoint: CGPointMake(18.88, 16.65)];
    [bezier6Path addCurveToPoint: CGPointMake(18.56, 16.7) controlPoint1: CGPointMake(18.8, 16.68) controlPoint2: CGPointMake(18.7, 16.7)];
    [bezier6Path addCurveToPoint: CGPointMake(18.15, 16.36) controlPoint1: CGPointMake(18.28, 16.7) controlPoint2: CGPointMake(18.15, 16.59)];
    [bezier6Path closePath];
    bezier6Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier6Path fill];
    
    
    //// Bezier 7 Drawing
    UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
    [bezier7Path moveToPoint: CGPointMake(21.14, 14.12)];
    [bezier7Path addCurveToPoint: CGPointMake(21.7, 14.93) controlPoint1: CGPointMake(21.82, 14.12) controlPoint2: CGPointMake(21.7, 14.84)];
    [bezier7Path addLineToPoint: CGPointMake(20.38, 14.93)];
    [bezier7Path addCurveToPoint: CGPointMake(21.14, 14.12) controlPoint1: CGPointMake(20.49, 14.41) controlPoint2: CGPointMake(20.77, 14.12)];
    [bezier7Path closePath];
    [bezier7Path moveToPoint: CGPointMake(22.66, 15.85)];
    [bezier7Path addCurveToPoint: CGPointMake(22.8, 14.73) controlPoint1: CGPointMake(22.76, 15.39) controlPoint2: CGPointMake(22.8, 15.06)];
    [bezier7Path addCurveToPoint: CGPointMake(21.2, 13.09) controlPoint1: CGPointMake(22.8, 13.73) controlPoint2: CGPointMake(22.18, 13.09)];
    [bezier7Path addCurveToPoint: CGPointMake(19.12, 15.78) controlPoint1: CGPointMake(20, 13.09) controlPoint2: CGPointMake(19.12, 14.23)];
    [bezier7Path addCurveToPoint: CGPointMake(21.15, 17.8) controlPoint1: CGPointMake(19.12, 17.11) controlPoint2: CGPointMake(19.82, 17.8)];
    [bezier7Path addCurveToPoint: CGPointMake(22.36, 17.62) controlPoint1: CGPointMake(21.56, 17.81) controlPoint2: CGPointMake(21.96, 17.75)];
    [bezier7Path addLineToPoint: CGPointMake(22.56, 16.49)];
    [bezier7Path addCurveToPoint: CGPointMake(21.33, 16.78) controlPoint1: CGPointMake(22.13, 16.69) controlPoint2: CGPointMake(21.75, 16.78)];
    [bezier7Path addCurveToPoint: CGPointMake(20.29, 15.85) controlPoint1: CGPointMake(20.64, 16.78) controlPoint2: CGPointMake(20.21, 16.5)];
    [bezier7Path addLineToPoint: CGPointMake(22.66, 15.85)];
    [bezier7Path closePath];
    bezier7Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier7Path fill];
    
    
    //// Bezier 8 Drawing
    UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
    [bezier8Path moveToPoint: CGPointMake(15.95, 14.16)];
    [bezier8Path addCurveToPoint: CGPointMake(16.81, 14.23) controlPoint1: CGPointMake(16.18, 14.16) controlPoint2: CGPointMake(16.5, 14.18)];
    [bezier8Path addLineToPoint: CGPointMake(16.98, 13.18)];
    [bezier8Path addCurveToPoint: CGPointMake(15.93, 13.09) controlPoint1: CGPointMake(16.67, 13.13) controlPoint2: CGPointMake(16.2, 13.09)];
    [bezier8Path addCurveToPoint: CGPointMake(14.13, 14.62) controlPoint1: CGPointMake(14.59, 13.09) controlPoint2: CGPointMake(14.13, 13.78)];
    [bezier8Path addCurveToPoint: CGPointMake(15.04, 15.89) controlPoint1: CGPointMake(14.13, 15.2) controlPoint2: CGPointMake(14.41, 15.59)];
    [bezier8Path addCurveToPoint: CGPointMake(15.6, 16.39) controlPoint1: CGPointMake(15.53, 16.12) controlPoint2: CGPointMake(15.6, 16.18)];
    [bezier8Path addCurveToPoint: CGPointMake(14.91, 16.8) controlPoint1: CGPointMake(15.6, 16.67) controlPoint2: CGPointMake(15.39, 16.8)];
    [bezier8Path addCurveToPoint: CGPointMake(13.84, 16.62) controlPoint1: CGPointMake(14.56, 16.8) controlPoint2: CGPointMake(14.23, 16.75)];
    [bezier8Path addCurveToPoint: CGPointMake(13.68, 17.67) controlPoint1: CGPointMake(13.84, 16.62) controlPoint2: CGPointMake(13.69, 17.62)];
    [bezier8Path addCurveToPoint: CGPointMake(14.92, 17.8) controlPoint1: CGPointMake(13.95, 17.73) controlPoint2: CGPointMake(14.19, 17.78)];
    [bezier8Path addCurveToPoint: CGPointMake(16.77, 16.29) controlPoint1: CGPointMake(16.18, 17.8) controlPoint2: CGPointMake(16.77, 17.32)];
    [bezier8Path addCurveToPoint: CGPointMake(15.92, 15.02) controlPoint1: CGPointMake(16.77, 15.66) controlPoint2: CGPointMake(16.52, 15.3)];
    [bezier8Path addCurveToPoint: CGPointMake(15.37, 14.53) controlPoint1: CGPointMake(15.42, 14.79) controlPoint2: CGPointMake(15.37, 14.74)];
    [bezier8Path addCurveToPoint: CGPointMake(15.95, 14.16) controlPoint1: CGPointMake(15.37, 14.28) controlPoint2: CGPointMake(15.56, 14.16)];
    [bezier8Path closePath];
    bezier8Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier8Path fill];
    
    
    //// Bezier 9 Drawing
    UIBezierPath* bezier9Path = [UIBezierPath bezierPath];
    [bezier9Path moveToPoint: CGPointMake(26.65, 15.3)];
    [bezier9Path addCurveToPoint: CGPointMake(28.17, 13.21) controlPoint1: CGPointMake(26.65, 14.07) controlPoint2: CGPointMake(27.28, 13.21)];
    [bezier9Path addCurveToPoint: CGPointMake(29.24, 13.51) controlPoint1: CGPointMake(28.5, 13.21) controlPoint2: CGPointMake(28.81, 13.29)];
    [bezier9Path addLineToPoint: CGPointMake(29.43, 12.3)];
    [bezier9Path addCurveToPoint: CGPointMake(28.12, 11.83) controlPoint1: CGPointMake(29.26, 12.23) controlPoint2: CGPointMake(28.64, 11.83)];
    [bezier9Path addCurveToPoint: CGPointMake(26.17, 12.88) controlPoint1: CGPointMake(27.32, 11.83) controlPoint2: CGPointMake(26.65, 12.22)];
    [bezier9Path addCurveToPoint: CGPointMake(24.84, 13.57) controlPoint1: CGPointMake(25.48, 12.65) controlPoint2: CGPointMake(25.19, 13.11)];
    [bezier9Path addLineToPoint: CGPointMake(24.53, 13.64)];
    [bezier9Path addCurveToPoint: CGPointMake(24.57, 13.19) controlPoint1: CGPointMake(24.56, 13.49) controlPoint2: CGPointMake(24.58, 13.34)];
    [bezier9Path addLineToPoint: CGPointMake(23.47, 13.19)];
    [bezier9Path addCurveToPoint: CGPointMake(22.85, 17.42) controlPoint1: CGPointMake(23.32, 14.59) controlPoint2: CGPointMake(23.06, 16.02)];
    [bezier9Path addLineToPoint: CGPointMake(22.8, 17.73)];
    [bezier9Path addLineToPoint: CGPointMake(23.99, 17.73)];
    [bezier9Path addCurveToPoint: CGPointMake(24.37, 15.04) controlPoint1: CGPointMake(24.19, 16.43) controlPoint2: CGPointMake(24.3, 15.6)];
    [bezier9Path addLineToPoint: CGPointMake(24.82, 14.79)];
    [bezier9Path addCurveToPoint: CGPointMake(25.52, 14.47) controlPoint1: CGPointMake(24.88, 14.54) controlPoint2: CGPointMake(25.09, 14.46)];
    [bezier9Path addCurveToPoint: CGPointMake(25.43, 15.4) controlPoint1: CGPointMake(25.46, 14.76) controlPoint2: CGPointMake(25.43, 15.07)];
    [bezier9Path addCurveToPoint: CGPointMake(27.52, 17.8) controlPoint1: CGPointMake(25.43, 16.88) controlPoint2: CGPointMake(26.23, 17.8)];
    [bezier9Path addCurveToPoint: CGPointMake(28.57, 17.64) controlPoint1: CGPointMake(27.85, 17.8) controlPoint2: CGPointMake(28.13, 17.76)];
    [bezier9Path addLineToPoint: CGPointMake(28.78, 16.37)];
    [bezier9Path addCurveToPoint: CGPointMake(27.77, 16.66) controlPoint1: CGPointMake(28.39, 16.56) controlPoint2: CGPointMake(28.06, 16.66)];
    [bezier9Path addCurveToPoint: CGPointMake(26.65, 15.3) controlPoint1: CGPointMake(27.07, 16.66) controlPoint2: CGPointMake(26.65, 16.14)];
    [bezier9Path closePath];
    bezier9Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier9Path fill];
    
    
    //// Bezier 10 Drawing
    UIBezierPath* bezier10Path = [UIBezierPath bezierPath];
    [bezier10Path moveToPoint: CGPointMake(36.79, 16.68)];
    [bezier10Path addCurveToPoint: CGPointMake(36.18, 15.78) controlPoint1: CGPointMake(36.38, 16.68) controlPoint2: CGPointMake(36.18, 16.38)];
    [bezier10Path addCurveToPoint: CGPointMake(37.1, 14.26) controlPoint1: CGPointMake(36.18, 14.89) controlPoint2: CGPointMake(36.56, 14.26)];
    [bezier10Path addCurveToPoint: CGPointMake(37.73, 15.15) controlPoint1: CGPointMake(37.51, 14.26) controlPoint2: CGPointMake(37.73, 14.57)];
    [bezier10Path addCurveToPoint: CGPointMake(36.79, 16.68) controlPoint1: CGPointMake(37.73, 16.05) controlPoint2: CGPointMake(37.34, 16.68)];
    [bezier10Path closePath];
    [bezier10Path moveToPoint: CGPointMake(38.28, 12.15)];
    [bezier10Path addLineToPoint: CGPointMake(38.02, 13.76)];
    [bezier10Path addCurveToPoint: CGPointMake(36.88, 13.02) controlPoint1: CGPointMake(37.69, 13.33) controlPoint2: CGPointMake(37.34, 13.02)];
    [bezier10Path addCurveToPoint: CGPointMake(35.37, 14.15) controlPoint1: CGPointMake(36.27, 13.02) controlPoint2: CGPointMake(35.72, 13.47)];
    [bezier10Path addCurveToPoint: CGPointMake(34.35, 13.87) controlPoint1: CGPointMake(34.87, 14.04) controlPoint2: CGPointMake(34.35, 13.87)];
    [bezier10Path addCurveToPoint: CGPointMake(34.35, 13.87) controlPoint1: CGPointMake(34.35, 13.87) controlPoint2: CGPointMake(34.35, 13.87)];
    [bezier10Path addLineToPoint: CGPointMake(34.35, 13.87)];
    [bezier10Path addLineToPoint: CGPointMake(34.35, 13.87)];
    [bezier10Path addCurveToPoint: CGPointMake(34.4, 13.19) controlPoint1: CGPointMake(34.39, 13.49) controlPoint2: CGPointMake(34.4, 13.27)];
    [bezier10Path addLineToPoint: CGPointMake(33.3, 13.19)];
    [bezier10Path addCurveToPoint: CGPointMake(32.68, 17.42) controlPoint1: CGPointMake(33.15, 14.59) controlPoint2: CGPointMake(32.89, 16.02)];
    [bezier10Path addLineToPoint: CGPointMake(32.63, 17.73)];
    [bezier10Path addLineToPoint: CGPointMake(33.82, 17.73)];
    [bezier10Path addCurveToPoint: CGPointMake(34.2, 15.12) controlPoint1: CGPointMake(33.98, 16.68) controlPoint2: CGPointMake(34.11, 15.81)];
    [bezier10Path addCurveToPoint: CGPointMake(35.22, 14.45) controlPoint1: CGPointMake(34.61, 14.75) controlPoint2: CGPointMake(34.81, 14.43)];
    [bezier10Path addCurveToPoint: CGPointMake(34.93, 15.92) controlPoint1: CGPointMake(35.04, 14.89) controlPoint2: CGPointMake(34.93, 15.4)];
    [bezier10Path addCurveToPoint: CGPointMake(36.37, 17.8) controlPoint1: CGPointMake(34.93, 17.06) controlPoint2: CGPointMake(35.51, 17.8)];
    [bezier10Path addCurveToPoint: CGPointMake(37.48, 17.3) controlPoint1: CGPointMake(36.81, 17.8) controlPoint2: CGPointMake(37.15, 17.65)];
    [bezier10Path addLineToPoint: CGPointMake(37.42, 17.73)];
    [bezier10Path addLineToPoint: CGPointMake(38.55, 17.73)];
    [bezier10Path addLineToPoint: CGPointMake(39.46, 12.15)];
    [bezier10Path addLineToPoint: CGPointMake(38.28, 12.15)];
    [bezier10Path closePath];
    bezier10Path.usesEvenOddFillRule = YES;
    
    [fillColor4 setFill];
    [bezier10Path fill];
    
    
    //// Bezier 11 Drawing
    UIBezierPath* bezier11Path = [UIBezierPath bezierPath];
    [bezier11Path moveToPoint: CGPointMake(39.72, 17.02)];
    [bezier11Path addLineToPoint: CGPointMake(39.76, 17.02)];
    [bezier11Path addCurveToPoint: CGPointMake(39.81, 17.01) controlPoint1: CGPointMake(39.78, 17.02) controlPoint2: CGPointMake(39.8, 17.02)];
    [bezier11Path addCurveToPoint: CGPointMake(39.83, 16.98) controlPoint1: CGPointMake(39.82, 17) controlPoint2: CGPointMake(39.83, 16.99)];
    [bezier11Path addCurveToPoint: CGPointMake(39.81, 16.94) controlPoint1: CGPointMake(39.83, 16.96) controlPoint2: CGPointMake(39.82, 16.95)];
    [bezier11Path addCurveToPoint: CGPointMake(39.76, 16.94) controlPoint1: CGPointMake(39.8, 16.94) controlPoint2: CGPointMake(39.78, 16.94)];
    [bezier11Path addLineToPoint: CGPointMake(39.72, 16.94)];
    [bezier11Path addLineToPoint: CGPointMake(39.72, 17.02)];
    [bezier11Path closePath];
    [bezier11Path moveToPoint: CGPointMake(39.72, 17.19)];
    [bezier11Path addLineToPoint: CGPointMake(39.65, 17.19)];
    [bezier11Path addLineToPoint: CGPointMake(39.65, 16.88)];
    [bezier11Path addLineToPoint: CGPointMake(39.78, 16.88)];
    [bezier11Path addCurveToPoint: CGPointMake(39.86, 16.9) controlPoint1: CGPointMake(39.81, 16.88) controlPoint2: CGPointMake(39.84, 16.88)];
    [bezier11Path addCurveToPoint: CGPointMake(39.9, 16.98) controlPoint1: CGPointMake(39.89, 16.92) controlPoint2: CGPointMake(39.9, 16.95)];
    [bezier11Path addCurveToPoint: CGPointMake(39.85, 17.06) controlPoint1: CGPointMake(39.9, 17.01) controlPoint2: CGPointMake(39.88, 17.05)];
    [bezier11Path addLineToPoint: CGPointMake(39.91, 17.19)];
    [bezier11Path addLineToPoint: CGPointMake(39.83, 17.19)];
    [bezier11Path addLineToPoint: CGPointMake(39.78, 17.07)];
    [bezier11Path addLineToPoint: CGPointMake(39.72, 17.07)];
    [bezier11Path addLineToPoint: CGPointMake(39.72, 17.19)];
    [bezier11Path closePath];
    [bezier11Path moveToPoint: CGPointMake(39.77, 17.31)];
    [bezier11Path addCurveToPoint: CGPointMake(40.04, 17.04) controlPoint1: CGPointMake(39.92, 17.31) controlPoint2: CGPointMake(40.04, 17.19)];
    [bezier11Path addCurveToPoint: CGPointMake(39.77, 16.77) controlPoint1: CGPointMake(40.04, 16.89) controlPoint2: CGPointMake(39.92, 16.77)];
    [bezier11Path addCurveToPoint: CGPointMake(39.5, 17.04) controlPoint1: CGPointMake(39.62, 16.77) controlPoint2: CGPointMake(39.5, 16.89)];
    [bezier11Path addCurveToPoint: CGPointMake(39.77, 17.31) controlPoint1: CGPointMake(39.5, 17.19) controlPoint2: CGPointMake(39.62, 17.31)];
    [bezier11Path closePath];
    [bezier11Path moveToPoint: CGPointMake(39.42, 17.04)];
    [bezier11Path addCurveToPoint: CGPointMake(39.77, 16.68) controlPoint1: CGPointMake(39.42, 16.84) controlPoint2: CGPointMake(39.58, 16.68)];
    [bezier11Path addCurveToPoint: CGPointMake(40.13, 17.04) controlPoint1: CGPointMake(39.97, 16.68) controlPoint2: CGPointMake(40.13, 16.84)];
    [bezier11Path addCurveToPoint: CGPointMake(39.77, 17.4) controlPoint1: CGPointMake(40.13, 17.24) controlPoint2: CGPointMake(39.97, 17.4)];
    [bezier11Path addCurveToPoint: CGPointMake(39.42, 17.04) controlPoint1: CGPointMake(39.58, 17.4) controlPoint2: CGPointMake(39.42, 17.24)];
    [bezier11Path closePath];
    bezier11Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier11Path fill];
    
    
    //// Bezier 12 Drawing
    UIBezierPath* bezier12Path = [UIBezierPath bezierPath];
    [bezier12Path moveToPoint: CGPointMake(9.02, 11.82)];
    [bezier12Path addLineToPoint: CGPointMake(7.86, 15.27)];
    [bezier12Path addLineToPoint: CGPointMake(7.81, 11.82)];
    [bezier12Path addLineToPoint: CGPointMake(6.1, 11.82)];
    [bezier12Path addLineToPoint: CGPointMake(5.16, 17.39)];
    [bezier12Path addLineToPoint: CGPointMake(6.28, 17.39)];
    [bezier12Path addLineToPoint: CGPointMake(7, 13.13)];
    [bezier12Path addLineToPoint: CGPointMake(7.1, 17.39)];
    [bezier12Path addLineToPoint: CGPointMake(7.91, 17.39)];
    [bezier12Path addLineToPoint: CGPointMake(9.44, 13.11)];
    [bezier12Path addLineToPoint: CGPointMake(8.76, 17.39)];
    [bezier12Path addLineToPoint: CGPointMake(9.95, 17.39)];
    [bezier12Path addLineToPoint: CGPointMake(10.87, 11.82)];
    [bezier12Path addLineToPoint: CGPointMake(9.02, 11.82)];
    [bezier12Path closePath];
    bezier12Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier12Path fill];
    
    
    //// Bezier 13 Drawing
    UIBezierPath* bezier13Path = [UIBezierPath bezierPath];
    [bezier13Path moveToPoint: CGPointMake(12.03, 16.51)];
    [bezier13Path addCurveToPoint: CGPointMake(11.61, 16.05) controlPoint1: CGPointMake(11.77, 16.51) controlPoint2: CGPointMake(11.61, 16.33)];
    [bezier13Path addCurveToPoint: CGPointMake(12.63, 15.36) controlPoint1: CGPointMake(11.61, 15.59) controlPoint2: CGPointMake(11.95, 15.36)];
    [bezier13Path addCurveToPoint: CGPointMake(12.89, 15.37) controlPoint1: CGPointMake(12.71, 15.36) controlPoint2: CGPointMake(12.77, 15.36)];
    [bezier13Path addCurveToPoint: CGPointMake(12.03, 16.51) controlPoint1: CGPointMake(12.87, 16.05) controlPoint2: CGPointMake(12.52, 16.51)];
    [bezier13Path closePath];
    [bezier13Path moveToPoint: CGPointMake(14.21, 14.09)];
    [bezier13Path addCurveToPoint: CGPointMake(12.65, 12.76) controlPoint1: CGPointMake(14.21, 13.22) controlPoint2: CGPointMake(13.67, 12.76)];
    [bezier13Path addCurveToPoint: CGPointMake(11.22, 13) controlPoint1: CGPointMake(12.2, 12.76) controlPoint2: CGPointMake(11.81, 12.82)];
    [bezier13Path addCurveToPoint: CGPointMake(11.05, 14.02) controlPoint1: CGPointMake(11.22, 13) controlPoint2: CGPointMake(11.06, 13.94)];
    [bezier13Path addCurveToPoint: CGPointMake(12.32, 13.81) controlPoint1: CGPointMake(11.25, 13.95) controlPoint2: CGPointMake(11.73, 13.81)];
    [bezier13Path addCurveToPoint: CGPointMake(13.08, 14.23) controlPoint1: CGPointMake(12.87, 13.81) controlPoint2: CGPointMake(13.08, 13.93)];
    [bezier13Path addCurveToPoint: CGPointMake(13.03, 14.52) controlPoint1: CGPointMake(13.08, 14.31) controlPoint2: CGPointMake(13.07, 14.37)];
    [bezier13Path addCurveToPoint: CGPointMake(12.55, 14.49) controlPoint1: CGPointMake(12.86, 14.5) controlPoint2: CGPointMake(12.68, 14.49)];
    [bezier13Path addCurveToPoint: CGPointMake(10.45, 16.23) controlPoint1: CGPointMake(11.22, 14.49) controlPoint2: CGPointMake(10.45, 15.13)];
    [bezier13Path addCurveToPoint: CGPointMake(11.54, 17.47) controlPoint1: CGPointMake(10.45, 16.97) controlPoint2: CGPointMake(10.89, 17.47)];
    [bezier13Path addCurveToPoint: CGPointMake(12.79, 16.93) controlPoint1: CGPointMake(12.09, 17.47) controlPoint2: CGPointMake(12.49, 17.3)];
    [bezier13Path addLineToPoint: CGPointMake(12.77, 17.4)];
    [bezier13Path addLineToPoint: CGPointMake(13.76, 17.4)];
    [bezier13Path addCurveToPoint: CGPointMake(14.12, 14.99) controlPoint1: CGPointMake(13.79, 17.05) controlPoint2: CGPointMake(14.01, 15.64)];
    [bezier13Path addCurveToPoint: CGPointMake(14.21, 14.09) controlPoint1: CGPointMake(14.18, 14.61) controlPoint2: CGPointMake(14.22, 14.32)];
    [bezier13Path closePath];
    bezier13Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier13Path fill];
    
    
    //// Bezier 14 Drawing
    UIBezierPath* bezier14Path = [UIBezierPath bezierPath];
    [bezier14Path moveToPoint: CGPointMake(27, 14.97)];
    [bezier14Path addCurveToPoint: CGPointMake(28.51, 12.88) controlPoint1: CGPointMake(27, 13.74) controlPoint2: CGPointMake(27.62, 12.88)];
    [bezier14Path addCurveToPoint: CGPointMake(29.58, 13.18) controlPoint1: CGPointMake(28.85, 12.88) controlPoint2: CGPointMake(29.15, 12.96)];
    [bezier14Path addLineToPoint: CGPointMake(29.78, 11.97)];
    [bezier14Path addCurveToPoint: CGPointMake(28.46, 11.68) controlPoint1: CGPointMake(29.6, 11.9) controlPoint2: CGPointMake(28.99, 11.68)];
    [bezier14Path addCurveToPoint: CGPointMake(25.77, 15.07) controlPoint1: CGPointMake(26.88, 11.68) controlPoint2: CGPointMake(25.77, 13.07)];
    [bezier14Path addCurveToPoint: CGPointMake(27.86, 17.47) controlPoint1: CGPointMake(25.77, 16.55) controlPoint2: CGPointMake(26.58, 17.47)];
    [bezier14Path addCurveToPoint: CGPointMake(28.92, 17.31) controlPoint1: CGPointMake(28.19, 17.47) controlPoint2: CGPointMake(28.48, 17.43)];
    [bezier14Path addLineToPoint: CGPointMake(29.13, 16.04)];
    [bezier14Path addCurveToPoint: CGPointMake(28.11, 16.33) controlPoint1: CGPointMake(28.73, 16.23) controlPoint2: CGPointMake(28.41, 16.33)];
    [bezier14Path addCurveToPoint: CGPointMake(27, 14.97) controlPoint1: CGPointMake(27.42, 16.33) controlPoint2: CGPointMake(27, 15.81)];
    [bezier14Path closePath];
    bezier14Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier14Path fill];
    
    
    //// Bezier 15 Drawing
    UIBezierPath* bezier15Path = [UIBezierPath bezierPath];
    [bezier15Path moveToPoint: CGPointMake(30.85, 16.51)];
    [bezier15Path addCurveToPoint: CGPointMake(30.42, 16.05) controlPoint1: CGPointMake(30.59, 16.51) controlPoint2: CGPointMake(30.42, 16.33)];
    [bezier15Path addCurveToPoint: CGPointMake(31.44, 15.36) controlPoint1: CGPointMake(30.42, 15.59) controlPoint2: CGPointMake(30.76, 15.36)];
    [bezier15Path addCurveToPoint: CGPointMake(31.7, 15.37) controlPoint1: CGPointMake(31.52, 15.36) controlPoint2: CGPointMake(31.58, 15.36)];
    [bezier15Path addCurveToPoint: CGPointMake(30.85, 16.51) controlPoint1: CGPointMake(31.68, 16.05) controlPoint2: CGPointMake(31.33, 16.51)];
    [bezier15Path closePath];
    [bezier15Path moveToPoint: CGPointMake(31.46, 12.76)];
    [bezier15Path addCurveToPoint: CGPointMake(30.03, 13) controlPoint1: CGPointMake(31.02, 12.76) controlPoint2: CGPointMake(30.62, 12.82)];
    [bezier15Path addCurveToPoint: CGPointMake(29.86, 14.02) controlPoint1: CGPointMake(30.03, 13) controlPoint2: CGPointMake(29.88, 13.94)];
    [bezier15Path addCurveToPoint: CGPointMake(31.13, 13.81) controlPoint1: CGPointMake(30.06, 13.95) controlPoint2: CGPointMake(30.54, 13.81)];
    [bezier15Path addCurveToPoint: CGPointMake(31.89, 14.23) controlPoint1: CGPointMake(31.68, 13.81) controlPoint2: CGPointMake(31.89, 13.93)];
    [bezier15Path addCurveToPoint: CGPointMake(31.85, 14.52) controlPoint1: CGPointMake(31.89, 14.31) controlPoint2: CGPointMake(31.88, 14.37)];
    [bezier15Path addCurveToPoint: CGPointMake(31.36, 14.49) controlPoint1: CGPointMake(31.67, 14.5) controlPoint2: CGPointMake(31.49, 14.49)];
    [bezier15Path addCurveToPoint: CGPointMake(29.26, 16.23) controlPoint1: CGPointMake(30.03, 14.49) controlPoint2: CGPointMake(29.26, 15.13)];
    [bezier15Path addCurveToPoint: CGPointMake(30.35, 17.47) controlPoint1: CGPointMake(29.26, 16.97) controlPoint2: CGPointMake(29.71, 17.47)];
    [bezier15Path addCurveToPoint: CGPointMake(31.61, 16.93) controlPoint1: CGPointMake(30.9, 17.47) controlPoint2: CGPointMake(31.3, 17.3)];
    [bezier15Path addLineToPoint: CGPointMake(31.58, 17.4)];
    [bezier15Path addLineToPoint: CGPointMake(32.57, 17.4)];
    [bezier15Path addCurveToPoint: CGPointMake(32.93, 14.99) controlPoint1: CGPointMake(32.6, 17.05) controlPoint2: CGPointMake(32.83, 15.64)];
    [bezier15Path addCurveToPoint: CGPointMake(33.02, 14.09) controlPoint1: CGPointMake(32.99, 14.61) controlPoint2: CGPointMake(33.03, 14.32)];
    [bezier15Path addCurveToPoint: CGPointMake(31.46, 12.76) controlPoint1: CGPointMake(33.03, 13.22) controlPoint2: CGPointMake(32.48, 12.76)];
    [bezier15Path closePath];
    bezier15Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier15Path fill];
    
    
    //// Bezier 16 Drawing
    UIBezierPath* bezier16Path = [UIBezierPath bezierPath];
    [bezier16Path moveToPoint: CGPointMake(19.44, 13.95)];
    [bezier16Path addLineToPoint: CGPointMake(19.6, 12.86)];
    [bezier16Path addLineToPoint: CGPointMake(19, 12.86)];
    [bezier16Path addLineToPoint: CGPointMake(19.13, 12.17)];
    [bezier16Path addLineToPoint: CGPointMake(17.95, 12.17)];
    [bezier16Path addCurveToPoint: CGPointMake(17.43, 15.27) controlPoint1: CGPointMake(17.95, 12.17) controlPoint2: CGPointMake(17.5, 14.84)];
    [bezier16Path addCurveToPoint: CGPointMake(17.27, 16.48) controlPoint1: CGPointMake(17.35, 15.75) controlPoint2: CGPointMake(17.26, 16.28)];
    [bezier16Path addCurveToPoint: CGPointMake(18.21, 17.47) controlPoint1: CGPointMake(17.27, 17.12) controlPoint2: CGPointMake(17.6, 17.47)];
    [bezier16Path addCurveToPoint: CGPointMake(19.07, 17.33) controlPoint1: CGPointMake(18.49, 17.47) controlPoint2: CGPointMake(18.74, 17.43)];
    [bezier16Path addLineToPoint: CGPointMake(19.22, 16.32)];
    [bezier16Path addCurveToPoint: CGPointMake(18.9, 16.36) controlPoint1: CGPointMake(19.14, 16.35) controlPoint2: CGPointMake(19.04, 16.36)];
    [bezier16Path addCurveToPoint: CGPointMake(18.49, 16.03) controlPoint1: CGPointMake(18.62, 16.36) controlPoint2: CGPointMake(18.49, 16.26)];
    [bezier16Path addCurveToPoint: CGPointMake(18.83, 13.95) controlPoint1: CGPointMake(18.5, 15.89) controlPoint2: CGPointMake(18.69, 14.81)];
    [bezier16Path addLineToPoint: CGPointMake(19.44, 13.95)];
    [bezier16Path closePath];
    bezier16Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier16Path fill];
    
    
    //// Bezier 17 Drawing
    UIBezierPath* bezier17Path = [UIBezierPath bezierPath];
    [bezier17Path moveToPoint: CGPointMake(21.49, 13.79)];
    [bezier17Path addCurveToPoint: CGPointMake(22.04, 14.6) controlPoint1: CGPointMake(22.16, 13.79) controlPoint2: CGPointMake(22.05, 14.51)];
    [bezier17Path addLineToPoint: CGPointMake(20.73, 14.6)];
    [bezier17Path addCurveToPoint: CGPointMake(21.49, 13.79) controlPoint1: CGPointMake(20.84, 14.08) controlPoint2: CGPointMake(21.11, 13.79)];
    [bezier17Path closePath];
    [bezier17Path moveToPoint: CGPointMake(23, 15.52)];
    [bezier17Path addCurveToPoint: CGPointMake(23.15, 14.4) controlPoint1: CGPointMake(23.1, 15.06) controlPoint2: CGPointMake(23.15, 14.73)];
    [bezier17Path addCurveToPoint: CGPointMake(21.54, 12.76) controlPoint1: CGPointMake(23.15, 13.4) controlPoint2: CGPointMake(22.52, 12.76)];
    [bezier17Path addCurveToPoint: CGPointMake(19.47, 15.45) controlPoint1: CGPointMake(20.35, 12.76) controlPoint2: CGPointMake(19.47, 13.9)];
    [bezier17Path addCurveToPoint: CGPointMake(21.49, 17.47) controlPoint1: CGPointMake(19.47, 16.78) controlPoint2: CGPointMake(20.16, 17.47)];
    [bezier17Path addCurveToPoint: CGPointMake(22.71, 17.29) controlPoint1: CGPointMake(21.9, 17.47) controlPoint2: CGPointMake(22.3, 17.41)];
    [bezier17Path addLineToPoint: CGPointMake(22.9, 16.16)];
    [bezier17Path addCurveToPoint: CGPointMake(21.67, 16.45) controlPoint1: CGPointMake(22.48, 16.36) controlPoint2: CGPointMake(22.09, 16.45)];
    [bezier17Path addCurveToPoint: CGPointMake(20.64, 15.52) controlPoint1: CGPointMake(20.98, 16.45) controlPoint2: CGPointMake(20.56, 16.17)];
    [bezier17Path addLineToPoint: CGPointMake(23, 15.52)];
    [bezier17Path closePath];
    bezier17Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier17Path fill];
    
    
    //// Bezier 18 Drawing
    UIBezierPath* bezier18Path = [UIBezierPath bezierPath];
    [bezier18Path moveToPoint: CGPointMake(16.29, 13.83)];
    [bezier18Path addCurveToPoint: CGPointMake(17.15, 13.9) controlPoint1: CGPointMake(16.53, 13.83) controlPoint2: CGPointMake(16.85, 13.85)];
    [bezier18Path addLineToPoint: CGPointMake(17.32, 12.84)];
    [bezier18Path addCurveToPoint: CGPointMake(16.27, 12.76) controlPoint1: CGPointMake(17.01, 12.8) controlPoint2: CGPointMake(16.54, 12.76)];
    [bezier18Path addCurveToPoint: CGPointMake(14.48, 14.29) controlPoint1: CGPointMake(14.93, 12.76) controlPoint2: CGPointMake(14.47, 13.45)];
    [bezier18Path addCurveToPoint: CGPointMake(15.39, 15.56) controlPoint1: CGPointMake(14.48, 14.87) controlPoint2: CGPointMake(14.75, 15.26)];
    [bezier18Path addCurveToPoint: CGPointMake(15.94, 16.06) controlPoint1: CGPointMake(15.87, 15.79) controlPoint2: CGPointMake(15.94, 15.85)];
    [bezier18Path addCurveToPoint: CGPointMake(15.26, 16.47) controlPoint1: CGPointMake(15.94, 16.34) controlPoint2: CGPointMake(15.73, 16.47)];
    [bezier18Path addCurveToPoint: CGPointMake(14.19, 16.29) controlPoint1: CGPointMake(14.9, 16.47) controlPoint2: CGPointMake(14.57, 16.41)];
    [bezier18Path addCurveToPoint: CGPointMake(14.02, 17.34) controlPoint1: CGPointMake(14.19, 16.29) controlPoint2: CGPointMake(14.03, 17.29)];
    [bezier18Path addCurveToPoint: CGPointMake(15.27, 17.47) controlPoint1: CGPointMake(14.3, 17.4) controlPoint2: CGPointMake(14.54, 17.45)];
    [bezier18Path addCurveToPoint: CGPointMake(17.11, 15.96) controlPoint1: CGPointMake(16.53, 17.47) controlPoint2: CGPointMake(17.11, 16.99)];
    [bezier18Path addCurveToPoint: CGPointMake(16.27, 14.69) controlPoint1: CGPointMake(17.11, 15.33) controlPoint2: CGPointMake(16.87, 14.97)];
    [bezier18Path addCurveToPoint: CGPointMake(15.71, 14.2) controlPoint1: CGPointMake(15.77, 14.46) controlPoint2: CGPointMake(15.71, 14.41)];
    [bezier18Path addCurveToPoint: CGPointMake(16.29, 13.83) controlPoint1: CGPointMake(15.71, 13.95) controlPoint2: CGPointMake(15.91, 13.83)];
    [bezier18Path closePath];
    bezier18Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier18Path fill];
    
    
    //// Bezier 19 Drawing
    UIBezierPath* bezier19Path = [UIBezierPath bezierPath];
    [bezier19Path moveToPoint: CGPointMake(37.13, 16.35)];
    [bezier19Path addCurveToPoint: CGPointMake(36.52, 15.45) controlPoint1: CGPointMake(36.73, 16.35) controlPoint2: CGPointMake(36.52, 16.05)];
    [bezier19Path addCurveToPoint: CGPointMake(37.45, 13.93) controlPoint1: CGPointMake(36.52, 14.56) controlPoint2: CGPointMake(36.9, 13.93)];
    [bezier19Path addCurveToPoint: CGPointMake(38.08, 14.82) controlPoint1: CGPointMake(37.86, 13.93) controlPoint2: CGPointMake(38.08, 14.24)];
    [bezier19Path addCurveToPoint: CGPointMake(37.13, 16.35) controlPoint1: CGPointMake(38.08, 15.72) controlPoint2: CGPointMake(37.69, 16.35)];
    [bezier19Path closePath];
    [bezier19Path moveToPoint: CGPointMake(38.62, 11.82)];
    [bezier19Path addLineToPoint: CGPointMake(38.36, 13.43)];
    [bezier19Path addCurveToPoint: CGPointMake(37.22, 12.81) controlPoint1: CGPointMake(38.03, 13) controlPoint2: CGPointMake(37.68, 12.81)];
    [bezier19Path addCurveToPoint: CGPointMake(35.28, 15.59) controlPoint1: CGPointMake(36.17, 12.81) controlPoint2: CGPointMake(35.28, 14.08)];
    [bezier19Path addCurveToPoint: CGPointMake(36.72, 17.47) controlPoint1: CGPointMake(35.28, 16.73) controlPoint2: CGPointMake(35.85, 17.47)];
    [bezier19Path addCurveToPoint: CGPointMake(37.82, 16.97) controlPoint1: CGPointMake(37.16, 17.47) controlPoint2: CGPointMake(37.49, 17.32)];
    [bezier19Path addLineToPoint: CGPointMake(37.76, 17.39)];
    [bezier19Path addLineToPoint: CGPointMake(38.89, 17.39)];
    [bezier19Path addLineToPoint: CGPointMake(39.8, 11.82)];
    [bezier19Path addLineToPoint: CGPointMake(38.62, 11.82)];
    [bezier19Path closePath];
    bezier19Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier19Path fill];
    
    
    //// Bezier 20 Drawing
    UIBezierPath* bezier20Path = [UIBezierPath bezierPath];
    [bezier20Path moveToPoint: CGPointMake(35.82, 12.83)];
    [bezier20Path addCurveToPoint: CGPointMake(34.67, 13.55) controlPoint1: CGPointMake(35.32, 12.73) controlPoint2: CGPointMake(35.04, 13.01)];
    [bezier20Path addCurveToPoint: CGPointMake(34.74, 12.86) controlPoint1: CGPointMake(34.7, 13.31) controlPoint2: CGPointMake(34.76, 13.09)];
    [bezier20Path addLineToPoint: CGPointMake(33.65, 12.86)];
    [bezier20Path addCurveToPoint: CGPointMake(33.02, 17.09) controlPoint1: CGPointMake(33.5, 14.26) controlPoint2: CGPointMake(33.23, 15.68)];
    [bezier20Path addLineToPoint: CGPointMake(32.97, 17.4)];
    [bezier20Path addLineToPoint: CGPointMake(34.16, 17.4)];
    [bezier20Path addCurveToPoint: CGPointMake(35.37, 14.15) controlPoint1: CGPointMake(34.59, 14.62) controlPoint2: CGPointMake(34.7, 14.08)];
    [bezier20Path addCurveToPoint: CGPointMake(35.82, 12.83) controlPoint1: CGPointMake(35.47, 13.58) controlPoint2: CGPointMake(35.67, 13.08)];
    [bezier20Path closePath];
    bezier20Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier20Path fill];
    
    
    //// Bezier 21 Drawing
    UIBezierPath* bezier21Path = [UIBezierPath bezierPath];
    [bezier21Path moveToPoint: CGPointMake(24.84, 13.55)];
    [bezier21Path addCurveToPoint: CGPointMake(24.91, 12.86) controlPoint1: CGPointMake(24.87, 13.31) controlPoint2: CGPointMake(24.92, 13.09)];
    [bezier21Path addLineToPoint: CGPointMake(23.82, 12.86)];
    [bezier21Path addCurveToPoint: CGPointMake(23.19, 17.09) controlPoint1: CGPointMake(23.67, 14.26) controlPoint2: CGPointMake(23.4, 15.68)];
    [bezier21Path addLineToPoint: CGPointMake(23.14, 17.39)];
    [bezier21Path addLineToPoint: CGPointMake(24.34, 17.39)];
    [bezier21Path addCurveToPoint: CGPointMake(25.53, 14.15) controlPoint1: CGPointMake(24.76, 14.62) controlPoint2: CGPointMake(24.87, 14.08)];
    [bezier21Path addCurveToPoint: CGPointMake(25.99, 12.83) controlPoint1: CGPointMake(25.64, 13.58) controlPoint2: CGPointMake(25.84, 13.08)];
    [bezier21Path addCurveToPoint: CGPointMake(24.84, 13.55) controlPoint1: CGPointMake(25.49, 12.73) controlPoint2: CGPointMake(25.21, 13.01)];
    [bezier21Path closePath];
    bezier21Path.usesEvenOddFillRule = YES;
    
    [fillColor2 setFill];
    [bezier21Path fill];
}
@end
