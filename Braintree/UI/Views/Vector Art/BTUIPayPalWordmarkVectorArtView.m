#import "BTUIPayPalWordmarkVectorArtView.h"
#import "BTUI.h"

@implementation BTUIPayPalWordmarkVectorArtView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.artDimensions = CGSizeMake(158, 88);
        self.opaque = NO;
        self.theme = [BTUI braintreeTheme];
    }
    return self;
}

- (void)drawArt
{
    //// Color Declarations
    UIColor* payColor = [self.theme payBlue]; //[UIColor colorWithRed: 0.005 green: 0.123 blue: 0.454 alpha: 1];
    UIColor* palColor = [self.theme palBlue]; //[UIColor colorWithRed: 0.066 green: 0.536 blue: 0.839 alpha: 1];

    //// Assets
    {
        //// button-paypal
        {
            //// Rectangle Drawing


            //// logo/paypal
            {
                //// Bezier Drawing
                UIBezierPath* bezierPath = [UIBezierPath bezierPath];
                [bezierPath moveToPoint: CGPointMake(102.29, 34.76)];
                [bezierPath addCurveToPoint: CGPointMake(96.25, 38.4) controlPoint1: CGPointMake(101.73, 38.4) controlPoint2: CGPointMake(98.95, 38.4)];
                [bezierPath addLineToPoint: CGPointMake(94.72, 38.4)];
                [bezierPath addLineToPoint: CGPointMake(95.8, 31.6)];
                [bezierPath addCurveToPoint: CGPointMake(96.63, 30.89) controlPoint1: CGPointMake(95.86, 31.19) controlPoint2: CGPointMake(96.22, 30.89)];
                [bezierPath addLineToPoint: CGPointMake(97.33, 30.89)];
                [bezierPath addCurveToPoint: CGPointMake(101.79, 31.93) controlPoint1: CGPointMake(99.17, 30.89) controlPoint2: CGPointMake(100.9, 30.89)];
                [bezierPath addCurveToPoint: CGPointMake(102.29, 34.76) controlPoint1: CGPointMake(102.33, 32.55) controlPoint2: CGPointMake(102.49, 33.48)];
                [bezierPath addLineToPoint: CGPointMake(102.29, 34.76)];
                [bezierPath closePath];
                [bezierPath moveToPoint: CGPointMake(91, 25)];
                [bezierPath addCurveToPoint: CGPointMake(89.56, 26.45) controlPoint1: CGPointMake(90.31, 25) controlPoint2: CGPointMake(89.67, 25.76)];
                [bezierPath addLineToPoint: CGPointMake(85.5, 53)];
                [bezierPath addCurveToPoint: CGPointMake(86.5, 54) controlPoint1: CGPointMake(85.42, 53.51) controlPoint2: CGPointMake(85.98, 54)];
                [bezierPath addLineToPoint: CGPointMake(91.5, 54)];
                [bezierPath addCurveToPoint: CGPointMake(92.5, 53) controlPoint1: CGPointMake(91.99, 54) controlPoint2: CGPointMake(92.42, 53.48)];
                [bezierPath addLineToPoint: CGPointMake(93.64, 45.22)];
                [bezierPath addCurveToPoint: CGPointMake(95.04, 44.03) controlPoint1: CGPointMake(93.75, 44.54) controlPoint2: CGPointMake(94.34, 44.03)];
                [bezierPath addLineToPoint: CGPointMake(98.25, 44.03)];
                [bezierPath addCurveToPoint: CGPointMake(109.81, 34.4) controlPoint1: CGPointMake(104.94, 44.03) controlPoint2: CGPointMake(108.8, 40.8)];
                [bezierPath addCurveToPoint: CGPointMake(108.52, 27.85) controlPoint1: CGPointMake(110.27, 31.59) controlPoint2: CGPointMake(109.83, 29.39)];
                [bezierPath addCurveToPoint: CGPointMake(101, 25) controlPoint1: CGPointMake(107.07, 26.16) controlPoint2: CGPointMake(104.4, 25)];
                [bezierPath addLineToPoint: CGPointMake(91, 25)];
                [bezierPath closePath];
                [bezierPath moveToPoint: CGPointMake(123.7, 44.09)];
                [bezierPath addCurveToPoint: CGPointMake(118.21, 48.73) controlPoint1: CGPointMake(123.22, 46.87) controlPoint2: CGPointMake(121.02, 48.73)];
                [bezierPath addCurveToPoint: CGPointMake(114.94, 47.42) controlPoint1: CGPointMake(116.79, 48.73) controlPoint2: CGPointMake(115.67, 48.28)];
                [bezierPath addCurveToPoint: CGPointMake(114.18, 44.01) controlPoint1: CGPointMake(114.22, 46.57) controlPoint2: CGPointMake(113.95, 45.36)];
                [bezierPath addCurveToPoint: CGPointMake(119.63, 39.33) controlPoint1: CGPointMake(114.61, 41.26) controlPoint2: CGPointMake(116.86, 39.33)];
                [bezierPath addCurveToPoint: CGPointMake(122.87, 40.66) controlPoint1: CGPointMake(121.01, 39.33) controlPoint2: CGPointMake(122.13, 39.79)];
                [bezierPath addCurveToPoint: CGPointMake(123.7, 44.09) controlPoint1: CGPointMake(123.62, 41.53) controlPoint2: CGPointMake(123.91, 42.75)];
                [bezierPath closePath];
                [bezierPath moveToPoint: CGPointMake(131.15, 34.46)];
                [bezierPath addLineToPoint: CGPointMake(126.25, 34.46)];
                [bezierPath addCurveToPoint: CGPointMake(125.41, 35.19) controlPoint1: CGPointMake(125.83, 34.46) controlPoint2: CGPointMake(125.48, 34.77)];
                [bezierPath addLineToPoint: CGPointMake(125.2, 36.57)];
                [bezierPath addLineToPoint: CGPointMake(124.85, 36.07)];
                [bezierPath addCurveToPoint: CGPointMake(119.07, 34) controlPoint1: CGPointMake(123.79, 34.52) controlPoint2: CGPointMake(121.43, 34)];
                [bezierPath addCurveToPoint: CGPointMake(108.15, 43.92) controlPoint1: CGPointMake(113.67, 34) controlPoint2: CGPointMake(109.05, 38.13)];
                [bezierPath addCurveToPoint: CGPointMake(109.97, 51.49) controlPoint1: CGPointMake(107.68, 46.81) controlPoint2: CGPointMake(108.34, 49.57)];
                [bezierPath addCurveToPoint: CGPointMake(116.13, 54) controlPoint1: CGPointMake(111.46, 53.26) controlPoint2: CGPointMake(113.59, 54)];
                [bezierPath addCurveToPoint: CGPointMake(122.91, 51.18) controlPoint1: CGPointMake(120.49, 54) controlPoint2: CGPointMake(122.91, 51.18)];
                [bezierPath addLineToPoint: CGPointMake(122.69, 52.55)];
                [bezierPath addCurveToPoint: CGPointMake(123.53, 53.54) controlPoint1: CGPointMake(122.61, 53.07) controlPoint2: CGPointMake(123.01, 53.54)];
                [bezierPath addLineToPoint: CGPointMake(127.94, 53.54)];
                [bezierPath addCurveToPoint: CGPointMake(129.34, 52.33) controlPoint1: CGPointMake(128.64, 53.54) controlPoint2: CGPointMake(129.23, 53.03)];
                [bezierPath addLineToPoint: CGPointMake(131.99, 35.46)];
                [bezierPath addCurveToPoint: CGPointMake(131.15, 34.46) controlPoint1: CGPointMake(132.07, 34.94) controlPoint2: CGPointMake(131.67, 34.46)];
                [bezierPath closePath];
                [bezierPath moveToPoint: CGPointMake(137, 27)];
                [bezierPath addLineToPoint: CGPointMake(133, 53)];
                [bezierPath addCurveToPoint: CGPointMake(134, 54) controlPoint1: CGPointMake(132.93, 53.54) controlPoint2: CGPointMake(133.34, 54)];
                [bezierPath addLineToPoint: CGPointMake(138, 54)];
                [bezierPath addCurveToPoint: CGPointMake(140, 53) controlPoint1: CGPointMake(138.98, 54) controlPoint2: CGPointMake(139.59, 53.5)];
                [bezierPath addLineToPoint: CGPointMake(144, 27)];
                [bezierPath addCurveToPoint: CGPointMake(143, 26) controlPoint1: CGPointMake(144.07, 26.46) controlPoint2: CGPointMake(143.66, 26)];
                [bezierPath addLineToPoint: CGPointMake(138, 26)];
                [bezierPath addCurveToPoint: CGPointMake(137, 27) controlPoint1: CGPointMake(137.79, 26) controlPoint2: CGPointMake(137.42, 26.3)];
                [bezierPath closePath];
                bezierPath.miterLimit = 4;

                bezierPath.usesEvenOddFillRule = YES;

                [palColor setFill];
                [bezierPath fill];


                //// Bezier 2 Drawing
                UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
                [bezier2Path moveToPoint: CGPointMake(29.84, 34.76)];
                [bezier2Path addCurveToPoint: CGPointMake(23.81, 38.4) controlPoint1: CGPointMake(29.29, 38.4) controlPoint2: CGPointMake(26.5, 38.4)];
                [bezier2Path addLineToPoint: CGPointMake(22.28, 38.4)];
                [bezier2Path addLineToPoint: CGPointMake(23.35, 31.6)];
                [bezier2Path addCurveToPoint: CGPointMake(24.19, 30.89) controlPoint1: CGPointMake(23.42, 31.19) controlPoint2: CGPointMake(23.77, 30.89)];
                [bezier2Path addLineToPoint: CGPointMake(24.89, 30.89)];
                [bezier2Path addCurveToPoint: CGPointMake(29.35, 31.93) controlPoint1: CGPointMake(26.72, 30.89) controlPoint2: CGPointMake(28.45, 30.89)];
                [bezier2Path addCurveToPoint: CGPointMake(29.84, 34.76) controlPoint1: CGPointMake(29.88, 32.55) controlPoint2: CGPointMake(30.04, 33.48)];
                [bezier2Path addLineToPoint: CGPointMake(29.84, 34.76)];
                [bezier2Path closePath];
                [bezier2Path moveToPoint: CGPointMake(18.5, 25)];
                [bezier2Path addCurveToPoint: CGPointMake(17, 26.5) controlPoint1: CGPointMake(17.81, 25) controlPoint2: CGPointMake(17.11, 25.82)];
                [bezier2Path addLineToPoint: CGPointMake(13, 53)];
                [bezier2Path addCurveToPoint: CGPointMake(14, 54) controlPoint1: CGPointMake(12.92, 53.51) controlPoint2: CGPointMake(13.48, 54)];
                [bezier2Path addLineToPoint: CGPointMake(18.5, 54)];
                [bezier2Path addCurveToPoint: CGPointMake(20, 52.5) controlPoint1: CGPointMake(19.19, 54) controlPoint2: CGPointMake(19.89, 53.18)];
                [bezier2Path addLineToPoint: CGPointMake(21.2, 45.22)];
                [bezier2Path addCurveToPoint: CGPointMake(22.59, 44.03) controlPoint1: CGPointMake(21.31, 44.54) controlPoint2: CGPointMake(21.9, 44.03)];
                [bezier2Path addLineToPoint: CGPointMake(25.81, 44.03)];
                [bezier2Path addCurveToPoint: CGPointMake(37.37, 34.4) controlPoint1: CGPointMake(32.5, 44.03) controlPoint2: CGPointMake(36.36, 40.8)];
                [bezier2Path addCurveToPoint: CGPointMake(36.07, 27.85) controlPoint1: CGPointMake(37.82, 31.59) controlPoint2: CGPointMake(37.39, 29.39)];
                [bezier2Path addCurveToPoint: CGPointMake(28.5, 25) controlPoint1: CGPointMake(34.63, 26.16) controlPoint2: CGPointMake(31.9, 25)];
                [bezier2Path addLineToPoint: CGPointMake(18.5, 25)];
                [bezier2Path closePath];
                [bezier2Path moveToPoint: CGPointMake(52.25, 44.09)];
                [bezier2Path addCurveToPoint: CGPointMake(46.76, 48.73) controlPoint1: CGPointMake(51.78, 46.87) controlPoint2: CGPointMake(49.57, 48.73)];
                [bezier2Path addCurveToPoint: CGPointMake(43.49, 47.42) controlPoint1: CGPointMake(45.35, 48.73) controlPoint2: CGPointMake(44.22, 48.28)];
                [bezier2Path addCurveToPoint: CGPointMake(42.73, 44.01) controlPoint1: CGPointMake(42.77, 46.57) controlPoint2: CGPointMake(42.5, 45.36)];
                [bezier2Path addCurveToPoint: CGPointMake(48.18, 39.33) controlPoint1: CGPointMake(43.17, 41.26) controlPoint2: CGPointMake(45.41, 39.33)];
                [bezier2Path addCurveToPoint: CGPointMake(51.42, 40.66) controlPoint1: CGPointMake(49.56, 39.33) controlPoint2: CGPointMake(50.69, 39.79)];
                [bezier2Path addCurveToPoint: CGPointMake(52.25, 44.09) controlPoint1: CGPointMake(52.17, 41.53) controlPoint2: CGPointMake(52.46, 42.75)];
                [bezier2Path closePath];
                [bezier2Path moveToPoint: CGPointMake(54.5, 34)];
                [bezier2Path addCurveToPoint: CGPointMake(53.5, 35) controlPoint1: CGPointMake(54.08, 34) controlPoint2: CGPointMake(53.56, 34.58)];
                [bezier2Path addLineToPoint: CGPointMake(53.2, 36.57)];
                [bezier2Path addLineToPoint: CGPointMake(52.85, 36.07)];
                [bezier2Path addCurveToPoint: CGPointMake(47.07, 34) controlPoint1: CGPointMake(51.79, 34.52) controlPoint2: CGPointMake(49.43, 34)];
                [bezier2Path addCurveToPoint: CGPointMake(36.15, 43.92) controlPoint1: CGPointMake(41.67, 34) controlPoint2: CGPointMake(37.05, 38.13)];
                [bezier2Path addCurveToPoint: CGPointMake(37.97, 51.49) controlPoint1: CGPointMake(35.68, 46.81) controlPoint2: CGPointMake(36.34, 49.57)];
                [bezier2Path addCurveToPoint: CGPointMake(44.13, 54) controlPoint1: CGPointMake(39.46, 53.26) controlPoint2: CGPointMake(41.59, 54)];
                [bezier2Path addCurveToPoint: CGPointMake(50.91, 51.18) controlPoint1: CGPointMake(48.49, 54) controlPoint2: CGPointMake(50.91, 51.18)];
                [bezier2Path addLineToPoint: CGPointMake(50.5, 53)];
                [bezier2Path addCurveToPoint: CGPointMake(51.5, 54) controlPoint1: CGPointMake(50.42, 53.52) controlPoint2: CGPointMake(50.98, 54)];
                [bezier2Path addLineToPoint: CGPointMake(56, 54)];
                [bezier2Path addCurveToPoint: CGPointMake(57.5, 52.5) controlPoint1: CGPointMake(56.7, 54) controlPoint2: CGPointMake(57.39, 53.2)];
                [bezier2Path addLineToPoint: CGPointMake(60, 35)];
                [bezier2Path addCurveToPoint: CGPointMake(59, 34) controlPoint1: CGPointMake(60.08, 34.48) controlPoint2: CGPointMake(59.52, 34)];
                [bezier2Path addLineToPoint: CGPointMake(54.5, 34)];
                [bezier2Path closePath];
                [bezier2Path moveToPoint: CGPointMake(80, 34)];
                [bezier2Path addCurveToPoint: CGPointMake(79, 35.04) controlPoint1: CGPointMake(79.67, 34) controlPoint2: CGPointMake(79.22, 34.24)];
                [bezier2Path addLineToPoint: CGPointMake(72, 44.4)];
                [bezier2Path addLineToPoint: CGPointMake(69, 35.04)];
                [bezier2Path addCurveToPoint: CGPointMake(68, 34) controlPoint1: CGPointMake(68.97, 34.42) controlPoint2: CGPointMake(68.41, 34)];
                [bezier2Path addLineToPoint: CGPointMake(63, 34)];
                [bezier2Path addCurveToPoint: CGPointMake(62, 35.04) controlPoint1: CGPointMake(62.27, 34) controlPoint2: CGPointMake(61.86, 34.58)];
                [bezier2Path addLineToPoint: CGPointMake(68, 51.68)];
                [bezier2Path addLineToPoint: CGPointMake(62, 58.96)];
                [bezier2Path addCurveToPoint: CGPointMake(63, 60) controlPoint1: CGPointMake(61.97, 59.21) controlPoint2: CGPointMake(62.38, 60)];
                [bezier2Path addLineToPoint: CGPointMake(68, 60)];
                [bezier2Path addCurveToPoint: CGPointMake(69, 58.96) controlPoint1: CGPointMake(68.54, 60) controlPoint2: CGPointMake(68.98, 59.77)];
                [bezier2Path addLineToPoint: CGPointMake(86, 35.04)];
                [bezier2Path addCurveToPoint: CGPointMake(85, 34) controlPoint1: CGPointMake(86.24, 34.79) controlPoint2: CGPointMake(85.83, 34)];
                [bezier2Path addLineToPoint: CGPointMake(80, 34)];
                [bezier2Path closePath];
                bezier2Path.miterLimit = 4;
                
                bezier2Path.usesEvenOddFillRule = YES;
                
                [payColor setFill];
                [bezier2Path fill];
            }
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
