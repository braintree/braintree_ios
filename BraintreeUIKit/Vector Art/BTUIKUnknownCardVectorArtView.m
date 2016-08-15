#import "BTUIKUnknownCardVectorArtView.h"

@implementation BTUIKUnknownCardVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor7 = [UIColor colorWithRed: 0.551 green: 0.551 blue: 0.551 alpha: 1];
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(0, 7.67)];
    [bezierPath addLineToPoint: CGPointMake(45, 7.67)];
    [bezierPath addLineToPoint: CGPointMake(45, 3.58)];
    [bezierPath addLineToPoint: CGPointMake(0, 3.58)];
    [bezierPath addLineToPoint: CGPointMake(0, 7.67)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(38.35, 18.92)];
    [bezierPath addLineToPoint: CGPointMake(34.77, 18.92)];
    [bezierPath addCurveToPoint: CGPointMake(32.73, 20.97) controlPoint1: CGPointMake(33.64, 18.92) controlPoint2: CGPointMake(32.73, 19.84)];
    [bezierPath addCurveToPoint: CGPointMake(34.77, 23.01) controlPoint1: CGPointMake(32.73, 22.1) controlPoint2: CGPointMake(33.64, 23.01)];
    [bezierPath addLineToPoint: CGPointMake(38.35, 23.01)];
    [bezierPath addCurveToPoint: CGPointMake(40.4, 20.97) controlPoint1: CGPointMake(39.48, 23.01) controlPoint2: CGPointMake(40.4, 22.1)];
    [bezierPath addCurveToPoint: CGPointMake(38.35, 18.92) controlPoint1: CGPointMake(40.4, 19.84) controlPoint2: CGPointMake(39.48, 18.92)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(19.99, 20.97)];
    [bezierPath addLineToPoint: CGPointMake(5.58, 20.97)];
    [bezierPath addCurveToPoint: CGPointMake(4.6, 21.94) controlPoint1: CGPointMake(5.04, 20.97) controlPoint2: CGPointMake(4.6, 21.4)];
    [bezierPath addLineToPoint: CGPointMake(4.6, 22.04)];
    [bezierPath addCurveToPoint: CGPointMake(5.58, 23.01) controlPoint1: CGPointMake(4.6, 22.57) controlPoint2: CGPointMake(5.04, 23.01)];
    [bezierPath addLineToPoint: CGPointMake(19.99, 23.01)];
    [bezierPath addCurveToPoint: CGPointMake(20.97, 22.04) controlPoint1: CGPointMake(20.53, 23.01) controlPoint2: CGPointMake(20.97, 22.57)];
    [bezierPath addLineToPoint: CGPointMake(20.97, 21.94)];
    [bezierPath addCurveToPoint: CGPointMake(19.99, 20.97) controlPoint1: CGPointMake(20.97, 21.4) controlPoint2: CGPointMake(20.53, 20.97)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(5.58, 17.9)];
    [bezierPath addLineToPoint: CGPointMake(13.86, 17.9)];
    [bezierPath addCurveToPoint: CGPointMake(14.83, 16.92) controlPoint1: CGPointMake(14.39, 17.9) controlPoint2: CGPointMake(14.83, 17.46)];
    [bezierPath addLineToPoint: CGPointMake(14.83, 16.83)];
    [bezierPath addCurveToPoint: CGPointMake(13.86, 15.85) controlPoint1: CGPointMake(14.83, 16.29) controlPoint2: CGPointMake(14.39, 15.85)];
    [bezierPath addLineToPoint: CGPointMake(5.58, 15.85)];
    [bezierPath addCurveToPoint: CGPointMake(4.6, 16.83) controlPoint1: CGPointMake(5.04, 15.85) controlPoint2: CGPointMake(4.6, 16.29)];
    [bezierPath addLineToPoint: CGPointMake(4.6, 16.92)];
    [bezierPath addCurveToPoint: CGPointMake(5.58, 17.9) controlPoint1: CGPointMake(4.6, 17.46) controlPoint2: CGPointMake(5.04, 17.9)];
    [bezierPath closePath];
    [fillColor7 setFill];
    [bezierPath fill];
}
@end
