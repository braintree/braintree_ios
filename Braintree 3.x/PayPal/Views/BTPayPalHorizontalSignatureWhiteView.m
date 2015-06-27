#import "BTPayPalHorizontalSignatureWhiteView.h"

@implementation BTPayPalHorizontalSignatureWhiteView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.artDimensions = CGSizeMake(405, 99);
        self.opaque = NO;
    }
    return self;
}

- (void)drawArt
{
    //// Color Declarations
    UIColor* color0 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Group
    {
        //// Group 2
        {
            //// Group 3
            {
                //// Bezier Drawing
                UIBezierPath* bezierPath = [UIBezierPath bezierPath];
                [bezierPath moveToPoint: CGPointMake(311.63, 21.95)];
                [bezierPath addLineToPoint: CGPointMake(289.38, 21.95)];
                [bezierPath addCurveToPoint: CGPointMake(286.33, 24.56) controlPoint1: CGPointMake(287.86, 21.95) controlPoint2: CGPointMake(286.56, 23.06)];
                [bezierPath addLineToPoint: CGPointMake(277.33, 81.62)];
                [bezierPath addCurveToPoint: CGPointMake(279.16, 83.76) controlPoint1: CGPointMake(277.15, 82.74) controlPoint2: CGPointMake(278.02, 83.76)];
                [bezierPath addLineToPoint: CGPointMake(290.58, 83.76)];
                [bezierPath addCurveToPoint: CGPointMake(292.71, 81.93) controlPoint1: CGPointMake(291.64, 83.76) controlPoint2: CGPointMake(292.55, 82.99)];
                [bezierPath addLineToPoint: CGPointMake(295.27, 65.76)];
                [bezierPath addCurveToPoint: CGPointMake(298.32, 63.15) controlPoint1: CGPointMake(295.5, 64.26) controlPoint2: CGPointMake(296.8, 63.15)];
                [bezierPath addLineToPoint: CGPointMake(305.36, 63.15)];
                [bezierPath addCurveToPoint: CGPointMake(330.68, 42) controlPoint1: CGPointMake(320.01, 63.15) controlPoint2: CGPointMake(328.47, 56.06)];
                [bezierPath addCurveToPoint: CGPointMake(327.85, 27.64) controlPoint1: CGPointMake(331.68, 35.85) controlPoint2: CGPointMake(330.72, 31.02)];
                [bezierPath addCurveToPoint: CGPointMake(311.63, 21.95) controlPoint1: CGPointMake(324.68, 23.92) controlPoint2: CGPointMake(319.07, 21.95)];
                [bezierPath closePath];
                [bezierPath moveToPoint: CGPointMake(314.2, 42.79)];
                [bezierPath addCurveToPoint: CGPointMake(300.98, 50.78) controlPoint1: CGPointMake(312.98, 50.78) controlPoint2: CGPointMake(306.88, 50.78)];
                [bezierPath addLineToPoint: CGPointMake(297.62, 50.78)];
                [bezierPath addLineToPoint: CGPointMake(299.98, 35.87)];
                [bezierPath addCurveToPoint: CGPointMake(301.81, 34.3) controlPoint1: CGPointMake(300.12, 34.97) controlPoint2: CGPointMake(300.9, 34.3)];
                [bezierPath addLineToPoint: CGPointMake(303.35, 34.3)];
                [bezierPath addCurveToPoint: CGPointMake(313.11, 36.59) controlPoint1: CGPointMake(307.37, 34.3) controlPoint2: CGPointMake(311.16, 34.3)];
                [bezierPath addCurveToPoint: CGPointMake(314.2, 42.79) controlPoint1: CGPointMake(314.29, 37.96) controlPoint2: CGPointMake(314.64, 39.99)];
                [bezierPath closePath];
                bezierPath.miterLimit = 4;
                
                [color0 setFill];
                [bezierPath fill];
                
                
                //// Bezier 2 Drawing
                UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
                [bezier2Path moveToPoint: CGPointMake(152.93, 21.95)];
                [bezier2Path addLineToPoint: CGPointMake(130.68, 21.95)];
                [bezier2Path addCurveToPoint: CGPointMake(127.63, 24.56) controlPoint1: CGPointMake(129.16, 21.95) controlPoint2: CGPointMake(127.87, 23.06)];
                [bezier2Path addLineToPoint: CGPointMake(118.63, 81.62)];
                [bezier2Path addCurveToPoint: CGPointMake(120.46, 83.76) controlPoint1: CGPointMake(118.45, 82.74) controlPoint2: CGPointMake(119.32, 83.76)];
                [bezier2Path addLineToPoint: CGPointMake(131.09, 83.76)];
                [bezier2Path addCurveToPoint: CGPointMake(134.14, 81.15) controlPoint1: CGPointMake(132.61, 83.76) controlPoint2: CGPointMake(133.9, 82.65)];
                [bezier2Path addLineToPoint: CGPointMake(136.57, 65.76)];
                [bezier2Path addCurveToPoint: CGPointMake(139.62, 63.15) controlPoint1: CGPointMake(136.81, 64.26) controlPoint2: CGPointMake(138.1, 63.15)];
                [bezier2Path addLineToPoint: CGPointMake(146.66, 63.15)];
                [bezier2Path addCurveToPoint: CGPointMake(171.99, 42) controlPoint1: CGPointMake(161.32, 63.15) controlPoint2: CGPointMake(169.78, 56.06)];
                [bezier2Path addCurveToPoint: CGPointMake(169.15, 27.64) controlPoint1: CGPointMake(172.98, 35.85) controlPoint2: CGPointMake(172.03, 31.02)];
                [bezier2Path addCurveToPoint: CGPointMake(152.93, 21.95) controlPoint1: CGPointMake(165.98, 23.92) controlPoint2: CGPointMake(160.38, 21.95)];
                [bezier2Path closePath];
                [bezier2Path moveToPoint: CGPointMake(155.5, 42.79)];
                [bezier2Path addCurveToPoint: CGPointMake(142.28, 50.78) controlPoint1: CGPointMake(154.28, 50.78) controlPoint2: CGPointMake(148.18, 50.78)];
                [bezier2Path addLineToPoint: CGPointMake(138.93, 50.78)];
                [bezier2Path addLineToPoint: CGPointMake(141.28, 35.87)];
                [bezier2Path addCurveToPoint: CGPointMake(143.11, 34.3) controlPoint1: CGPointMake(141.43, 34.97) controlPoint2: CGPointMake(142.2, 34.3)];
                [bezier2Path addLineToPoint: CGPointMake(144.65, 34.3)];
                [bezier2Path addCurveToPoint: CGPointMake(154.42, 36.59) controlPoint1: CGPointMake(148.67, 34.3) controlPoint2: CGPointMake(152.46, 34.3)];
                [bezier2Path addCurveToPoint: CGPointMake(155.5, 42.79) controlPoint1: CGPointMake(155.59, 37.96) controlPoint2: CGPointMake(155.94, 39.99)];
                [bezier2Path closePath];
                bezier2Path.miterLimit = 4;
                
                [color0 setFill];
                [bezier2Path fill];
                
                
                //// Bezier 3 Drawing
                UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
                [bezier3Path moveToPoint: CGPointMake(219.44, 42.54)];
                [bezier3Path addLineToPoint: CGPointMake(208.78, 42.54)];
                [bezier3Path addCurveToPoint: CGPointMake(206.95, 44.1) controlPoint1: CGPointMake(207.87, 42.54) controlPoint2: CGPointMake(207.09, 43.2)];
                [bezier3Path addLineToPoint: CGPointMake(206.48, 47.08)];
                [bezier3Path addLineToPoint: CGPointMake(205.74, 46)];
                [bezier3Path addCurveToPoint: CGPointMake(193.15, 41.53) controlPoint1: CGPointMake(203.43, 42.65) controlPoint2: CGPointMake(198.29, 41.53)];
                [bezier3Path addCurveToPoint: CGPointMake(169.37, 62.97) controlPoint1: CGPointMake(181.38, 41.53) controlPoint2: CGPointMake(171.33, 50.45)];
                [bezier3Path addCurveToPoint: CGPointMake(173.34, 79.33) controlPoint1: CGPointMake(168.35, 69.21) controlPoint2: CGPointMake(169.8, 75.17)];
                [bezier3Path addCurveToPoint: CGPointMake(186.75, 84.75) controlPoint1: CGPointMake(176.59, 83.16) controlPoint2: CGPointMake(181.23, 84.75)];
                [bezier3Path addCurveToPoint: CGPointMake(201.5, 78.65) controlPoint1: CGPointMake(196.24, 84.75) controlPoint2: CGPointMake(201.5, 78.65)];
                [bezier3Path addLineToPoint: CGPointMake(201.03, 81.62)];
                [bezier3Path addCurveToPoint: CGPointMake(202.86, 83.76) controlPoint1: CGPointMake(200.85, 82.74) controlPoint2: CGPointMake(201.72, 83.76)];
                [bezier3Path addLineToPoint: CGPointMake(212.46, 83.76)];
                [bezier3Path addCurveToPoint: CGPointMake(215.51, 81.15) controlPoint1: CGPointMake(213.98, 83.76) controlPoint2: CGPointMake(215.27, 82.66)];
                [bezier3Path addLineToPoint: CGPointMake(221.27, 44.68)];
                [bezier3Path addCurveToPoint: CGPointMake(219.44, 42.54) controlPoint1: CGPointMake(221.44, 43.55) controlPoint2: CGPointMake(220.57, 42.54)];
                [bezier3Path closePath];
                [bezier3Path moveToPoint: CGPointMake(204.59, 63.27)];
                [bezier3Path addCurveToPoint: CGPointMake(192.56, 73.45) controlPoint1: CGPointMake(203.56, 69.36) controlPoint2: CGPointMake(198.73, 73.45)];
                [bezier3Path addCurveToPoint: CGPointMake(185.41, 70.57) controlPoint1: CGPointMake(189.47, 73.45) controlPoint2: CGPointMake(187, 72.45)];
                [bezier3Path addCurveToPoint: CGPointMake(183.74, 63.09) controlPoint1: CGPointMake(183.83, 68.71) controlPoint2: CGPointMake(183.24, 66.05)];
                [bezier3Path addCurveToPoint: CGPointMake(195.68, 52.84) controlPoint1: CGPointMake(184.7, 57.06) controlPoint2: CGPointMake(189.61, 52.84)];
                [bezier3Path addCurveToPoint: CGPointMake(202.78, 55.74) controlPoint1: CGPointMake(198.7, 52.84) controlPoint2: CGPointMake(201.16, 53.84)];
                [bezier3Path addCurveToPoint: CGPointMake(204.59, 63.27) controlPoint1: CGPointMake(204.41, 57.65) controlPoint2: CGPointMake(205.06, 60.33)];
                [bezier3Path closePath];
                bezier3Path.miterLimit = 4;
                
                [color0 setFill];
                [bezier3Path fill];
                
                
                //// Bezier 4 Drawing
                UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
                [bezier4Path moveToPoint: CGPointMake(378.13, 42.54)];
                [bezier4Path addLineToPoint: CGPointMake(367.48, 42.54)];
                [bezier4Path addCurveToPoint: CGPointMake(365.65, 44.1) controlPoint1: CGPointMake(366.57, 42.54) controlPoint2: CGPointMake(365.79, 43.2)];
                [bezier4Path addLineToPoint: CGPointMake(365.18, 47.08)];
                [bezier4Path addLineToPoint: CGPointMake(364.43, 46)];
                [bezier4Path addCurveToPoint: CGPointMake(351.85, 41.53) controlPoint1: CGPointMake(362.12, 42.65) controlPoint2: CGPointMake(356.98, 41.53)];
                [bezier4Path addCurveToPoint: CGPointMake(328.07, 62.97) controlPoint1: CGPointMake(340.08, 41.53) controlPoint2: CGPointMake(330.02, 50.45)];
                [bezier4Path addCurveToPoint: CGPointMake(332.03, 79.33) controlPoint1: CGPointMake(327.05, 69.21) controlPoint2: CGPointMake(328.49, 75.17)];
                [bezier4Path addCurveToPoint: CGPointMake(345.45, 84.75) controlPoint1: CGPointMake(335.28, 83.16) controlPoint2: CGPointMake(339.92, 84.75)];
                [bezier4Path addCurveToPoint: CGPointMake(360.2, 78.65) controlPoint1: CGPointMake(354.94, 84.75) controlPoint2: CGPointMake(360.2, 78.65)];
                [bezier4Path addLineToPoint: CGPointMake(359.73, 81.62)];
                [bezier4Path addCurveToPoint: CGPointMake(361.56, 83.76) controlPoint1: CGPointMake(359.55, 82.74) controlPoint2: CGPointMake(360.42, 83.76)];
                [bezier4Path addLineToPoint: CGPointMake(371.15, 83.76)];
                [bezier4Path addCurveToPoint: CGPointMake(374.21, 81.15) controlPoint1: CGPointMake(372.67, 83.76) controlPoint2: CGPointMake(373.97, 82.66)];
                [bezier4Path addLineToPoint: CGPointMake(379.97, 44.68)];
                [bezier4Path addCurveToPoint: CGPointMake(378.13, 42.54) controlPoint1: CGPointMake(380.14, 43.55) controlPoint2: CGPointMake(379.27, 42.54)];
                [bezier4Path closePath];
                [bezier4Path moveToPoint: CGPointMake(363.28, 63.27)];
                [bezier4Path addCurveToPoint: CGPointMake(351.26, 73.45) controlPoint1: CGPointMake(362.25, 69.36) controlPoint2: CGPointMake(357.42, 73.45)];
                [bezier4Path addCurveToPoint: CGPointMake(344.1, 70.57) controlPoint1: CGPointMake(348.17, 73.45) controlPoint2: CGPointMake(345.69, 72.45)];
                [bezier4Path addCurveToPoint: CGPointMake(342.44, 63.09) controlPoint1: CGPointMake(342.53, 68.71) controlPoint2: CGPointMake(341.94, 66.05)];
                [bezier4Path addCurveToPoint: CGPointMake(354.37, 52.84) controlPoint1: CGPointMake(343.4, 57.06) controlPoint2: CGPointMake(348.3, 52.84)];
                [bezier4Path addCurveToPoint: CGPointMake(361.48, 55.74) controlPoint1: CGPointMake(357.4, 52.84) controlPoint2: CGPointMake(359.86, 53.84)];
                [bezier4Path addCurveToPoint: CGPointMake(363.28, 63.27) controlPoint1: CGPointMake(363.11, 57.65) controlPoint2: CGPointMake(363.75, 60.33)];
                [bezier4Path closePath];
                bezier4Path.miterLimit = 4;
                
                [color0 setFill];
                [bezier4Path fill];
                
                
                //// Bezier 5 Drawing
                UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
                [bezier5Path moveToPoint: CGPointMake(276.18, 42.54)];
                [bezier5Path addLineToPoint: CGPointMake(265.47, 42.54)];
                [bezier5Path addCurveToPoint: CGPointMake(262.92, 43.89) controlPoint1: CGPointMake(264.45, 42.54) controlPoint2: CGPointMake(263.49, 43.05)];
                [bezier5Path addLineToPoint: CGPointMake(248.14, 65.65)];
                [bezier5Path addLineToPoint: CGPointMake(241.88, 44.74)];
                [bezier5Path addCurveToPoint: CGPointMake(238.92, 42.54) controlPoint1: CGPointMake(241.49, 43.43) controlPoint2: CGPointMake(240.29, 42.54)];
                [bezier5Path addLineToPoint: CGPointMake(228.39, 42.54)];
                [bezier5Path addCurveToPoint: CGPointMake(226.64, 44.99) controlPoint1: CGPointMake(227.12, 42.54) controlPoint2: CGPointMake(226.23, 43.79)];
                [bezier5Path addLineToPoint: CGPointMake(238.43, 79.6)];
                [bezier5Path addLineToPoint: CGPointMake(227.34, 95.25)];
                [bezier5Path addCurveToPoint: CGPointMake(228.85, 98.18) controlPoint1: CGPointMake(226.47, 96.48) controlPoint2: CGPointMake(227.35, 98.18)];
                [bezier5Path addLineToPoint: CGPointMake(239.55, 98.18)];
                [bezier5Path addCurveToPoint: CGPointMake(242.09, 96.85) controlPoint1: CGPointMake(240.57, 98.18) controlPoint2: CGPointMake(241.51, 97.68)];
                [bezier5Path addLineToPoint: CGPointMake(277.71, 45.45)];
                [bezier5Path addCurveToPoint: CGPointMake(276.18, 42.54) controlPoint1: CGPointMake(278.56, 44.22) controlPoint2: CGPointMake(277.68, 42.54)];
                [bezier5Path closePath];
                bezier5Path.miterLimit = 4;
                
                [color0 setFill];
                [bezier5Path fill];
                
                
                //// Bezier 6 Drawing
                UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
                [bezier6Path moveToPoint: CGPointMake(390.69, 23.52)];
                [bezier6Path addLineToPoint: CGPointMake(381.56, 81.62)];
                [bezier6Path addCurveToPoint: CGPointMake(383.39, 83.76) controlPoint1: CGPointMake(381.38, 82.74) controlPoint2: CGPointMake(382.25, 83.76)];
                [bezier6Path addLineToPoint: CGPointMake(392.57, 83.76)];
                [bezier6Path addCurveToPoint: CGPointMake(395.63, 81.15) controlPoint1: CGPointMake(394.1, 83.76) controlPoint2: CGPointMake(395.39, 82.66)];
                [bezier6Path addLineToPoint: CGPointMake(404.63, 24.1)];
                [bezier6Path addCurveToPoint: CGPointMake(402.8, 21.96) controlPoint1: CGPointMake(404.81, 22.97) controlPoint2: CGPointMake(403.94, 21.96)];
                [bezier6Path addLineToPoint: CGPointMake(392.52, 21.96)];
                [bezier6Path addCurveToPoint: CGPointMake(390.69, 23.52) controlPoint1: CGPointMake(391.61, 21.95) controlPoint2: CGPointMake(390.83, 22.62)];
                [bezier6Path closePath];
                bezier6Path.miterLimit = 4;
                
                [color0 setFill];
                [bezier6Path fill];
            }
        }
    }
    
    
    //// Group 4
    {
        //// Group 5
        {
            //// Bezier 7 Drawing
            UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
            [bezier7Path moveToPoint: CGPointMake(39.01, 56.64)];
            [bezier7Path addCurveToPoint: CGPointMake(32.16, 56.64) controlPoint1: CGPointMake(34.76, 56.64) controlPoint2: CGPointMake(32.16, 56.64)];
            [bezier7Path addLineToPoint: CGPointMake(30.34, 56.64)];
            [bezier7Path addCurveToPoint: CGPointMake(28.12, 58.55) controlPoint1: CGPointMake(29.23, 56.64) controlPoint2: CGPointMake(28.3, 57.44)];
            [bezier7Path addCurveToPoint: CGPointMake(22.25, 95.65) controlPoint1: CGPointMake(28.12, 58.55) controlPoint2: CGPointMake(22.59, 93.36)];
            [bezier7Path addCurveToPoint: CGPointMake(24.52, 98.18) controlPoint1: CGPointMake(22.05, 97.04) controlPoint2: CGPointMake(23.25, 98.18)];
            [bezier7Path addLineToPoint: CGPointMake(38.3, 98.18)];
            [bezier7Path addCurveToPoint: CGPointMake(42.07, 94.95) controlPoint1: CGPointMake(40.18, 98.18) controlPoint2: CGPointMake(41.78, 96.81)];
            [bezier7Path addLineToPoint: CGPointMake(45.41, 74.13)];
            [bezier7Path addCurveToPoint: CGPointMake(49.18, 70.91) controlPoint1: CGPointMake(45.7, 72.28) controlPoint2: CGPointMake(47.3, 70.91)];
            [bezier7Path addLineToPoint: CGPointMake(51.56, 70.91)];
            [bezier7Path addCurveToPoint: CGPointMake(82.51, 46.58) controlPoint1: CGPointMake(66.94, 70.91) controlPoint2: CGPointMake(78.99, 64.66)];
            [bezier7Path addCurveToPoint: CGPointMake(76.86, 26.21) controlPoint1: CGPointMake(83.98, 39.03) controlPoint2: CGPointMake(83.51, 30.63)];
            [bezier7Path addCurveToPoint: CGPointMake(39.01, 56.64) controlPoint1: CGPointMake(74.71, 38.22) controlPoint2: CGPointMake(67.94, 56.64)];
            [bezier7Path closePath];
            bezier7Path.miterLimit = 4;
            
            [color0 setFill];
            [bezier7Path fill];
        }
        
        
        //// Bezier 8 Drawing
        UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
        [bezier8Path moveToPoint: CGPointMake(30.34, 52.43)];
        [bezier8Path addCurveToPoint: CGPointMake(39.29, 52.43) controlPoint1: CGPointMake(35.71, 52.43) controlPoint2: CGPointMake(39.29, 52.43)];
        [bezier8Path addCurveToPoint: CGPointMake(52.03, 50.82) controlPoint1: CGPointMake(44.04, 52.43) controlPoint2: CGPointMake(48.28, 51.9)];
        [bezier8Path addCurveToPoint: CGPointMake(71.08, 32.13) controlPoint1: CGPointMake(61.51, 48.1) controlPoint2: CGPointMake(67.88, 41.93)];
        [bezier8Path addCurveToPoint: CGPointMake(68.74, 7.4) controlPoint1: CGPointMake(75.1, 19.78) controlPoint2: CGPointMake(73.32, 12.47)];
        [bezier8Path addCurveToPoint: CGPointMake(45.46, 0) controlPoint1: CGPointMake(64.12, 2.29) controlPoint2: CGPointMake(55.98, 0)];
        [bezier8Path addLineToPoint: CGPointMake(17.05, 0)];
        [bezier8Path addCurveToPoint: CGPointMake(12.74, 3.69) controlPoint1: CGPointMake(14.9, 0) controlPoint2: CGPointMake(13.07, 1.56)];
        [bezier8Path addLineToPoint: CGPointMake(0.03, 84.26)];
        [bezier8Path addCurveToPoint: CGPointMake(2.62, 87.28) controlPoint1: CGPointMake(-0.22, 85.85) controlPoint2: CGPointMake(1.01, 87.28)];
        [bezier8Path addLineToPoint: CGPointMake(19.36, 87.28)];
        [bezier8Path addCurveToPoint: CGPointMake(23.98, 58.19) controlPoint1: CGPointMake(19.36, 87.28) controlPoint2: CGPointMake(23.86, 59.01)];
        [bezier8Path addCurveToPoint: CGPointMake(30.34, 52.43) controlPoint1: CGPointMake(24.41, 55.44) controlPoint2: CGPointMake(26.15, 52.43)];
        [bezier8Path closePath];
        bezier8Path.miterLimit = 4;
        
        [color0 setFill];
        [bezier8Path fill];
    }
    
    
}


@end
