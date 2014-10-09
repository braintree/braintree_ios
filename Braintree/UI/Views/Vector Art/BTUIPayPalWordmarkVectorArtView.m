#import "BTUIPayPalWordmarkVectorArtView.h"
#import "BTUI.h"

@implementation BTUIPayPalWordmarkVectorArtView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.artDimensions = CGSizeMake(284.0f, 80.0f);
        self.opaque = NO;
        self.theme = [BTUI braintreeTheme];
    }
    return self;
}

- (void)drawArt
{
    //// Color Declarations
    UIColor* color0 = [self.theme palBlue];
    UIColor* color1 = [self.theme payBlue];

    //// PayPal
    {
        //// Group 2
        {
            //// Bezier Drawing
            UIBezierPath* bezierPath = [UIBezierPath bezierPath];
            [bezierPath moveToPoint: CGPointMake(189.07, 1.49)];
            [bezierPath addLineToPoint: CGPointMake(167.92, 1.49)];
            [bezierPath addCurveToPoint: CGPointMake(165.02, 3.97) controlPoint1: CGPointMake(166.48, 1.49) controlPoint2: CGPointMake(165.24, 2.54)];
            [bezierPath addLineToPoint: CGPointMake(156.47, 58.2)];
            [bezierPath addCurveToPoint: CGPointMake(158.21, 60.24) controlPoint1: CGPointMake(156.3, 59.27) controlPoint2: CGPointMake(157.12, 60.24)];
            [bezierPath addLineToPoint: CGPointMake(169.06, 60.24)];
            [bezierPath addCurveToPoint: CGPointMake(171.09, 58.5) controlPoint1: CGPointMake(170.07, 60.24) controlPoint2: CGPointMake(170.93, 59.5)];
            [bezierPath addLineToPoint: CGPointMake(173.52, 43.13)];
            [bezierPath addCurveToPoint: CGPointMake(176.42, 40.65) controlPoint1: CGPointMake(173.74, 41.7) controlPoint2: CGPointMake(174.97, 40.65)];
            [bezierPath addLineToPoint: CGPointMake(183.11, 40.65)];
            [bezierPath addCurveToPoint: CGPointMake(207.18, 20.54) controlPoint1: CGPointMake(197.04, 40.65) controlPoint2: CGPointMake(205.08, 33.91)];
            [bezierPath addCurveToPoint: CGPointMake(204.49, 6.89) controlPoint1: CGPointMake(208.13, 14.7) controlPoint2: CGPointMake(207.22, 10.11)];
            [bezierPath addCurveToPoint: CGPointMake(189.07, 1.49) controlPoint1: CGPointMake(201.48, 3.36) controlPoint2: CGPointMake(196.15, 1.49)];
            [bezierPath closePath];
            [bezierPath moveToPoint: CGPointMake(191.51, 21.3)];
            [bezierPath addCurveToPoint: CGPointMake(178.95, 28.89) controlPoint1: CGPointMake(190.36, 28.89) controlPoint2: CGPointMake(184.56, 28.89)];
            [bezierPath addLineToPoint: CGPointMake(175.76, 28.89)];
            [bezierPath addLineToPoint: CGPointMake(178, 14.71)];
            [bezierPath addCurveToPoint: CGPointMake(179.74, 13.23) controlPoint1: CGPointMake(178.13, 13.86) controlPoint2: CGPointMake(178.87, 13.23)];
            [bezierPath addLineToPoint: CGPointMake(181.2, 13.23)];
            [bezierPath addCurveToPoint: CGPointMake(190.48, 15.4) controlPoint1: CGPointMake(185.02, 13.23) controlPoint2: CGPointMake(188.62, 13.23)];
            [bezierPath addCurveToPoint: CGPointMake(191.51, 21.3) controlPoint1: CGPointMake(191.6, 16.7) controlPoint2: CGPointMake(191.93, 18.63)];
            [bezierPath closePath];
            bezierPath.miterLimit = 4;

            [color0 setFill];
            [bezierPath fill];


            //// Bezier 2 Drawing
            UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
            [bezier2Path moveToPoint: CGPointMake(38.22, 1.49)];
            [bezier2Path addLineToPoint: CGPointMake(17.07, 1.49)];
            [bezier2Path addCurveToPoint: CGPointMake(14.17, 3.97) controlPoint1: CGPointMake(15.62, 1.49) controlPoint2: CGPointMake(14.39, 2.54)];
            [bezier2Path addLineToPoint: CGPointMake(5.61, 58.2)];
            [bezier2Path addCurveToPoint: CGPointMake(7.36, 60.24) controlPoint1: CGPointMake(5.45, 59.27) controlPoint2: CGPointMake(6.27, 60.24)];
            [bezier2Path addLineToPoint: CGPointMake(17.45, 60.24)];
            [bezier2Path addCurveToPoint: CGPointMake(20.36, 57.76) controlPoint1: CGPointMake(18.9, 60.24) controlPoint2: CGPointMake(20.13, 59.19)];
            [bezier2Path addLineToPoint: CGPointMake(22.67, 43.13)];
            [bezier2Path addCurveToPoint: CGPointMake(25.57, 40.65) controlPoint1: CGPointMake(22.89, 41.7) controlPoint2: CGPointMake(24.12, 40.65)];
            [bezier2Path addLineToPoint: CGPointMake(32.26, 40.65)];
            [bezier2Path addCurveToPoint: CGPointMake(56.33, 20.54) controlPoint1: CGPointMake(46.19, 40.65) controlPoint2: CGPointMake(54.23, 33.91)];
            [bezier2Path addCurveToPoint: CGPointMake(53.64, 6.89) controlPoint1: CGPointMake(57.28, 14.7) controlPoint2: CGPointMake(56.37, 10.11)];
            [bezier2Path addCurveToPoint: CGPointMake(38.22, 1.49) controlPoint1: CGPointMake(50.63, 3.36) controlPoint2: CGPointMake(45.3, 1.49)];
            [bezier2Path closePath];
            [bezier2Path moveToPoint: CGPointMake(40.66, 21.3)];
            [bezier2Path addCurveToPoint: CGPointMake(28.1, 28.89) controlPoint1: CGPointMake(39.51, 28.89) controlPoint2: CGPointMake(33.71, 28.89)];
            [bezier2Path addLineToPoint: CGPointMake(24.91, 28.89)];
            [bezier2Path addLineToPoint: CGPointMake(27.15, 14.71)];
            [bezier2Path addCurveToPoint: CGPointMake(28.89, 13.23) controlPoint1: CGPointMake(27.28, 13.86) controlPoint2: CGPointMake(28.02, 13.23)];
            [bezier2Path addLineToPoint: CGPointMake(30.35, 13.23)];
            [bezier2Path addCurveToPoint: CGPointMake(39.63, 15.4) controlPoint1: CGPointMake(34.17, 13.23) controlPoint2: CGPointMake(37.77, 13.23)];
            [bezier2Path addCurveToPoint: CGPointMake(40.66, 21.3) controlPoint1: CGPointMake(40.74, 16.7) controlPoint2: CGPointMake(41.08, 18.63)];
            [bezier2Path closePath];
            bezier2Path.miterLimit = 4;

            [color1 setFill];
            [bezier2Path fill];


            //// Bezier 3 Drawing
            UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
            [bezier3Path moveToPoint: CGPointMake(101.44, 21.06)];
            [bezier3Path addLineToPoint: CGPointMake(91.31, 21.06)];
            [bezier3Path addCurveToPoint: CGPointMake(89.57, 22.54) controlPoint1: CGPointMake(90.44, 21.06) controlPoint2: CGPointMake(89.7, 21.69)];
            [bezier3Path addLineToPoint: CGPointMake(89.12, 25.38)];
            [bezier3Path addLineToPoint: CGPointMake(88.41, 24.35)];
            [bezier3Path addCurveToPoint: CGPointMake(76.45, 20.1) controlPoint1: CGPointMake(86.22, 21.17) controlPoint2: CGPointMake(81.33, 20.1)];
            [bezier3Path addCurveToPoint: CGPointMake(53.85, 40.47) controlPoint1: CGPointMake(65.26, 20.1) controlPoint2: CGPointMake(55.71, 28.58)];
            [bezier3Path addCurveToPoint: CGPointMake(57.62, 56.03) controlPoint1: CGPointMake(52.88, 46.41) controlPoint2: CGPointMake(54.25, 52.08)];
            [bezier3Path addCurveToPoint: CGPointMake(70.37, 61.18) controlPoint1: CGPointMake(60.71, 59.67) controlPoint2: CGPointMake(65.12, 61.18)];
            [bezier3Path addCurveToPoint: CGPointMake(84.39, 55.39) controlPoint1: CGPointMake(79.39, 61.18) controlPoint2: CGPointMake(84.39, 55.39)];
            [bezier3Path addLineToPoint: CGPointMake(83.94, 58.2)];
            [bezier3Path addCurveToPoint: CGPointMake(85.68, 60.24) controlPoint1: CGPointMake(83.77, 59.27) controlPoint2: CGPointMake(84.6, 60.24)];
            [bezier3Path addLineToPoint: CGPointMake(94.8, 60.24)];
            [bezier3Path addCurveToPoint: CGPointMake(97.7, 57.76) controlPoint1: CGPointMake(96.25, 60.24) controlPoint2: CGPointMake(97.48, 59.19)];
            [bezier3Path addLineToPoint: CGPointMake(103.18, 23.09)];
            [bezier3Path addCurveToPoint: CGPointMake(101.44, 21.06) controlPoint1: CGPointMake(103.35, 22.02) controlPoint2: CGPointMake(102.52, 21.06)];
            [bezier3Path closePath];
            [bezier3Path moveToPoint: CGPointMake(87.32, 40.77)];
            [bezier3Path addCurveToPoint: CGPointMake(75.89, 50.44) controlPoint1: CGPointMake(86.34, 46.55) controlPoint2: CGPointMake(81.75, 50.44)];
            [bezier3Path addCurveToPoint: CGPointMake(69.09, 47.71) controlPoint1: CGPointMake(72.95, 50.44) controlPoint2: CGPointMake(70.6, 49.49)];
            [bezier3Path addCurveToPoint: CGPointMake(67.5, 40.59) controlPoint1: CGPointMake(67.59, 45.93) controlPoint2: CGPointMake(67.03, 43.4)];
            [bezier3Path addCurveToPoint: CGPointMake(78.85, 30.85) controlPoint1: CGPointMake(68.42, 34.86) controlPoint2: CGPointMake(73.08, 30.85)];
            [bezier3Path addCurveToPoint: CGPointMake(85.61, 33.61) controlPoint1: CGPointMake(81.73, 30.85) controlPoint2: CGPointMake(84.07, 31.8)];
            [bezier3Path addCurveToPoint: CGPointMake(87.32, 40.77) controlPoint1: CGPointMake(87.16, 35.42) controlPoint2: CGPointMake(87.77, 37.97)];
            [bezier3Path closePath];
            bezier3Path.miterLimit = 4;

            [color1 setFill];
            [bezier3Path fill];


            //// Bezier 4 Drawing
            UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
            [bezier4Path moveToPoint: CGPointMake(252.29, 21.06)];
            [bezier4Path addLineToPoint: CGPointMake(242.16, 21.06)];
            [bezier4Path addCurveToPoint: CGPointMake(240.42, 22.54) controlPoint1: CGPointMake(241.29, 21.06) controlPoint2: CGPointMake(240.55, 21.69)];
            [bezier4Path addLineToPoint: CGPointMake(239.97, 25.38)];
            [bezier4Path addLineToPoint: CGPointMake(239.27, 24.35)];
            [bezier4Path addCurveToPoint: CGPointMake(227.3, 20.1) controlPoint1: CGPointMake(237.07, 21.17) controlPoint2: CGPointMake(232.18, 20.1)];
            [bezier4Path addCurveToPoint: CGPointMake(204.7, 40.47) controlPoint1: CGPointMake(216.12, 20.1) controlPoint2: CGPointMake(206.56, 28.58)];
            [bezier4Path addCurveToPoint: CGPointMake(208.47, 56.03) controlPoint1: CGPointMake(203.73, 46.41) controlPoint2: CGPointMake(205.1, 52.08)];
            [bezier4Path addCurveToPoint: CGPointMake(221.22, 61.18) controlPoint1: CGPointMake(211.56, 59.67) controlPoint2: CGPointMake(215.97, 61.18)];
            [bezier4Path addCurveToPoint: CGPointMake(235.24, 55.39) controlPoint1: CGPointMake(230.24, 61.18) controlPoint2: CGPointMake(235.24, 55.39)];
            [bezier4Path addLineToPoint: CGPointMake(234.79, 58.2)];
            [bezier4Path addCurveToPoint: CGPointMake(236.53, 60.24) controlPoint1: CGPointMake(234.62, 59.27) controlPoint2: CGPointMake(235.45, 60.24)];
            [bezier4Path addLineToPoint: CGPointMake(245.65, 60.24)];
            [bezier4Path addCurveToPoint: CGPointMake(248.56, 57.76) controlPoint1: CGPointMake(247.1, 60.24) controlPoint2: CGPointMake(248.33, 59.19)];
            [bezier4Path addLineToPoint: CGPointMake(254.03, 23.09)];
            [bezier4Path addCurveToPoint: CGPointMake(252.29, 21.06) controlPoint1: CGPointMake(254.2, 22.02) controlPoint2: CGPointMake(253.37, 21.06)];
            [bezier4Path closePath];
            [bezier4Path moveToPoint: CGPointMake(238.17, 40.77)];
            [bezier4Path addCurveToPoint: CGPointMake(226.74, 50.44) controlPoint1: CGPointMake(237.19, 46.55) controlPoint2: CGPointMake(232.6, 50.44)];
            [bezier4Path addCurveToPoint: CGPointMake(219.94, 47.71) controlPoint1: CGPointMake(223.8, 50.44) controlPoint2: CGPointMake(221.45, 49.49)];
            [bezier4Path addCurveToPoint: CGPointMake(218.35, 40.59) controlPoint1: CGPointMake(218.44, 45.93) controlPoint2: CGPointMake(217.88, 43.4)];
            [bezier4Path addCurveToPoint: CGPointMake(229.7, 30.85) controlPoint1: CGPointMake(219.26, 34.86) controlPoint2: CGPointMake(223.93, 30.85)];
            [bezier4Path addCurveToPoint: CGPointMake(236.46, 33.61) controlPoint1: CGPointMake(232.58, 30.85) controlPoint2: CGPointMake(234.91, 31.8)];
            [bezier4Path addCurveToPoint: CGPointMake(238.17, 40.77) controlPoint1: CGPointMake(238.01, 35.42) controlPoint2: CGPointMake(238.62, 37.97)];
            [bezier4Path closePath];
            bezier4Path.miterLimit = 4;

            [color0 setFill];
            [bezier4Path fill];


            //// Bezier 5 Drawing
            UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
            [bezier5Path moveToPoint: CGPointMake(155.38, 21.06)];
            [bezier5Path addLineToPoint: CGPointMake(145.2, 21.06)];
            [bezier5Path addCurveToPoint: CGPointMake(142.76, 22.34) controlPoint1: CGPointMake(144.22, 21.06) controlPoint2: CGPointMake(143.31, 21.54)];
            [bezier5Path addLineToPoint: CGPointMake(128.72, 43.02)];
            [bezier5Path addLineToPoint: CGPointMake(122.77, 23.15)];
            [bezier5Path addCurveToPoint: CGPointMake(119.96, 21.06) controlPoint1: CGPointMake(122.4, 21.91) controlPoint2: CGPointMake(121.26, 21.06)];
            [bezier5Path addLineToPoint: CGPointMake(109.95, 21.06)];
            [bezier5Path addCurveToPoint: CGPointMake(108.28, 23.39) controlPoint1: CGPointMake(108.74, 21.06) controlPoint2: CGPointMake(107.89, 22.24)];
            [bezier5Path addLineToPoint: CGPointMake(119.49, 56.29)];
            [bezier5Path addLineToPoint: CGPointMake(108.95, 71.16)];
            [bezier5Path addCurveToPoint: CGPointMake(110.39, 73.95) controlPoint1: CGPointMake(108.12, 72.33) controlPoint2: CGPointMake(108.96, 73.95)];
            [bezier5Path addLineToPoint: CGPointMake(120.56, 73.95)];
            [bezier5Path addCurveToPoint: CGPointMake(122.97, 72.68) controlPoint1: CGPointMake(121.52, 73.95) controlPoint2: CGPointMake(122.42, 73.47)];
            [bezier5Path addLineToPoint: CGPointMake(156.82, 23.82)];
            [bezier5Path addCurveToPoint: CGPointMake(155.38, 21.06) controlPoint1: CGPointMake(157.63, 22.65) controlPoint2: CGPointMake(156.8, 21.06)];
            [bezier5Path closePath];
            bezier5Path.miterLimit = 4;

            [color1 setFill];
            [bezier5Path fill];


            //// Bezier 6 Drawing
            UIBezierPath* bezier6Path = [UIBezierPath bezierPath];
            [bezier6Path moveToPoint: CGPointMake(264.22, 2.98)];
            [bezier6Path addLineToPoint: CGPointMake(255.54, 58.21)];
            [bezier6Path addCurveToPoint: CGPointMake(257.29, 60.24) controlPoint1: CGPointMake(255.38, 59.27) controlPoint2: CGPointMake(256.2, 60.24)];
            [bezier6Path addLineToPoint: CGPointMake(266.01, 60.24)];
            [bezier6Path addCurveToPoint: CGPointMake(268.92, 57.76) controlPoint1: CGPointMake(267.46, 60.24) controlPoint2: CGPointMake(268.69, 59.19)];
            [bezier6Path addLineToPoint: CGPointMake(277.48, 3.53)];
            [bezier6Path addCurveToPoint: CGPointMake(275.73, 1.49) controlPoint1: CGPointMake(277.64, 2.46) controlPoint2: CGPointMake(276.82, 1.49)];
            [bezier6Path addLineToPoint: CGPointMake(265.96, 1.49)];
            [bezier6Path addCurveToPoint: CGPointMake(264.22, 2.98) controlPoint1: CGPointMake(265.1, 1.49) controlPoint2: CGPointMake(264.36, 2.12)];
            [bezier6Path closePath];
            bezier6Path.miterLimit = 4;
            
            [color0 setFill];
            [bezier6Path fill];
        }
    }
}

- (void)updateConstraints {
    NSLayoutConstraint *aspectRatioConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                             attribute:NSLayoutAttributeWidth
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeHeight
                                                                            multiplier:(self.artDimensions.width / self.artDimensions.height)
                                                                              constant:0.0f];
    aspectRatioConstraint.priority = UILayoutPriorityRequired;

    [self addConstraint:aspectRatioConstraint];

    [super updateConstraints];
}

- (UILayoutPriority)contentCompressionResistancePriorityForAxis:(__unused UILayoutConstraintAxis)axis {
    return UILayoutPriorityRequired;
}

@end
