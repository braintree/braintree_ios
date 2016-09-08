#import "BTUIKDinersClubVectorArtView.h"

@implementation BTUIKDinersClubVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor3 = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(27.28, 14.48)];
    [bezierPath addCurveToPoint: CGPointMake(23.18, 8.52) controlPoint1: CGPointMake(27.27, 11.76) controlPoint2: CGPointMake(25.57, 9.44)];
    [bezierPath addLineToPoint: CGPointMake(23.18, 20.44)];
    [bezierPath addCurveToPoint: CGPointMake(27.28, 14.48) controlPoint1: CGPointMake(25.57, 19.52) controlPoint2: CGPointMake(27.27, 17.2)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(18.61, 20.44)];
    [bezierPath addLineToPoint: CGPointMake(18.61, 8.52)];
    [bezierPath addCurveToPoint: CGPointMake(14.51, 14.48) controlPoint1: CGPointMake(16.22, 9.45) controlPoint2: CGPointMake(14.52, 11.76)];
    [bezierPath addCurveToPoint: CGPointMake(18.61, 20.44) controlPoint1: CGPointMake(14.52, 17.2) controlPoint2: CGPointMake(16.22, 19.51)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(20.9, 4.41)];
    [bezierPath addCurveToPoint: CGPointMake(10.83, 14.48) controlPoint1: CGPointMake(15.33, 4.41) controlPoint2: CGPointMake(10.83, 8.92)];
    [bezierPath addCurveToPoint: CGPointMake(20.9, 24.55) controlPoint1: CGPointMake(10.83, 20.04) controlPoint2: CGPointMake(15.33, 24.55)];
    [bezierPath addCurveToPoint: CGPointMake(30.97, 14.48) controlPoint1: CGPointMake(26.46, 24.55) controlPoint2: CGPointMake(30.96, 20.04)];
    [bezierPath addCurveToPoint: CGPointMake(20.9, 4.41) controlPoint1: CGPointMake(30.96, 8.92) controlPoint2: CGPointMake(26.46, 4.41)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(20.87, 25.5)];
    [bezierPath addCurveToPoint: CGPointMake(9.77, 14.6) controlPoint1: CGPointMake(14.78, 25.53) controlPoint2: CGPointMake(9.77, 20.6)];
    [bezierPath addCurveToPoint: CGPointMake(20.87, 3.5) controlPoint1: CGPointMake(9.77, 8.04) controlPoint2: CGPointMake(14.78, 3.5)];
    [bezierPath addLineToPoint: CGPointMake(23.72, 3.5)];
    [bezierPath addCurveToPoint: CGPointMake(35.23, 14.6) controlPoint1: CGPointMake(29.74, 3.5) controlPoint2: CGPointMake(35.23, 8.03)];
    [bezierPath addCurveToPoint: CGPointMake(23.72, 25.5) controlPoint1: CGPointMake(35.23, 20.6) controlPoint2: CGPointMake(29.74, 25.5)];
    [bezierPath addLineToPoint: CGPointMake(20.87, 25.5)];
    [bezierPath closePath];
    [fillColor3 setFill];
    [bezierPath fill];
}

@end
