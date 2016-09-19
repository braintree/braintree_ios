#import "BTUIKLargeDinersClubVectorArtView.h"

@implementation BTUIKLargeDinersClubVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor3 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    UIColor* fillColor4 = [UIColor colorWithRed: 0.103 green: 0.092 blue: 0.095 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(46.56, 28.36)];
    [bezierPath addCurveToPoint: CGPointMake(40.54, 19.61) controlPoint1: CGPointMake(46.55, 24.36) controlPoint2: CGPointMake(44.05, 20.96)];
    [bezierPath addLineToPoint: CGPointMake(40.54, 37.1)];
    [bezierPath addCurveToPoint: CGPointMake(46.56, 28.36) controlPoint1: CGPointMake(44.05, 35.75) controlPoint2: CGPointMake(46.55, 32.35)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(33.83, 37.1)];
    [bezierPath addLineToPoint: CGPointMake(33.83, 19.61)];
    [bezierPath addCurveToPoint: CGPointMake(27.82, 28.36) controlPoint1: CGPointMake(30.32, 20.97) controlPoint2: CGPointMake(27.82, 24.37)];
    [bezierPath addCurveToPoint: CGPointMake(33.83, 37.1) controlPoint1: CGPointMake(27.82, 32.35) controlPoint2: CGPointMake(30.32, 35.75)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(37.19, 13.57)];
    [bezierPath addCurveToPoint: CGPointMake(22.41, 28.36) controlPoint1: CGPointMake(29.02, 13.58) controlPoint2: CGPointMake(22.41, 20.19)];
    [bezierPath addCurveToPoint: CGPointMake(37.19, 43.14) controlPoint1: CGPointMake(22.41, 36.52) controlPoint2: CGPointMake(29.02, 43.13)];
    [bezierPath addCurveToPoint: CGPointMake(51.97, 28.36) controlPoint1: CGPointMake(45.35, 43.13) controlPoint2: CGPointMake(51.97, 36.52)];
    [bezierPath addCurveToPoint: CGPointMake(37.19, 13.57) controlPoint1: CGPointMake(51.97, 20.19) controlPoint2: CGPointMake(45.35, 13.58)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(37.15, 44.53)];
    [bezierPath addCurveToPoint: CGPointMake(20.86, 28.53) controlPoint1: CGPointMake(28.22, 44.57) controlPoint2: CGPointMake(20.86, 37.34)];
    [bezierPath addCurveToPoint: CGPointMake(37.15, 12.24) controlPoint1: CGPointMake(20.86, 18.9) controlPoint2: CGPointMake(28.22, 12.24)];
    [bezierPath addLineToPoint: CGPointMake(41.34, 12.24)];
    [bezierPath addCurveToPoint: CGPointMake(58.22, 28.53) controlPoint1: CGPointMake(50.16, 12.24) controlPoint2: CGPointMake(58.22, 18.89)];
    [bezierPath addCurveToPoint: CGPointMake(41.34, 44.53) controlPoint1: CGPointMake(58.22, 37.33) controlPoint2: CGPointMake(50.16, 44.53)];
    [bezierPath addLineToPoint: CGPointMake(37.15, 44.53)];
    [bezierPath closePath];
    [fillColor3 setFill];
    [bezierPath fill];
    
    
    //// Bezier 2 Drawing
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(1.61, 47.54)];
    [bezier2Path addCurveToPoint: CGPointMake(0.06, 46.1) controlPoint1: CGPointMake(1.61, 46.02) controlPoint2: CGPointMake(0.82, 46.12)];
    [bezier2Path addLineToPoint: CGPointMake(0.06, 45.66)];
    [bezier2Path addCurveToPoint: CGPointMake(2.05, 45.7) controlPoint1: CGPointMake(0.72, 45.7) controlPoint2: CGPointMake(1.39, 45.7)];
    [bezier2Path addCurveToPoint: CGPointMake(4.98, 45.66) controlPoint1: CGPointMake(2.76, 45.7) controlPoint2: CGPointMake(3.73, 45.66)];
    [bezier2Path addCurveToPoint: CGPointMake(11.75, 51.59) controlPoint1: CGPointMake(9.36, 45.66) controlPoint2: CGPointMake(11.75, 48.59)];
    [bezier2Path addCurveToPoint: CGPointMake(4.78, 57.47) controlPoint1: CGPointMake(11.75, 53.26) controlPoint2: CGPointMake(10.77, 57.47)];
    [bezier2Path addCurveToPoint: CGPointMake(2.33, 57.44) controlPoint1: CGPointMake(3.92, 57.47) controlPoint2: CGPointMake(3.12, 57.44)];
    [bezier2Path addCurveToPoint: CGPointMake(0.06, 57.47) controlPoint1: CGPointMake(1.56, 57.44) controlPoint2: CGPointMake(0.82, 57.45)];
    [bezier2Path addLineToPoint: CGPointMake(0.06, 57.03)];
    [bezier2Path addCurveToPoint: CGPointMake(1.61, 55.75) controlPoint1: CGPointMake(1.07, 56.93) controlPoint2: CGPointMake(1.56, 56.9)];
    [bezier2Path addLineToPoint: CGPointMake(1.61, 47.54)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(3.27, 55.48)];
    [bezier2Path addCurveToPoint: CGPointMake(5.03, 56.93) controlPoint1: CGPointMake(3.27, 56.78) controlPoint2: CGPointMake(4.2, 56.93)];
    [bezier2Path addCurveToPoint: CGPointMake(9.89, 51.65) controlPoint1: CGPointMake(8.69, 56.93) controlPoint2: CGPointMake(9.89, 54.17)];
    [bezier2Path addCurveToPoint: CGPointMake(4.59, 46.21) controlPoint1: CGPointMake(9.89, 48.49) controlPoint2: CGPointMake(7.86, 46.21)];
    [bezier2Path addCurveToPoint: CGPointMake(3.27, 46.27) controlPoint1: CGPointMake(3.9, 46.21) controlPoint2: CGPointMake(3.58, 46.26)];
    [bezier2Path addLineToPoint: CGPointMake(3.27, 55.48)];
    [bezier2Path closePath];
    [fillColor4 setFill];
    [bezier2Path fill];
    
    
    //// Bezier 3 Drawing
    UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
    [bezier3Path moveToPoint: CGPointMake(12.34, 57.03)];
    [bezier3Path addLineToPoint: CGPointMake(12.66, 57.03)];
    [bezier3Path addCurveToPoint: CGPointMake(13.47, 56.47) controlPoint1: CGPointMake(13.14, 57.03) controlPoint2: CGPointMake(13.47, 57.03)];
    [bezier3Path addLineToPoint: CGPointMake(13.47, 51.89)];
    [bezier3Path addCurveToPoint: CGPointMake(12.59, 50.71) controlPoint1: CGPointMake(13.47, 51.15) controlPoint2: CGPointMake(13.22, 51.04)];
    [bezier3Path addLineToPoint: CGPointMake(12.59, 50.44)];
    [bezier3Path addCurveToPoint: CGPointMake(14.4, 49.83) controlPoint1: CGPointMake(13.39, 50.2) controlPoint2: CGPointMake(14.34, 49.88)];
    [bezier3Path addCurveToPoint: CGPointMake(14.71, 49.74) controlPoint1: CGPointMake(14.52, 49.76) controlPoint2: CGPointMake(14.62, 49.74)];
    [bezier3Path addCurveToPoint: CGPointMake(14.83, 49.98) controlPoint1: CGPointMake(14.79, 49.74) controlPoint2: CGPointMake(14.83, 49.84)];
    [bezier3Path addLineToPoint: CGPointMake(14.83, 56.47)];
    [bezier3Path addCurveToPoint: CGPointMake(15.67, 57.03) controlPoint1: CGPointMake(14.83, 57.03) controlPoint2: CGPointMake(15.2, 57.03)];
    [bezier3Path addLineToPoint: CGPointMake(15.96, 57.03)];
    [bezier3Path addLineToPoint: CGPointMake(15.96, 57.47)];
    [bezier3Path addCurveToPoint: CGPointMake(14.19, 57.44) controlPoint1: CGPointMake(15.39, 57.47) controlPoint2: CGPointMake(14.79, 57.44)];
    [bezier3Path addCurveToPoint: CGPointMake(12.34, 57.47) controlPoint1: CGPointMake(13.58, 57.44) controlPoint2: CGPointMake(12.97, 57.45)];
    [bezier3Path addLineToPoint: CGPointMake(12.34, 57.03)];
    [bezier3Path closePath];
    [bezier3Path moveToPoint: CGPointMake(14.15, 47.14)];
    [bezier3Path addCurveToPoint: CGPointMake(13.32, 46.29) controlPoint1: CGPointMake(13.71, 47.14) controlPoint2: CGPointMake(13.32, 46.73)];
    [bezier3Path addCurveToPoint: CGPointMake(14.15, 45.48) controlPoint1: CGPointMake(13.32, 45.87) controlPoint2: CGPointMake(13.73, 45.48)];
    [bezier3Path addCurveToPoint: CGPointMake(14.98, 46.29) controlPoint1: CGPointMake(14.59, 45.48) controlPoint2: CGPointMake(14.98, 45.83)];
    [bezier3Path addCurveToPoint: CGPointMake(14.15, 47.14) controlPoint1: CGPointMake(14.98, 46.75) controlPoint2: CGPointMake(14.61, 47.14)];
    [bezier3Path closePath];
    [fillColor4 setFill];
    [bezier3Path fill];
    
    
    //// Bezier 4 Drawing
    UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
    [bezier4Path moveToPoint: CGPointMake(17.57, 51.99)];
    [bezier4Path addCurveToPoint: CGPointMake(16.59, 50.88) controlPoint1: CGPointMake(17.57, 51.37) controlPoint2: CGPointMake(17.38, 51.2)];
    [bezier4Path addLineToPoint: CGPointMake(16.59, 50.55)];
    [bezier4Path addCurveToPoint: CGPointMake(18.82, 49.74) controlPoint1: CGPointMake(17.31, 50.32) controlPoint2: CGPointMake(18.01, 50.1)];
    [bezier4Path addCurveToPoint: CGPointMake(18.92, 49.91) controlPoint1: CGPointMake(18.87, 49.74) controlPoint2: CGPointMake(18.92, 49.78)];
    [bezier4Path addLineToPoint: CGPointMake(18.92, 51.01)];
    [bezier4Path addCurveToPoint: CGPointMake(21.85, 49.74) controlPoint1: CGPointMake(19.89, 50.32) controlPoint2: CGPointMake(20.71, 49.74)];
    [bezier4Path addCurveToPoint: CGPointMake(23.79, 52.11) controlPoint1: CGPointMake(23.29, 49.74) controlPoint2: CGPointMake(23.79, 50.79)];
    [bezier4Path addLineToPoint: CGPointMake(23.79, 56.47)];
    [bezier4Path addCurveToPoint: CGPointMake(24.64, 57.03) controlPoint1: CGPointMake(23.79, 57.03) controlPoint2: CGPointMake(24.17, 57.03)];
    [bezier4Path addLineToPoint: CGPointMake(24.94, 57.03)];
    [bezier4Path addLineToPoint: CGPointMake(24.94, 57.47)];
    [bezier4Path addCurveToPoint: CGPointMake(23.15, 57.44) controlPoint1: CGPointMake(24.35, 57.47) controlPoint2: CGPointMake(23.76, 57.44)];
    [bezier4Path addCurveToPoint: CGPointMake(21.32, 57.47) controlPoint1: CGPointMake(22.54, 57.44) controlPoint2: CGPointMake(21.93, 57.46)];
    [bezier4Path addLineToPoint: CGPointMake(21.32, 57.03)];
    [bezier4Path addLineToPoint: CGPointMake(21.63, 57.03)];
    [bezier4Path addCurveToPoint: CGPointMake(22.44, 56.47) controlPoint1: CGPointMake(22.1, 57.03) controlPoint2: CGPointMake(22.44, 57.03)];
    [bezier4Path addLineToPoint: CGPointMake(22.44, 52.09)];
    [bezier4Path addCurveToPoint: CGPointMake(20.88, 50.66) controlPoint1: CGPointMake(22.44, 51.13) controlPoint2: CGPointMake(21.85, 50.66)];
    [bezier4Path addCurveToPoint: CGPointMake(18.92, 51.47) controlPoint1: CGPointMake(20.34, 50.66) controlPoint2: CGPointMake(19.48, 51.09)];
    [bezier4Path addLineToPoint: CGPointMake(18.92, 56.47)];
    [bezier4Path addCurveToPoint: CGPointMake(19.77, 57.03) controlPoint1: CGPointMake(18.92, 57.03) controlPoint2: CGPointMake(19.29, 57.03)];
    [bezier4Path addLineToPoint: CGPointMake(20.07, 57.03)];
    [bezier4Path addLineToPoint: CGPointMake(20.07, 57.47)];
    [bezier4Path addCurveToPoint: CGPointMake(18.28, 57.44) controlPoint1: CGPointMake(19.48, 57.47) controlPoint2: CGPointMake(18.89, 57.44)];
    [bezier4Path addCurveToPoint: CGPointMake(16.45, 57.47) controlPoint1: CGPointMake(17.67, 57.44) controlPoint2: CGPointMake(17.06, 57.46)];
    [bezier4Path addLineToPoint: CGPointMake(16.45, 57.03)];
    [bezier4Path addLineToPoint: CGPointMake(16.76, 57.03)];
    [bezier4Path addCurveToPoint: CGPointMake(17.57, 56.47) controlPoint1: CGPointMake(17.23, 57.03) controlPoint2: CGPointMake(17.57, 57.03)];
    [bezier4Path addLineToPoint: CGPointMake(17.57, 51.99)];
    [bezier4Path closePath];
    [fillColor4 setFill];
    [bezier4Path fill];
    
    
    //// Bezier 5 Drawing
    UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
    [bezier5Path moveToPoint: CGPointMake(26.23, 52.8)];
    [bezier5Path addCurveToPoint: CGPointMake(26.23, 53.79) controlPoint1: CGPointMake(26.2, 52.96) controlPoint2: CGPointMake(26.2, 53.21)];
    [bezier5Path addCurveToPoint: CGPointMake(28.71, 56.71) controlPoint1: CGPointMake(26.33, 55.39) controlPoint2: CGPointMake(27.36, 56.71)];
    [bezier5Path addCurveToPoint: CGPointMake(31, 55.58) controlPoint1: CGPointMake(29.65, 56.71) controlPoint2: CGPointMake(30.38, 56.2)];
    [bezier5Path addLineToPoint: CGPointMake(31.24, 55.82)];
    [bezier5Path addCurveToPoint: CGPointMake(28.11, 57.73) controlPoint1: CGPointMake(30.46, 56.85) controlPoint2: CGPointMake(29.49, 57.73)];
    [bezier5Path addCurveToPoint: CGPointMake(24.88, 54.04) controlPoint1: CGPointMake(25.42, 57.73) controlPoint2: CGPointMake(24.88, 55.12)];
    [bezier5Path addCurveToPoint: CGPointMake(28.29, 49.74) controlPoint1: CGPointMake(24.88, 50.72) controlPoint2: CGPointMake(27.11, 49.74)];
    [bezier5Path addCurveToPoint: CGPointMake(31.15, 52.4) controlPoint1: CGPointMake(29.66, 49.74) controlPoint2: CGPointMake(31.14, 50.6)];
    [bezier5Path addCurveToPoint: CGPointMake(31.14, 52.7) controlPoint1: CGPointMake(31.15, 52.5) controlPoint2: CGPointMake(31.15, 52.6)];
    [bezier5Path addLineToPoint: CGPointMake(30.98, 52.8)];
    [bezier5Path addLineToPoint: CGPointMake(26.23, 52.8)];
    [bezier5Path closePath];
    [bezier5Path moveToPoint: CGPointMake(29.23, 52.26)];
    [bezier5Path addCurveToPoint: CGPointMake(29.7, 51.84) controlPoint1: CGPointMake(29.65, 52.26) controlPoint2: CGPointMake(29.7, 52.04)];
    [bezier5Path addCurveToPoint: CGPointMake(28.23, 50.28) controlPoint1: CGPointMake(29.7, 50.98) controlPoint2: CGPointMake(29.17, 50.28)];
    [bezier5Path addCurveToPoint: CGPointMake(26.28, 52.26) controlPoint1: CGPointMake(27.19, 50.28) controlPoint2: CGPointMake(26.48, 51.04)];
    [bezier5Path addLineToPoint: CGPointMake(29.23, 52.26)];
    [bezier5Path closePath];
    [fillColor4 setFill];
    [bezier5Path fill];
    
    
    //// Bezier 6 Drawing
    UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
    [bezier6Path moveToPoint: CGPointMake(31.54, 57.03)];
    [bezier6Path addLineToPoint: CGPointMake(32, 57.03)];
    [bezier6Path addCurveToPoint: CGPointMake(32.81, 56.47) controlPoint1: CGPointMake(32.47, 57.03) controlPoint2: CGPointMake(32.81, 57.03)];
    [bezier6Path addLineToPoint: CGPointMake(32.81, 51.72)];
    [bezier6Path addCurveToPoint: CGPointMake(31.93, 50.96) controlPoint1: CGPointMake(32.81, 51.2) controlPoint2: CGPointMake(32.18, 51.09)];
    [bezier6Path addLineToPoint: CGPointMake(31.93, 50.71)];
    [bezier6Path addCurveToPoint: CGPointMake(34, 49.74) controlPoint1: CGPointMake(33.16, 50.18) controlPoint2: CGPointMake(33.84, 49.74)];
    [bezier6Path addCurveToPoint: CGPointMake(34.15, 49.96) controlPoint1: CGPointMake(34.1, 49.74) controlPoint2: CGPointMake(34.15, 49.79)];
    [bezier6Path addLineToPoint: CGPointMake(34.15, 51.48)];
    [bezier6Path addLineToPoint: CGPointMake(34.18, 51.48)];
    [bezier6Path addCurveToPoint: CGPointMake(36.35, 49.74) controlPoint1: CGPointMake(34.6, 50.82) controlPoint2: CGPointMake(35.31, 49.74)];
    [bezier6Path addCurveToPoint: CGPointMake(37.31, 50.64) controlPoint1: CGPointMake(36.77, 49.74) controlPoint2: CGPointMake(37.31, 50.03)];
    [bezier6Path addCurveToPoint: CGPointMake(36.52, 51.5) controlPoint1: CGPointMake(37.31, 51.09) controlPoint2: CGPointMake(36.99, 51.5)];
    [bezier6Path addCurveToPoint: CGPointMake(35.4, 51.09) controlPoint1: CGPointMake(35.99, 51.5) controlPoint2: CGPointMake(35.99, 51.09)];
    [bezier6Path addCurveToPoint: CGPointMake(34.16, 52.5) controlPoint1: CGPointMake(35.11, 51.09) controlPoint2: CGPointMake(34.16, 51.48)];
    [bezier6Path addLineToPoint: CGPointMake(34.16, 56.47)];
    [bezier6Path addCurveToPoint: CGPointMake(34.97, 57.03) controlPoint1: CGPointMake(34.16, 57.03) controlPoint2: CGPointMake(34.5, 57.03)];
    [bezier6Path addLineToPoint: CGPointMake(35.92, 57.03)];
    [bezier6Path addLineToPoint: CGPointMake(35.92, 57.47)];
    [bezier6Path addCurveToPoint: CGPointMake(33.55, 57.44) controlPoint1: CGPointMake(34.99, 57.45) controlPoint2: CGPointMake(34.28, 57.44)];
    [bezier6Path addCurveToPoint: CGPointMake(31.54, 57.47) controlPoint1: CGPointMake(32.86, 57.44) controlPoint2: CGPointMake(32.15, 57.45)];
    [bezier6Path addLineToPoint: CGPointMake(31.54, 57.03)];
    [bezier6Path closePath];
    [fillColor4 setFill];
    [bezier6Path fill];
    
    
    //// Bezier 7 Drawing
    UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
    [bezier7Path moveToPoint: CGPointMake(38.05, 55.12)];
    [bezier7Path addCurveToPoint: CGPointMake(40.19, 57.19) controlPoint1: CGPointMake(38.27, 56.24) controlPoint2: CGPointMake(38.95, 57.19)];
    [bezier7Path addCurveToPoint: CGPointMake(41.56, 55.98) controlPoint1: CGPointMake(41.18, 57.19) controlPoint2: CGPointMake(41.56, 56.58)];
    [bezier7Path addCurveToPoint: CGPointMake(37.87, 51.91) controlPoint1: CGPointMake(41.56, 53.99) controlPoint2: CGPointMake(37.87, 54.63)];
    [bezier7Path addCurveToPoint: CGPointMake(40.49, 49.74) controlPoint1: CGPointMake(37.87, 50.96) controlPoint2: CGPointMake(38.63, 49.74)];
    [bezier7Path addCurveToPoint: CGPointMake(42.42, 50.23) controlPoint1: CGPointMake(41.03, 49.74) controlPoint2: CGPointMake(41.76, 49.89)];
    [bezier7Path addLineToPoint: CGPointMake(42.54, 51.96)];
    [bezier7Path addLineToPoint: CGPointMake(42.15, 51.96)];
    [bezier7Path addCurveToPoint: CGPointMake(40.3, 50.28) controlPoint1: CGPointMake(41.98, 50.89) controlPoint2: CGPointMake(41.39, 50.28)];
    [bezier7Path addCurveToPoint: CGPointMake(38.98, 51.4) controlPoint1: CGPointMake(39.63, 50.28) controlPoint2: CGPointMake(38.98, 50.67)];
    [bezier7Path addCurveToPoint: CGPointMake(42.91, 55.43) controlPoint1: CGPointMake(38.98, 53.38) controlPoint2: CGPointMake(42.91, 52.77)];
    [bezier7Path addCurveToPoint: CGPointMake(40, 57.73) controlPoint1: CGPointMake(42.91, 56.54) controlPoint2: CGPointMake(42.01, 57.73)];
    [bezier7Path addCurveToPoint: CGPointMake(37.94, 57.15) controlPoint1: CGPointMake(39.32, 57.73) controlPoint2: CGPointMake(38.53, 57.49)];
    [bezier7Path addLineToPoint: CGPointMake(37.75, 55.21)];
    [bezier7Path addLineToPoint: CGPointMake(38.05, 55.12)];
    [bezier7Path closePath];
    [fillColor4 setFill];
    [bezier7Path fill];
    
    
    //// Bezier 8 Drawing
    UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
    [bezier8Path moveToPoint: CGPointMake(58.18, 48.73)];
    [bezier8Path addLineToPoint: CGPointMake(57.76, 48.73)];
    [bezier8Path addCurveToPoint: CGPointMake(54.14, 45.95) controlPoint1: CGPointMake(57.44, 46.75) controlPoint2: CGPointMake(56.04, 45.95)];
    [bezier8Path addCurveToPoint: CGPointMake(49.37, 51.31) controlPoint1: CGPointMake(52.19, 45.95) controlPoint2: CGPointMake(49.37, 47.25)];
    [bezier8Path addCurveToPoint: CGPointMake(54.41, 57.19) controlPoint1: CGPointMake(49.37, 54.73) controlPoint2: CGPointMake(51.81, 57.19)];
    [bezier8Path addCurveToPoint: CGPointMake(57.81, 54.26) controlPoint1: CGPointMake(56.09, 57.19) controlPoint2: CGPointMake(57.48, 56.03)];
    [bezier8Path addLineToPoint: CGPointMake(58.2, 54.36)];
    [bezier8Path addLineToPoint: CGPointMake(57.81, 56.83)];
    [bezier8Path addCurveToPoint: CGPointMake(54.07, 57.73) controlPoint1: CGPointMake(57.1, 57.27) controlPoint2: CGPointMake(55.19, 57.73)];
    [bezier8Path addCurveToPoint: CGPointMake(47.61, 51.37) controlPoint1: CGPointMake(50.12, 57.73) controlPoint2: CGPointMake(47.61, 55.17)];
    [bezier8Path addCurveToPoint: CGPointMake(54.02, 45.41) controlPoint1: CGPointMake(47.61, 47.9) controlPoint2: CGPointMake(50.71, 45.41)];
    [bezier8Path addCurveToPoint: CGPointMake(58.02, 46.31) controlPoint1: CGPointMake(55.39, 45.41) controlPoint2: CGPointMake(56.71, 45.85)];
    [bezier8Path addLineToPoint: CGPointMake(58.18, 48.73)];
    [bezier8Path closePath];
    [fillColor4 setFill];
    [bezier8Path fill];
    
    
    //// Bezier 9 Drawing
    UIBezierPath* bezier9Path = [UIBezierPath bezierPath];
    [bezier9Path moveToPoint: CGPointMake(58.79, 57.03)];
    [bezier9Path addLineToPoint: CGPointMake(59.11, 57.03)];
    [bezier9Path addCurveToPoint: CGPointMake(59.93, 56.47) controlPoint1: CGPointMake(59.59, 57.03) controlPoint2: CGPointMake(59.93, 57.03)];
    [bezier9Path addLineToPoint: CGPointMake(59.93, 47.05)];
    [bezier9Path addCurveToPoint: CGPointMake(59.03, 45.73) controlPoint1: CGPointMake(59.93, 45.95) controlPoint2: CGPointMake(59.67, 45.92)];
    [bezier9Path addLineToPoint: CGPointMake(59.03, 45.46)];
    [bezier9Path addCurveToPoint: CGPointMake(60.77, 44.73) controlPoint1: CGPointMake(59.71, 45.24) controlPoint2: CGPointMake(60.42, 44.94)];
    [bezier9Path addCurveToPoint: CGPointMake(61.14, 44.55) controlPoint1: CGPointMake(60.96, 44.63) controlPoint2: CGPointMake(61.09, 44.55)];
    [bezier9Path addCurveToPoint: CGPointMake(61.28, 44.79) controlPoint1: CGPointMake(61.25, 44.55) controlPoint2: CGPointMake(61.28, 44.65)];
    [bezier9Path addLineToPoint: CGPointMake(61.28, 56.47)];
    [bezier9Path addCurveToPoint: CGPointMake(62.13, 57.03) controlPoint1: CGPointMake(61.28, 57.03) controlPoint2: CGPointMake(61.65, 57.03)];
    [bezier9Path addLineToPoint: CGPointMake(62.41, 57.03)];
    [bezier9Path addLineToPoint: CGPointMake(62.41, 57.47)];
    [bezier9Path addCurveToPoint: CGPointMake(60.64, 57.44) controlPoint1: CGPointMake(61.84, 57.47) controlPoint2: CGPointMake(61.25, 57.44)];
    [bezier9Path addCurveToPoint: CGPointMake(58.79, 57.47) controlPoint1: CGPointMake(60.03, 57.44) controlPoint2: CGPointMake(59.42, 57.45)];
    [bezier9Path addLineToPoint: CGPointMake(58.79, 57.03)];
    [bezier9Path closePath];
    [fillColor4 setFill];
    [bezier9Path fill];
    
    
    //// Bezier 10 Drawing
    UIBezierPath* bezier10Path = [UIBezierPath bezierPath];
    [bezier10Path moveToPoint: CGPointMake(69.66, 56.54)];
    [bezier10Path addCurveToPoint: CGPointMake(70.13, 56.86) controlPoint1: CGPointMake(69.66, 56.85) controlPoint2: CGPointMake(69.84, 56.86)];
    [bezier10Path addCurveToPoint: CGPointMake(70.81, 56.85) controlPoint1: CGPointMake(70.33, 56.86) controlPoint2: CGPointMake(70.58, 56.85)];
    [bezier10Path addLineToPoint: CGPointMake(70.81, 57.2)];
    [bezier10Path addCurveToPoint: CGPointMake(68.37, 57.73) controlPoint1: CGPointMake(70.08, 57.27) controlPoint2: CGPointMake(68.69, 57.63)];
    [bezier10Path addLineToPoint: CGPointMake(68.28, 57.68)];
    [bezier10Path addLineToPoint: CGPointMake(68.28, 56.31)];
    [bezier10Path addCurveToPoint: CGPointMake(65.29, 57.73) controlPoint1: CGPointMake(67.27, 57.13) controlPoint2: CGPointMake(66.49, 57.73)];
    [bezier10Path addCurveToPoint: CGPointMake(63.43, 55.71) controlPoint1: CGPointMake(64.38, 57.73) controlPoint2: CGPointMake(63.43, 57.13)];
    [bezier10Path addLineToPoint: CGPointMake(63.43, 51.38)];
    [bezier10Path addCurveToPoint: CGPointMake(62.42, 50.44) controlPoint1: CGPointMake(63.43, 50.94) controlPoint2: CGPointMake(63.36, 50.52)];
    [bezier10Path addLineToPoint: CGPointMake(62.42, 50.11)];
    [bezier10Path addCurveToPoint: CGPointMake(64.6, 50) controlPoint1: CGPointMake(63.02, 50.1) controlPoint2: CGPointMake(64.38, 50)];
    [bezier10Path addCurveToPoint: CGPointMake(64.78, 50.49) controlPoint1: CGPointMake(64.78, 50) controlPoint2: CGPointMake(64.78, 50.11)];
    [bezier10Path addLineToPoint: CGPointMake(64.78, 54.85)];
    [bezier10Path addCurveToPoint: CGPointMake(66.25, 56.81) controlPoint1: CGPointMake(64.78, 55.36) controlPoint2: CGPointMake(64.78, 56.81)];
    [bezier10Path addCurveToPoint: CGPointMake(68.3, 55.78) controlPoint1: CGPointMake(66.83, 56.81) controlPoint2: CGPointMake(67.59, 56.37)];
    [bezier10Path addLineToPoint: CGPointMake(68.3, 51.23)];
    [bezier10Path addCurveToPoint: CGPointMake(66.88, 50.54) controlPoint1: CGPointMake(68.3, 50.89) controlPoint2: CGPointMake(67.49, 50.71)];
    [bezier10Path addLineToPoint: CGPointMake(66.88, 50.23)];
    [bezier10Path addCurveToPoint: CGPointMake(69.52, 50) controlPoint1: CGPointMake(68.4, 50.13) controlPoint2: CGPointMake(69.35, 50)];
    [bezier10Path addCurveToPoint: CGPointMake(69.66, 50.3) controlPoint1: CGPointMake(69.66, 50) controlPoint2: CGPointMake(69.66, 50.11)];
    [bezier10Path addLineToPoint: CGPointMake(69.66, 56.54)];
    [bezier10Path closePath];
    [fillColor4 setFill];
    [bezier10Path fill];
    
    
    //// Bezier 11 Drawing
    UIBezierPath* bezier11Path = [UIBezierPath bezierPath];
    [bezier11Path moveToPoint: CGPointMake(73.02, 50.96)];
    [bezier11Path addCurveToPoint: CGPointMake(75.54, 49.74) controlPoint1: CGPointMake(73.7, 50.38) controlPoint2: CGPointMake(74.61, 49.74)];
    [bezier11Path addCurveToPoint: CGPointMake(78.69, 53.29) controlPoint1: CGPointMake(77.5, 49.74) controlPoint2: CGPointMake(78.69, 51.45)];
    [bezier11Path addCurveToPoint: CGPointMake(74.64, 57.73) controlPoint1: CGPointMake(78.69, 55.51) controlPoint2: CGPointMake(77.06, 57.73)];
    [bezier11Path addCurveToPoint: CGPointMake(72.29, 57.13) controlPoint1: CGPointMake(73.39, 57.73) controlPoint2: CGPointMake(72.73, 57.32)];
    [bezier11Path addLineToPoint: CGPointMake(71.79, 57.52)];
    [bezier11Path addLineToPoint: CGPointMake(71.43, 57.34)];
    [bezier11Path addCurveToPoint: CGPointMake(71.67, 54.33) controlPoint1: CGPointMake(71.58, 56.34) controlPoint2: CGPointMake(71.67, 55.36)];
    [bezier11Path addLineToPoint: CGPointMake(71.67, 47.05)];
    [bezier11Path addCurveToPoint: CGPointMake(70.77, 45.73) controlPoint1: CGPointMake(71.67, 45.95) controlPoint2: CGPointMake(71.41, 45.92)];
    [bezier11Path addLineToPoint: CGPointMake(70.77, 45.46)];
    [bezier11Path addCurveToPoint: CGPointMake(72.51, 44.73) controlPoint1: CGPointMake(71.45, 45.24) controlPoint2: CGPointMake(72.16, 44.94)];
    [bezier11Path addCurveToPoint: CGPointMake(72.89, 44.55) controlPoint1: CGPointMake(72.7, 44.63) controlPoint2: CGPointMake(72.84, 44.55)];
    [bezier11Path addCurveToPoint: CGPointMake(73.02, 44.79) controlPoint1: CGPointMake(72.99, 44.55) controlPoint2: CGPointMake(73.02, 44.65)];
    [bezier11Path addLineToPoint: CGPointMake(73.02, 50.96)];
    [bezier11Path closePath];
    [bezier11Path moveToPoint: CGPointMake(73.02, 55.56)];
    [bezier11Path addCurveToPoint: CGPointMake(74.76, 57.29) controlPoint1: CGPointMake(73.02, 56.2) controlPoint2: CGPointMake(73.63, 57.29)];
    [bezier11Path addCurveToPoint: CGPointMake(77.33, 54) controlPoint1: CGPointMake(76.57, 57.29) controlPoint2: CGPointMake(77.33, 55.51)];
    [bezier11Path addCurveToPoint: CGPointMake(74.63, 50.65) controlPoint1: CGPointMake(77.33, 52.18) controlPoint2: CGPointMake(75.95, 50.65)];
    [bezier11Path addCurveToPoint: CGPointMake(73.02, 51.45) controlPoint1: CGPointMake(74, 50.65) controlPoint2: CGPointMake(73.48, 51.06)];
    [bezier11Path addLineToPoint: CGPointMake(73.02, 55.56)];
    [bezier11Path closePath];
    [fillColor4 setFill];
    [bezier11Path fill];
    
    
    //// Bezier 12 Drawing
    UIBezierPath* bezier12Path = [UIBezierPath bezierPath];
    [bezier12Path moveToPoint: CGPointMake(0.04, 67.31)];
    [bezier12Path addLineToPoint: CGPointMake(0.17, 67.31)];
    [bezier12Path addCurveToPoint: CGPointMake(0.85, 66.78) controlPoint1: CGPointMake(0.5, 67.31) controlPoint2: CGPointMake(0.85, 67.26)];
    [bezier12Path addLineToPoint: CGPointMake(0.85, 61.96)];
    [bezier12Path addCurveToPoint: CGPointMake(0.17, 61.44) controlPoint1: CGPointMake(0.85, 61.48) controlPoint2: CGPointMake(0.5, 61.44)];
    [bezier12Path addLineToPoint: CGPointMake(0.04, 61.44)];
    [bezier12Path addLineToPoint: CGPointMake(0.04, 61.16)];
    [bezier12Path addCurveToPoint: CGPointMake(1.4, 61.2) controlPoint1: CGPointMake(0.4, 61.16) controlPoint2: CGPointMake(0.95, 61.2)];
    [bezier12Path addCurveToPoint: CGPointMake(2.85, 61.16) controlPoint1: CGPointMake(1.86, 61.2) controlPoint2: CGPointMake(2.42, 61.16)];
    [bezier12Path addLineToPoint: CGPointMake(2.85, 61.44)];
    [bezier12Path addLineToPoint: CGPointMake(2.72, 61.44)];
    [bezier12Path addCurveToPoint: CGPointMake(2.04, 61.96) controlPoint1: CGPointMake(2.39, 61.44) controlPoint2: CGPointMake(2.04, 61.48)];
    [bezier12Path addLineToPoint: CGPointMake(2.04, 66.78)];
    [bezier12Path addCurveToPoint: CGPointMake(2.72, 67.31) controlPoint1: CGPointMake(2.04, 67.26) controlPoint2: CGPointMake(2.39, 67.31)];
    [bezier12Path addLineToPoint: CGPointMake(2.85, 67.31)];
    [bezier12Path addLineToPoint: CGPointMake(2.85, 67.59)];
    [bezier12Path addCurveToPoint: CGPointMake(1.39, 67.55) controlPoint1: CGPointMake(2.41, 67.59) controlPoint2: CGPointMake(1.85, 67.55)];
    [bezier12Path addCurveToPoint: CGPointMake(0.04, 67.59) controlPoint1: CGPointMake(0.94, 67.55) controlPoint2: CGPointMake(0.4, 67.59)];
    [bezier12Path addLineToPoint: CGPointMake(0.04, 67.31)];
    [bezier12Path closePath];
    [fillColor4 setFill];
    [bezier12Path fill];
    
    
    //// Bezier 13 Drawing
    UIBezierPath* bezier13Path = [UIBezierPath bezierPath];
    [bezier13Path moveToPoint: CGPointMake(9.17, 65.77)];
    [bezier13Path addLineToPoint: CGPointMake(9.19, 65.75)];
    [bezier13Path addLineToPoint: CGPointMake(9.19, 62.3)];
    [bezier13Path addCurveToPoint: CGPointMake(8.39, 61.44) controlPoint1: CGPointMake(9.19, 61.55) controlPoint2: CGPointMake(8.66, 61.44)];
    [bezier13Path addLineToPoint: CGPointMake(8.19, 61.44)];
    [bezier13Path addLineToPoint: CGPointMake(8.19, 61.16)];
    [bezier13Path addCurveToPoint: CGPointMake(9.47, 61.2) controlPoint1: CGPointMake(8.62, 61.16) controlPoint2: CGPointMake(9.04, 61.2)];
    [bezier13Path addCurveToPoint: CGPointMake(10.61, 61.16) controlPoint1: CGPointMake(9.85, 61.2) controlPoint2: CGPointMake(10.23, 61.16)];
    [bezier13Path addLineToPoint: CGPointMake(10.61, 61.44)];
    [bezier13Path addLineToPoint: CGPointMake(10.47, 61.44)];
    [bezier13Path addCurveToPoint: CGPointMake(9.65, 62.61) controlPoint1: CGPointMake(10.08, 61.44) controlPoint2: CGPointMake(9.65, 61.51)];
    [bezier13Path addLineToPoint: CGPointMake(9.65, 66.79)];
    [bezier13Path addCurveToPoint: CGPointMake(9.7, 67.72) controlPoint1: CGPointMake(9.65, 67.12) controlPoint2: CGPointMake(9.66, 67.44)];
    [bezier13Path addLineToPoint: CGPointMake(9.35, 67.72)];
    [bezier13Path addLineToPoint: CGPointMake(4.61, 62.44)];
    [bezier13Path addLineToPoint: CGPointMake(4.61, 66.23)];
    [bezier13Path addCurveToPoint: CGPointMake(5.48, 67.31) controlPoint1: CGPointMake(4.61, 67.03) controlPoint2: CGPointMake(4.77, 67.31)];
    [bezier13Path addLineToPoint: CGPointMake(5.64, 67.31)];
    [bezier13Path addLineToPoint: CGPointMake(5.64, 67.59)];
    [bezier13Path addCurveToPoint: CGPointMake(4.45, 67.55) controlPoint1: CGPointMake(5.24, 67.59) controlPoint2: CGPointMake(4.84, 67.55)];
    [bezier13Path addCurveToPoint: CGPointMake(3.2, 67.59) controlPoint1: CGPointMake(4.04, 67.55) controlPoint2: CGPointMake(3.61, 67.59)];
    [bezier13Path addLineToPoint: CGPointMake(3.2, 67.31)];
    [bezier13Path addLineToPoint: CGPointMake(3.33, 67.31)];
    [bezier13Path addCurveToPoint: CGPointMake(4.15, 66.14) controlPoint1: CGPointMake(3.96, 67.31) controlPoint2: CGPointMake(4.15, 66.88)];
    [bezier13Path addLineToPoint: CGPointMake(4.15, 62.26)];
    [bezier13Path addCurveToPoint: CGPointMake(3.32, 61.44) controlPoint1: CGPointMake(4.15, 61.75) controlPoint2: CGPointMake(3.73, 61.44)];
    [bezier13Path addLineToPoint: CGPointMake(3.2, 61.44)];
    [bezier13Path addLineToPoint: CGPointMake(3.2, 61.16)];
    [bezier13Path addCurveToPoint: CGPointMake(4.25, 61.2) controlPoint1: CGPointMake(3.55, 61.16) controlPoint2: CGPointMake(3.91, 61.2)];
    [bezier13Path addCurveToPoint: CGPointMake(5.07, 61.16) controlPoint1: CGPointMake(4.53, 61.2) controlPoint2: CGPointMake(4.8, 61.16)];
    [bezier13Path addLineToPoint: CGPointMake(9.17, 65.77)];
    [bezier13Path closePath];
    [fillColor4 setFill];
    [bezier13Path fill];
    
    
    //// Bezier 14 Drawing
    UIBezierPath* bezier14Path = [UIBezierPath bezierPath];
    [bezier14Path moveToPoint: CGPointMake(11.99, 61.62)];
    [bezier14Path addCurveToPoint: CGPointMake(11.13, 62.46) controlPoint1: CGPointMake(11.3, 61.62) controlPoint2: CGPointMake(11.27, 61.79)];
    [bezier14Path addLineToPoint: CGPointMake(10.85, 62.46)];
    [bezier14Path addCurveToPoint: CGPointMake(10.96, 61.68) controlPoint1: CGPointMake(10.89, 62.2) controlPoint2: CGPointMake(10.94, 61.94)];
    [bezier14Path addCurveToPoint: CGPointMake(11.02, 60.89) controlPoint1: CGPointMake(11, 61.42) controlPoint2: CGPointMake(11.02, 61.16)];
    [bezier14Path addLineToPoint: CGPointMake(11.24, 60.89)];
    [bezier14Path addCurveToPoint: CGPointMake(11.79, 61.16) controlPoint1: CGPointMake(11.31, 61.17) controlPoint2: CGPointMake(11.55, 61.16)];
    [bezier14Path addLineToPoint: CGPointMake(16.54, 61.16)];
    [bezier14Path addCurveToPoint: CGPointMake(17.04, 60.87) controlPoint1: CGPointMake(16.79, 61.16) controlPoint2: CGPointMake(17.02, 61.15)];
    [bezier14Path addLineToPoint: CGPointMake(17.26, 60.91)];
    [bezier14Path addCurveToPoint: CGPointMake(17.16, 61.66) controlPoint1: CGPointMake(17.22, 61.16) controlPoint2: CGPointMake(17.19, 61.41)];
    [bezier14Path addCurveToPoint: CGPointMake(17.14, 62.4) controlPoint1: CGPointMake(17.14, 61.91) controlPoint2: CGPointMake(17.14, 62.15)];
    [bezier14Path addLineToPoint: CGPointMake(16.87, 62.51)];
    [bezier14Path addCurveToPoint: CGPointMake(16.18, 61.62) controlPoint1: CGPointMake(16.85, 62.16) controlPoint2: CGPointMake(16.8, 61.62)];
    [bezier14Path addLineToPoint: CGPointMake(14.67, 61.62)];
    [bezier14Path addLineToPoint: CGPointMake(14.67, 66.52)];
    [bezier14Path addCurveToPoint: CGPointMake(15.44, 67.31) controlPoint1: CGPointMake(14.67, 67.23) controlPoint2: CGPointMake(15, 67.31)];
    [bezier14Path addLineToPoint: CGPointMake(15.61, 67.31)];
    [bezier14Path addLineToPoint: CGPointMake(15.61, 67.59)];
    [bezier14Path addCurveToPoint: CGPointMake(14.11, 67.55) controlPoint1: CGPointMake(15.26, 67.59) controlPoint2: CGPointMake(14.61, 67.55)];
    [bezier14Path addCurveToPoint: CGPointMake(12.56, 67.59) controlPoint1: CGPointMake(13.56, 67.55) controlPoint2: CGPointMake(12.92, 67.59)];
    [bezier14Path addLineToPoint: CGPointMake(12.56, 67.31)];
    [bezier14Path addLineToPoint: CGPointMake(12.73, 67.31)];
    [bezier14Path addCurveToPoint: CGPointMake(13.5, 66.54) controlPoint1: CGPointMake(13.24, 67.31) controlPoint2: CGPointMake(13.5, 67.26)];
    [bezier14Path addLineToPoint: CGPointMake(13.5, 61.62)];
    [bezier14Path addLineToPoint: CGPointMake(11.99, 61.62)];
    [bezier14Path closePath];
    [fillColor4 setFill];
    [bezier14Path fill];
    
    
    //// Bezier 15 Drawing
    UIBezierPath* bezier15Path = [UIBezierPath bezierPath];
    [bezier15Path moveToPoint: CGPointMake(17.55, 67.31)];
    [bezier15Path addLineToPoint: CGPointMake(17.68, 67.31)];
    [bezier15Path addCurveToPoint: CGPointMake(18.36, 66.78) controlPoint1: CGPointMake(18.01, 67.31) controlPoint2: CGPointMake(18.36, 67.26)];
    [bezier15Path addLineToPoint: CGPointMake(18.36, 61.96)];
    [bezier15Path addCurveToPoint: CGPointMake(17.68, 61.44) controlPoint1: CGPointMake(18.36, 61.48) controlPoint2: CGPointMake(18.01, 61.44)];
    [bezier15Path addLineToPoint: CGPointMake(17.55, 61.44)];
    [bezier15Path addLineToPoint: CGPointMake(17.55, 61.16)];
    [bezier15Path addCurveToPoint: CGPointMake(19.84, 61.2) controlPoint1: CGPointMake(18.11, 61.16) controlPoint2: CGPointMake(19.07, 61.2)];
    [bezier15Path addCurveToPoint: CGPointMake(22.2, 61.16) controlPoint1: CGPointMake(20.62, 61.2) controlPoint2: CGPointMake(21.58, 61.16)];
    [bezier15Path addCurveToPoint: CGPointMake(22.22, 62.57) controlPoint1: CGPointMake(22.19, 61.56) controlPoint2: CGPointMake(22.19, 62.16)];
    [bezier15Path addLineToPoint: CGPointMake(21.94, 62.64)];
    [bezier15Path addCurveToPoint: CGPointMake(20.82, 61.57) controlPoint1: CGPointMake(21.9, 62.04) controlPoint2: CGPointMake(21.79, 61.57)];
    [bezier15Path addLineToPoint: CGPointMake(19.54, 61.57)];
    [bezier15Path addLineToPoint: CGPointMake(19.54, 63.98)];
    [bezier15Path addLineToPoint: CGPointMake(20.64, 63.98)];
    [bezier15Path addCurveToPoint: CGPointMake(21.36, 63.17) controlPoint1: CGPointMake(21.19, 63.98) controlPoint2: CGPointMake(21.31, 63.66)];
    [bezier15Path addLineToPoint: CGPointMake(21.64, 63.17)];
    [bezier15Path addCurveToPoint: CGPointMake(21.61, 64.24) controlPoint1: CGPointMake(21.62, 63.53) controlPoint2: CGPointMake(21.61, 63.89)];
    [bezier15Path addCurveToPoint: CGPointMake(21.64, 65.29) controlPoint1: CGPointMake(21.61, 64.59) controlPoint2: CGPointMake(21.62, 64.94)];
    [bezier15Path addLineToPoint: CGPointMake(21.36, 65.35)];
    [bezier15Path addCurveToPoint: CGPointMake(20.65, 64.44) controlPoint1: CGPointMake(21.31, 64.8) controlPoint2: CGPointMake(21.28, 64.44)];
    [bezier15Path addLineToPoint: CGPointMake(19.54, 64.44)];
    [bezier15Path addLineToPoint: CGPointMake(19.54, 66.58)];
    [bezier15Path addCurveToPoint: CGPointMake(20.67, 67.18) controlPoint1: CGPointMake(19.54, 67.18) controlPoint2: CGPointMake(20.08, 67.18)];
    [bezier15Path addCurveToPoint: CGPointMake(22.53, 66.06) controlPoint1: CGPointMake(21.77, 67.18) controlPoint2: CGPointMake(22.26, 67.11)];
    [bezier15Path addLineToPoint: CGPointMake(22.79, 66.12)];
    [bezier15Path addCurveToPoint: CGPointMake(22.48, 67.59) controlPoint1: CGPointMake(22.67, 66.61) controlPoint2: CGPointMake(22.56, 67.1)];
    [bezier15Path addCurveToPoint: CGPointMake(20, 67.55) controlPoint1: CGPointMake(21.89, 67.59) controlPoint2: CGPointMake(20.83, 67.55)];
    [bezier15Path addCurveToPoint: CGPointMake(17.55, 67.59) controlPoint1: CGPointMake(19.17, 67.55) controlPoint2: CGPointMake(18.08, 67.59)];
    [bezier15Path addLineToPoint: CGPointMake(17.55, 67.31)];
    [bezier15Path closePath];
    [fillColor4 setFill];
    [bezier15Path fill];
    
    
    //// Bezier 16 Drawing
    UIBezierPath* bezier16Path = [UIBezierPath bezierPath];
    [bezier16Path moveToPoint: CGPointMake(24.03, 62.13)];
    [bezier16Path addCurveToPoint: CGPointMake(23.38, 61.44) controlPoint1: CGPointMake(24.03, 61.46) controlPoint2: CGPointMake(23.67, 61.44)];
    [bezier16Path addLineToPoint: CGPointMake(23.21, 61.44)];
    [bezier16Path addLineToPoint: CGPointMake(23.21, 61.16)];
    [bezier16Path addCurveToPoint: CGPointMake(24.64, 61.2) controlPoint1: CGPointMake(23.51, 61.16) controlPoint2: CGPointMake(24.08, 61.2)];
    [bezier16Path addCurveToPoint: CGPointMake(26.12, 61.16) controlPoint1: CGPointMake(25.19, 61.2) controlPoint2: CGPointMake(25.64, 61.16)];
    [bezier16Path addCurveToPoint: CGPointMake(28.31, 62.78) controlPoint1: CGPointMake(27.28, 61.16) controlPoint2: CGPointMake(28.31, 61.47)];
    [bezier16Path addCurveToPoint: CGPointMake(27.03, 64.4) controlPoint1: CGPointMake(28.31, 63.61) controlPoint2: CGPointMake(27.76, 64.11)];
    [bezier16Path addLineToPoint: CGPointMake(28.61, 66.76)];
    [bezier16Path addCurveToPoint: CGPointMake(29.5, 67.31) controlPoint1: CGPointMake(28.87, 67.15) controlPoint2: CGPointMake(29.05, 67.25)];
    [bezier16Path addLineToPoint: CGPointMake(29.5, 67.59)];
    [bezier16Path addCurveToPoint: CGPointMake(28.6, 67.55) controlPoint1: CGPointMake(29.2, 67.59) controlPoint2: CGPointMake(28.9, 67.55)];
    [bezier16Path addCurveToPoint: CGPointMake(27.73, 67.59) controlPoint1: CGPointMake(28.31, 67.55) controlPoint2: CGPointMake(28.02, 67.59)];
    [bezier16Path addCurveToPoint: CGPointMake(25.82, 64.6) controlPoint1: CGPointMake(27.03, 66.66) controlPoint2: CGPointMake(26.42, 65.66)];
    [bezier16Path addLineToPoint: CGPointMake(25.21, 64.6)];
    [bezier16Path addLineToPoint: CGPointMake(25.21, 66.57)];
    [bezier16Path addCurveToPoint: CGPointMake(25.97, 67.31) controlPoint1: CGPointMake(25.21, 67.28) controlPoint2: CGPointMake(25.54, 67.31)];
    [bezier16Path addLineToPoint: CGPointMake(26.13, 67.31)];
    [bezier16Path addLineToPoint: CGPointMake(26.13, 67.59)];
    [bezier16Path addCurveToPoint: CGPointMake(24.55, 67.55) controlPoint1: CGPointMake(25.61, 67.59) controlPoint2: CGPointMake(25.07, 67.55)];
    [bezier16Path addCurveToPoint: CGPointMake(23.21, 67.59) controlPoint1: CGPointMake(24.11, 67.55) controlPoint2: CGPointMake(23.67, 67.59)];
    [bezier16Path addLineToPoint: CGPointMake(23.21, 67.31)];
    [bezier16Path addLineToPoint: CGPointMake(23.38, 67.31)];
    [bezier16Path addCurveToPoint: CGPointMake(24.03, 66.81) controlPoint1: CGPointMake(23.72, 67.31) controlPoint2: CGPointMake(24.03, 67.15)];
    [bezier16Path addLineToPoint: CGPointMake(24.03, 62.13)];
    [bezier16Path closePath];
    [bezier16Path moveToPoint: CGPointMake(25.21, 64.27)];
    [bezier16Path addLineToPoint: CGPointMake(25.66, 64.27)];
    [bezier16Path addCurveToPoint: CGPointMake(27.08, 62.83) controlPoint1: CGPointMake(26.58, 64.27) controlPoint2: CGPointMake(27.08, 63.92)];
    [bezier16Path addCurveToPoint: CGPointMake(25.74, 61.49) controlPoint1: CGPointMake(27.08, 62.02) controlPoint2: CGPointMake(26.56, 61.49)];
    [bezier16Path addCurveToPoint: CGPointMake(25.21, 61.53) controlPoint1: CGPointMake(25.46, 61.49) controlPoint2: CGPointMake(25.34, 61.52)];
    [bezier16Path addLineToPoint: CGPointMake(25.21, 64.27)];
    [bezier16Path closePath];
    [fillColor4 setFill];
    [bezier16Path fill];
    
    
    //// Bezier 17 Drawing
    UIBezierPath* bezier17Path = [UIBezierPath bezierPath];
    [bezier17Path moveToPoint: CGPointMake(35.75, 65.77)];
    [bezier17Path addLineToPoint: CGPointMake(35.77, 65.75)];
    [bezier17Path addLineToPoint: CGPointMake(35.77, 62.3)];
    [bezier17Path addCurveToPoint: CGPointMake(34.97, 61.44) controlPoint1: CGPointMake(35.77, 61.55) controlPoint2: CGPointMake(35.24, 61.44)];
    [bezier17Path addLineToPoint: CGPointMake(34.77, 61.44)];
    [bezier17Path addLineToPoint: CGPointMake(34.77, 61.16)];
    [bezier17Path addCurveToPoint: CGPointMake(36.05, 61.2) controlPoint1: CGPointMake(35.2, 61.16) controlPoint2: CGPointMake(35.62, 61.2)];
    [bezier17Path addCurveToPoint: CGPointMake(37.19, 61.16) controlPoint1: CGPointMake(36.43, 61.2) controlPoint2: CGPointMake(36.81, 61.16)];
    [bezier17Path addLineToPoint: CGPointMake(37.19, 61.44)];
    [bezier17Path addLineToPoint: CGPointMake(37.05, 61.44)];
    [bezier17Path addCurveToPoint: CGPointMake(36.23, 62.61) controlPoint1: CGPointMake(36.66, 61.44) controlPoint2: CGPointMake(36.23, 61.51)];
    [bezier17Path addLineToPoint: CGPointMake(36.23, 66.79)];
    [bezier17Path addCurveToPoint: CGPointMake(36.28, 67.72) controlPoint1: CGPointMake(36.23, 67.12) controlPoint2: CGPointMake(36.24, 67.44)];
    [bezier17Path addLineToPoint: CGPointMake(35.94, 67.72)];
    [bezier17Path addLineToPoint: CGPointMake(31.2, 62.44)];
    [bezier17Path addLineToPoint: CGPointMake(31.2, 66.23)];
    [bezier17Path addCurveToPoint: CGPointMake(32.06, 67.31) controlPoint1: CGPointMake(31.2, 67.03) controlPoint2: CGPointMake(31.35, 67.31)];
    [bezier17Path addLineToPoint: CGPointMake(32.22, 67.31)];
    [bezier17Path addLineToPoint: CGPointMake(32.22, 67.59)];
    [bezier17Path addCurveToPoint: CGPointMake(31.03, 67.55) controlPoint1: CGPointMake(31.82, 67.59) controlPoint2: CGPointMake(31.42, 67.55)];
    [bezier17Path addCurveToPoint: CGPointMake(29.78, 67.59) controlPoint1: CGPointMake(30.61, 67.55) controlPoint2: CGPointMake(30.19, 67.59)];
    [bezier17Path addLineToPoint: CGPointMake(29.78, 67.31)];
    [bezier17Path addLineToPoint: CGPointMake(29.9, 67.31)];
    [bezier17Path addCurveToPoint: CGPointMake(30.73, 66.14) controlPoint1: CGPointMake(30.54, 67.31) controlPoint2: CGPointMake(30.73, 66.88)];
    [bezier17Path addLineToPoint: CGPointMake(30.73, 62.26)];
    [bezier17Path addCurveToPoint: CGPointMake(29.9, 61.44) controlPoint1: CGPointMake(30.73, 61.75) controlPoint2: CGPointMake(30.31, 61.44)];
    [bezier17Path addLineToPoint: CGPointMake(29.78, 61.44)];
    [bezier17Path addLineToPoint: CGPointMake(29.78, 61.16)];
    [bezier17Path addCurveToPoint: CGPointMake(30.84, 61.2) controlPoint1: CGPointMake(30.12, 61.16) controlPoint2: CGPointMake(30.49, 61.2)];
    [bezier17Path addCurveToPoint: CGPointMake(31.65, 61.16) controlPoint1: CGPointMake(31.11, 61.2) controlPoint2: CGPointMake(31.38, 61.16)];
    [bezier17Path addLineToPoint: CGPointMake(35.75, 65.77)];
    [bezier17Path closePath];
    [fillColor4 setFill];
    [bezier17Path fill];
    
    
    //// Bezier 18 Drawing
    UIBezierPath* bezier18Path = [UIBezierPath bezierPath];
    [bezier18Path moveToPoint: CGPointMake(38.67, 66.27)];
    [bezier18Path addCurveToPoint: CGPointMake(38.46, 66.99) controlPoint1: CGPointMake(38.57, 66.58) controlPoint2: CGPointMake(38.46, 66.82)];
    [bezier18Path addCurveToPoint: CGPointMake(39.15, 67.31) controlPoint1: CGPointMake(38.46, 67.26) controlPoint2: CGPointMake(38.85, 67.31)];
    [bezier18Path addLineToPoint: CGPointMake(39.26, 67.31)];
    [bezier18Path addLineToPoint: CGPointMake(39.26, 67.59)];
    [bezier18Path addCurveToPoint: CGPointMake(38.14, 67.55) controlPoint1: CGPointMake(38.89, 67.57) controlPoint2: CGPointMake(38.51, 67.55)];
    [bezier18Path addCurveToPoint: CGPointMake(37.15, 67.59) controlPoint1: CGPointMake(37.81, 67.55) controlPoint2: CGPointMake(37.48, 67.57)];
    [bezier18Path addLineToPoint: CGPointMake(37.15, 67.31)];
    [bezier18Path addLineToPoint: CGPointMake(37.2, 67.31)];
    [bezier18Path addCurveToPoint: CGPointMake(38, 66.71) controlPoint1: CGPointMake(37.56, 67.31) controlPoint2: CGPointMake(37.87, 67.1)];
    [bezier18Path addLineToPoint: CGPointMake(39.48, 62.49)];
    [bezier18Path addCurveToPoint: CGPointMake(39.82, 61.34) controlPoint1: CGPointMake(39.6, 62.15) controlPoint2: CGPointMake(39.76, 61.69)];
    [bezier18Path addCurveToPoint: CGPointMake(40.65, 60.95) controlPoint1: CGPointMake(40.11, 61.24) controlPoint2: CGPointMake(40.48, 61.06)];
    [bezier18Path addCurveToPoint: CGPointMake(40.73, 60.93) controlPoint1: CGPointMake(40.68, 60.94) controlPoint2: CGPointMake(40.7, 60.93)];
    [bezier18Path addCurveToPoint: CGPointMake(40.79, 60.96) controlPoint1: CGPointMake(40.76, 60.93) controlPoint2: CGPointMake(40.77, 60.93)];
    [bezier18Path addCurveToPoint: CGPointMake(40.88, 61.19) controlPoint1: CGPointMake(40.82, 61.03) controlPoint2: CGPointMake(40.85, 61.11)];
    [bezier18Path addLineToPoint: CGPointMake(42.57, 66)];
    [bezier18Path addCurveToPoint: CGPointMake(42.91, 66.94) controlPoint1: CGPointMake(42.68, 66.32) controlPoint2: CGPointMake(42.79, 66.66)];
    [bezier18Path addCurveToPoint: CGPointMake(43.52, 67.31) controlPoint1: CGPointMake(43.02, 67.2) controlPoint2: CGPointMake(43.21, 67.31)];
    [bezier18Path addLineToPoint: CGPointMake(43.57, 67.31)];
    [bezier18Path addLineToPoint: CGPointMake(43.57, 67.59)];
    [bezier18Path addCurveToPoint: CGPointMake(42.3, 67.55) controlPoint1: CGPointMake(43.16, 67.57) controlPoint2: CGPointMake(42.74, 67.55)];
    [bezier18Path addCurveToPoint: CGPointMake(40.92, 67.59) controlPoint1: CGPointMake(41.85, 67.55) controlPoint2: CGPointMake(41.39, 67.57)];
    [bezier18Path addLineToPoint: CGPointMake(40.92, 67.31)];
    [bezier18Path addLineToPoint: CGPointMake(41.02, 67.31)];
    [bezier18Path addCurveToPoint: CGPointMake(41.59, 67.04) controlPoint1: CGPointMake(41.23, 67.31) controlPoint2: CGPointMake(41.59, 67.27)];
    [bezier18Path addCurveToPoint: CGPointMake(41.41, 66.38) controlPoint1: CGPointMake(41.59, 66.92) controlPoint2: CGPointMake(41.51, 66.67)];
    [bezier18Path addLineToPoint: CGPointMake(41.05, 65.31)];
    [bezier18Path addLineToPoint: CGPointMake(38.96, 65.31)];
    [bezier18Path addLineToPoint: CGPointMake(38.67, 66.27)];
    [bezier18Path closePath];
    [bezier18Path moveToPoint: CGPointMake(40.01, 62.19)];
    [bezier18Path addLineToPoint: CGPointMake(39.99, 62.19)];
    [bezier18Path addLineToPoint: CGPointMake(39.14, 64.8)];
    [bezier18Path addLineToPoint: CGPointMake(40.86, 64.8)];
    [bezier18Path addLineToPoint: CGPointMake(40.01, 62.19)];
    [bezier18Path closePath];
    [fillColor4 setFill];
    [bezier18Path fill];
    
    
    //// Bezier 19 Drawing
    UIBezierPath* bezier19Path = [UIBezierPath bezierPath];
    [bezier19Path moveToPoint: CGPointMake(43.98, 61.62)];
    [bezier19Path addCurveToPoint: CGPointMake(43.12, 62.46) controlPoint1: CGPointMake(43.29, 61.62) controlPoint2: CGPointMake(43.26, 61.79)];
    [bezier19Path addLineToPoint: CGPointMake(42.84, 62.46)];
    [bezier19Path addCurveToPoint: CGPointMake(42.96, 61.68) controlPoint1: CGPointMake(42.88, 62.2) controlPoint2: CGPointMake(42.93, 61.94)];
    [bezier19Path addCurveToPoint: CGPointMake(43.01, 60.89) controlPoint1: CGPointMake(42.99, 61.42) controlPoint2: CGPointMake(43.01, 61.16)];
    [bezier19Path addLineToPoint: CGPointMake(43.23, 60.89)];
    [bezier19Path addCurveToPoint: CGPointMake(43.78, 61.16) controlPoint1: CGPointMake(43.3, 61.17) controlPoint2: CGPointMake(43.53, 61.16)];
    [bezier19Path addLineToPoint: CGPointMake(48.53, 61.16)];
    [bezier19Path addCurveToPoint: CGPointMake(49.03, 60.87) controlPoint1: CGPointMake(48.78, 61.16) controlPoint2: CGPointMake(49.01, 61.15)];
    [bezier19Path addLineToPoint: CGPointMake(49.25, 60.91)];
    [bezier19Path addCurveToPoint: CGPointMake(49.15, 61.66) controlPoint1: CGPointMake(49.22, 61.16) controlPoint2: CGPointMake(49.18, 61.41)];
    [bezier19Path addCurveToPoint: CGPointMake(49.13, 62.4) controlPoint1: CGPointMake(49.13, 61.91) controlPoint2: CGPointMake(49.13, 62.15)];
    [bezier19Path addLineToPoint: CGPointMake(48.85, 62.51)];
    [bezier19Path addCurveToPoint: CGPointMake(48.17, 61.62) controlPoint1: CGPointMake(48.84, 62.16) controlPoint2: CGPointMake(48.79, 61.62)];
    [bezier19Path addLineToPoint: CGPointMake(46.66, 61.62)];
    [bezier19Path addLineToPoint: CGPointMake(46.66, 66.52)];
    [bezier19Path addCurveToPoint: CGPointMake(47.43, 67.31) controlPoint1: CGPointMake(46.66, 67.23) controlPoint2: CGPointMake(46.99, 67.31)];
    [bezier19Path addLineToPoint: CGPointMake(47.6, 67.31)];
    [bezier19Path addLineToPoint: CGPointMake(47.6, 67.59)];
    [bezier19Path addCurveToPoint: CGPointMake(46.1, 67.55) controlPoint1: CGPointMake(47.24, 67.59) controlPoint2: CGPointMake(46.6, 67.55)];
    [bezier19Path addCurveToPoint: CGPointMake(44.55, 67.59) controlPoint1: CGPointMake(45.55, 67.55) controlPoint2: CGPointMake(44.91, 67.59)];
    [bezier19Path addLineToPoint: CGPointMake(44.55, 67.31)];
    [bezier19Path addLineToPoint: CGPointMake(44.72, 67.31)];
    [bezier19Path addCurveToPoint: CGPointMake(45.49, 66.54) controlPoint1: CGPointMake(45.23, 67.31) controlPoint2: CGPointMake(45.49, 67.26)];
    [bezier19Path addLineToPoint: CGPointMake(45.49, 61.62)];
    [bezier19Path addLineToPoint: CGPointMake(43.98, 61.62)];
    [bezier19Path closePath];
    [fillColor4 setFill];
    [bezier19Path fill];
    
    
    //// Bezier 20 Drawing
    UIBezierPath* bezier20Path = [UIBezierPath bezierPath];
    [bezier20Path moveToPoint: CGPointMake(49.59, 67.31)];
    [bezier20Path addLineToPoint: CGPointMake(49.72, 67.31)];
    [bezier20Path addCurveToPoint: CGPointMake(50.4, 66.78) controlPoint1: CGPointMake(50.05, 67.31) controlPoint2: CGPointMake(50.4, 67.26)];
    [bezier20Path addLineToPoint: CGPointMake(50.4, 61.96)];
    [bezier20Path addCurveToPoint: CGPointMake(49.72, 61.44) controlPoint1: CGPointMake(50.4, 61.48) controlPoint2: CGPointMake(50.05, 61.44)];
    [bezier20Path addLineToPoint: CGPointMake(49.59, 61.44)];
    [bezier20Path addLineToPoint: CGPointMake(49.59, 61.16)];
    [bezier20Path addCurveToPoint: CGPointMake(50.95, 61.2) controlPoint1: CGPointMake(49.95, 61.16) controlPoint2: CGPointMake(50.5, 61.2)];
    [bezier20Path addCurveToPoint: CGPointMake(52.4, 61.16) controlPoint1: CGPointMake(51.41, 61.2) controlPoint2: CGPointMake(51.97, 61.16)];
    [bezier20Path addLineToPoint: CGPointMake(52.4, 61.44)];
    [bezier20Path addLineToPoint: CGPointMake(52.27, 61.44)];
    [bezier20Path addCurveToPoint: CGPointMake(51.59, 61.96) controlPoint1: CGPointMake(51.94, 61.44) controlPoint2: CGPointMake(51.59, 61.48)];
    [bezier20Path addLineToPoint: CGPointMake(51.59, 66.78)];
    [bezier20Path addCurveToPoint: CGPointMake(52.27, 67.31) controlPoint1: CGPointMake(51.59, 67.26) controlPoint2: CGPointMake(51.94, 67.31)];
    [bezier20Path addLineToPoint: CGPointMake(52.4, 67.31)];
    [bezier20Path addLineToPoint: CGPointMake(52.4, 67.59)];
    [bezier20Path addCurveToPoint: CGPointMake(50.94, 67.55) controlPoint1: CGPointMake(51.96, 67.59) controlPoint2: CGPointMake(51.4, 67.55)];
    [bezier20Path addCurveToPoint: CGPointMake(49.59, 67.59) controlPoint1: CGPointMake(50.49, 67.55) controlPoint2: CGPointMake(49.95, 67.59)];
    [bezier20Path addLineToPoint: CGPointMake(49.59, 67.31)];
    [bezier20Path closePath];
    [fillColor4 setFill];
    [bezier20Path fill];
    
    
    //// Bezier 21 Drawing
    UIBezierPath* bezier21Path = [UIBezierPath bezierPath];
    [bezier21Path moveToPoint: CGPointMake(56.07, 61.02)];
    [bezier21Path addCurveToPoint: CGPointMake(59.59, 64.2) controlPoint1: CGPointMake(58.03, 61.02) controlPoint2: CGPointMake(59.59, 62.24)];
    [bezier21Path addCurveToPoint: CGPointMake(56.12, 67.72) controlPoint1: CGPointMake(59.59, 66.32) controlPoint2: CGPointMake(58.08, 67.72)];
    [bezier21Path addCurveToPoint: CGPointMake(52.67, 64.42) controlPoint1: CGPointMake(54.16, 67.72) controlPoint2: CGPointMake(52.67, 66.4)];
    [bezier21Path addCurveToPoint: CGPointMake(56.07, 61.02) controlPoint1: CGPointMake(52.67, 62.51) controlPoint2: CGPointMake(54.15, 61.02)];
    [bezier21Path closePath];
    [bezier21Path moveToPoint: CGPointMake(56.21, 67.32)];
    [bezier21Path addCurveToPoint: CGPointMake(58.31, 64.4) controlPoint1: CGPointMake(57.99, 67.32) controlPoint2: CGPointMake(58.31, 65.74)];
    [bezier21Path addCurveToPoint: CGPointMake(56.05, 61.43) controlPoint1: CGPointMake(58.31, 63.06) controlPoint2: CGPointMake(57.58, 61.43)];
    [bezier21Path addCurveToPoint: CGPointMake(53.96, 64.1) controlPoint1: CGPointMake(54.44, 61.43) controlPoint2: CGPointMake(53.96, 62.86)];
    [bezier21Path addCurveToPoint: CGPointMake(56.21, 67.32) controlPoint1: CGPointMake(53.96, 65.74) controlPoint2: CGPointMake(54.72, 67.32)];
    [bezier21Path closePath];
    [fillColor4 setFill];
    [bezier21Path fill];
    
    
    //// Bezier 22 Drawing
    UIBezierPath* bezier22Path = [UIBezierPath bezierPath];
    [bezier22Path moveToPoint: CGPointMake(65.8, 65.77)];
    [bezier22Path addLineToPoint: CGPointMake(65.82, 65.75)];
    [bezier22Path addLineToPoint: CGPointMake(65.82, 62.3)];
    [bezier22Path addCurveToPoint: CGPointMake(65.02, 61.44) controlPoint1: CGPointMake(65.82, 61.55) controlPoint2: CGPointMake(65.29, 61.44)];
    [bezier22Path addLineToPoint: CGPointMake(64.81, 61.44)];
    [bezier22Path addLineToPoint: CGPointMake(64.81, 61.16)];
    [bezier22Path addCurveToPoint: CGPointMake(66.1, 61.2) controlPoint1: CGPointMake(65.25, 61.16) controlPoint2: CGPointMake(65.67, 61.2)];
    [bezier22Path addCurveToPoint: CGPointMake(67.24, 61.16) controlPoint1: CGPointMake(66.48, 61.2) controlPoint2: CGPointMake(66.86, 61.16)];
    [bezier22Path addLineToPoint: CGPointMake(67.24, 61.44)];
    [bezier22Path addLineToPoint: CGPointMake(67.1, 61.44)];
    [bezier22Path addCurveToPoint: CGPointMake(66.28, 62.61) controlPoint1: CGPointMake(66.71, 61.44) controlPoint2: CGPointMake(66.28, 61.51)];
    [bezier22Path addLineToPoint: CGPointMake(66.28, 66.79)];
    [bezier22Path addCurveToPoint: CGPointMake(66.33, 67.72) controlPoint1: CGPointMake(66.28, 67.12) controlPoint2: CGPointMake(66.29, 67.44)];
    [bezier22Path addLineToPoint: CGPointMake(65.98, 67.72)];
    [bezier22Path addLineToPoint: CGPointMake(61.24, 62.44)];
    [bezier22Path addLineToPoint: CGPointMake(61.24, 66.23)];
    [bezier22Path addCurveToPoint: CGPointMake(62.11, 67.31) controlPoint1: CGPointMake(61.24, 67.03) controlPoint2: CGPointMake(61.4, 67.31)];
    [bezier22Path addLineToPoint: CGPointMake(62.26, 67.31)];
    [bezier22Path addLineToPoint: CGPointMake(62.26, 67.59)];
    [bezier22Path addCurveToPoint: CGPointMake(61.08, 67.55) controlPoint1: CGPointMake(61.87, 67.59) controlPoint2: CGPointMake(61.47, 67.55)];
    [bezier22Path addCurveToPoint: CGPointMake(59.82, 67.59) controlPoint1: CGPointMake(60.66, 67.55) controlPoint2: CGPointMake(60.24, 67.59)];
    [bezier22Path addLineToPoint: CGPointMake(59.82, 67.31)];
    [bezier22Path addLineToPoint: CGPointMake(59.95, 67.31)];
    [bezier22Path addCurveToPoint: CGPointMake(60.78, 66.14) controlPoint1: CGPointMake(60.59, 67.31) controlPoint2: CGPointMake(60.78, 66.88)];
    [bezier22Path addLineToPoint: CGPointMake(60.78, 62.26)];
    [bezier22Path addCurveToPoint: CGPointMake(59.94, 61.44) controlPoint1: CGPointMake(60.78, 61.75) controlPoint2: CGPointMake(60.36, 61.44)];
    [bezier22Path addLineToPoint: CGPointMake(59.82, 61.44)];
    [bezier22Path addLineToPoint: CGPointMake(59.82, 61.16)];
    [bezier22Path addCurveToPoint: CGPointMake(60.88, 61.2) controlPoint1: CGPointMake(60.17, 61.16) controlPoint2: CGPointMake(60.53, 61.2)];
    [bezier22Path addCurveToPoint: CGPointMake(61.7, 61.16) controlPoint1: CGPointMake(61.16, 61.2) controlPoint2: CGPointMake(61.42, 61.16)];
    [bezier22Path addLineToPoint: CGPointMake(65.8, 65.77)];
    [bezier22Path closePath];
    [fillColor4 setFill];
    [bezier22Path fill];
    
    
    //// Bezier 23 Drawing
    UIBezierPath* bezier23Path = [UIBezierPath bezierPath];
    [bezier23Path moveToPoint: CGPointMake(68.71, 66.27)];
    [bezier23Path addCurveToPoint: CGPointMake(68.51, 66.99) controlPoint1: CGPointMake(68.62, 66.58) controlPoint2: CGPointMake(68.51, 66.82)];
    [bezier23Path addCurveToPoint: CGPointMake(69.2, 67.31) controlPoint1: CGPointMake(68.51, 67.26) controlPoint2: CGPointMake(68.9, 67.31)];
    [bezier23Path addLineToPoint: CGPointMake(69.3, 67.31)];
    [bezier23Path addLineToPoint: CGPointMake(69.3, 67.59)];
    [bezier23Path addCurveToPoint: CGPointMake(68.19, 67.55) controlPoint1: CGPointMake(68.94, 67.57) controlPoint2: CGPointMake(68.56, 67.55)];
    [bezier23Path addCurveToPoint: CGPointMake(67.2, 67.59) controlPoint1: CGPointMake(67.86, 67.55) controlPoint2: CGPointMake(67.53, 67.57)];
    [bezier23Path addLineToPoint: CGPointMake(67.2, 67.31)];
    [bezier23Path addLineToPoint: CGPointMake(67.25, 67.31)];
    [bezier23Path addCurveToPoint: CGPointMake(68.05, 66.71) controlPoint1: CGPointMake(67.61, 67.31) controlPoint2: CGPointMake(67.92, 67.1)];
    [bezier23Path addLineToPoint: CGPointMake(69.53, 62.49)];
    [bezier23Path addCurveToPoint: CGPointMake(69.86, 61.34) controlPoint1: CGPointMake(69.64, 62.15) controlPoint2: CGPointMake(69.81, 61.69)];
    [bezier23Path addCurveToPoint: CGPointMake(70.7, 60.95) controlPoint1: CGPointMake(70.16, 61.24) controlPoint2: CGPointMake(70.53, 61.06)];
    [bezier23Path addCurveToPoint: CGPointMake(70.78, 60.93) controlPoint1: CGPointMake(70.73, 60.94) controlPoint2: CGPointMake(70.75, 60.93)];
    [bezier23Path addCurveToPoint: CGPointMake(70.84, 60.96) controlPoint1: CGPointMake(70.8, 60.93) controlPoint2: CGPointMake(70.82, 60.93)];
    [bezier23Path addCurveToPoint: CGPointMake(70.92, 61.19) controlPoint1: CGPointMake(70.87, 61.03) controlPoint2: CGPointMake(70.9, 61.11)];
    [bezier23Path addLineToPoint: CGPointMake(72.62, 66)];
    [bezier23Path addCurveToPoint: CGPointMake(72.96, 66.94) controlPoint1: CGPointMake(72.73, 66.32) controlPoint2: CGPointMake(72.84, 66.66)];
    [bezier23Path addCurveToPoint: CGPointMake(73.57, 67.31) controlPoint1: CGPointMake(73.07, 67.2) controlPoint2: CGPointMake(73.26, 67.31)];
    [bezier23Path addLineToPoint: CGPointMake(73.62, 67.31)];
    [bezier23Path addLineToPoint: CGPointMake(73.62, 67.59)];
    [bezier23Path addCurveToPoint: CGPointMake(72.35, 67.55) controlPoint1: CGPointMake(73.21, 67.57) controlPoint2: CGPointMake(72.79, 67.55)];
    [bezier23Path addCurveToPoint: CGPointMake(70.97, 67.59) controlPoint1: CGPointMake(71.9, 67.55) controlPoint2: CGPointMake(71.44, 67.57)];
    [bezier23Path addLineToPoint: CGPointMake(70.97, 67.31)];
    [bezier23Path addLineToPoint: CGPointMake(71.07, 67.31)];
    [bezier23Path addCurveToPoint: CGPointMake(71.64, 67.04) controlPoint1: CGPointMake(71.28, 67.31) controlPoint2: CGPointMake(71.64, 67.27)];
    [bezier23Path addCurveToPoint: CGPointMake(71.46, 66.38) controlPoint1: CGPointMake(71.64, 66.92) controlPoint2: CGPointMake(71.56, 66.67)];
    [bezier23Path addLineToPoint: CGPointMake(71.1, 65.31)];
    [bezier23Path addLineToPoint: CGPointMake(69.01, 65.31)];
    [bezier23Path addLineToPoint: CGPointMake(68.71, 66.27)];
    [bezier23Path closePath];
    [bezier23Path moveToPoint: CGPointMake(70.06, 62.19)];
    [bezier23Path addLineToPoint: CGPointMake(70.04, 62.19)];
    [bezier23Path addLineToPoint: CGPointMake(69.18, 64.8)];
    [bezier23Path addLineToPoint: CGPointMake(70.91, 64.8)];
    [bezier23Path addLineToPoint: CGPointMake(70.06, 62.19)];
    [bezier23Path closePath];
    [fillColor4 setFill];
    [bezier23Path fill];
    
    
    //// Bezier 24 Drawing
    UIBezierPath* bezier24Path = [UIBezierPath bezierPath];
    [bezier24Path moveToPoint: CGPointMake(75.94, 66.68)];
    [bezier24Path addCurveToPoint: CGPointMake(76.49, 67.2) controlPoint1: CGPointMake(75.94, 67.05) controlPoint2: CGPointMake(76.2, 67.16)];
    [bezier24Path addCurveToPoint: CGPointMake(77.71, 67.18) controlPoint1: CGPointMake(76.87, 67.23) controlPoint2: CGPointMake(77.28, 67.23)];
    [bezier24Path addCurveToPoint: CGPointMake(78.59, 66.68) controlPoint1: CGPointMake(78.09, 67.13) controlPoint2: CGPointMake(78.43, 66.91)];
    [bezier24Path addCurveToPoint: CGPointMake(78.88, 66.02) controlPoint1: CGPointMake(78.74, 66.48) controlPoint2: CGPointMake(78.82, 66.22)];
    [bezier24Path addLineToPoint: CGPointMake(79.14, 66.02)];
    [bezier24Path addCurveToPoint: CGPointMake(78.8, 67.59) controlPoint1: CGPointMake(79.04, 66.55) controlPoint2: CGPointMake(78.91, 67.06)];
    [bezier24Path addCurveToPoint: CGPointMake(76.37, 67.55) controlPoint1: CGPointMake(77.99, 67.59) controlPoint2: CGPointMake(77.18, 67.55)];
    [bezier24Path addCurveToPoint: CGPointMake(73.94, 67.59) controlPoint1: CGPointMake(75.56, 67.55) controlPoint2: CGPointMake(74.75, 67.59)];
    [bezier24Path addLineToPoint: CGPointMake(73.94, 67.31)];
    [bezier24Path addLineToPoint: CGPointMake(74.07, 67.31)];
    [bezier24Path addCurveToPoint: CGPointMake(74.76, 66.69) controlPoint1: CGPointMake(74.4, 67.31) controlPoint2: CGPointMake(74.76, 67.26)];
    [bezier24Path addLineToPoint: CGPointMake(74.76, 61.96)];
    [bezier24Path addCurveToPoint: CGPointMake(74.07, 61.44) controlPoint1: CGPointMake(74.76, 61.48) controlPoint2: CGPointMake(74.4, 61.44)];
    [bezier24Path addLineToPoint: CGPointMake(73.94, 61.44)];
    [bezier24Path addLineToPoint: CGPointMake(73.94, 61.16)];
    [bezier24Path addCurveToPoint: CGPointMake(75.4, 61.2) controlPoint1: CGPointMake(74.43, 61.16) controlPoint2: CGPointMake(74.91, 61.2)];
    [bezier24Path addCurveToPoint: CGPointMake(76.8, 61.16) controlPoint1: CGPointMake(75.87, 61.2) controlPoint2: CGPointMake(76.33, 61.16)];
    [bezier24Path addLineToPoint: CGPointMake(76.8, 61.44)];
    [bezier24Path addLineToPoint: CGPointMake(76.56, 61.44)];
    [bezier24Path addCurveToPoint: CGPointMake(75.94, 61.93) controlPoint1: CGPointMake(76.22, 61.44) controlPoint2: CGPointMake(75.94, 61.45)];
    [bezier24Path addLineToPoint: CGPointMake(75.94, 66.68)];
    [bezier24Path closePath];
    [fillColor4 setFill];
    [bezier24Path fill];
    
    
    //// Bezier 25 Drawing
    UIBezierPath* bezier25Path = [UIBezierPath bezierPath];
    [bezier25Path moveToPoint: CGPointMake(79.03, 60.9)];
    [bezier25Path addCurveToPoint: CGPointMake(80, 61.87) controlPoint1: CGPointMake(79.59, 60.9) controlPoint2: CGPointMake(80, 61.33)];
    [bezier25Path addCurveToPoint: CGPointMake(79.03, 62.84) controlPoint1: CGPointMake(80, 62.42) controlPoint2: CGPointMake(79.59, 62.84)];
    [bezier25Path addCurveToPoint: CGPointMake(78.06, 61.87) controlPoint1: CGPointMake(78.48, 62.84) controlPoint2: CGPointMake(78.06, 62.42)];
    [bezier25Path addCurveToPoint: CGPointMake(79.03, 60.9) controlPoint1: CGPointMake(78.06, 61.33) controlPoint2: CGPointMake(78.48, 60.9)];
    [bezier25Path closePath];
    [bezier25Path moveToPoint: CGPointMake(79.03, 62.66)];
    [bezier25Path addCurveToPoint: CGPointMake(79.8, 61.87) controlPoint1: CGPointMake(79.47, 62.66) controlPoint2: CGPointMake(79.8, 62.29)];
    [bezier25Path addCurveToPoint: CGPointMake(79.03, 61.08) controlPoint1: CGPointMake(79.8, 61.45) controlPoint2: CGPointMake(79.47, 61.08)];
    [bezier25Path addCurveToPoint: CGPointMake(78.26, 61.87) controlPoint1: CGPointMake(78.59, 61.08) controlPoint2: CGPointMake(78.26, 61.45)];
    [bezier25Path addCurveToPoint: CGPointMake(79.03, 62.66) controlPoint1: CGPointMake(78.26, 62.29) controlPoint2: CGPointMake(78.59, 62.66)];
    [bezier25Path closePath];
    [bezier25Path moveToPoint: CGPointMake(78.55, 62.38)];
    [bezier25Path addLineToPoint: CGPointMake(78.55, 62.34)];
    [bezier25Path addCurveToPoint: CGPointMake(78.69, 62.25) controlPoint1: CGPointMake(78.67, 62.32) controlPoint2: CGPointMake(78.69, 62.32)];
    [bezier25Path addLineToPoint: CGPointMake(78.69, 61.53)];
    [bezier25Path addCurveToPoint: CGPointMake(78.55, 61.4) controlPoint1: CGPointMake(78.69, 61.43) controlPoint2: CGPointMake(78.68, 61.39)];
    [bezier25Path addLineToPoint: CGPointMake(78.55, 61.35)];
    [bezier25Path addLineToPoint: CGPointMake(79.05, 61.35)];
    [bezier25Path addCurveToPoint: CGPointMake(79.38, 61.61) controlPoint1: CGPointMake(79.22, 61.35) controlPoint2: CGPointMake(79.38, 61.43)];
    [bezier25Path addCurveToPoint: CGPointMake(79.15, 61.9) controlPoint1: CGPointMake(79.38, 61.75) controlPoint2: CGPointMake(79.28, 61.86)];
    [bezier25Path addLineToPoint: CGPointMake(79.31, 62.12)];
    [bezier25Path addCurveToPoint: CGPointMake(79.52, 62.35) controlPoint1: CGPointMake(79.38, 62.22) controlPoint2: CGPointMake(79.47, 62.32)];
    [bezier25Path addLineToPoint: CGPointMake(79.52, 62.38)];
    [bezier25Path addLineToPoint: CGPointMake(79.33, 62.38)];
    [bezier25Path addCurveToPoint: CGPointMake(78.98, 61.94) controlPoint1: CGPointMake(79.24, 62.38) controlPoint2: CGPointMake(79.16, 62.19)];
    [bezier25Path addLineToPoint: CGPointMake(78.88, 61.94)];
    [bezier25Path addLineToPoint: CGPointMake(78.88, 62.26)];
    [bezier25Path addCurveToPoint: CGPointMake(79.02, 62.34) controlPoint1: CGPointMake(78.88, 62.32) controlPoint2: CGPointMake(78.9, 62.32)];
    [bezier25Path addLineToPoint: CGPointMake(79.02, 62.38)];
    [bezier25Path addLineToPoint: CGPointMake(78.55, 62.38)];
    [bezier25Path closePath];
    [bezier25Path moveToPoint: CGPointMake(78.88, 61.87)];
    [bezier25Path addLineToPoint: CGPointMake(78.99, 61.87)];
    [bezier25Path addCurveToPoint: CGPointMake(79.17, 61.62) controlPoint1: CGPointMake(79.11, 61.87) controlPoint2: CGPointMake(79.17, 61.78)];
    [bezier25Path addCurveToPoint: CGPointMake(78.98, 61.41) controlPoint1: CGPointMake(79.17, 61.47) controlPoint2: CGPointMake(79.08, 61.41)];
    [bezier25Path addLineToPoint: CGPointMake(78.88, 61.41)];
    [bezier25Path addLineToPoint: CGPointMake(78.88, 61.87)];
    [bezier25Path closePath];
    [fillColor4 setFill];
    [bezier25Path fill];
}

@end
