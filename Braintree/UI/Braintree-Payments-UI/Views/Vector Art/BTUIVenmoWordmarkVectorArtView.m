#import "BTUIVenmoWordmarkVectorArtView.h"

@implementation BTUIVenmoWordmarkVectorArtView

- (id)init {
    self = [super init];
    if (self) {
        self.artDimensions = CGSizeMake(578.0f, 111.0f);
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
    UIColor* fillColor = self.color;

    //// Group
    {
        //// Bezier Drawing
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: CGPointMake(95.38, 1)];
        [bezierPath addCurveToPoint: CGPointMake(101.03, 22.43) controlPoint1: CGPointMake(99.27, 7.43) controlPoint2: CGPointMake(101.03, 14.06)];
        [bezierPath addCurveToPoint: CGPointMake(59.74, 108.16) controlPoint1: CGPointMake(101.03, 49.12) controlPoint2: CGPointMake(78.24, 83.8)];
        [bezierPath addLineToPoint: CGPointMake(17.5, 108.16)];
        [bezierPath addLineToPoint: CGPointMake(0.55, 6.84)];
        [bezierPath addLineToPoint: CGPointMake(37.54, 3.33)];
        [bezierPath addLineToPoint: CGPointMake(46.5, 75.42)];
        [bezierPath addCurveToPoint: CGPointMake(65.2, 25.75) controlPoint1: CGPointMake(54.87, 61.79) controlPoint2: CGPointMake(65.2, 40.36)];
        [bezierPath addCurveToPoint: CGPointMake(61.69, 7.82) controlPoint1: CGPointMake(65.2, 17.75) controlPoint2: CGPointMake(63.83, 12.3)];
        [bezierPath addLineToPoint: CGPointMake(95.38, 1)];
        [bezierPath closePath];
        bezierPath.miterLimit = 4;

        [fillColor setFill];
        [bezierPath fill];


        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
        [bezier2Path moveToPoint: CGPointMake(143.32, 45.61)];
        [bezier2Path addCurveToPoint: CGPointMake(167.26, 32.76) controlPoint1: CGPointMake(150.12, 45.61) controlPoint2: CGPointMake(167.26, 42.5)];
        [bezier2Path addCurveToPoint: CGPointMake(160.06, 25.75) controlPoint1: CGPointMake(167.26, 28.08) controlPoint2: CGPointMake(163.95, 25.75)];
        [bezier2Path addCurveToPoint: CGPointMake(143.32, 45.61) controlPoint1: CGPointMake(153.24, 25.75) controlPoint2: CGPointMake(144.29, 33.92)];
        [bezier2Path closePath];
        [bezier2Path moveToPoint: CGPointMake(142.54, 64.9)];
        [bezier2Path addCurveToPoint: CGPointMake(157.92, 81.46) controlPoint1: CGPointMake(142.54, 76.79) controlPoint2: CGPointMake(149.15, 81.46)];
        [bezier2Path addCurveToPoint: CGPointMake(188.49, 73.09) controlPoint1: CGPointMake(167.47, 81.46) controlPoint2: CGPointMake(176.61, 79.13)];
        [bezier2Path addLineToPoint: CGPointMake(184.01, 103.48)];
        [bezier2Path addCurveToPoint: CGPointMake(149.93, 110.3) controlPoint1: CGPointMake(175.64, 107.57) controlPoint2: CGPointMake(162.6, 110.3)];
        [bezier2Path addCurveToPoint: CGPointMake(106.32, 66.46) controlPoint1: CGPointMake(117.81, 110.3) controlPoint2: CGPointMake(106.32, 90.82)];
        [bezier2Path addCurveToPoint: CGPointMake(163.57, 1.38) controlPoint1: CGPointMake(106.32, 34.9) controlPoint2: CGPointMake(125.02, 1.38)];
        [bezier2Path addCurveToPoint: CGPointMake(196.66, 29.84) controlPoint1: CGPointMake(184.79, 1.38) controlPoint2: CGPointMake(196.66, 13.28)];
        [bezier2Path addCurveToPoint: CGPointMake(142.54, 64.9) controlPoint1: CGPointMake(196.67, 56.53) controlPoint2: CGPointMake(162.4, 64.71)];
        [bezier2Path closePath];
        bezier2Path.miterLimit = 4;

        [fillColor setFill];
        [bezier2Path fill];


        //// Bezier 3 Drawing
        UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
        [bezier3Path moveToPoint: CGPointMake(303.41, 24.77)];
        [bezier3Path addCurveToPoint: CGPointMake(302.24, 38.01) controlPoint1: CGPointMake(303.41, 28.67) controlPoint2: CGPointMake(302.82, 34.32)];
        [bezier3Path addLineToPoint: CGPointMake(291.13, 108.16)];
        [bezier3Path addLineToPoint: CGPointMake(255.12, 108.16)];
        [bezier3Path addLineToPoint: CGPointMake(265.24, 43.86)];
        [bezier3Path addCurveToPoint: CGPointMake(266.02, 36.65) controlPoint1: CGPointMake(265.43, 42.11) controlPoint2: CGPointMake(266.02, 38.6)];
        [bezier3Path addCurveToPoint: CGPointMake(259.59, 30.81) controlPoint1: CGPointMake(266.02, 31.98) controlPoint2: CGPointMake(263.1, 30.81)];
        [bezier3Path addCurveToPoint: CGPointMake(247.13, 34.51) controlPoint1: CGPointMake(254.92, 30.81) controlPoint2: CGPointMake(250.24, 32.95)];
        [bezier3Path addLineToPoint: CGPointMake(235.65, 108.16)];
        [bezier3Path addLineToPoint: CGPointMake(199.42, 108.16)];
        [bezier3Path addLineToPoint: CGPointMake(215.97, 3.14)];
        [bezier3Path addLineToPoint: CGPointMake(247.32, 3.14)];
        [bezier3Path addLineToPoint: CGPointMake(247.72, 11.52)];
        [bezier3Path addCurveToPoint: CGPointMake(278.67, 1.39) controlPoint1: CGPointMake(255.12, 6.65) controlPoint2: CGPointMake(264.85, 1.39)];
        [bezier3Path addCurveToPoint: CGPointMake(303.41, 24.77) controlPoint1: CGPointMake(296.98, 1.38) controlPoint2: CGPointMake(303.41, 10.74)];
        [bezier3Path closePath];
        bezier3Path.miterLimit = 4;

        [fillColor setFill];
        [bezier3Path fill];


        //// Bezier 4 Drawing
        UIBezierPath* bezier4Path = [UIBezierPath bezierPath];
        [bezier4Path moveToPoint: CGPointMake(410.34, 12.88)];
        [bezier4Path addCurveToPoint: CGPointMake(443.83, 1.38) controlPoint1: CGPointMake(420.66, 5.48) controlPoint2: CGPointMake(430.4, 1.38)];
        [bezier4Path addCurveToPoint: CGPointMake(468.76, 24.77) controlPoint1: CGPointMake(462.33, 1.38) controlPoint2: CGPointMake(468.76, 10.74)];
        [bezier4Path addCurveToPoint: CGPointMake(467.58, 38.01) controlPoint1: CGPointMake(468.76, 28.67) controlPoint2: CGPointMake(468.17, 34.32)];
        [bezier4Path addLineToPoint: CGPointMake(456.5, 108.15)];
        [bezier4Path addLineToPoint: CGPointMake(420.47, 108.15)];
        [bezier4Path addLineToPoint: CGPointMake(430.79, 42.5)];
        [bezier4Path addCurveToPoint: CGPointMake(431.37, 37.24) controlPoint1: CGPointMake(430.98, 40.74) controlPoint2: CGPointMake(431.37, 38.6)];
        [bezier4Path addCurveToPoint: CGPointMake(424.94, 30.81) controlPoint1: CGPointMake(431.37, 31.98) controlPoint2: CGPointMake(428.45, 30.81)];
        [bezier4Path addCurveToPoint: CGPointMake(412.67, 34.51) controlPoint1: CGPointMake(420.47, 30.81) controlPoint2: CGPointMake(415.99, 32.76)];
        [bezier4Path addLineToPoint: CGPointMake(401.19, 108.16)];
        [bezier4Path addLineToPoint: CGPointMake(365.17, 108.16)];
        [bezier4Path addLineToPoint: CGPointMake(375.49, 42.5)];
        [bezier4Path addCurveToPoint: CGPointMake(376.07, 37.24) controlPoint1: CGPointMake(375.68, 40.74) controlPoint2: CGPointMake(376.07, 38.6)];
        [bezier4Path addCurveToPoint: CGPointMake(369.64, 30.81) controlPoint1: CGPointMake(376.07, 31.98) controlPoint2: CGPointMake(373.14, 30.81)];
        [bezier4Path addCurveToPoint: CGPointMake(357.18, 34.51) controlPoint1: CGPointMake(364.97, 30.81) controlPoint2: CGPointMake(360.3, 32.95)];
        [bezier4Path addLineToPoint: CGPointMake(345.69, 108.16)];
        [bezier4Path addLineToPoint: CGPointMake(309.48, 108.16)];
        [bezier4Path addLineToPoint: CGPointMake(326.03, 3.14)];
        [bezier4Path addLineToPoint: CGPointMake(356.99, 3.14)];
        [bezier4Path addLineToPoint: CGPointMake(357.97, 11.91)];
        [bezier4Path addCurveToPoint: CGPointMake(387.95, 1.39) controlPoint1: CGPointMake(365.17, 6.65) controlPoint2: CGPointMake(374.9, 1.39)];
        [bezier4Path addCurveToPoint: CGPointMake(410.34, 12.88) controlPoint1: CGPointMake(399.24, 1.38) controlPoint2: CGPointMake(406.64, 6.25)];
        [bezier4Path closePath];
        bezier4Path.miterLimit = 4;

        [fillColor setFill];
        [bezier4Path fill];


        //// Bezier 5 Drawing
        UIBezierPath* bezier5Path = [UIBezierPath bezierPath];
        [bezier5Path moveToPoint: CGPointMake(540.44, 43.47)];
        [bezier5Path addCurveToPoint: CGPointMake(531.88, 29.05) controlPoint1: CGPointMake(540.44, 34.9) controlPoint2: CGPointMake(538.3, 29.05)];
        [bezier5Path addCurveToPoint: CGPointMake(514.75, 67.04) controlPoint1: CGPointMake(517.66, 29.05) controlPoint2: CGPointMake(514.75, 54.18)];
        [bezier5Path addCurveToPoint: CGPointMake(523.89, 82.83) controlPoint1: CGPointMake(514.75, 76.79) controlPoint2: CGPointMake(517.48, 82.83)];
        [bezier5Path addCurveToPoint: CGPointMake(540.44, 43.47) controlPoint1: CGPointMake(537.33, 82.83) controlPoint2: CGPointMake(540.44, 56.33)];
        [bezier5Path closePath];
        [bezier5Path moveToPoint: CGPointMake(478.14, 65.49)];
        [bezier5Path addCurveToPoint: CGPointMake(535.97, 1.38) controlPoint1: CGPointMake(478.14, 32.37) controlPoint2: CGPointMake(495.66, 1.38)];
        [bezier5Path addCurveToPoint: CGPointMake(577.45, 44.06) controlPoint1: CGPointMake(566.35, 1.38) controlPoint2: CGPointMake(577.45, 19.31)];
        [bezier5Path addCurveToPoint: CGPointMake(518.84, 110.69) controlPoint1: CGPointMake(577.45, 76.79) controlPoint2: CGPointMake(560.12, 110.69)];
        [bezier5Path addCurveToPoint: CGPointMake(478.14, 65.49) controlPoint1: CGPointMake(488.26, 110.69) controlPoint2: CGPointMake(478.14, 90.62)];
        [bezier5Path closePath];
        bezier5Path.miterLimit = 4;
        
        [fillColor setFill];
        [bezier5Path fill];
    }
}

- (void)updateConstraints {
    NSLayoutConstraint *aspectRatioConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                             attribute:NSLayoutAttributeWidth
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeHeight
                                                                            multiplier:578.0f/111.0f
                                                                              constant:0.0f];
    aspectRatioConstraint.priority = UILayoutPriorityRequired;

    [self addConstraint:aspectRatioConstraint];

    [super updateConstraints];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(578.0f, 111.0f);
}

- (UILayoutPriority)contentCompressionResistancePriorityForAxis:(__unused UILayoutConstraintAxis)axis {
    return UILayoutPriorityRequired;
}

@end
