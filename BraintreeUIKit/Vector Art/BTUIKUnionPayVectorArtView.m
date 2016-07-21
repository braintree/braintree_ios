#import "BTUIKUnionPayVectorArtView.h"

@implementation BTUIKUnionPayVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 0.89 green: 0.094 blue: 0.216 alpha: 1];
    UIColor* color2 = [UIColor colorWithRed: 0 green: 0.267 blue: 0.486 alpha: 1];
    UIColor* color3 = [UIColor colorWithRed: 0 green: 0.482 blue: 0.522 alpha: 1];
    
    //// Group
    {
        //// Bezier Drawing
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: CGPointMake(17.18, 0.52)];
        [bezierPath addLineToPoint: CGPointMake(38.79, 0.52)];
        [bezierPath addCurveToPoint: CGPointMake(42.99, 6.12) controlPoint1: CGPointMake(41.83, 0.52) controlPoint2: CGPointMake(43.72, 3.02)];
        [bezierPath addLineToPoint: CGPointMake(32.92, 50.03)];
        [bezierPath addCurveToPoint: CGPointMake(26.17, 55.63) controlPoint1: CGPointMake(32.19, 53.13) controlPoint2: CGPointMake(29.15, 55.63)];
        [bezierPath addLineToPoint: CGPointMake(4.57, 55.63)];
        [bezierPath addCurveToPoint: CGPointMake(0.36, 50.03) controlPoint1: CGPointMake(1.52, 55.63) controlPoint2: CGPointMake(-0.36, 53.13)];
        [bezierPath addLineToPoint: CGPointMake(10.44, 6.12)];
        [bezierPath addCurveToPoint: CGPointMake(17.18, 0.52) controlPoint1: CGPointMake(11.17, 3.02) controlPoint2: CGPointMake(14.14, 0.52)];
        [bezierPath addLineToPoint: CGPointMake(17.18, 0.52)];
        [bezierPath addLineToPoint: CGPointMake(17.18, 0.52)];
        [bezierPath closePath];
        bezierPath.miterLimit = 4;
        
        [color setFill];
        [bezierPath fill];
        
        
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
        [bezier2Path moveToPoint: CGPointMake(37.05, 0.52)];
        [bezier2Path addLineToPoint: CGPointMake(61.92, 0.52)];
        [bezier2Path addCurveToPoint: CGPointMake(62.86, 6.12) controlPoint1: CGPointMake(64.96, 0.52) controlPoint2: CGPointMake(63.58, 3.02)];
        [bezier2Path addLineToPoint: CGPointMake(52.78, 50.03)];
        [bezier2Path addCurveToPoint: CGPointMake(49.3, 55.63) controlPoint1: CGPointMake(52.06, 53.13) controlPoint2: CGPointMake(52.27, 55.63)];
        [bezier2Path addLineToPoint: CGPointMake(24.43, 55.63)];
        [bezier2Path addCurveToPoint: CGPointMake(20.23, 50.03) controlPoint1: CGPointMake(21.39, 55.63) controlPoint2: CGPointMake(19.5, 53.13)];
        [bezier2Path addLineToPoint: CGPointMake(30.3, 6.12)];
        [bezier2Path addCurveToPoint: CGPointMake(37.05, 0.52) controlPoint1: CGPointMake(30.96, 3.02) controlPoint2: CGPointMake(34, 0.52)];
        [bezier2Path addLineToPoint: CGPointMake(37.05, 0.52)];
        [bezier2Path addLineToPoint: CGPointMake(37.05, 0.52)];
        [bezier2Path closePath];
        bezier2Path.miterLimit = 4;
        
        [color2 setFill];
        [bezier2Path fill];
        
        
        //// Bezier 3 Drawing
        UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
        [bezier3Path moveToPoint: CGPointMake(60.9, 0.52)];
        [bezier3Path addLineToPoint: CGPointMake(82.51, 0.52)];
        [bezier3Path addCurveToPoint: CGPointMake(86.71, 6.12) controlPoint1: CGPointMake(85.55, 0.52) controlPoint2: CGPointMake(87.44, 3.02)];
        [bezier3Path addLineToPoint: CGPointMake(76.63, 50.03)];
        [bezier3Path addCurveToPoint: CGPointMake(69.89, 55.63) controlPoint1: CGPointMake(75.91, 53.13) controlPoint2: CGPointMake(72.93, 55.63)];
        [bezier3Path addLineToPoint: CGPointMake(48.28, 55.63)];
        [bezier3Path addCurveToPoint: CGPointMake(44.08, 50.03) controlPoint1: CGPointMake(45.24, 55.63) controlPoint2: CGPointMake(43.36, 53.13)];
        [bezier3Path addLineToPoint: CGPointMake(54.16, 6.12)];
        [bezier3Path addCurveToPoint: CGPointMake(60.9, 0.52) controlPoint1: CGPointMake(54.88, 3.02) controlPoint2: CGPointMake(57.93, 0.52)];
        [bezier3Path addLineToPoint: CGPointMake(60.9, 0.52)];
        [bezier3Path addLineToPoint: CGPointMake(60.9, 0.52)];
        [bezier3Path closePath];
        bezier3Path.miterLimit = 4;
        
        [color3 setFill];
        [bezier3Path fill];
        
        
        //// Bezier 4 Drawing
        UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
        [bezier4Path moveToPoint: CGPointMake(57.27, 41.85)];
        [bezier4Path addLineToPoint: CGPointMake(59.31, 41.85)];
        [bezier4Path addLineToPoint: CGPointMake(59.88, 39.86)];
        [bezier4Path addLineToPoint: CGPointMake(57.86, 39.86)];
        [bezier4Path addLineToPoint: CGPointMake(57.27, 41.85)];
        [bezier4Path addLineToPoint: CGPointMake(57.27, 41.85)];
        [bezier4Path closePath];
        [bezier4Path moveToPoint: CGPointMake(58.94, 36.33)];
        [bezier4Path addLineToPoint: CGPointMake(58.22, 38.68)];
        [bezier4Path addCurveToPoint: CGPointMake(59.38, 38.17) controlPoint1: CGPointMake(58.22, 38.68) controlPoint2: CGPointMake(59.02, 38.32)];
        [bezier4Path addCurveToPoint: CGPointMake(60.47, 38.02) controlPoint1: CGPointMake(59.81, 38.09) controlPoint2: CGPointMake(60.47, 38.02)];
        [bezier4Path addLineToPoint: CGPointMake(60.97, 36.4)];
        [bezier4Path addLineToPoint: CGPointMake(58.94, 36.4)];
        [bezier4Path addLineToPoint: CGPointMake(58.94, 36.33)];
        [bezier4Path closePath];
        [bezier4Path moveToPoint: CGPointMake(59.96, 32.94)];
        [bezier4Path addLineToPoint: CGPointMake(59.31, 35.22)];
        [bezier4Path addCurveToPoint: CGPointMake(60.47, 34.78) controlPoint1: CGPointMake(59.31, 35.22) controlPoint2: CGPointMake(60.03, 34.85)];
        [bezier4Path addCurveToPoint: CGPointMake(61.48, 34.63) controlPoint1: CGPointMake(60.9, 34.71) controlPoint2: CGPointMake(61.48, 34.63)];
        [bezier4Path addLineToPoint: CGPointMake(61.99, 33.01)];
        [bezier4Path addLineToPoint: CGPointMake(59.96, 33.01)];
        [bezier4Path addLineToPoint: CGPointMake(59.96, 32.94)];
        [bezier4Path closePath];
        [bezier4Path moveToPoint: CGPointMake(64.45, 32.94)];
        [bezier4Path addLineToPoint: CGPointMake(61.84, 41.78)];
        [bezier4Path addLineToPoint: CGPointMake(62.57, 41.78)];
        [bezier4Path addLineToPoint: CGPointMake(61.99, 43.62)];
        [bezier4Path addLineToPoint: CGPointMake(61.26, 43.62)];
        [bezier4Path addLineToPoint: CGPointMake(61.12, 44.21)];
        [bezier4Path addLineToPoint: CGPointMake(58.58, 44.21)];
        [bezier4Path addLineToPoint: CGPointMake(58.73, 43.62)];
        [bezier4Path addLineToPoint: CGPointMake(53.65, 43.62)];
        [bezier4Path addLineToPoint: CGPointMake(54.16, 41.93)];
        [bezier4Path addLineToPoint: CGPointMake(54.67, 41.93)];
        [bezier4Path addLineToPoint: CGPointMake(57.35, 32.94)];
        [bezier4Path addLineToPoint: CGPointMake(57.86, 31.09)];
        [bezier4Path addLineToPoint: CGPointMake(60.39, 31.09)];
        [bezier4Path addLineToPoint: CGPointMake(60.1, 31.98)];
        [bezier4Path addCurveToPoint: CGPointMake(61.41, 31.32) controlPoint1: CGPointMake(60.1, 31.98) controlPoint2: CGPointMake(60.76, 31.46)];
        [bezier4Path addCurveToPoint: CGPointMake(65.76, 31.09) controlPoint1: CGPointMake(62.06, 31.17) controlPoint2: CGPointMake(65.76, 31.09)];
        [bezier4Path addLineToPoint: CGPointMake(65.18, 32.94)];
        [bezier4Path addLineToPoint: CGPointMake(64.45, 32.94)];
        [bezier4Path addLineToPoint: CGPointMake(64.45, 32.94)];
        [bezier4Path closePath];
        bezier4Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier4Path fill];
        
        
        //// Bezier 5 Drawing
        UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
        [bezier5Path moveToPoint: CGPointMake(65.61, 31.09)];
        [bezier5Path addLineToPoint: CGPointMake(68.37, 31.09)];
        [bezier5Path addLineToPoint: CGPointMake(68.37, 32.13)];
        [bezier5Path addCurveToPoint: CGPointMake(68.8, 32.35) controlPoint1: CGPointMake(68.37, 32.27) controlPoint2: CGPointMake(68.51, 32.35)];
        [bezier5Path addLineToPoint: CGPointMake(69.38, 32.35)];
        [bezier5Path addLineToPoint: CGPointMake(68.88, 34.04)];
        [bezier5Path addLineToPoint: CGPointMake(67.42, 34.04)];
        [bezier5Path addCurveToPoint: CGPointMake(65.68, 32.94) controlPoint1: CGPointMake(66.12, 34.12) controlPoint2: CGPointMake(65.68, 33.6)];
        [bezier5Path addLineToPoint: CGPointMake(65.61, 31.09)];
        [bezier5Path addLineToPoint: CGPointMake(65.61, 31.09)];
        [bezier5Path closePath];
        bezier5Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier5Path fill];
        
        
        //// Bezier 6 Drawing
        UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
        [bezier6Path moveToPoint: CGPointMake(65.97, 39.2)];
        [bezier6Path addLineToPoint: CGPointMake(63.37, 39.2)];
        [bezier6Path addLineToPoint: CGPointMake(63.8, 37.65)];
        [bezier6Path addLineToPoint: CGPointMake(66.77, 37.65)];
        [bezier6Path addLineToPoint: CGPointMake(67.21, 36.25)];
        [bezier6Path addLineToPoint: CGPointMake(64.23, 36.25)];
        [bezier6Path addLineToPoint: CGPointMake(64.74, 34.56)];
        [bezier6Path addLineToPoint: CGPointMake(72.93, 34.56)];
        [bezier6Path addLineToPoint: CGPointMake(72.43, 36.25)];
        [bezier6Path addLineToPoint: CGPointMake(69.67, 36.25)];
        [bezier6Path addLineToPoint: CGPointMake(69.24, 37.65)];
        [bezier6Path addLineToPoint: CGPointMake(71.99, 37.65)];
        [bezier6Path addLineToPoint: CGPointMake(71.56, 39.2)];
        [bezier6Path addLineToPoint: CGPointMake(68.58, 39.2)];
        [bezier6Path addLineToPoint: CGPointMake(68.08, 39.86)];
        [bezier6Path addLineToPoint: CGPointMake(69.31, 39.86)];
        [bezier6Path addLineToPoint: CGPointMake(69.6, 41.78)];
        [bezier6Path addCurveToPoint: CGPointMake(69.67, 42.15) controlPoint1: CGPointMake(69.6, 42) controlPoint2: CGPointMake(69.6, 42.07)];
        [bezier6Path addCurveToPoint: CGPointMake(70.33, 42.22) controlPoint1: CGPointMake(69.74, 42.22) controlPoint2: CGPointMake(70.11, 42.22)];
        [bezier6Path addLineToPoint: CGPointMake(70.69, 42.22)];
        [bezier6Path addLineToPoint: CGPointMake(70.11, 44.06)];
        [bezier6Path addLineToPoint: CGPointMake(69.17, 44.06)];
        [bezier6Path addCurveToPoint: CGPointMake(68.51, 44.06) controlPoint1: CGPointMake(69.02, 44.06) controlPoint2: CGPointMake(68.8, 44.06)];
        [bezier6Path addCurveToPoint: CGPointMake(67.86, 43.77) controlPoint1: CGPointMake(68.22, 44.06) controlPoint2: CGPointMake(68.01, 43.84)];
        [bezier6Path addCurveToPoint: CGPointMake(67.35, 43.11) controlPoint1: CGPointMake(67.72, 43.69) controlPoint2: CGPointMake(67.42, 43.47)];
        [bezier6Path addLineToPoint: CGPointMake(67.06, 41.19)];
        [bezier6Path addLineToPoint: CGPointMake(65.68, 43.11)];
        [bezier6Path addCurveToPoint: CGPointMake(63.73, 44.14) controlPoint1: CGPointMake(65.25, 43.69) controlPoint2: CGPointMake(64.67, 44.14)];
        [bezier6Path addLineToPoint: CGPointMake(61.84, 44.14)];
        [bezier6Path addLineToPoint: CGPointMake(62.35, 42.44)];
        [bezier6Path addLineToPoint: CGPointMake(63.08, 42.44)];
        [bezier6Path addCurveToPoint: CGPointMake(63.58, 42.29) controlPoint1: CGPointMake(63.29, 42.44) controlPoint2: CGPointMake(63.44, 42.37)];
        [bezier6Path addCurveToPoint: CGPointMake(64.02, 41.93) controlPoint1: CGPointMake(63.73, 42.22) controlPoint2: CGPointMake(63.87, 42.15)];
        [bezier6Path addLineToPoint: CGPointMake(65.97, 39.2)];
        [bezier6Path addLineToPoint: CGPointMake(65.97, 39.2)];
        [bezier6Path closePath];
        bezier6Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier6Path fill];
        
        
        //// Bezier 7 Drawing
        UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
        [bezier7Path moveToPoint: CGPointMake(37.41, 35.07)];
        [bezier7Path addLineToPoint: CGPointMake(44.3, 35.07)];
        [bezier7Path addLineToPoint: CGPointMake(43.79, 36.77)];
        [bezier7Path addLineToPoint: CGPointMake(41.03, 36.77)];
        [bezier7Path addLineToPoint: CGPointMake(40.6, 38.17)];
        [bezier7Path addLineToPoint: CGPointMake(43.43, 38.17)];
        [bezier7Path addLineToPoint: CGPointMake(42.92, 39.86)];
        [bezier7Path addLineToPoint: CGPointMake(40.09, 39.86)];
        [bezier7Path addLineToPoint: CGPointMake(39.44, 42.15)];
        [bezier7Path addCurveToPoint: CGPointMake(40.38, 42.44) controlPoint1: CGPointMake(39.37, 42.37) controlPoint2: CGPointMake(40.09, 42.44)];
        [bezier7Path addLineToPoint: CGPointMake(41.76, 42.22)];
        [bezier7Path addLineToPoint: CGPointMake(41.18, 44.14)];
        [bezier7Path addLineToPoint: CGPointMake(37.99, 44.14)];
        [bezier7Path addCurveToPoint: CGPointMake(37.27, 44.06) controlPoint1: CGPointMake(37.7, 44.14) controlPoint2: CGPointMake(37.56, 44.14)];
        [bezier7Path addCurveToPoint: CGPointMake(36.76, 43.69) controlPoint1: CGPointMake(36.97, 43.99) controlPoint2: CGPointMake(36.9, 43.84)];
        [bezier7Path addCurveToPoint: CGPointMake(36.61, 42.96) controlPoint1: CGPointMake(36.61, 43.47) controlPoint2: CGPointMake(36.47, 43.33)];
        [bezier7Path addLineToPoint: CGPointMake(37.56, 39.86)];
        [bezier7Path addLineToPoint: CGPointMake(35.96, 39.86)];
        [bezier7Path addLineToPoint: CGPointMake(36.47, 38.09)];
        [bezier7Path addLineToPoint: CGPointMake(38.06, 38.09)];
        [bezier7Path addLineToPoint: CGPointMake(38.5, 36.69)];
        [bezier7Path addLineToPoint: CGPointMake(36.9, 36.69)];
        [bezier7Path addLineToPoint: CGPointMake(37.41, 35.07)];
        [bezier7Path addLineToPoint: CGPointMake(37.41, 35.07)];
        [bezier7Path closePath];
        bezier7Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier7Path fill];
        
        
        //// Bezier 8 Drawing
        UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
        [bezier8Path moveToPoint: CGPointMake(42.05, 32.05)];
        [bezier8Path addLineToPoint: CGPointMake(44.88, 32.05)];
        [bezier8Path addLineToPoint: CGPointMake(44.37, 33.82)];
        [bezier8Path addLineToPoint: CGPointMake(40.53, 33.82)];
        [bezier8Path addLineToPoint: CGPointMake(40.09, 34.19)];
        [bezier8Path addCurveToPoint: CGPointMake(39.58, 34.41) controlPoint1: CGPointMake(39.95, 34.34) controlPoint2: CGPointMake(39.88, 34.26)];
        [bezier8Path addCurveToPoint: CGPointMake(38.28, 34.71) controlPoint1: CGPointMake(39.37, 34.48) controlPoint2: CGPointMake(38.93, 34.71)];
        [bezier8Path addLineToPoint: CGPointMake(37.05, 34.71)];
        [bezier8Path addLineToPoint: CGPointMake(37.56, 33.01)];
        [bezier8Path addLineToPoint: CGPointMake(37.92, 33.01)];
        [bezier8Path addCurveToPoint: CGPointMake(38.57, 32.94) controlPoint1: CGPointMake(38.21, 33.01) controlPoint2: CGPointMake(38.42, 33.01)];
        [bezier8Path addCurveToPoint: CGPointMake(39.01, 32.42) controlPoint1: CGPointMake(38.72, 32.86) controlPoint2: CGPointMake(38.86, 32.72)];
        [bezier8Path addLineToPoint: CGPointMake(39.73, 31.09)];
        [bezier8Path addLineToPoint: CGPointMake(42.56, 31.09)];
        [bezier8Path addLineToPoint: CGPointMake(42.05, 32.05)];
        [bezier8Path addLineToPoint: CGPointMake(42.05, 32.05)];
        [bezier8Path closePath];
        bezier8Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier8Path fill];
        
        
        //// Bezier 9 Drawing
        UIBezierPath* bezier9Path = [UIBezierPath bezierPath];
        [bezier9Path moveToPoint: CGPointMake(47.49, 34.93)];
        [bezier9Path addCurveToPoint: CGPointMake(49.59, 33.97) controlPoint1: CGPointMake(47.49, 34.93) controlPoint2: CGPointMake(48.28, 34.19)];
        [bezier9Path addCurveToPoint: CGPointMake(51.77, 33.89) controlPoint1: CGPointMake(49.88, 33.89) controlPoint2: CGPointMake(51.77, 33.89)];
        [bezier9Path addLineToPoint: CGPointMake(52.06, 32.94)];
        [bezier9Path addLineToPoint: CGPointMake(48.07, 32.94)];
        [bezier9Path addLineToPoint: CGPointMake(47.49, 34.93)];
        [bezier9Path addLineToPoint: CGPointMake(47.49, 34.93)];
        [bezier9Path closePath];
        [bezier9Path moveToPoint: CGPointMake(51.26, 35.66)];
        [bezier9Path addLineToPoint: CGPointMake(47.34, 35.66)];
        [bezier9Path addLineToPoint: CGPointMake(47.12, 36.47)];
        [bezier9Path addLineToPoint: CGPointMake(50.53, 36.47)];
        [bezier9Path addCurveToPoint: CGPointMake(51.04, 36.47) controlPoint1: CGPointMake(50.97, 36.4) controlPoint2: CGPointMake(51.04, 36.47)];
        [bezier9Path addLineToPoint: CGPointMake(51.26, 35.66)];
        [bezier9Path addLineToPoint: CGPointMake(51.26, 35.66)];
        [bezier9Path closePath];
        [bezier9Path moveToPoint: CGPointMake(46.11, 31.09)];
        [bezier9Path addLineToPoint: CGPointMake(48.5, 31.09)];
        [bezier9Path addLineToPoint: CGPointMake(48.14, 32.35)];
        [bezier9Path addCurveToPoint: CGPointMake(49.44, 31.54) controlPoint1: CGPointMake(48.14, 32.35) controlPoint2: CGPointMake(48.87, 31.76)];
        [bezier9Path addCurveToPoint: CGPointMake(51.18, 31.17) controlPoint1: CGPointMake(49.95, 31.32) controlPoint2: CGPointMake(51.18, 31.17)];
        [bezier9Path addLineToPoint: CGPointMake(55.1, 31.17)];
        [bezier9Path addLineToPoint: CGPointMake(53.79, 35.66)];
        [bezier9Path addCurveToPoint: CGPointMake(53.14, 37.14) controlPoint1: CGPointMake(53.58, 36.4) controlPoint2: CGPointMake(53.29, 36.92)];
        [bezier9Path addCurveToPoint: CGPointMake(52.49, 37.73) controlPoint1: CGPointMake(53, 37.36) controlPoint2: CGPointMake(52.85, 37.58)];
        [bezier9Path addCurveToPoint: CGPointMake(51.62, 38.02) controlPoint1: CGPointMake(52.13, 37.87) controlPoint2: CGPointMake(51.84, 38.02)];
        [bezier9Path addCurveToPoint: CGPointMake(50.39, 38.02) controlPoint1: CGPointMake(51.33, 38.02) controlPoint2: CGPointMake(50.97, 38.02)];
        [bezier9Path addLineToPoint: CGPointMake(46.62, 38.02)];
        [bezier9Path addLineToPoint: CGPointMake(45.53, 41.56)];
        [bezier9Path addCurveToPoint: CGPointMake(45.46, 42.15) controlPoint1: CGPointMake(45.46, 41.93) controlPoint2: CGPointMake(45.38, 42.07)];
        [bezier9Path addCurveToPoint: CGPointMake(45.82, 42.29) controlPoint1: CGPointMake(45.53, 42.22) controlPoint2: CGPointMake(45.67, 42.29)];
        [bezier9Path addLineToPoint: CGPointMake(47.49, 42.15)];
        [bezier9Path addLineToPoint: CGPointMake(46.91, 44.06)];
        [bezier9Path addLineToPoint: CGPointMake(45.02, 44.06)];
        [bezier9Path addCurveToPoint: CGPointMake(43.72, 44.06) controlPoint1: CGPointMake(44.44, 44.06) controlPoint2: CGPointMake(44.01, 44.06)];
        [bezier9Path addCurveToPoint: CGPointMake(42.92, 43.92) controlPoint1: CGPointMake(43.43, 44.06) controlPoint2: CGPointMake(43.14, 44.06)];
        [bezier9Path addCurveToPoint: CGPointMake(42.48, 43.33) controlPoint1: CGPointMake(42.77, 43.77) controlPoint2: CGPointMake(42.48, 43.55)];
        [bezier9Path addCurveToPoint: CGPointMake(42.7, 42.37) controlPoint1: CGPointMake(42.48, 43.11) controlPoint2: CGPointMake(42.56, 42.81)];
        [bezier9Path addLineToPoint: CGPointMake(46.11, 31.09)];
        [bezier9Path addLineToPoint: CGPointMake(46.11, 31.09)];
        [bezier9Path closePath];
        bezier9Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier9Path fill];
        
        
        //// Bezier 10 Drawing
        UIBezierPath* bezier10Path = [UIBezierPath bezierPath];
        [bezier10Path moveToPoint: CGPointMake(53.14, 38.39)];
        [bezier10Path addLineToPoint: CGPointMake(52.92, 39.49)];
        [bezier10Path addCurveToPoint: CGPointMake(52.49, 40.31) controlPoint1: CGPointMake(52.85, 39.86) controlPoint2: CGPointMake(52.78, 40.08)];
        [bezier10Path addCurveToPoint: CGPointMake(51.18, 40.75) controlPoint1: CGPointMake(52.2, 40.53) controlPoint2: CGPointMake(51.91, 40.75)];
        [bezier10Path addLineToPoint: CGPointMake(49.88, 40.82)];
        [bezier10Path addLineToPoint: CGPointMake(49.88, 42.07)];
        [bezier10Path addCurveToPoint: CGPointMake(50.02, 42.44) controlPoint1: CGPointMake(49.88, 42.44) controlPoint2: CGPointMake(49.95, 42.37)];
        [bezier10Path addCurveToPoint: CGPointMake(50.17, 42.52) controlPoint1: CGPointMake(50.1, 42.52) controlPoint2: CGPointMake(50.17, 42.52)];
        [bezier10Path addLineToPoint: CGPointMake(50.61, 42.52)];
        [bezier10Path addLineToPoint: CGPointMake(51.91, 42.44)];
        [bezier10Path addLineToPoint: CGPointMake(51.4, 44.21)];
        [bezier10Path addLineToPoint: CGPointMake(49.95, 44.21)];
        [bezier10Path addCurveToPoint: CGPointMake(47.92, 43.99) controlPoint1: CGPointMake(48.94, 44.21) controlPoint2: CGPointMake(48.14, 44.21)];
        [bezier10Path addCurveToPoint: CGPointMake(47.63, 43.33) controlPoint1: CGPointMake(47.71, 43.84) controlPoint2: CGPointMake(47.63, 43.62)];
        [bezier10Path addLineToPoint: CGPointMake(47.71, 38.54)];
        [bezier10Path addLineToPoint: CGPointMake(50.02, 38.54)];
        [bezier10Path addLineToPoint: CGPointMake(50.02, 39.49)];
        [bezier10Path addLineToPoint: CGPointMake(50.61, 39.49)];
        [bezier10Path addCurveToPoint: CGPointMake(51.04, 39.42) controlPoint1: CGPointMake(50.82, 39.49) controlPoint2: CGPointMake(50.89, 39.49)];
        [bezier10Path addCurveToPoint: CGPointMake(51.18, 39.2) controlPoint1: CGPointMake(51.11, 39.35) controlPoint2: CGPointMake(51.18, 39.27)];
        [bezier10Path addLineToPoint: CGPointMake(51.4, 38.46)];
        [bezier10Path addLineToPoint: CGPointMake(53.14, 38.46)];
        [bezier10Path addLineToPoint: CGPointMake(53.14, 38.39)];
        [bezier10Path closePath];
        bezier10Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier10Path fill];
        
        
        //// Bezier 11 Drawing
        UIBezierPath* bezier11Path = [UIBezierPath bezierPath];
        [bezier11Path moveToPoint: CGPointMake(19.72, 14.52)];
        [bezier11Path addCurveToPoint: CGPointMake(18.12, 21.96) controlPoint1: CGPointMake(19.65, 14.88) controlPoint2: CGPointMake(18.12, 21.96)];
        [bezier11Path addCurveToPoint: CGPointMake(16.75, 25.05) controlPoint1: CGPointMake(17.83, 23.36) controlPoint2: CGPointMake(17.55, 24.39)];
        [bezier11Path addCurveToPoint: CGPointMake(15.15, 25.64) controlPoint1: CGPointMake(16.31, 25.42) controlPoint2: CGPointMake(15.73, 25.64)];
        [bezier11Path addCurveToPoint: CGPointMake(13.48, 24.17) controlPoint1: CGPointMake(14.14, 25.64) controlPoint2: CGPointMake(13.56, 25.13)];
        [bezier11Path addLineToPoint: CGPointMake(13.48, 23.87)];
        [bezier11Path addLineToPoint: CGPointMake(13.78, 21.96)];
        [bezier11Path addCurveToPoint: CGPointMake(15.66, 14.66) controlPoint1: CGPointMake(13.78, 21.96) controlPoint2: CGPointMake(15.37, 15.55)];
        [bezier11Path addCurveToPoint: CGPointMake(15.66, 14.59) controlPoint1: CGPointMake(15.66, 14.59) controlPoint2: CGPointMake(15.66, 14.59)];
        [bezier11Path addCurveToPoint: CGPointMake(12.03, 14.52) controlPoint1: CGPointMake(12.62, 14.59) controlPoint2: CGPointMake(12.03, 14.59)];
        [bezier11Path addCurveToPoint: CGPointMake(11.96, 14.96) controlPoint1: CGPointMake(12.03, 14.59) controlPoint2: CGPointMake(11.96, 14.96)];
        [bezier11Path addLineToPoint: CGPointMake(10.37, 22.18)];
        [bezier11Path addLineToPoint: CGPointMake(10.22, 22.77)];
        [bezier11Path addLineToPoint: CGPointMake(9.93, 24.76)];
        [bezier11Path addCurveToPoint: CGPointMake(10.3, 26.23) controlPoint1: CGPointMake(9.93, 25.35) controlPoint2: CGPointMake(10.08, 25.86)];
        [bezier11Path addCurveToPoint: CGPointMake(14.28, 27.71) controlPoint1: CGPointMake(11.02, 27.56) controlPoint2: CGPointMake(13.12, 27.71)];
        [bezier11Path addCurveToPoint: CGPointMake(18.2, 26.75) controlPoint1: CGPointMake(15.8, 27.71) controlPoint2: CGPointMake(17.25, 27.41)];
        [bezier11Path addCurveToPoint: CGPointMake(20.73, 22.77) controlPoint1: CGPointMake(19.87, 25.72) controlPoint2: CGPointMake(20.3, 24.17)];
        [bezier11Path addLineToPoint: CGPointMake(20.88, 22.03)];
        [bezier11Path addCurveToPoint: CGPointMake(22.77, 14.52) controlPoint1: CGPointMake(20.88, 22.03) controlPoint2: CGPointMake(22.48, 15.4)];
        [bezier11Path addCurveToPoint: CGPointMake(22.77, 14.44) controlPoint1: CGPointMake(22.77, 14.44) controlPoint2: CGPointMake(22.77, 14.44)];
        [bezier11Path addCurveToPoint: CGPointMake(19.72, 14.52) controlPoint1: CGPointMake(20.59, 14.59) controlPoint2: CGPointMake(19.94, 14.59)];
        [bezier11Path addLineToPoint: CGPointMake(19.72, 14.52)];
        [bezier11Path closePath];
        bezier11Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier11Path fill];
        
        
        //// Bezier 12 Drawing
        UIBezierPath* bezier12Path = [UIBezierPath bezierPath];
        [bezier12Path moveToPoint: CGPointMake(28.71, 27.78)];
        [bezier12Path addCurveToPoint: CGPointMake(25.95, 27.85) controlPoint1: CGPointMake(27.62, 27.78) controlPoint2: CGPointMake(27.26, 27.78)];
        [bezier12Path addLineToPoint: CGPointMake(25.88, 27.78)];
        [bezier12Path addCurveToPoint: CGPointMake(26.25, 26.31) controlPoint1: CGPointMake(26.03, 27.26) controlPoint2: CGPointMake(26.1, 26.82)];
        [bezier12Path addLineToPoint: CGPointMake(26.39, 25.64)];
        [bezier12Path addCurveToPoint: CGPointMake(26.9, 22.99) controlPoint1: CGPointMake(26.61, 24.61) controlPoint2: CGPointMake(26.82, 23.36)];
        [bezier12Path addCurveToPoint: CGPointMake(26.39, 22.18) controlPoint1: CGPointMake(26.9, 22.77) controlPoint2: CGPointMake(26.97, 22.18)];
        [bezier12Path addCurveToPoint: CGPointMake(25.59, 22.47) controlPoint1: CGPointMake(26.1, 22.18) controlPoint2: CGPointMake(25.88, 22.33)];
        [bezier12Path addCurveToPoint: CGPointMake(25.01, 25.27) controlPoint1: CGPointMake(25.45, 23.06) controlPoint2: CGPointMake(25.16, 24.61)];
        [bezier12Path addCurveToPoint: CGPointMake(24.5, 27.71) controlPoint1: CGPointMake(24.72, 26.75) controlPoint2: CGPointMake(24.65, 26.97)];
        [bezier12Path addLineToPoint: CGPointMake(24.43, 27.78)];
        [bezier12Path addCurveToPoint: CGPointMake(21.6, 27.85) controlPoint1: CGPointMake(23.35, 27.78) controlPoint2: CGPointMake(22.91, 27.78)];
        [bezier12Path addLineToPoint: CGPointMake(21.53, 27.78)];
        [bezier12Path addCurveToPoint: CGPointMake(22.18, 25.13) controlPoint1: CGPointMake(21.75, 26.89) controlPoint2: CGPointMake(21.97, 26.01)];
        [bezier12Path addCurveToPoint: CGPointMake(22.98, 20.56) controlPoint1: CGPointMake(22.69, 22.69) controlPoint2: CGPointMake(22.84, 21.81)];
        [bezier12Path addLineToPoint: CGPointMake(23.05, 20.48)];
        [bezier12Path addCurveToPoint: CGPointMake(25.95, 19.97) controlPoint1: CGPointMake(24.29, 20.34) controlPoint2: CGPointMake(24.65, 20.26)];
        [bezier12Path addLineToPoint: CGPointMake(26.1, 20.12)];
        [bezier12Path addLineToPoint: CGPointMake(25.88, 20.85)];
        [bezier12Path addCurveToPoint: CGPointMake(26.53, 20.48) controlPoint1: CGPointMake(26.1, 20.71) controlPoint2: CGPointMake(26.32, 20.56)];
        [bezier12Path addCurveToPoint: CGPointMake(28.27, 20.04) controlPoint1: CGPointMake(27.19, 20.19) controlPoint2: CGPointMake(27.91, 20.04)];
        [bezier12Path addCurveToPoint: CGPointMake(29.8, 20.93) controlPoint1: CGPointMake(28.85, 20.04) controlPoint2: CGPointMake(29.51, 20.19)];
        [bezier12Path addCurveToPoint: CGPointMake(29.58, 23.87) controlPoint1: CGPointMake(30.09, 21.52) controlPoint2: CGPointMake(29.87, 22.33)];
        [bezier12Path addLineToPoint: CGPointMake(29.43, 24.61)];
        [bezier12Path addCurveToPoint: CGPointMake(28.85, 27.78) controlPoint1: CGPointMake(29.07, 26.31) controlPoint2: CGPointMake(29, 26.6)];
        [bezier12Path addLineToPoint: CGPointMake(28.71, 27.78)];
        [bezier12Path addLineToPoint: CGPointMake(28.71, 27.78)];
        [bezier12Path closePath];
        bezier12Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier12Path fill];
        
        
        //// Bezier 13 Drawing
        UIBezierPath* bezier13Path = [UIBezierPath bezierPath];
        [bezier13Path moveToPoint: CGPointMake(33.13, 27.78)];
        [bezier13Path addCurveToPoint: CGPointMake(31.61, 27.78) controlPoint1: CGPointMake(32.48, 27.78) controlPoint2: CGPointMake(32.04, 27.78)];
        [bezier13Path addCurveToPoint: CGPointMake(30.16, 27.85) controlPoint1: CGPointMake(31.18, 27.78) controlPoint2: CGPointMake(30.81, 27.78)];
        [bezier13Path addLineToPoint: CGPointMake(30.16, 27.78)];
        [bezier13Path addLineToPoint: CGPointMake(30.09, 27.71)];
        [bezier13Path addCurveToPoint: CGPointMake(30.45, 26.6) controlPoint1: CGPointMake(30.23, 27.04) controlPoint2: CGPointMake(30.38, 26.82)];
        [bezier13Path addCurveToPoint: CGPointMake(30.74, 25.49) controlPoint1: CGPointMake(30.52, 26.38) controlPoint2: CGPointMake(30.6, 26.16)];
        [bezier13Path addCurveToPoint: CGPointMake(31.1, 23.51) controlPoint1: CGPointMake(30.96, 24.68) controlPoint2: CGPointMake(31.03, 24.02)];
        [bezier13Path addCurveToPoint: CGPointMake(31.32, 22.11) controlPoint1: CGPointMake(31.18, 22.99) controlPoint2: CGPointMake(31.25, 22.55)];
        [bezier13Path addLineToPoint: CGPointMake(31.39, 22.03)];
        [bezier13Path addLineToPoint: CGPointMake(31.47, 21.96)];
        [bezier13Path addCurveToPoint: CGPointMake(32.99, 21.74) controlPoint1: CGPointMake(32.12, 21.88) controlPoint2: CGPointMake(32.55, 21.81)];
        [bezier13Path addCurveToPoint: CGPointMake(34.51, 21.44) controlPoint1: CGPointMake(33.42, 21.66) controlPoint2: CGPointMake(33.86, 21.59)];
        [bezier13Path addLineToPoint: CGPointMake(34.51, 21.52)];
        [bezier13Path addLineToPoint: CGPointMake(34.51, 21.59)];
        [bezier13Path addCurveToPoint: CGPointMake(34.15, 23.14) controlPoint1: CGPointMake(34.37, 22.11) controlPoint2: CGPointMake(34.29, 22.62)];
        [bezier13Path addCurveToPoint: CGPointMake(33.78, 24.68) controlPoint1: CGPointMake(34, 23.65) controlPoint2: CGPointMake(33.93, 24.17)];
        [bezier13Path addCurveToPoint: CGPointMake(33.35, 26.53) controlPoint1: CGPointMake(33.57, 25.79) controlPoint2: CGPointMake(33.42, 26.23)];
        [bezier13Path addCurveToPoint: CGPointMake(33.21, 27.56) controlPoint1: CGPointMake(33.28, 26.82) controlPoint2: CGPointMake(33.28, 26.97)];
        [bezier13Path addLineToPoint: CGPointMake(33.13, 27.78)];
        [bezier13Path addLineToPoint: CGPointMake(33.13, 27.78)];
        [bezier13Path addLineToPoint: CGPointMake(33.13, 27.78)];
        [bezier13Path closePath];
        bezier13Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier13Path fill];
        
        
        //// Bezier 14 Drawing
        UIBezierPath* bezier14Path = [UIBezierPath bezierPath];
        [bezier14Path moveToPoint: CGPointMake(40.09, 23.8)];
        [bezier14Path addCurveToPoint: CGPointMake(39.44, 25.64) controlPoint1: CGPointMake(40.02, 24.09) controlPoint2: CGPointMake(39.8, 25.13)];
        [bezier14Path addCurveToPoint: CGPointMake(38.64, 26.16) controlPoint1: CGPointMake(39.22, 26.01) controlPoint2: CGPointMake(38.93, 26.16)];
        [bezier14Path addCurveToPoint: CGPointMake(37.99, 25.35) controlPoint1: CGPointMake(38.57, 26.16) controlPoint2: CGPointMake(37.99, 26.16)];
        [bezier14Path addCurveToPoint: CGPointMake(38.13, 24.09) controlPoint1: CGPointMake(37.99, 24.98) controlPoint2: CGPointMake(38.06, 24.54)];
        [bezier14Path addCurveToPoint: CGPointMake(39.66, 21.74) controlPoint1: CGPointMake(38.43, 22.84) controlPoint2: CGPointMake(38.79, 21.74)];
        [bezier14Path addCurveToPoint: CGPointMake(40.09, 23.8) controlPoint1: CGPointMake(40.31, 21.74) controlPoint2: CGPointMake(40.38, 22.55)];
        [bezier14Path addLineToPoint: CGPointMake(40.09, 23.8)];
        [bezier14Path closePath];
        [bezier14Path moveToPoint: CGPointMake(42.92, 23.95)];
        [bezier14Path addCurveToPoint: CGPointMake(42.63, 21) controlPoint1: CGPointMake(43.28, 22.25) controlPoint2: CGPointMake(42.99, 21.44)];
        [bezier14Path addCurveToPoint: CGPointMake(40.02, 20.04) controlPoint1: CGPointMake(42.05, 20.26) controlPoint2: CGPointMake(41.03, 20.04)];
        [bezier14Path addCurveToPoint: CGPointMake(36.76, 21.22) controlPoint1: CGPointMake(39.37, 20.04) controlPoint2: CGPointMake(37.92, 20.12)];
        [bezier14Path addCurveToPoint: CGPointMake(35.31, 24.09) controlPoint1: CGPointMake(35.96, 22.03) controlPoint2: CGPointMake(35.52, 23.06)];
        [bezier14Path addCurveToPoint: CGPointMake(36.47, 27.71) controlPoint1: CGPointMake(35.09, 25.13) controlPoint2: CGPointMake(34.8, 27.04)];
        [bezier14Path addCurveToPoint: CGPointMake(38.21, 28) controlPoint1: CGPointMake(36.98, 27.93) controlPoint2: CGPointMake(37.77, 28)];
        [bezier14Path addCurveToPoint: CGPointMake(41.69, 26.6) controlPoint1: CGPointMake(39.44, 28) controlPoint2: CGPointMake(40.74, 27.63)];
        [bezier14Path addCurveToPoint: CGPointMake(42.92, 23.95) controlPoint1: CGPointMake(42.48, 25.72) controlPoint2: CGPointMake(42.77, 24.46)];
        [bezier14Path addLineToPoint: CGPointMake(42.92, 23.95)];
        [bezier14Path closePath];
        bezier14Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier14Path fill];
        
        
        //// Bezier 15 Drawing
        UIBezierPath* bezier15Path = [UIBezierPath bezierPath];
        [bezier15Path moveToPoint: CGPointMake(69.53, 27.85)];
        [bezier15Path addCurveToPoint: CGPointMake(66.63, 27.93) controlPoint1: CGPointMake(68.22, 27.85) controlPoint2: CGPointMake(67.86, 27.85)];
        [bezier15Path addLineToPoint: CGPointMake(66.56, 27.85)];
        [bezier15Path addCurveToPoint: CGPointMake(67.5, 24.02) controlPoint1: CGPointMake(66.92, 26.6) controlPoint2: CGPointMake(67.21, 25.35)];
        [bezier15Path addCurveToPoint: CGPointMake(68.08, 20.71) controlPoint1: CGPointMake(67.86, 22.33) controlPoint2: CGPointMake(67.93, 21.66)];
        [bezier15Path addLineToPoint: CGPointMake(68.15, 20.63)];
        [bezier15Path addCurveToPoint: CGPointMake(71.19, 20.12) controlPoint1: CGPointMake(69.46, 20.41) controlPoint2: CGPointMake(69.82, 20.41)];
        [bezier15Path addLineToPoint: CGPointMake(71.27, 20.26)];
        [bezier15Path addCurveToPoint: CGPointMake(70.54, 23.43) controlPoint1: CGPointMake(71.05, 21.29) controlPoint2: CGPointMake(70.76, 22.33)];
        [bezier15Path addCurveToPoint: CGPointMake(69.67, 27.85) controlPoint1: CGPointMake(70.03, 25.64) controlPoint2: CGPointMake(69.89, 26.75)];
        [bezier15Path addLineToPoint: CGPointMake(69.53, 27.85)];
        [bezier15Path addLineToPoint: CGPointMake(69.53, 27.85)];
        [bezier15Path closePath];
        bezier15Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier15Path fill];
        
        
        //// Bezier 16 Drawing
        UIBezierPath* bezier16Path = [UIBezierPath bezierPath];
        [bezier16Path moveToPoint: CGPointMake(67.57, 23.95)];
        [bezier16Path addCurveToPoint: CGPointMake(66.92, 25.72) controlPoint1: CGPointMake(67.5, 24.24) controlPoint2: CGPointMake(67.28, 25.27)];
        [bezier16Path addCurveToPoint: CGPointMake(65.83, 26.23) controlPoint1: CGPointMake(66.7, 26.01) controlPoint2: CGPointMake(66.19, 26.23)];
        [bezier16Path addCurveToPoint: CGPointMake(65.18, 25.42) controlPoint1: CGPointMake(65.76, 26.23) controlPoint2: CGPointMake(65.18, 26.23)];
        [bezier16Path addCurveToPoint: CGPointMake(65.32, 24.17) controlPoint1: CGPointMake(65.18, 25.05) controlPoint2: CGPointMake(65.25, 24.61)];
        [bezier16Path addCurveToPoint: CGPointMake(66.84, 21.81) controlPoint1: CGPointMake(65.61, 22.92) controlPoint2: CGPointMake(65.98, 21.81)];
        [bezier16Path addCurveToPoint: CGPointMake(67.57, 23.95) controlPoint1: CGPointMake(67.57, 21.88) controlPoint2: CGPointMake(67.86, 22.69)];
        [bezier16Path addLineToPoint: CGPointMake(67.57, 23.95)];
        [bezier16Path closePath];
        [bezier16Path moveToPoint: CGPointMake(70.11, 24.09)];
        [bezier16Path addCurveToPoint: CGPointMake(68.73, 23.36) controlPoint1: CGPointMake(70.47, 22.4) controlPoint2: CGPointMake(68.95, 23.95)];
        [bezier16Path addCurveToPoint: CGPointMake(67.06, 20.12) controlPoint1: CGPointMake(68.37, 22.47) controlPoint2: CGPointMake(68.58, 20.71)];
        [bezier16Path addCurveToPoint: CGPointMake(63.94, 21.29) controlPoint1: CGPointMake(66.48, 19.89) controlPoint2: CGPointMake(65.11, 20.19)];
        [bezier16Path addCurveToPoint: CGPointMake(62.49, 24.17) controlPoint1: CGPointMake(63.15, 22.11) controlPoint2: CGPointMake(62.71, 23.14)];
        [bezier16Path addCurveToPoint: CGPointMake(63.66, 27.71) controlPoint1: CGPointMake(62.28, 25.2) controlPoint2: CGPointMake(61.99, 27.04)];
        [bezier16Path addCurveToPoint: CGPointMake(65.18, 28) controlPoint1: CGPointMake(64.16, 27.93) controlPoint2: CGPointMake(64.67, 28)];
        [bezier16Path addCurveToPoint: CGPointMake(69.09, 24.24) controlPoint1: CGPointMake(66.84, 27.93) controlPoint2: CGPointMake(68.15, 25.27)];
        [bezier16Path addCurveToPoint: CGPointMake(70.11, 24.09) controlPoint1: CGPointMake(69.89, 23.51) controlPoint2: CGPointMake(70.03, 24.61)];
        [bezier16Path addLineToPoint: CGPointMake(70.11, 24.09)];
        [bezier16Path closePath];
        bezier16Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier16Path fill];
        
        
        //// Bezier 17 Drawing
        UIBezierPath* bezier17Path = [UIBezierPath bezierPath];
        [bezier17Path moveToPoint: CGPointMake(50.39, 27.78)];
        [bezier17Path addCurveToPoint: CGPointMake(47.63, 27.85) controlPoint1: CGPointMake(49.3, 27.78) controlPoint2: CGPointMake(48.94, 27.78)];
        [bezier17Path addLineToPoint: CGPointMake(47.56, 27.78)];
        [bezier17Path addCurveToPoint: CGPointMake(47.92, 26.31) controlPoint1: CGPointMake(47.63, 27.26) controlPoint2: CGPointMake(47.78, 26.82)];
        [bezier17Path addLineToPoint: CGPointMake(48.07, 25.64)];
        [bezier17Path addCurveToPoint: CGPointMake(48.58, 22.99) controlPoint1: CGPointMake(48.28, 24.61) controlPoint2: CGPointMake(48.5, 23.36)];
        [bezier17Path addCurveToPoint: CGPointMake(48.07, 22.18) controlPoint1: CGPointMake(48.58, 22.77) controlPoint2: CGPointMake(48.65, 22.18)];
        [bezier17Path addCurveToPoint: CGPointMake(47.27, 22.47) controlPoint1: CGPointMake(47.78, 22.18) controlPoint2: CGPointMake(47.56, 22.33)];
        [bezier17Path addCurveToPoint: CGPointMake(46.62, 25.27) controlPoint1: CGPointMake(47.12, 23.06) controlPoint2: CGPointMake(46.83, 24.61)];
        [bezier17Path addCurveToPoint: CGPointMake(46.18, 27.71) controlPoint1: CGPointMake(46.33, 26.75) controlPoint2: CGPointMake(46.26, 26.97)];
        [bezier17Path addLineToPoint: CGPointMake(46.11, 27.78)];
        [bezier17Path addCurveToPoint: CGPointMake(43.28, 27.85) controlPoint1: CGPointMake(45.02, 27.78) controlPoint2: CGPointMake(44.59, 27.78)];
        [bezier17Path addLineToPoint: CGPointMake(43.21, 27.78)];
        [bezier17Path addCurveToPoint: CGPointMake(43.86, 25.13) controlPoint1: CGPointMake(43.43, 26.89) controlPoint2: CGPointMake(43.64, 26.01)];
        [bezier17Path addCurveToPoint: CGPointMake(44.66, 20.56) controlPoint1: CGPointMake(44.37, 22.69) controlPoint2: CGPointMake(44.52, 21.81)];
        [bezier17Path addLineToPoint: CGPointMake(44.73, 20.48)];
        [bezier17Path addCurveToPoint: CGPointMake(47.63, 19.97) controlPoint1: CGPointMake(45.97, 20.34) controlPoint2: CGPointMake(46.33, 20.26)];
        [bezier17Path addLineToPoint: CGPointMake(47.78, 20.12)];
        [bezier17Path addLineToPoint: CGPointMake(47.56, 20.85)];
        [bezier17Path addCurveToPoint: CGPointMake(48.21, 20.48) controlPoint1: CGPointMake(47.78, 20.71) controlPoint2: CGPointMake(47.99, 20.56)];
        [bezier17Path addCurveToPoint: CGPointMake(49.95, 20.04) controlPoint1: CGPointMake(48.87, 20.19) controlPoint2: CGPointMake(49.59, 20.04)];
        [bezier17Path addCurveToPoint: CGPointMake(51.48, 20.93) controlPoint1: CGPointMake(50.53, 20.04) controlPoint2: CGPointMake(51.18, 20.19)];
        [bezier17Path addCurveToPoint: CGPointMake(51.18, 23.87) controlPoint1: CGPointMake(51.77, 21.52) controlPoint2: CGPointMake(51.55, 22.33)];
        [bezier17Path addLineToPoint: CGPointMake(51.04, 24.61)];
        [bezier17Path addCurveToPoint: CGPointMake(50.46, 27.78) controlPoint1: CGPointMake(50.68, 26.31) controlPoint2: CGPointMake(50.61, 26.6)];
        [bezier17Path addLineToPoint: CGPointMake(50.39, 27.78)];
        [bezier17Path addLineToPoint: CGPointMake(50.39, 27.78)];
        [bezier17Path closePath];
        bezier17Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier17Path fill];
        
        
        //// Bezier 18 Drawing
        UIBezierPath* bezier18Path = [UIBezierPath bezierPath];
        [bezier18Path moveToPoint: CGPointMake(59.81, 14.52)];
        [bezier18Path addLineToPoint: CGPointMake(58.94, 14.52)];
        [bezier18Path addCurveToPoint: CGPointMake(55.24, 14.52) controlPoint1: CGPointMake(56.62, 14.52) controlPoint2: CGPointMake(55.68, 14.52)];
        [bezier18Path addCurveToPoint: CGPointMake(55.17, 15.03) controlPoint1: CGPointMake(55.24, 14.66) controlPoint2: CGPointMake(55.17, 15.03)];
        [bezier18Path addLineToPoint: CGPointMake(54.3, 19.01)];
        [bezier18Path addCurveToPoint: CGPointMake(52.2, 27.85) controlPoint1: CGPointMake(54.3, 19.01) controlPoint2: CGPointMake(52.27, 27.48)];
        [bezier18Path addCurveToPoint: CGPointMake(55.46, 27.85) controlPoint1: CGPointMake(54.23, 27.85) controlPoint2: CGPointMake(55.1, 27.85)];
        [bezier18Path addCurveToPoint: CGPointMake(56.04, 25.13) controlPoint1: CGPointMake(55.53, 27.48) controlPoint2: CGPointMake(56.04, 25.13)];
        [bezier18Path addCurveToPoint: CGPointMake(56.48, 23.36) controlPoint1: CGPointMake(56.04, 25.13) controlPoint2: CGPointMake(56.48, 23.43)];
        [bezier18Path addCurveToPoint: CGPointMake(56.77, 23.14) controlPoint1: CGPointMake(56.48, 23.36) controlPoint2: CGPointMake(56.62, 23.21)];
        [bezier18Path addLineToPoint: CGPointMake(56.98, 23.14)];
        [bezier18Path addCurveToPoint: CGPointMake(62.35, 21.96) controlPoint1: CGPointMake(58.73, 23.14) controlPoint2: CGPointMake(60.76, 23.14)];
        [bezier18Path addCurveToPoint: CGPointMake(64.45, 18.49) controlPoint1: CGPointMake(63.44, 21.15) controlPoint2: CGPointMake(64.16, 19.97)];
        [bezier18Path addCurveToPoint: CGPointMake(64.6, 17.32) controlPoint1: CGPointMake(64.52, 18.13) controlPoint2: CGPointMake(64.6, 17.68)];
        [bezier18Path addCurveToPoint: CGPointMake(64.16, 15.77) controlPoint1: CGPointMake(64.6, 16.8) controlPoint2: CGPointMake(64.52, 16.21)];
        [bezier18Path addCurveToPoint: CGPointMake(59.81, 14.52) controlPoint1: CGPointMake(63.22, 14.52) controlPoint2: CGPointMake(61.62, 14.52)];
        [bezier18Path addLineToPoint: CGPointMake(59.81, 14.52)];
        [bezier18Path closePath];
        [bezier18Path moveToPoint: CGPointMake(60.97, 18.64)];
        [bezier18Path addCurveToPoint: CGPointMake(59.52, 20.63) controlPoint1: CGPointMake(60.76, 19.53) controlPoint2: CGPointMake(60.25, 20.26)];
        [bezier18Path addCurveToPoint: CGPointMake(57.42, 20.93) controlPoint1: CGPointMake(58.94, 20.93) controlPoint2: CGPointMake(58.22, 20.93)];
        [bezier18Path addLineToPoint: CGPointMake(56.91, 20.93)];
        [bezier18Path addLineToPoint: CGPointMake(56.91, 20.71)];
        [bezier18Path addLineToPoint: CGPointMake(57.78, 16.73)];
        [bezier18Path addLineToPoint: CGPointMake(57.78, 16.51)];
        [bezier18Path addLineToPoint: CGPointMake(57.78, 16.36)];
        [bezier18Path addLineToPoint: CGPointMake(58.14, 16.43)];
        [bezier18Path addCurveToPoint: CGPointMake(60.03, 16.58) controlPoint1: CGPointMake(58.14, 16.43) controlPoint2: CGPointMake(59.96, 16.58)];
        [bezier18Path addCurveToPoint: CGPointMake(60.97, 18.64) controlPoint1: CGPointMake(60.9, 16.95) controlPoint2: CGPointMake(61.19, 17.68)];
        [bezier18Path addLineToPoint: CGPointMake(60.97, 18.64)];
        [bezier18Path closePath];
        bezier18Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier18Path fill];
        
        
        //// Bezier 19 Drawing
        UIBezierPath* bezier19Path = [UIBezierPath bezierPath];
        [bezier19Path moveToPoint: CGPointMake(80.26, 20.04)];
        [bezier19Path addLineToPoint: CGPointMake(80.19, 19.89)];
        [bezier19Path addCurveToPoint: CGPointMake(77.36, 20.41) controlPoint1: CGPointMake(78.81, 20.19) controlPoint2: CGPointMake(78.59, 20.19)];
        [bezier19Path addLineToPoint: CGPointMake(77.28, 20.48)];
        [bezier19Path addLineToPoint: CGPointMake(77.28, 20.56)];
        [bezier19Path addLineToPoint: CGPointMake(77.28, 20.56)];
        [bezier19Path addCurveToPoint: CGPointMake(75.62, 23.95) controlPoint1: CGPointMake(76.34, 22.69) controlPoint2: CGPointMake(76.42, 22.25)];
        [bezier19Path addCurveToPoint: CGPointMake(75.62, 23.73) controlPoint1: CGPointMake(75.62, 23.87) controlPoint2: CGPointMake(75.62, 23.8)];
        [bezier19Path addLineToPoint: CGPointMake(75.4, 20.04)];
        [bezier19Path addLineToPoint: CGPointMake(75.26, 19.89)];
        [bezier19Path addCurveToPoint: CGPointMake(72.5, 20.41) controlPoint1: CGPointMake(73.88, 20.19) controlPoint2: CGPointMake(73.81, 20.19)];
        [bezier19Path addLineToPoint: CGPointMake(72.43, 20.48)];
        [bezier19Path addCurveToPoint: CGPointMake(72.43, 20.63) controlPoint1: CGPointMake(72.43, 20.56) controlPoint2: CGPointMake(72.43, 20.56)];
        [bezier19Path addLineToPoint: CGPointMake(72.43, 20.63)];
        [bezier19Path addCurveToPoint: CGPointMake(72.72, 22.62) controlPoint1: CGPointMake(72.57, 21.44) controlPoint2: CGPointMake(72.57, 21.29)];
        [bezier19Path addCurveToPoint: CGPointMake(72.93, 24.61) controlPoint1: CGPointMake(72.79, 23.28) controlPoint2: CGPointMake(72.86, 23.95)];
        [bezier19Path addCurveToPoint: CGPointMake(73.3, 27.85) controlPoint1: CGPointMake(73.08, 25.72) controlPoint2: CGPointMake(73.15, 26.23)];
        [bezier19Path addCurveToPoint: CGPointMake(71.34, 31.17) controlPoint1: CGPointMake(72.43, 29.33) controlPoint2: CGPointMake(72.21, 29.92)];
        [bezier19Path addLineToPoint: CGPointMake(71.41, 31.32)];
        [bezier19Path addCurveToPoint: CGPointMake(73.95, 31.24) controlPoint1: CGPointMake(72.72, 31.24) controlPoint2: CGPointMake(73.01, 31.24)];
        [bezier19Path addLineToPoint: CGPointMake(74.17, 31.02)];
        [bezier19Path addCurveToPoint: CGPointMake(80.26, 20.04) controlPoint1: CGPointMake(74.89, 29.47) controlPoint2: CGPointMake(80.26, 20.04)];
        [bezier19Path addLineToPoint: CGPointMake(80.26, 20.04)];
        [bezier19Path closePath];
        bezier19Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier19Path fill];
        
        
        //// Bezier 20 Drawing
        UIBezierPath* bezier20Path = [UIBezierPath bezierPath];
        [bezier20Path moveToPoint: CGPointMake(34.37, 21)];
        [bezier20Path addCurveToPoint: CGPointMake(34.58, 19.45) controlPoint1: CGPointMake(35.09, 20.48) controlPoint2: CGPointMake(35.16, 19.82)];
        [bezier20Path addCurveToPoint: CGPointMake(32.19, 19.67) controlPoint1: CGPointMake(34, 19.08) controlPoint2: CGPointMake(32.92, 19.23)];
        [bezier20Path addCurveToPoint: CGPointMake(31.97, 21.22) controlPoint1: CGPointMake(31.47, 20.19) controlPoint2: CGPointMake(31.39, 20.85)];
        [bezier20Path addCurveToPoint: CGPointMake(34.37, 21) controlPoint1: CGPointMake(32.55, 21.59) controlPoint2: CGPointMake(33.64, 21.44)];
        [bezier20Path addLineToPoint: CGPointMake(34.37, 21)];
        [bezier20Path closePath];
        bezier20Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier20Path fill];
        
        
        //// Bezier 21 Drawing
        UIBezierPath* bezier21Path = [UIBezierPath bezierPath];
        [bezier21Path moveToPoint: CGPointMake(74.02, 31.17)];
        [bezier21Path addLineToPoint: CGPointMake(72.93, 33.01)];
        [bezier21Path addCurveToPoint: CGPointMake(70.98, 34.12) controlPoint1: CGPointMake(72.57, 33.67) controlPoint2: CGPointMake(71.99, 34.12)];
        [bezier21Path addLineToPoint: CGPointMake(69.31, 34.12)];
        [bezier21Path addLineToPoint: CGPointMake(69.82, 32.49)];
        [bezier21Path addLineToPoint: CGPointMake(70.18, 32.49)];
        [bezier21Path addCurveToPoint: CGPointMake(70.54, 32.42) controlPoint1: CGPointMake(70.33, 32.49) controlPoint2: CGPointMake(70.47, 32.49)];
        [bezier21Path addCurveToPoint: CGPointMake(70.76, 32.2) controlPoint1: CGPointMake(70.62, 32.42) controlPoint2: CGPointMake(70.69, 32.35)];
        [bezier21Path addLineToPoint: CGPointMake(71.41, 31.17)];
        [bezier21Path addLineToPoint: CGPointMake(74.02, 31.17)];
        [bezier21Path addLineToPoint: CGPointMake(74.02, 31.17)];
        [bezier21Path closePath];
        bezier21Path.miterLimit = 4;
        
        [[UIColor whiteColor] setFill];
        [bezier21Path fill];
    }
}

@end
