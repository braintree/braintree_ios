#import "BTUIPayPalMonogramColorView.h"

@implementation BTUIPayPalMonogramColorView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.artDimensions = CGSizeMake(156, 184);
        self.opaque = NO;
    }
    return self;
}

- (void)updateConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                    attribute:NSLayoutAttributeWidth
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self
                                                    attribute:NSLayoutAttributeHeight
                                                    multiplier:156.0f/184.0f
                                                      constant:0]];
    [super updateConstraints];
}

- (void)drawArt
{
    //// Color Declarations
    UIColor* color2 = [UIColor colorWithRed: 0.007 green: 0.082 blue: 0.337 alpha: 1];
    UIColor* color0 = [UIColor colorWithRed: 0.005 green: 0.123 blue: 0.454 alpha: 1];
    UIColor* color1 = [UIColor colorWithRed: 0.066 green: 0.536 blue: 0.839 alpha: 1];
    
    //// Group
    {
        //// Bezier Drawing
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: CGPointMake(146.33, 108.36)];
        [bezierPath addCurveToPoint: CGPointMake(154.08, 87.06) controlPoint1: CGPointMake(149.88, 102.42) controlPoint2: CGPointMake(152.48, 95.25)];
        [bezierPath addCurveToPoint: CGPointMake(154.86, 67.84) controlPoint1: CGPointMake(155.48, 79.84) controlPoint2: CGPointMake(155.75, 73.38)];
        [bezierPath addCurveToPoint: CGPointMake(148.18, 53.03) controlPoint1: CGPointMake(153.93, 62) controlPoint2: CGPointMake(151.68, 57.02)];
        [bezierPath addCurveToPoint: CGPointMake(140.1, 46.8) controlPoint1: CGPointMake(146.06, 50.61) controlPoint2: CGPointMake(143.34, 48.52)];
        [bezierPath addLineToPoint: CGPointMake(139.97, 46.73)];
        [bezierPath addLineToPoint: CGPointMake(139.99, 46.69)];
        [bezierPath addLineToPoint: CGPointMake(140.01, 46.61)];
        [bezierPath addCurveToPoint: CGPointMake(139.88, 28.23) controlPoint1: CGPointMake(141.13, 39.41) controlPoint2: CGPointMake(141.09, 33.4)];
        [bezierPath addCurveToPoint: CGPointMake(132.31, 13.96) controlPoint1: CGPointMake(138.66, 23.04) controlPoint2: CGPointMake(136.18, 18.37)];
        [bezierPath addCurveToPoint: CGPointMake(88.93, 0.19) controlPoint1: CGPointMake(124.29, 4.82) controlPoint2: CGPointMake(109.7, 0.19)];
        [bezierPath addLineToPoint: CGPointMake(31.88, 0.19)];
        [bezierPath addCurveToPoint: CGPointMake(24, 6.92) controlPoint1: CGPointMake(27.93, 0.19) controlPoint2: CGPointMake(24.62, 3.02)];
        [bezierPath addLineToPoint: CGPointMake(0.24, 157.57)];
        [bezierPath addCurveToPoint: CGPointMake(1.32, 161.36) controlPoint1: CGPointMake(0.03, 158.93) controlPoint2: CGPointMake(0.42, 160.31)];
        [bezierPath addCurveToPoint: CGPointMake(4.9, 163.01) controlPoint1: CGPointMake(2.21, 162.41) controlPoint2: CGPointMake(3.52, 163.01)];
        [bezierPath addLineToPoint: CGPointMake(40.34, 163.01)];
        [bezierPath addLineToPoint: CGPointMake(40.31, 163.23)];
        [bezierPath addLineToPoint: CGPointMake(37.87, 178.64)];
        [bezierPath addCurveToPoint: CGPointMake(38.81, 181.94) controlPoint1: CGPointMake(37.69, 179.83) controlPoint2: CGPointMake(38.03, 181.03)];
        [bezierPath addCurveToPoint: CGPointMake(41.92, 183.38) controlPoint1: CGPointMake(39.59, 182.85) controlPoint2: CGPointMake(40.72, 183.38)];
        [bezierPath addLineToPoint: CGPointMake(71.61, 183.38)];
        [bezierPath addCurveToPoint: CGPointMake(78.48, 177.51) controlPoint1: CGPointMake(75.05, 183.38) controlPoint2: CGPointMake(77.94, 180.91)];
        [bezierPath addLineToPoint: CGPointMake(78.77, 175.99)];
        [bezierPath addLineToPoint: CGPointMake(84.36, 140.53)];
        [bezierPath addLineToPoint: CGPointMake(84.72, 138.57)];
        [bezierPath addCurveToPoint: CGPointMake(91.96, 132.39) controlPoint1: CGPointMake(85.29, 134.99) controlPoint2: CGPointMake(88.33, 132.39)];
        [bezierPath addLineToPoint: CGPointMake(96.4, 132.39)];
        [bezierPath addCurveToPoint: CGPointMake(133.54, 122.36) controlPoint1: CGPointMake(111.68, 132.39) controlPoint2: CGPointMake(124.18, 129.01)];
        [bezierPath addCurveToPoint: CGPointMake(146.33, 108.36) controlPoint1: CGPointMake(138.66, 118.72) controlPoint2: CGPointMake(142.96, 114.01)];
        [bezierPath closePath];
        bezierPath.miterLimit = 4;
        
        [color0 setFill];
        [bezierPath fill];
        
        
        //// Group 2
        {
            //// Group 3
            {
                //// Bezier 2 Drawing
                UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
                [bezier2Path moveToPoint: CGPointMake(58.47, 46.83)];
                [bezier2Path addCurveToPoint: CGPointMake(62.44, 41.5) controlPoint1: CGPointMake(58.85, 44.44) controlPoint2: CGPointMake(60.38, 42.49)];
                [bezier2Path addCurveToPoint: CGPointMake(65.53, 40.8) controlPoint1: CGPointMake(63.38, 41.05) controlPoint2: CGPointMake(64.43, 40.8)];
                [bezier2Path addLineToPoint: CGPointMake(110.25, 40.8)];
                [bezier2Path addCurveToPoint: CGPointMake(125, 41.87) controlPoint1: CGPointMake(115.55, 40.8) controlPoint2: CGPointMake(120.48, 41.14)];
                [bezier2Path addCurveToPoint: CGPointMake(128.77, 42.59) controlPoint1: CGPointMake(126.29, 42.08) controlPoint2: CGPointMake(127.55, 42.32)];
                [bezier2Path addCurveToPoint: CGPointMake(132.32, 43.5) controlPoint1: CGPointMake(129.99, 42.86) controlPoint2: CGPointMake(131.17, 43.16)];
                [bezier2Path addCurveToPoint: CGPointMake(134.01, 44.03) controlPoint1: CGPointMake(132.89, 43.66) controlPoint2: CGPointMake(133.46, 43.84)];
                [bezier2Path addCurveToPoint: CGPointMake(140.19, 46.64) controlPoint1: CGPointMake(136.23, 44.76) controlPoint2: CGPointMake(138.29, 45.63)];
                [bezier2Path addCurveToPoint: CGPointMake(132.45, 13.84) controlPoint1: CGPointMake(142.43, 32.36) controlPoint2: CGPointMake(140.18, 22.64)];
                [bezier2Path addCurveToPoint: CGPointMake(88.93, 0) controlPoint1: CGPointMake(123.95, 4.15) controlPoint2: CGPointMake(108.59, 0)];
                [bezier2Path addLineToPoint: CGPointMake(31.88, 0)];
                [bezier2Path addCurveToPoint: CGPointMake(23.82, 6.89) controlPoint1: CGPointMake(27.86, 0) controlPoint2: CGPointMake(24.44, 2.92)];
                [bezier2Path addLineToPoint: CGPointMake(0.06, 157.54)];
                [bezier2Path addCurveToPoint: CGPointMake(4.9, 163.2) controlPoint1: CGPointMake(-0.41, 160.51) controlPoint2: CGPointMake(1.89, 163.2)];
                [bezier2Path addLineToPoint: CGPointMake(40.12, 163.2)];
                [bezier2Path addLineToPoint: CGPointMake(48.97, 107.09)];
                [bezier2Path addLineToPoint: CGPointMake(58.47, 46.83)];
                [bezier2Path closePath];
                bezier2Path.miterLimit = 4;
                
                [color0 setFill];
                [bezier2Path fill];
                
                
                //// Bezier 3 Drawing
                UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
                [bezier3Path moveToPoint: CGPointMake(140.19, 46.64)];
                [bezier3Path addLineToPoint: CGPointMake(140.19, 46.64)];
                [bezier3Path addLineToPoint: CGPointMake(140.19, 46.64)];
                [bezier3Path addCurveToPoint: CGPointMake(139.61, 49.98) controlPoint1: CGPointMake(140.02, 47.73) controlPoint2: CGPointMake(139.83, 48.84)];
                [bezier3Path addCurveToPoint: CGPointMake(73.47, 101.96) controlPoint1: CGPointMake(132.09, 88.61) controlPoint2: CGPointMake(106.34, 101.96)];
                [bezier3Path addLineToPoint: CGPointMake(56.73, 101.96)];
                [bezier3Path addCurveToPoint: CGPointMake(48.69, 108.85) controlPoint1: CGPointMake(52.71, 101.96) controlPoint2: CGPointMake(49.32, 104.89)];
                [bezier3Path addLineToPoint: CGPointMake(48.69, 108.85)];
                [bezier3Path addLineToPoint: CGPointMake(48.69, 108.85)];
                [bezier3Path addLineToPoint: CGPointMake(40.12, 163.2)];
                [bezier3Path addLineToPoint: CGPointMake(37.69, 178.61)];
                [bezier3Path addCurveToPoint: CGPointMake(41.92, 183.56) controlPoint1: CGPointMake(37.28, 181.21) controlPoint2: CGPointMake(39.29, 183.56)];
                [bezier3Path addLineToPoint: CGPointMake(71.61, 183.56)];
                [bezier3Path addCurveToPoint: CGPointMake(78.66, 177.54) controlPoint1: CGPointMake(75.12, 183.56) controlPoint2: CGPointMake(78.11, 181.01)];
                [bezier3Path addLineToPoint: CGPointMake(78.95, 176.03)];
                [bezier3Path addLineToPoint: CGPointMake(84.55, 140.56)];
                [bezier3Path addLineToPoint: CGPointMake(84.91, 138.6)];
                [bezier3Path addCurveToPoint: CGPointMake(91.96, 132.58) controlPoint1: CGPointMake(85.45, 135.13) controlPoint2: CGPointMake(88.45, 132.58)];
                [bezier3Path addLineToPoint: CGPointMake(96.4, 132.58)];
                [bezier3Path addCurveToPoint: CGPointMake(154.26, 87.1) controlPoint1: CGPointMake(125.16, 132.58) controlPoint2: CGPointMake(147.68, 120.89)];
                [bezier3Path addCurveToPoint: CGPointMake(148.32, 52.91) controlPoint1: CGPointMake(157.01, 72.98) controlPoint2: CGPointMake(155.59, 61.19)];
                [bezier3Path addCurveToPoint: CGPointMake(140.19, 46.64) controlPoint1: CGPointMake(146.12, 50.4) controlPoint2: CGPointMake(143.38, 48.33)];
                [bezier3Path closePath];
                bezier3Path.miterLimit = 4;
                
                [color1 setFill];
                [bezier3Path fill];
                
                
                //// Bezier 4 Drawing
                UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
                [bezier4Path moveToPoint: CGPointMake(132.32, 43.5)];
                [bezier4Path addCurveToPoint: CGPointMake(128.77, 42.59) controlPoint1: CGPointMake(131.17, 43.16) controlPoint2: CGPointMake(129.99, 42.86)];
                [bezier4Path addCurveToPoint: CGPointMake(125, 41.87) controlPoint1: CGPointMake(127.55, 42.32) controlPoint2: CGPointMake(126.29, 42.08)];
                [bezier4Path addCurveToPoint: CGPointMake(110.25, 40.8) controlPoint1: CGPointMake(120.48, 41.15) controlPoint2: CGPointMake(115.54, 40.8)];
                [bezier4Path addLineToPoint: CGPointMake(65.53, 40.8)];
                [bezier4Path addCurveToPoint: CGPointMake(62.44, 41.5) controlPoint1: CGPointMake(64.43, 40.8) controlPoint2: CGPointMake(63.38, 41.05)];
                [bezier4Path addCurveToPoint: CGPointMake(58.47, 46.83) controlPoint1: CGPointMake(60.38, 42.49) controlPoint2: CGPointMake(58.85, 44.44)];
                [bezier4Path addLineToPoint: CGPointMake(48.97, 107.09)];
                [bezier4Path addLineToPoint: CGPointMake(48.69, 108.86)];
                [bezier4Path addCurveToPoint: CGPointMake(56.73, 101.96) controlPoint1: CGPointMake(49.32, 104.89) controlPoint2: CGPointMake(52.71, 101.96)];
                [bezier4Path addLineToPoint: CGPointMake(73.47, 101.96)];
                [bezier4Path addCurveToPoint: CGPointMake(139.61, 49.98) controlPoint1: CGPointMake(106.34, 101.96) controlPoint2: CGPointMake(132.09, 88.61)];
                [bezier4Path addCurveToPoint: CGPointMake(140.19, 46.64) controlPoint1: CGPointMake(139.83, 48.84) controlPoint2: CGPointMake(140.02, 47.73)];
                [bezier4Path addCurveToPoint: CGPointMake(134.01, 44.03) controlPoint1: CGPointMake(138.29, 45.63) controlPoint2: CGPointMake(136.23, 44.76)];
                [bezier4Path addCurveToPoint: CGPointMake(132.32, 43.5) controlPoint1: CGPointMake(133.46, 43.84) controlPoint2: CGPointMake(132.89, 43.67)];
                [bezier4Path closePath];
                bezier4Path.miterLimit = 4;
                
                [color2 setFill];
                [bezier4Path fill];
            }
        }
    }
    
    
}


@end
