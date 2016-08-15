#import "BTUIKUnionPayVectorArtView.h"

@implementation BTUIKUnionPayVectorArtView

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
    [bezierPath moveToPoint: CGPointMake(11.8, 3.5)];
    [bezierPath addLineToPoint: CGPointMake(20.58, 3.5)];
    [bezierPath addCurveToPoint: CGPointMake(22.28, 5.73) controlPoint1: CGPointMake(21.81, 3.5) controlPoint2: CGPointMake(22.57, 4.5)];
    [bezierPath addLineToPoint: CGPointMake(18.2, 23.28)];
    [bezierPath addCurveToPoint: CGPointMake(15.45, 25.5) controlPoint1: CGPointMake(17.91, 24.5) controlPoint2: CGPointMake(16.68, 25.5)];
    [bezierPath addLineToPoint: CGPointMake(6.68, 25.5)];
    [bezierPath addCurveToPoint: CGPointMake(4.98, 23.28) controlPoint1: CGPointMake(5.45, 25.5) controlPoint2: CGPointMake(4.69, 24.5)];
    [bezierPath addLineToPoint: CGPointMake(9.06, 5.73)];
    [bezierPath addCurveToPoint: CGPointMake(11.8, 3.5) controlPoint1: CGPointMake(9.35, 4.5) controlPoint2: CGPointMake(10.58, 3.5)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    
    [fillColor17 setFill];
    [bezierPath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(19.85, 3.5)];
    [bezier2Path addLineToPoint: CGPointMake(29.95, 3.5)];
    [bezier2Path addCurveToPoint: CGPointMake(30.33, 5.73) controlPoint1: CGPointMake(31.17, 3.5) controlPoint2: CGPointMake(30.62, 4.5)];
    [bezier2Path addLineToPoint: CGPointMake(26.24, 23.28)];
    [bezier2Path addCurveToPoint: CGPointMake(24.82, 25.5) controlPoint1: CGPointMake(25.96, 24.5) controlPoint2: CGPointMake(26.05, 25.5)];
    [bezier2Path addLineToPoint: CGPointMake(14.73, 25.5)];
    [bezier2Path addCurveToPoint: CGPointMake(13.03, 23.28) controlPoint1: CGPointMake(13.5, 25.5) controlPoint2: CGPointMake(12.74, 24.5)];
    [bezier2Path addLineToPoint: CGPointMake(17.11, 5.73)];
    [bezier2Path addCurveToPoint: CGPointMake(19.85, 3.5) controlPoint1: CGPointMake(17.4, 4.5) controlPoint2: CGPointMake(18.62, 3.5)];
    [bezier2Path closePath];
    bezier2Path.usesEvenOddFillRule = YES;
    
    [fillColor18 setFill];
    [bezier2Path fill];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(29.55, 3.5)];
    [bezier3Path addLineToPoint: CGPointMake(38.32, 3.5)];
    [bezier3Path addCurveToPoint: CGPointMake(40.02, 5.73) controlPoint1: CGPointMake(39.55, 3.5) controlPoint2: CGPointMake(40.31, 4.5)];
    [bezier3Path addLineToPoint: CGPointMake(35.94, 23.28)];
    [bezier3Path addCurveToPoint: CGPointMake(33.19, 25.5) controlPoint1: CGPointMake(35.65, 24.5) controlPoint2: CGPointMake(34.42, 25.5)];
    [bezier3Path addLineToPoint: CGPointMake(24.42, 25.5)];
    [bezier3Path addCurveToPoint: CGPointMake(22.72, 23.28) controlPoint1: CGPointMake(23.19, 25.5) controlPoint2: CGPointMake(22.43, 24.5)];
    [bezier3Path addLineToPoint: CGPointMake(26.81, 5.73)];
    [bezier3Path addCurveToPoint: CGPointMake(29.55, 3.5) controlPoint1: CGPointMake(27.09, 4.5) controlPoint2: CGPointMake(28.32, 3.5)];
    [bezier3Path closePath];
    bezier3Path.usesEvenOddFillRule = YES;
    
    [fillColor19 setFill];
    [bezier3Path fill];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(29.35, 17.18)];
    [bezier4Path addCurveToPoint: CGPointMake(28.88, 17.36) controlPoint1: CGPointMake(29.19, 17.22) controlPoint2: CGPointMake(28.88, 17.36)];
    [bezier4Path addLineToPoint: CGPointMake(29.15, 16.46)];
    [bezier4Path addLineToPoint: CGPointMake(29.98, 16.46)];
    [bezier4Path addLineToPoint: CGPointMake(29.78, 17.11)];
    [bezier4Path addCurveToPoint: CGPointMake(29.35, 17.18) controlPoint1: CGPointMake(29.78, 17.11) controlPoint2: CGPointMake(29.53, 17.13)];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(29.37, 18.47)];
    [bezier4Path addCurveToPoint: CGPointMake(28.94, 18.54) controlPoint1: CGPointMake(29.37, 18.47) controlPoint2: CGPointMake(29.11, 18.5)];
    [bezier4Path addCurveToPoint: CGPointMake(28.46, 18.75) controlPoint1: CGPointMake(28.77, 18.59) controlPoint2: CGPointMake(28.46, 18.75)];
    [bezier4Path addLineToPoint: CGPointMake(28.74, 17.81)];
    [bezier4Path addLineToPoint: CGPointMake(29.57, 17.81)];
    [bezier4Path addLineToPoint: CGPointMake(29.37, 18.47)];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(28.91, 20.01)];
    [bezier4Path addLineToPoint: CGPointMake(28.08, 20.01)];
    [bezier4Path addLineToPoint: CGPointMake(28.32, 19.21)];
    [bezier4Path addLineToPoint: CGPointMake(29.15, 19.21)];
    [bezier4Path addLineToPoint: CGPointMake(28.91, 20.01)];
    [bezier4Path closePath];
    [bezier4Path moveToPoint: CGPointMake(30.2, 20)];
    [bezier4Path addLineToPoint: CGPointMake(29.91, 20)];
    [bezier4Path addLineToPoint: CGPointMake(30.98, 16.46)];
    [bezier4Path addLineToPoint: CGPointMake(31.34, 16.46)];
    [bezier4Path addLineToPoint: CGPointMake(31.45, 16.09)];
    [bezier4Path addLineToPoint: CGPointMake(31.46, 16.5)];
    [bezier4Path addCurveToPoint: CGPointMake(32.17, 16.93) controlPoint1: CGPointMake(31.45, 16.75) controlPoint2: CGPointMake(31.65, 16.97)];
    [bezier4Path addLineToPoint: CGPointMake(32.76, 16.93)];
    [bezier4Path addLineToPoint: CGPointMake(32.97, 16.25)];
    [bezier4Path addLineToPoint: CGPointMake(32.74, 16.25)];
    [bezier4Path addCurveToPoint: CGPointMake(32.56, 16.15) controlPoint1: CGPointMake(32.62, 16.25) controlPoint2: CGPointMake(32.56, 16.22)];
    [bezier4Path addLineToPoint: CGPointMake(32.55, 15.73)];
    [bezier4Path addLineToPoint: CGPointMake(31.44, 15.73)];
    [bezier4Path addLineToPoint: CGPointMake(31.44, 15.74)];
    [bezier4Path addCurveToPoint: CGPointMake(29.79, 15.83) controlPoint1: CGPointMake(31.08, 15.74) controlPoint2: CGPointMake(30.01, 15.77)];
    [bezier4Path addCurveToPoint: CGPointMake(29.26, 16.1) controlPoint1: CGPointMake(29.53, 15.9) controlPoint2: CGPointMake(29.26, 16.1)];
    [bezier4Path addLineToPoint: CGPointMake(29.36, 15.73)];
    [bezier4Path addLineToPoint: CGPointMake(28.32, 15.73)];
    [bezier4Path addLineToPoint: CGPointMake(28.11, 16.46)];
    [bezier4Path addLineToPoint: CGPointMake(27.02, 20.05)];
    [bezier4Path addLineToPoint: CGPointMake(26.81, 20.05)];
    [bezier4Path addLineToPoint: CGPointMake(26.61, 20.73)];
    [bezier4Path addLineToPoint: CGPointMake(28.68, 20.73)];
    [bezier4Path addLineToPoint: CGPointMake(28.61, 20.95)];
    [bezier4Path addLineToPoint: CGPointMake(29.62, 20.95)];
    [bezier4Path addLineToPoint: CGPointMake(29.69, 20.73)];
    [bezier4Path addLineToPoint: CGPointMake(29.98, 20.73)];
    [bezier4Path addLineToPoint: CGPointMake(30.2, 20)];
    [bezier4Path closePath];
    bezier4Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier4Path fill];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(30.9, 17.81)];
    [bezier5Path addLineToPoint: CGPointMake(32.09, 17.81)];
    [bezier5Path addLineToPoint: CGPointMake(31.92, 18.36)];
    [bezier5Path addLineToPoint: CGPointMake(30.71, 18.36)];
    [bezier5Path addLineToPoint: CGPointMake(30.53, 18.97)];
    [bezier5Path addLineToPoint: CGPointMake(31.59, 18.97)];
    [bezier5Path addLineToPoint: CGPointMake(30.79, 20.1)];
    [bezier5Path addCurveToPoint: CGPointMake(30.63, 20.23) controlPoint1: CGPointMake(30.73, 20.18) controlPoint2: CGPointMake(30.68, 20.21)];
    [bezier5Path addCurveToPoint: CGPointMake(30.41, 20.29) controlPoint1: CGPointMake(30.57, 20.26) controlPoint2: CGPointMake(30.49, 20.29)];
    [bezier5Path addLineToPoint: CGPointMake(30.12, 20.29)];
    [bezier5Path addLineToPoint: CGPointMake(29.92, 20.96)];
    [bezier5Path addLineToPoint: CGPointMake(30.68, 20.96)];
    [bezier5Path addCurveToPoint: CGPointMake(31.49, 20.54) controlPoint1: CGPointMake(31.08, 20.96) controlPoint2: CGPointMake(31.32, 20.78)];
    [bezier5Path addLineToPoint: CGPointMake(32.04, 19.79)];
    [bezier5Path addLineToPoint: CGPointMake(32.16, 20.55)];
    [bezier5Path addCurveToPoint: CGPointMake(32.36, 20.81) controlPoint1: CGPointMake(32.18, 20.69) controlPoint2: CGPointMake(32.29, 20.78)];
    [bezier5Path addCurveToPoint: CGPointMake(32.63, 20.92) controlPoint1: CGPointMake(32.43, 20.85) controlPoint2: CGPointMake(32.51, 20.92)];
    [bezier5Path addCurveToPoint: CGPointMake(32.89, 20.94) controlPoint1: CGPointMake(32.74, 20.93) controlPoint2: CGPointMake(32.83, 20.94)];
    [bezier5Path addLineToPoint: CGPointMake(33.27, 20.94)];
    [bezier5Path addLineToPoint: CGPointMake(33.49, 20.19)];
    [bezier5Path addLineToPoint: CGPointMake(33.34, 20.19)];
    [bezier5Path addCurveToPoint: CGPointMake(33.09, 20.15) controlPoint1: CGPointMake(33.26, 20.19) controlPoint2: CGPointMake(33.11, 20.18)];
    [bezier5Path addCurveToPoint: CGPointMake(33.05, 19.99) controlPoint1: CGPointMake(33.06, 20.12) controlPoint2: CGPointMake(33.06, 20.07)];
    [bezier5Path addLineToPoint: CGPointMake(32.93, 19.23)];
    [bezier5Path addLineToPoint: CGPointMake(32.44, 19.23)];
    [bezier5Path addLineToPoint: CGPointMake(32.65, 18.97)];
    [bezier5Path addLineToPoint: CGPointMake(33.86, 18.97)];
    [bezier5Path addLineToPoint: CGPointMake(34.04, 18.36)];
    [bezier5Path addLineToPoint: CGPointMake(32.93, 18.36)];
    [bezier5Path addLineToPoint: CGPointMake(33.1, 17.81)];
    [bezier5Path addLineToPoint: CGPointMake(34.21, 17.81)];
    [bezier5Path addLineToPoint: CGPointMake(34.42, 17.12)];
    [bezier5Path addLineToPoint: CGPointMake(31.1, 17.12)];
    [bezier5Path addLineToPoint: CGPointMake(30.9, 17.81)];
    [bezier5Path closePath];
    bezier5Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier5Path fill];
    
    
    //// Bezier 6 Drawing
    UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
    [bezier6Path moveToPoint: CGPointMake(20.83, 20.16)];
    [bezier6Path addLineToPoint: CGPointMake(21.11, 19.23)];
    [bezier6Path addLineToPoint: CGPointMake(22.25, 19.23)];
    [bezier6Path addLineToPoint: CGPointMake(22.46, 18.54)];
    [bezier6Path addLineToPoint: CGPointMake(21.31, 18.54)];
    [bezier6Path addLineToPoint: CGPointMake(21.49, 17.98)];
    [bezier6Path addLineToPoint: CGPointMake(22.61, 17.98)];
    [bezier6Path addLineToPoint: CGPointMake(22.81, 17.31)];
    [bezier6Path addLineToPoint: CGPointMake(20.02, 17.31)];
    [bezier6Path addLineToPoint: CGPointMake(19.81, 17.98)];
    [bezier6Path addLineToPoint: CGPointMake(20.45, 17.98)];
    [bezier6Path addLineToPoint: CGPointMake(20.28, 18.54)];
    [bezier6Path addLineToPoint: CGPointMake(19.64, 18.54)];
    [bezier6Path addLineToPoint: CGPointMake(19.43, 19.24)];
    [bezier6Path addLineToPoint: CGPointMake(20.06, 19.24)];
    [bezier6Path addLineToPoint: CGPointMake(19.69, 20.47)];
    [bezier6Path addCurveToPoint: CGPointMake(19.76, 20.77) controlPoint1: CGPointMake(19.65, 20.63) controlPoint2: CGPointMake(19.72, 20.69)];
    [bezier6Path addCurveToPoint: CGPointMake(19.97, 20.92) controlPoint1: CGPointMake(19.81, 20.84) controlPoint2: CGPointMake(19.86, 20.89)];
    [bezier6Path addCurveToPoint: CGPointMake(20.26, 20.96) controlPoint1: CGPointMake(20.08, 20.94) controlPoint2: CGPointMake(20.16, 20.96)];
    [bezier6Path addLineToPoint: CGPointMake(21.55, 20.96)];
    [bezier6Path addLineToPoint: CGPointMake(21.78, 20.2)];
    [bezier6Path addLineToPoint: CGPointMake(21.21, 20.28)];
    [bezier6Path addCurveToPoint: CGPointMake(20.83, 20.16) controlPoint1: CGPointMake(21.1, 20.28) controlPoint2: CGPointMake(20.79, 20.26)];
    [bezier6Path closePath];
    bezier6Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier6Path fill];
    
    
    //// Bezier 7 Drawing
    UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
    [bezier7Path moveToPoint: CGPointMake(20.96, 15.73)];
    [bezier7Path addLineToPoint: CGPointMake(20.67, 16.25)];
    [bezier7Path addCurveToPoint: CGPointMake(20.5, 16.47) controlPoint1: CGPointMake(20.61, 16.37) controlPoint2: CGPointMake(20.55, 16.44)];
    [bezier7Path addCurveToPoint: CGPointMake(20.24, 16.51) controlPoint1: CGPointMake(20.46, 16.5) controlPoint2: CGPointMake(20.37, 16.51)];
    [bezier7Path addLineToPoint: CGPointMake(20.09, 16.51)];
    [bezier7Path addLineToPoint: CGPointMake(19.89, 17.18)];
    [bezier7Path addLineToPoint: CGPointMake(20.39, 17.18)];
    [bezier7Path addCurveToPoint: CGPointMake(20.91, 17.05) controlPoint1: CGPointMake(20.63, 17.18) controlPoint2: CGPointMake(20.82, 17.09)];
    [bezier7Path addCurveToPoint: CGPointMake(21.1, 16.95) controlPoint1: CGPointMake(21, 16.99) controlPoint2: CGPointMake(21.03, 17.02)];
    [bezier7Path addLineToPoint: CGPointMake(21.27, 16.81)];
    [bezier7Path addLineToPoint: CGPointMake(22.84, 16.81)];
    [bezier7Path addLineToPoint: CGPointMake(23.05, 16.11)];
    [bezier7Path addLineToPoint: CGPointMake(21.9, 16.11)];
    [bezier7Path addLineToPoint: CGPointMake(22.1, 15.73)];
    [bezier7Path addLineToPoint: CGPointMake(20.96, 15.73)];
    [bezier7Path closePath];
    bezier7Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier7Path fill];
    
    
    //// Bezier 8 Drawing
    UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
    [bezier8Path moveToPoint: CGPointMake(24.01, 17.55)];
    [bezier8Path addLineToPoint: CGPointMake(25.62, 17.55)];
    [bezier8Path addLineToPoint: CGPointMake(25.51, 17.87)];
    [bezier8Path addCurveToPoint: CGPointMake(25.3, 17.87) controlPoint1: CGPointMake(25.5, 17.87) controlPoint2: CGPointMake(25.46, 17.85)];
    [bezier8Path addLineToPoint: CGPointMake(23.91, 17.87)];
    [bezier8Path addLineToPoint: CGPointMake(24.01, 17.55)];
    [bezier8Path closePath];
    [bezier8Path moveToPoint: CGPointMake(24.33, 16.48)];
    [bezier8Path addLineToPoint: CGPointMake(25.95, 16.48)];
    [bezier8Path addLineToPoint: CGPointMake(25.83, 16.86)];
    [bezier8Path addCurveToPoint: CGPointMake(24.95, 16.88) controlPoint1: CGPointMake(25.83, 16.86) controlPoint2: CGPointMake(25.07, 16.85)];
    [bezier8Path addCurveToPoint: CGPointMake(24.1, 17.26) controlPoint1: CGPointMake(24.41, 16.97) controlPoint2: CGPointMake(24.1, 17.26)];
    [bezier8Path addLineToPoint: CGPointMake(24.33, 16.48)];
    [bezier8Path closePath];
    [bezier8Path moveToPoint: CGPointMake(23.27, 20.17)];
    [bezier8Path addCurveToPoint: CGPointMake(23.31, 19.93) controlPoint1: CGPointMake(23.25, 20.13) controlPoint2: CGPointMake(23.27, 20.07)];
    [bezier8Path addLineToPoint: CGPointMake(23.74, 18.51)];
    [bezier8Path addLineToPoint: CGPointMake(25.26, 18.51)];
    [bezier8Path addCurveToPoint: CGPointMake(25.75, 18.49) controlPoint1: CGPointMake(25.48, 18.5) controlPoint2: CGPointMake(25.64, 18.5)];
    [bezier8Path addCurveToPoint: CGPointMake(26.12, 18.37) controlPoint1: CGPointMake(25.86, 18.48) controlPoint2: CGPointMake(25.98, 18.44)];
    [bezier8Path addCurveToPoint: CGPointMake(26.38, 18.12) controlPoint1: CGPointMake(26.25, 18.29) controlPoint2: CGPointMake(26.32, 18.22)];
    [bezier8Path addCurveToPoint: CGPointMake(26.65, 17.53) controlPoint1: CGPointMake(26.45, 18.03) controlPoint2: CGPointMake(26.55, 17.83)];
    [bezier8Path addLineToPoint: CGPointMake(27.18, 15.73)];
    [bezier8Path addLineToPoint: CGPointMake(25.6, 15.74)];
    [bezier8Path addCurveToPoint: CGPointMake(24.9, 15.89) controlPoint1: CGPointMake(25.6, 15.74) controlPoint2: CGPointMake(25.11, 15.81)];
    [bezier8Path addCurveToPoint: CGPointMake(24.37, 16.23) controlPoint1: CGPointMake(24.68, 15.98) controlPoint2: CGPointMake(24.37, 16.23)];
    [bezier8Path addLineToPoint: CGPointMake(24.52, 15.73)];
    [bezier8Path addLineToPoint: CGPointMake(23.54, 15.73)];
    [bezier8Path addLineToPoint: CGPointMake(22.17, 20.28)];
    [bezier8Path addCurveToPoint: CGPointMake(22.08, 20.66) controlPoint1: CGPointMake(22.12, 20.45) controlPoint2: CGPointMake(22.09, 20.58)];
    [bezier8Path addCurveToPoint: CGPointMake(22.26, 20.88) controlPoint1: CGPointMake(22.08, 20.74) controlPoint2: CGPointMake(22.19, 20.82)];
    [bezier8Path addCurveToPoint: CGPointMake(22.57, 20.94) controlPoint1: CGPointMake(22.34, 20.94) controlPoint2: CGPointMake(22.46, 20.94)];
    [bezier8Path addCurveToPoint: CGPointMake(23.11, 20.96) controlPoint1: CGPointMake(22.7, 20.95) controlPoint2: CGPointMake(22.87, 20.96)];
    [bezier8Path addLineToPoint: CGPointMake(23.86, 20.96)];
    [bezier8Path addLineToPoint: CGPointMake(24.09, 20.18)];
    [bezier8Path addLineToPoint: CGPointMake(23.42, 20.24)];
    [bezier8Path addCurveToPoint: CGPointMake(23.27, 20.17) controlPoint1: CGPointMake(23.35, 20.24) controlPoint2: CGPointMake(23.3, 20.21)];
    [bezier8Path closePath];
    bezier8Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier8Path fill];
    
    
    //// Bezier 9 Drawing
    UIBezierPath* bezier9Path = [UIBezierPath bezierPath];
    [bezier9Path moveToPoint: CGPointMake(25.55, 18.94)];
    [bezier9Path addCurveToPoint: CGPointMake(25.49, 19.03) controlPoint1: CGPointMake(25.54, 18.98) controlPoint2: CGPointMake(25.51, 19.01)];
    [bezier9Path addCurveToPoint: CGPointMake(25.32, 19.06) controlPoint1: CGPointMake(25.45, 19.06) controlPoint2: CGPointMake(25.4, 19.06)];
    [bezier9Path addLineToPoint: CGPointMake(25.09, 19.06)];
    [bezier9Path addLineToPoint: CGPointMake(25.11, 18.68)];
    [bezier9Path addLineToPoint: CGPointMake(24.16, 18.68)];
    [bezier9Path addLineToPoint: CGPointMake(24.12, 20.58)];
    [bezier9Path addCurveToPoint: CGPointMake(24.23, 20.85) controlPoint1: CGPointMake(24.12, 20.71) controlPoint2: CGPointMake(24.13, 20.79)];
    [bezier9Path addCurveToPoint: CGPointMake(25.06, 20.94) controlPoint1: CGPointMake(24.33, 20.94) controlPoint2: CGPointMake(24.64, 20.94)];
    [bezier9Path addLineToPoint: CGPointMake(25.65, 20.94)];
    [bezier9Path addLineToPoint: CGPointMake(25.87, 20.23)];
    [bezier9Path addLineToPoint: CGPointMake(25.35, 20.26)];
    [bezier9Path addLineToPoint: CGPointMake(25.18, 20.27)];
    [bezier9Path addCurveToPoint: CGPointMake(25.1, 20.23) controlPoint1: CGPointMake(25.15, 20.26) controlPoint2: CGPointMake(25.13, 20.25)];
    [bezier9Path addCurveToPoint: CGPointMake(25.05, 20.08) controlPoint1: CGPointMake(25.08, 20.21) controlPoint2: CGPointMake(25.05, 20.22)];
    [bezier9Path addLineToPoint: CGPointMake(25.06, 19.59)];
    [bezier9Path addLineToPoint: CGPointMake(25.6, 19.57)];
    [bezier9Path addCurveToPoint: CGPointMake(26.13, 19.39) controlPoint1: CGPointMake(25.89, 19.57) controlPoint2: CGPointMake(26.02, 19.48)];
    [bezier9Path addCurveToPoint: CGPointMake(26.3, 19.06) controlPoint1: CGPointMake(26.23, 19.3) controlPoint2: CGPointMake(26.26, 19.2)];
    [bezier9Path addLineToPoint: CGPointMake(26.39, 18.63)];
    [bezier9Path addLineToPoint: CGPointMake(25.64, 18.63)];
    [bezier9Path addLineToPoint: CGPointMake(25.55, 18.94)];
    [bezier9Path closePath];
    bezier9Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier9Path fill];
    
    
    //// Bezier 10 Drawing
    UIBezierPath* bezier10Path = [UIBezierPath bezierPath];
    [bezier10Path moveToPoint: CGPointMake(14.09, 9.12)];
    [bezier10Path addCurveToPoint: CGPointMake(12.84, 9.1) controlPoint1: CGPointMake(13.19, 9.13) controlPoint2: CGPointMake(12.93, 9.12)];
    [bezier10Path addCurveToPoint: CGPointMake(12.2, 12.07) controlPoint1: CGPointMake(12.81, 9.26) controlPoint2: CGPointMake(12.2, 12.07)];
    [bezier10Path addCurveToPoint: CGPointMake(11.65, 13.31) controlPoint1: CGPointMake(12.07, 12.64) controlPoint2: CGPointMake(11.97, 13.05)];
    [bezier10Path addCurveToPoint: CGPointMake(11, 13.53) controlPoint1: CGPointMake(11.46, 13.46) controlPoint2: CGPointMake(11.25, 13.53)];
    [bezier10Path addCurveToPoint: CGPointMake(10.33, 12.96) controlPoint1: CGPointMake(10.6, 13.53) controlPoint2: CGPointMake(10.37, 13.33)];
    [bezier10Path addLineToPoint: CGPointMake(10.32, 12.83)];
    [bezier10Path addCurveToPoint: CGPointMake(10.44, 12.06) controlPoint1: CGPointMake(10.32, 12.83) controlPoint2: CGPointMake(10.44, 12.06)];
    [bezier10Path addCurveToPoint: CGPointMake(11.19, 9.16) controlPoint1: CGPointMake(10.44, 12.06) controlPoint2: CGPointMake(11.08, 9.5)];
    [bezier10Path addCurveToPoint: CGPointMake(11.2, 9.12) controlPoint1: CGPointMake(11.2, 9.14) controlPoint2: CGPointMake(11.2, 9.13)];
    [bezier10Path addCurveToPoint: CGPointMake(9.72, 9.1) controlPoint1: CGPointMake(9.96, 9.13) controlPoint2: CGPointMake(9.74, 9.12)];
    [bezier10Path addCurveToPoint: CGPointMake(9.68, 9.29) controlPoint1: CGPointMake(9.72, 9.13) controlPoint2: CGPointMake(9.68, 9.29)];
    [bezier10Path addLineToPoint: CGPointMake(9.03, 12.17)];
    [bezier10Path addLineToPoint: CGPointMake(8.97, 12.42)];
    [bezier10Path addLineToPoint: CGPointMake(8.87, 13.22)];
    [bezier10Path addCurveToPoint: CGPointMake(9.01, 13.82) controlPoint1: CGPointMake(8.87, 13.46) controlPoint2: CGPointMake(8.91, 13.65)];
    [bezier10Path addCurveToPoint: CGPointMake(10.63, 14.41) controlPoint1: CGPointMake(9.3, 14.34) controlPoint2: CGPointMake(10.15, 14.41)];
    [bezier10Path addCurveToPoint: CGPointMake(12.22, 14.04) controlPoint1: CGPointMake(11.25, 14.41) controlPoint2: CGPointMake(11.83, 14.28)];
    [bezier10Path addCurveToPoint: CGPointMake(13.24, 12.45) controlPoint1: CGPointMake(12.9, 13.64) controlPoint2: CGPointMake(13.08, 13.01)];
    [bezier10Path addLineToPoint: CGPointMake(13.31, 12.17)];
    [bezier10Path addCurveToPoint: CGPointMake(14.09, 9.16) controlPoint1: CGPointMake(13.31, 12.17) controlPoint2: CGPointMake(13.97, 9.51)];
    [bezier10Path addCurveToPoint: CGPointMake(14.09, 9.12) controlPoint1: CGPointMake(14.09, 9.14) controlPoint2: CGPointMake(14.09, 9.13)];
    [bezier10Path closePath];
    bezier10Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier10Path fill];
    
    
    //// Bezier 11 Drawing
    UIBezierPath* bezier11Path = [UIBezierPath bezierPath];
    [bezier11Path moveToPoint: CGPointMake(16.34, 11.27)];
    [bezier11Path addCurveToPoint: CGPointMake(15.63, 11.43) controlPoint1: CGPointMake(16.18, 11.27) controlPoint2: CGPointMake(15.89, 11.31)];
    [bezier11Path addCurveToPoint: CGPointMake(15.35, 11.6) controlPoint1: CGPointMake(15.53, 11.48) controlPoint2: CGPointMake(15.44, 11.54)];
    [bezier11Path addLineToPoint: CGPointMake(15.43, 11.29)];
    [bezier11Path addLineToPoint: CGPointMake(15.39, 11.24)];
    [bezier11Path addCurveToPoint: CGPointMake(14.2, 11.43) controlPoint1: CGPointMake(14.83, 11.35) controlPoint2: CGPointMake(14.71, 11.36)];
    [bezier11Path addLineToPoint: CGPointMake(14.16, 11.46)];
    [bezier11Path addCurveToPoint: CGPointMake(13.83, 13.29) controlPoint1: CGPointMake(14.1, 11.96) controlPoint2: CGPointMake(14.05, 12.33)];
    [bezier11Path addCurveToPoint: CGPointMake(13.57, 14.36) controlPoint1: CGPointMake(13.74, 13.65) controlPoint2: CGPointMake(13.66, 14.01)];
    [bezier11Path addLineToPoint: CGPointMake(13.59, 14.41)];
    [bezier11Path addCurveToPoint: CGPointMake(14.73, 14.39) controlPoint1: CGPointMake(14.12, 14.38) controlPoint2: CGPointMake(14.27, 14.38)];
    [bezier11Path addLineToPoint: CGPointMake(14.77, 14.35)];
    [bezier11Path addCurveToPoint: CGPointMake(14.96, 13.38) controlPoint1: CGPointMake(14.82, 14.05) controlPoint2: CGPointMake(14.83, 13.98)];
    [bezier11Path addCurveToPoint: CGPointMake(15.21, 12.25) controlPoint1: CGPointMake(15.02, 13.1) controlPoint2: CGPointMake(15.14, 12.47)];
    [bezier11Path addCurveToPoint: CGPointMake(15.54, 12.15) controlPoint1: CGPointMake(15.32, 12.2) controlPoint2: CGPointMake(15.43, 12.15)];
    [bezier11Path addCurveToPoint: CGPointMake(15.75, 12.46) controlPoint1: CGPointMake(15.79, 12.15) controlPoint2: CGPointMake(15.76, 12.37)];
    [bezier11Path addCurveToPoint: CGPointMake(15.55, 13.51) controlPoint1: CGPointMake(15.74, 12.61) controlPoint2: CGPointMake(15.65, 13.09)];
    [bezier11Path addLineToPoint: CGPointMake(15.49, 13.78)];
    [bezier11Path addCurveToPoint: CGPointMake(15.35, 14.37) controlPoint1: CGPointMake(15.45, 13.98) controlPoint2: CGPointMake(15.4, 14.17)];
    [bezier11Path addLineToPoint: CGPointMake(15.37, 14.41)];
    [bezier11Path addCurveToPoint: CGPointMake(16.48, 14.39) controlPoint1: CGPointMake(15.89, 14.38) controlPoint2: CGPointMake(16.04, 14.38)];
    [bezier11Path addLineToPoint: CGPointMake(16.54, 14.35)];
    [bezier11Path addCurveToPoint: CGPointMake(16.78, 13.09) controlPoint1: CGPointMake(16.62, 13.88) controlPoint2: CGPointMake(16.64, 13.76)];
    [bezier11Path addLineToPoint: CGPointMake(16.85, 12.78)];
    [bezier11Path addCurveToPoint: CGPointMake(16.95, 11.62) controlPoint1: CGPointMake(16.99, 12.17) controlPoint2: CGPointMake(17.06, 11.87)];
    [bezier11Path addCurveToPoint: CGPointMake(16.34, 11.27) controlPoint1: CGPointMake(16.84, 11.34) controlPoint2: CGPointMake(16.58, 11.27)];
    [bezier11Path closePath];
    bezier11Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier11Path fill];
    
    
    //// Bezier 12 Drawing
    UIBezierPath* bezier12Path = [UIBezierPath bezierPath];
    [bezier12Path moveToPoint: CGPointMake(18.84, 11.9)];
    [bezier12Path addCurveToPoint: CGPointMake(18.22, 12.01) controlPoint1: CGPointMake(18.56, 11.96) controlPoint2: CGPointMake(18.39, 11.99)];
    [bezier12Path addCurveToPoint: CGPointMake(17.61, 12.1) controlPoint1: CGPointMake(18.05, 12.04) controlPoint2: CGPointMake(17.88, 12.06)];
    [bezier12Path addLineToPoint: CGPointMake(17.59, 12.12)];
    [bezier12Path addLineToPoint: CGPointMake(17.57, 12.14)];
    [bezier12Path addCurveToPoint: CGPointMake(17.49, 12.71) controlPoint1: CGPointMake(17.55, 12.33) controlPoint2: CGPointMake(17.52, 12.5)];
    [bezier12Path addCurveToPoint: CGPointMake(17.33, 13.49) controlPoint1: CGPointMake(17.46, 12.91) controlPoint2: CGPointMake(17.41, 13.15)];
    [bezier12Path addCurveToPoint: CGPointMake(17.21, 13.93) controlPoint1: CGPointMake(17.27, 13.75) controlPoint2: CGPointMake(17.24, 13.84)];
    [bezier12Path addCurveToPoint: CGPointMake(17.07, 14.36) controlPoint1: CGPointMake(17.17, 14.02) controlPoint2: CGPointMake(17.14, 14.11)];
    [bezier12Path addLineToPoint: CGPointMake(17.08, 14.38)];
    [bezier12Path addLineToPoint: CGPointMake(17.1, 14.41)];
    [bezier12Path addCurveToPoint: CGPointMake(17.67, 14.38) controlPoint1: CGPointMake(17.35, 14.39) controlPoint2: CGPointMake(17.51, 14.39)];
    [bezier12Path addCurveToPoint: CGPointMake(18.28, 14.39) controlPoint1: CGPointMake(17.84, 14.38) controlPoint2: CGPointMake(18.01, 14.38)];
    [bezier12Path addLineToPoint: CGPointMake(18.3, 14.37)];
    [bezier12Path addLineToPoint: CGPointMake(18.33, 14.35)];
    [bezier12Path addCurveToPoint: CGPointMake(18.39, 13.94) controlPoint1: CGPointMake(18.37, 14.12) controlPoint2: CGPointMake(18.37, 14.05)];
    [bezier12Path addCurveToPoint: CGPointMake(18.56, 13.21) controlPoint1: CGPointMake(18.42, 13.82) controlPoint2: CGPointMake(18.46, 13.66)];
    [bezier12Path addCurveToPoint: CGPointMake(18.7, 12.58) controlPoint1: CGPointMake(18.6, 13) controlPoint2: CGPointMake(18.66, 12.79)];
    [bezier12Path addCurveToPoint: CGPointMake(18.86, 11.95) controlPoint1: CGPointMake(18.75, 12.37) controlPoint2: CGPointMake(18.81, 12.16)];
    [bezier12Path addLineToPoint: CGPointMake(18.85, 11.93)];
    [bezier12Path addLineToPoint: CGPointMake(18.84, 11.9)];
    [bezier12Path closePath];
    bezier12Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier12Path fill];
    
    
    //// Bezier 13 Drawing
    UIBezierPath* bezier13Path = [UIBezierPath bezierPath];
    [bezier13Path moveToPoint: CGPointMake(20.31, 12.93)];
    [bezier13Path addCurveToPoint: CGPointMake(20.92, 11.98) controlPoint1: CGPointMake(20.43, 12.41) controlPoint2: CGPointMake(20.57, 11.98)];
    [bezier13Path addCurveToPoint: CGPointMake(21.09, 12.82) controlPoint1: CGPointMake(21.19, 11.98) controlPoint2: CGPointMake(21.21, 12.3)];
    [bezier13Path addCurveToPoint: CGPointMake(20.83, 13.54) controlPoint1: CGPointMake(21.07, 12.93) controlPoint2: CGPointMake(20.97, 13.36)];
    [bezier13Path addCurveToPoint: CGPointMake(20.5, 13.75) controlPoint1: CGPointMake(20.74, 13.67) controlPoint2: CGPointMake(20.62, 13.75)];
    [bezier13Path addCurveToPoint: CGPointMake(20.24, 13.43) controlPoint1: CGPointMake(20.46, 13.75) controlPoint2: CGPointMake(20.25, 13.75)];
    [bezier13Path addCurveToPoint: CGPointMake(20.31, 12.93) controlPoint1: CGPointMake(20.24, 13.27) controlPoint2: CGPointMake(20.27, 13.1)];
    [bezier13Path closePath];
    [bezier13Path moveToPoint: CGPointMake(20.35, 14.45)];
    [bezier13Path addCurveToPoint: CGPointMake(21.76, 13.9) controlPoint1: CGPointMake(20.85, 14.45) controlPoint2: CGPointMake(21.37, 14.31)];
    [bezier13Path addCurveToPoint: CGPointMake(22.24, 12.87) controlPoint1: CGPointMake(22.06, 13.57) controlPoint2: CGPointMake(22.2, 13.07)];
    [bezier13Path addCurveToPoint: CGPointMake(22.13, 11.68) controlPoint1: CGPointMake(22.4, 12.19) controlPoint2: CGPointMake(22.28, 11.87)];
    [bezier13Path addCurveToPoint: CGPointMake(21.07, 11.29) controlPoint1: CGPointMake(21.9, 11.38) controlPoint2: CGPointMake(21.49, 11.29)];
    [bezier13Path addCurveToPoint: CGPointMake(19.74, 11.75) controlPoint1: CGPointMake(20.82, 11.29) controlPoint2: CGPointMake(20.21, 11.31)];
    [bezier13Path addCurveToPoint: CGPointMake(19.15, 12.9) controlPoint1: CGPointMake(19.4, 12.06) controlPoint2: CGPointMake(19.25, 12.49)];
    [bezier13Path addCurveToPoint: CGPointMake(19.64, 14.34) controlPoint1: CGPointMake(19.06, 13.31) controlPoint2: CGPointMake(18.95, 14.06)];
    [bezier13Path addCurveToPoint: CGPointMake(20.35, 14.45) controlPoint1: CGPointMake(19.85, 14.43) controlPoint2: CGPointMake(20.15, 14.45)];
    [bezier13Path closePath];
    bezier13Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier13Path fill];
    
    
    //// Bezier 14 Drawing
    UIBezierPath* bezier14Path = [UIBezierPath bezierPath];
    [bezier14Path moveToPoint: CGPointMake(31.36, 12.98)];
    [bezier14Path addCurveToPoint: CGPointMake(31.96, 12.05) controlPoint1: CGPointMake(31.48, 12.48) controlPoint2: CGPointMake(31.61, 12.05)];
    [bezier14Path addCurveToPoint: CGPointMake(32.28, 12.6) controlPoint1: CGPointMake(32.18, 12.05) controlPoint2: CGPointMake(32.3, 12.25)];
    [bezier14Path addCurveToPoint: CGPointMake(32.21, 12.88) controlPoint1: CGPointMake(32.26, 12.69) controlPoint2: CGPointMake(32.24, 12.78)];
    [bezier14Path addCurveToPoint: CGPointMake(32.09, 13.36) controlPoint1: CGPointMake(32.18, 13.05) controlPoint2: CGPointMake(32.13, 13.2)];
    [bezier14Path addCurveToPoint: CGPointMake(31.97, 13.59) controlPoint1: CGPointMake(32.06, 13.45) controlPoint2: CGPointMake(32.02, 13.54)];
    [bezier14Path addCurveToPoint: CGPointMake(31.55, 13.8) controlPoint1: CGPointMake(31.88, 13.72) controlPoint2: CGPointMake(31.67, 13.8)];
    [bezier14Path addCurveToPoint: CGPointMake(31.29, 13.48) controlPoint1: CGPointMake(31.51, 13.8) controlPoint2: CGPointMake(31.29, 13.8)];
    [bezier14Path addCurveToPoint: CGPointMake(31.36, 12.98) controlPoint1: CGPointMake(31.28, 13.32) controlPoint2: CGPointMake(31.32, 13.16)];
    [bezier14Path closePath];
    [bezier14Path moveToPoint: CGPointMake(30.2, 12.95)];
    [bezier14Path addCurveToPoint: CGPointMake(30.68, 14.38) controlPoint1: CGPointMake(30.11, 13.36) controlPoint2: CGPointMake(30, 14.11)];
    [bezier14Path addCurveToPoint: CGPointMake(31.29, 14.49) controlPoint1: CGPointMake(30.9, 14.47) controlPoint2: CGPointMake(31.09, 14.5)];
    [bezier14Path addCurveToPoint: CGPointMake(31.88, 14.22) controlPoint1: CGPointMake(31.5, 14.48) controlPoint2: CGPointMake(31.7, 14.37)];
    [bezier14Path addCurveToPoint: CGPointMake(31.83, 14.41) controlPoint1: CGPointMake(31.86, 14.28) controlPoint2: CGPointMake(31.84, 14.34)];
    [bezier14Path addLineToPoint: CGPointMake(31.86, 14.45)];
    [bezier14Path addCurveToPoint: CGPointMake(33.04, 14.43) controlPoint1: CGPointMake(32.35, 14.43) controlPoint2: CGPointMake(32.51, 14.43)];
    [bezier14Path addLineToPoint: CGPointMake(33.09, 14.39)];
    [bezier14Path addCurveToPoint: CGPointMake(33.44, 12.62) controlPoint1: CGPointMake(33.16, 13.94) controlPoint2: CGPointMake(33.24, 13.49)];
    [bezier14Path addCurveToPoint: CGPointMake(33.74, 11.36) controlPoint1: CGPointMake(33.54, 12.2) controlPoint2: CGPointMake(33.64, 11.78)];
    [bezier14Path addLineToPoint: CGPointMake(33.72, 11.32)];
    [bezier14Path addCurveToPoint: CGPointMake(32.49, 11.52) controlPoint1: CGPointMake(33.17, 11.42) controlPoint2: CGPointMake(33.02, 11.44)];
    [bezier14Path addLineToPoint: CGPointMake(32.45, 11.55)];
    [bezier14Path addCurveToPoint: CGPointMake(32.44, 11.68) controlPoint1: CGPointMake(32.45, 11.59) controlPoint2: CGPointMake(32.44, 11.64)];
    [bezier14Path addCurveToPoint: CGPointMake(32.05, 11.36) controlPoint1: CGPointMake(32.36, 11.54) controlPoint2: CGPointMake(32.24, 11.43)];
    [bezier14Path addCurveToPoint: CGPointMake(30.79, 11.81) controlPoint1: CGPointMake(31.82, 11.26) controlPoint2: CGPointMake(31.26, 11.38)];
    [bezier14Path addCurveToPoint: CGPointMake(30.2, 12.95) controlPoint1: CGPointMake(30.45, 12.13) controlPoint2: CGPointMake(30.29, 12.55)];
    [bezier14Path closePath];
    bezier14Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier14Path fill];
    
    
    //// Bezier 15 Drawing
    UIBezierPath* bezier15Path = [UIBezierPath bezierPath];
    [bezier15Path moveToPoint: CGPointMake(23.5, 14.39)];
    [bezier15Path addLineToPoint: CGPointMake(23.54, 14.35)];
    [bezier15Path addCurveToPoint: CGPointMake(23.73, 13.38) controlPoint1: CGPointMake(23.6, 14.05) controlPoint2: CGPointMake(23.61, 13.98)];
    [bezier15Path addCurveToPoint: CGPointMake(23.98, 12.25) controlPoint1: CGPointMake(23.79, 13.1) controlPoint2: CGPointMake(23.92, 12.47)];
    [bezier15Path addCurveToPoint: CGPointMake(24.32, 12.15) controlPoint1: CGPointMake(24.1, 12.2) controlPoint2: CGPointMake(24.21, 12.15)];
    [bezier15Path addCurveToPoint: CGPointMake(24.53, 12.46) controlPoint1: CGPointMake(24.57, 12.15) controlPoint2: CGPointMake(24.54, 12.37)];
    [bezier15Path addCurveToPoint: CGPointMake(24.33, 13.51) controlPoint1: CGPointMake(24.52, 12.61) controlPoint2: CGPointMake(24.43, 13.09)];
    [bezier15Path addLineToPoint: CGPointMake(24.27, 13.78)];
    [bezier15Path addCurveToPoint: CGPointMake(24.13, 14.37) controlPoint1: CGPointMake(24.22, 13.98) controlPoint2: CGPointMake(24.17, 14.17)];
    [bezier15Path addLineToPoint: CGPointMake(24.15, 14.41)];
    [bezier15Path addCurveToPoint: CGPointMake(25.26, 14.39) controlPoint1: CGPointMake(24.67, 14.38) controlPoint2: CGPointMake(24.82, 14.38)];
    [bezier15Path addLineToPoint: CGPointMake(25.31, 14.35)];
    [bezier15Path addCurveToPoint: CGPointMake(25.56, 13.09) controlPoint1: CGPointMake(25.39, 13.88) controlPoint2: CGPointMake(25.41, 13.76)];
    [bezier15Path addLineToPoint: CGPointMake(25.63, 12.78)];
    [bezier15Path addCurveToPoint: CGPointMake(25.73, 11.62) controlPoint1: CGPointMake(25.77, 12.17) controlPoint2: CGPointMake(25.84, 11.87)];
    [bezier15Path addCurveToPoint: CGPointMake(25.11, 11.27) controlPoint1: CGPointMake(25.62, 11.34) controlPoint2: CGPointMake(25.35, 11.27)];
    [bezier15Path addCurveToPoint: CGPointMake(24.4, 11.43) controlPoint1: CGPointMake(24.96, 11.27) controlPoint2: CGPointMake(24.66, 11.31)];
    [bezier15Path addCurveToPoint: CGPointMake(24.13, 11.6) controlPoint1: CGPointMake(24.31, 11.48) controlPoint2: CGPointMake(24.22, 11.54)];
    [bezier15Path addLineToPoint: CGPointMake(24.21, 11.29)];
    [bezier15Path addLineToPoint: CGPointMake(24.16, 11.24)];
    [bezier15Path addCurveToPoint: CGPointMake(22.98, 11.43) controlPoint1: CGPointMake(23.61, 11.35) controlPoint2: CGPointMake(23.49, 11.36)];
    [bezier15Path addLineToPoint: CGPointMake(22.94, 11.46)];
    [bezier15Path addCurveToPoint: CGPointMake(22.6, 13.29) controlPoint1: CGPointMake(22.87, 11.96) controlPoint2: CGPointMake(22.82, 12.32)];
    [bezier15Path addCurveToPoint: CGPointMake(22.35, 14.36) controlPoint1: CGPointMake(22.52, 13.65) controlPoint2: CGPointMake(22.43, 14.01)];
    [bezier15Path addLineToPoint: CGPointMake(22.37, 14.41)];
    [bezier15Path addCurveToPoint: CGPointMake(23.5, 14.39) controlPoint1: CGPointMake(22.89, 14.38) controlPoint2: CGPointMake(23.05, 14.38)];
    [bezier15Path closePath];
    bezier15Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier15Path fill];
    
    
    //// Bezier 16 Drawing
    UIBezierPath* bezier16Path = [UIBezierPath bezierPath];
    [bezier16Path moveToPoint: CGPointMake(27.94, 11.59)];
    [bezier16Path addCurveToPoint: CGPointMake(28.3, 10.02) controlPoint1: CGPointMake(27.94, 11.59) controlPoint2: CGPointMake(28.3, 10.01)];
    [bezier16Path addLineToPoint: CGPointMake(28.31, 9.94)];
    [bezier16Path addLineToPoint: CGPointMake(28.32, 9.87)];
    [bezier16Path addLineToPoint: CGPointMake(28.46, 9.89)];
    [bezier16Path addCurveToPoint: CGPointMake(29.23, 9.95) controlPoint1: CGPointMake(28.46, 9.89) controlPoint2: CGPointMake(29.21, 9.95)];
    [bezier16Path addCurveToPoint: CGPointMake(29.56, 10.75) controlPoint1: CGPointMake(29.53, 10.07) controlPoint2: CGPointMake(29.65, 10.36)];
    [bezier16Path addCurveToPoint: CGPointMake(28.96, 11.54) controlPoint1: CGPointMake(29.49, 11.1) controlPoint2: CGPointMake(29.26, 11.4)];
    [bezier16Path addCurveToPoint: CGPointMake(28.12, 11.67) controlPoint1: CGPointMake(28.72, 11.66) controlPoint2: CGPointMake(28.43, 11.67)];
    [bezier16Path addLineToPoint: CGPointMake(27.92, 11.67)];
    [bezier16Path addLineToPoint: CGPointMake(27.94, 11.59)];
    [bezier16Path closePath];
    [bezier16Path moveToPoint: CGPointMake(27.3, 14.41)];
    [bezier16Path addCurveToPoint: CGPointMake(27.53, 13.31) controlPoint1: CGPointMake(27.34, 14.25) controlPoint2: CGPointMake(27.53, 13.31)];
    [bezier16Path addCurveToPoint: CGPointMake(27.71, 12.59) controlPoint1: CGPointMake(27.53, 13.31) controlPoint2: CGPointMake(27.7, 12.62)];
    [bezier16Path addCurveToPoint: CGPointMake(27.81, 12.49) controlPoint1: CGPointMake(27.71, 12.59) controlPoint2: CGPointMake(27.76, 12.52)];
    [bezier16Path addLineToPoint: CGPointMake(27.89, 12.49)];
    [bezier16Path addCurveToPoint: CGPointMake(30.05, 12.02) controlPoint1: CGPointMake(28.61, 12.49) controlPoint2: CGPointMake(29.42, 12.49)];
    [bezier16Path addCurveToPoint: CGPointMake(30.91, 10.65) controlPoint1: CGPointMake(30.49, 11.7) controlPoint2: CGPointMake(30.78, 11.23)];
    [bezier16Path addCurveToPoint: CGPointMake(30.97, 10.18) controlPoint1: CGPointMake(30.95, 10.51) controlPoint2: CGPointMake(30.97, 10.34)];
    [bezier16Path addCurveToPoint: CGPointMake(30.8, 9.57) controlPoint1: CGPointMake(30.97, 9.95) controlPoint2: CGPointMake(30.93, 9.74)];
    [bezier16Path addCurveToPoint: CGPointMake(29.08, 9.1) controlPoint1: CGPointMake(30.48, 9.11) controlPoint2: CGPointMake(29.83, 9.1)];
    [bezier16Path addCurveToPoint: CGPointMake(28.72, 9.1) controlPoint1: CGPointMake(29.08, 9.1) controlPoint2: CGPointMake(28.72, 9.1)];
    [bezier16Path addCurveToPoint: CGPointMake(27.22, 9.09) controlPoint1: CGPointMake(27.76, 9.12) controlPoint2: CGPointMake(27.38, 9.11)];
    [bezier16Path addCurveToPoint: CGPointMake(27.18, 9.29) controlPoint1: CGPointMake(27.21, 9.16) controlPoint2: CGPointMake(27.18, 9.29)];
    [bezier16Path addCurveToPoint: CGPointMake(26.84, 10.87) controlPoint1: CGPointMake(27.18, 9.29) controlPoint2: CGPointMake(26.84, 10.87)];
    [bezier16Path addCurveToPoint: CGPointMake(25.99, 14.4) controlPoint1: CGPointMake(26.84, 10.87) controlPoint2: CGPointMake(26.03, 14.24)];
    [bezier16Path addCurveToPoint: CGPointMake(27.3, 14.41) controlPoint1: CGPointMake(26.82, 14.39) controlPoint2: CGPointMake(27.16, 14.39)];
    [bezier16Path closePath];
    bezier16Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier16Path fill];
    
    
    //// Bezier 17 Drawing
    UIBezierPath* bezier17Path = [UIBezierPath bezierPath];
    [bezier17Path moveToPoint: CGPointMake(37.4, 11.31)];
    [bezier17Path addLineToPoint: CGPointMake(37.36, 11.27)];
    [bezier17Path addCurveToPoint: CGPointMake(36.21, 11.46) controlPoint1: CGPointMake(36.81, 11.37) controlPoint2: CGPointMake(36.71, 11.39)];
    [bezier17Path addLineToPoint: CGPointMake(36.18, 11.5)];
    [bezier17Path addCurveToPoint: CGPointMake(36.17, 11.52) controlPoint1: CGPointMake(36.17, 11.5) controlPoint2: CGPointMake(36.17, 11.51)];
    [bezier17Path addLineToPoint: CGPointMake(36.17, 11.51)];
    [bezier17Path addCurveToPoint: CGPointMake(35.5, 12.86) controlPoint1: CGPointMake(35.79, 12.37) controlPoint2: CGPointMake(35.81, 12.19)];
    [bezier17Path addCurveToPoint: CGPointMake(35.5, 12.78) controlPoint1: CGPointMake(35.5, 12.83) controlPoint2: CGPointMake(35.5, 12.81)];
    [bezier17Path addLineToPoint: CGPointMake(35.42, 11.31)];
    [bezier17Path addLineToPoint: CGPointMake(35.38, 11.27)];
    [bezier17Path addCurveToPoint: CGPointMake(34.26, 11.46) controlPoint1: CGPointMake(34.81, 11.37) controlPoint2: CGPointMake(34.79, 11.39)];
    [bezier17Path addLineToPoint: CGPointMake(34.22, 11.5)];
    [bezier17Path addCurveToPoint: CGPointMake(34.21, 11.56) controlPoint1: CGPointMake(34.22, 11.52) controlPoint2: CGPointMake(34.22, 11.53)];
    [bezier17Path addLineToPoint: CGPointMake(34.22, 11.56)];
    [bezier17Path addCurveToPoint: CGPointMake(34.33, 12.36) controlPoint1: CGPointMake(34.28, 11.9) controlPoint2: CGPointMake(34.27, 11.82)];
    [bezier17Path addCurveToPoint: CGPointMake(34.43, 13.14) controlPoint1: CGPointMake(34.37, 12.62) controlPoint2: CGPointMake(34.41, 12.88)];
    [bezier17Path addCurveToPoint: CGPointMake(34.58, 14.44) controlPoint1: CGPointMake(34.49, 13.57) controlPoint2: CGPointMake(34.52, 13.78)];
    [bezier17Path addCurveToPoint: CGPointMake(33.8, 15.76) controlPoint1: CGPointMake(34.23, 15.03) controlPoint2: CGPointMake(34.14, 15.25)];
    [bezier17Path addLineToPoint: CGPointMake(33.8, 15.77)];
    [bezier17Path addLineToPoint: CGPointMake(33.56, 16.15)];
    [bezier17Path addCurveToPoint: CGPointMake(33.47, 16.23) controlPoint1: CGPointMake(33.53, 16.19) controlPoint2: CGPointMake(33.51, 16.22)];
    [bezier17Path addCurveToPoint: CGPointMake(33.31, 16.25) controlPoint1: CGPointMake(33.43, 16.25) controlPoint2: CGPointMake(33.38, 16.25)];
    [bezier17Path addLineToPoint: CGPointMake(33.18, 16.25)];
    [bezier17Path addLineToPoint: CGPointMake(32.98, 16.91)];
    [bezier17Path addLineToPoint: CGPointMake(33.66, 16.92)];
    [bezier17Path addCurveToPoint: CGPointMake(34.45, 16.48) controlPoint1: CGPointMake(34.06, 16.92) controlPoint2: CGPointMake(34.31, 16.74)];
    [bezier17Path addLineToPoint: CGPointMake(34.88, 15.75)];
    [bezier17Path addLineToPoint: CGPointMake(34.87, 15.75)];
    [bezier17Path addLineToPoint: CGPointMake(34.92, 15.7)];
    [bezier17Path addCurveToPoint: CGPointMake(37.4, 11.31) controlPoint1: CGPointMake(35.21, 15.08) controlPoint2: CGPointMake(37.4, 11.31)];
    [bezier17Path closePath];
    bezier17Path.usesEvenOddFillRule = YES;
    
    [fillColor20 setFill];
    [bezier17Path fill];
    
    
    //// Oval Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 18.3, 11.4);
    CGContextRotateCTM(context, -14.85 * M_PI / 180);
    
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(-0.7, -0.5, 1.4, 1)];
    [fillColor20 setFill];
    [ovalPath fill];
    
    CGContextRestoreGState(context);
}

@end
