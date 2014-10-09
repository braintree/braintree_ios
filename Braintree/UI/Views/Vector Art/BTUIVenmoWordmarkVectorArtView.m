#import "BTUIVenmoWordmarkVectorArtView.h"

@implementation BTUIVenmoWordmarkVectorArtView

- (id)init {
    self = [super init];
    if (self) {
        self.artDimensions = CGSizeMake(284.0f, 80.0f);
        self.opaque = NO;
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self setNeedsDisplay];
}

- (void)drawArt {
    //// Color Declarations
    UIColor* color = self.color;

    //// Venmo
    {
        //// Bezier 7 Drawing
        UIBezierPath* bezier7Path = [UIBezierPath bezierPath];
        [bezier7Path moveToPoint: CGPointMake(53.07, 11.45)];
        [bezier7Path addCurveToPoint: CGPointMake(55.62, 21.1) controlPoint1: CGPointMake(54.83, 14.35) controlPoint2: CGPointMake(55.62, 17.33)];
        [bezier7Path addCurveToPoint: CGPointMake(36.98, 59.72) controlPoint1: CGPointMake(55.62, 33.13) controlPoint2: CGPointMake(45.33, 48.75)];
        [bezier7Path addLineToPoint: CGPointMake(17.9, 59.72)];
        [bezier7Path addLineToPoint: CGPointMake(10.25, 14.08)];
        [bezier7Path addLineToPoint: CGPointMake(26.95, 12.5)];
        [bezier7Path addLineToPoint: CGPointMake(31, 44.97)];
        [bezier7Path addCurveToPoint: CGPointMake(39.44, 22.6) controlPoint1: CGPointMake(34.78, 38.83) controlPoint2: CGPointMake(39.44, 29.18)];
        [bezier7Path addCurveToPoint: CGPointMake(37.86, 14.52) controlPoint1: CGPointMake(39.44, 19) controlPoint2: CGPointMake(38.82, 16.54)];
        [bezier7Path addLineToPoint: CGPointMake(53.07, 11.45)];
        [bezier7Path closePath];
        bezier7Path.miterLimit = 4;

        [color setFill];
        [bezier7Path fill];


        //// Bezier 8 Drawing
        UIBezierPath* bezier8Path = [UIBezierPath bezierPath];
        [bezier8Path moveToPoint: CGPointMake(74.72, 31.55)];
        [bezier8Path addCurveToPoint: CGPointMake(85.53, 25.76) controlPoint1: CGPointMake(77.79, 31.55) controlPoint2: CGPointMake(85.53, 30.14)];
        [bezier8Path addCurveToPoint: CGPointMake(82.28, 22.6) controlPoint1: CGPointMake(85.53, 23.65) controlPoint2: CGPointMake(84.04, 22.6)];
        [bezier8Path addCurveToPoint: CGPointMake(74.72, 31.55) controlPoint1: CGPointMake(79.2, 22.6) controlPoint2: CGPointMake(75.16, 26.28)];
        [bezier8Path closePath];
        [bezier8Path moveToPoint: CGPointMake(74.36, 40.23)];
        [bezier8Path addCurveToPoint: CGPointMake(81.31, 47.69) controlPoint1: CGPointMake(74.36, 45.59) controlPoint2: CGPointMake(77.35, 47.69)];
        [bezier8Path addCurveToPoint: CGPointMake(95.11, 43.92) controlPoint1: CGPointMake(85.62, 47.69) controlPoint2: CGPointMake(89.75, 46.64)];
        [bezier8Path addLineToPoint: CGPointMake(93.09, 57.61)];
        [bezier8Path addCurveToPoint: CGPointMake(77.7, 60.68) controlPoint1: CGPointMake(89.31, 59.45) controlPoint2: CGPointMake(83.42, 60.68)];
        [bezier8Path addCurveToPoint: CGPointMake(58.01, 40.94) controlPoint1: CGPointMake(63.2, 60.68) controlPoint2: CGPointMake(58.01, 51.91)];
        [bezier8Path addCurveToPoint: CGPointMake(83.86, 11.62) controlPoint1: CGPointMake(58.01, 26.72) controlPoint2: CGPointMake(66.45, 11.62)];
        [bezier8Path addCurveToPoint: CGPointMake(98.8, 24.44) controlPoint1: CGPointMake(93.45, 11.62) controlPoint2: CGPointMake(98.8, 16.98)];
        [bezier8Path addCurveToPoint: CGPointMake(74.36, 40.23) controlPoint1: CGPointMake(98.81, 36.46) controlPoint2: CGPointMake(83.33, 40.15)];
        [bezier8Path closePath];
        bezier8Path.miterLimit = 4;

        [color setFill];
        [bezier8Path fill];


        //// Bezier 9 Drawing
        UIBezierPath* bezier9Path = [UIBezierPath bezierPath];
        [bezier9Path moveToPoint: CGPointMake(147.01, 22.16)];
        [bezier9Path addCurveToPoint: CGPointMake(146.48, 28.12) controlPoint1: CGPointMake(147.01, 23.91) controlPoint2: CGPointMake(146.74, 26.46)];
        [bezier9Path addLineToPoint: CGPointMake(141.46, 59.72)];
        [bezier9Path addLineToPoint: CGPointMake(125.2, 59.72)];
        [bezier9Path addLineToPoint: CGPointMake(129.77, 30.76)];
        [bezier9Path addCurveToPoint: CGPointMake(130.12, 27.51) controlPoint1: CGPointMake(129.86, 29.97) controlPoint2: CGPointMake(130.12, 28.39)];
        [bezier9Path addCurveToPoint: CGPointMake(127.22, 24.88) controlPoint1: CGPointMake(130.12, 25.4) controlPoint2: CGPointMake(128.81, 24.88)];
        [bezier9Path addCurveToPoint: CGPointMake(121.59, 26.55) controlPoint1: CGPointMake(125.11, 24.88) controlPoint2: CGPointMake(123, 25.84)];
        [bezier9Path addLineToPoint: CGPointMake(116.41, 59.72)];
        [bezier9Path addLineToPoint: CGPointMake(100.05, 59.72)];
        [bezier9Path addLineToPoint: CGPointMake(107.52, 12.41)];
        [bezier9Path addLineToPoint: CGPointMake(121.68, 12.41)];
        [bezier9Path addLineToPoint: CGPointMake(121.86, 16.19)];
        [bezier9Path addCurveToPoint: CGPointMake(135.84, 11.62) controlPoint1: CGPointMake(125.2, 14) controlPoint2: CGPointMake(129.6, 11.62)];
        [bezier9Path addCurveToPoint: CGPointMake(147.01, 22.16) controlPoint1: CGPointMake(144.1, 11.62) controlPoint2: CGPointMake(147.01, 15.84)];
        [bezier9Path closePath];
        bezier9Path.miterLimit = 4;

        [color setFill];
        [bezier9Path fill];


        //// Bezier 10 Drawing
        UIBezierPath* bezier10Path = [UIBezierPath bezierPath];
        [bezier10Path moveToPoint: CGPointMake(195.29, 16.8)];
        [bezier10Path addCurveToPoint: CGPointMake(210.42, 11.62) controlPoint1: CGPointMake(199.95, 13.47) controlPoint2: CGPointMake(204.35, 11.62)];
        [bezier10Path addCurveToPoint: CGPointMake(221.67, 22.16) controlPoint1: CGPointMake(218.77, 11.62) controlPoint2: CGPointMake(221.67, 15.84)];
        [bezier10Path addCurveToPoint: CGPointMake(221.14, 28.12) controlPoint1: CGPointMake(221.67, 23.91) controlPoint2: CGPointMake(221.41, 26.46)];
        [bezier10Path addLineToPoint: CGPointMake(216.13, 59.72)];
        [bezier10Path addLineToPoint: CGPointMake(199.86, 59.72)];
        [bezier10Path addLineToPoint: CGPointMake(204.52, 30.14)];
        [bezier10Path addCurveToPoint: CGPointMake(204.79, 27.78) controlPoint1: CGPointMake(204.61, 29.35) controlPoint2: CGPointMake(204.79, 28.39)];
        [bezier10Path addCurveToPoint: CGPointMake(201.88, 24.88) controlPoint1: CGPointMake(204.79, 25.4) controlPoint2: CGPointMake(203.47, 24.88)];
        [bezier10Path addCurveToPoint: CGPointMake(196.35, 26.55) controlPoint1: CGPointMake(199.86, 24.88) controlPoint2: CGPointMake(197.84, 25.76)];
        [bezier10Path addLineToPoint: CGPointMake(191.16, 59.72)];
        [bezier10Path addLineToPoint: CGPointMake(174.9, 59.72)];
        [bezier10Path addLineToPoint: CGPointMake(179.55, 30.14)];
        [bezier10Path addCurveToPoint: CGPointMake(179.82, 27.78) controlPoint1: CGPointMake(179.64, 29.35) controlPoint2: CGPointMake(179.82, 28.39)];
        [bezier10Path addCurveToPoint: CGPointMake(176.91, 24.88) controlPoint1: CGPointMake(179.82, 25.4) controlPoint2: CGPointMake(178.49, 24.88)];
        [bezier10Path addCurveToPoint: CGPointMake(171.29, 26.55) controlPoint1: CGPointMake(174.8, 24.88) controlPoint2: CGPointMake(172.7, 25.84)];
        [bezier10Path addLineToPoint: CGPointMake(166.1, 59.72)];
        [bezier10Path addLineToPoint: CGPointMake(149.75, 59.72)];
        [bezier10Path addLineToPoint: CGPointMake(157.22, 12.42)];
        [bezier10Path addLineToPoint: CGPointMake(171.2, 12.42)];
        [bezier10Path addLineToPoint: CGPointMake(171.64, 16.36)];
        [bezier10Path addCurveToPoint: CGPointMake(185.18, 11.63) controlPoint1: CGPointMake(174.9, 14) controlPoint2: CGPointMake(179.29, 11.63)];
        [bezier10Path addCurveToPoint: CGPointMake(195.29, 16.8) controlPoint1: CGPointMake(190.28, 11.62) controlPoint2: CGPointMake(193.62, 13.82)];
        [bezier10Path closePath];
        bezier10Path.miterLimit = 4;

        [color setFill];
        [bezier10Path fill];


        //// Bezier 11 Drawing
        UIBezierPath* bezier11Path = [UIBezierPath bezierPath];
        [bezier11Path moveToPoint: CGPointMake(254.04, 30.58)];
        [bezier11Path addCurveToPoint: CGPointMake(250.17, 24.09) controlPoint1: CGPointMake(254.04, 26.72) controlPoint2: CGPointMake(253.07, 24.09)];
        [bezier11Path addCurveToPoint: CGPointMake(242.44, 41.2) controlPoint1: CGPointMake(243.76, 24.09) controlPoint2: CGPointMake(242.44, 35.41)];
        [bezier11Path addCurveToPoint: CGPointMake(246.57, 48.31) controlPoint1: CGPointMake(242.44, 45.59) controlPoint2: CGPointMake(243.67, 48.31)];
        [bezier11Path addCurveToPoint: CGPointMake(254.04, 30.58) controlPoint1: CGPointMake(252.63, 48.31) controlPoint2: CGPointMake(254.04, 36.37)];
        [bezier11Path closePath];
        [bezier11Path moveToPoint: CGPointMake(225.91, 40.5)];
        [bezier11Path addCurveToPoint: CGPointMake(252.02, 11.62) controlPoint1: CGPointMake(225.91, 25.58) controlPoint2: CGPointMake(233.82, 11.62)];
        [bezier11Path addCurveToPoint: CGPointMake(270.75, 30.85) controlPoint1: CGPointMake(265.74, 11.62) controlPoint2: CGPointMake(270.75, 19.7)];
        [bezier11Path addCurveToPoint: CGPointMake(244.28, 60.86) controlPoint1: CGPointMake(270.75, 45.59) controlPoint2: CGPointMake(262.92, 60.86)];
        [bezier11Path addCurveToPoint: CGPointMake(225.91, 40.5) controlPoint1: CGPointMake(230.48, 60.86) controlPoint2: CGPointMake(225.91, 51.82)];
        [bezier11Path closePath];
        bezier11Path.miterLimit = 4;
        
        [color setFill];
        [bezier11Path fill];
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
