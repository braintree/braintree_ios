#import "BTUIKLargeUnknownCardVectorArtView.h"

@implementation BTUIKLargeUnknownCardVectorArtView

- (void)drawArt {
    //// Color Declarations
    UIColor* fillColor7 = [UIColor colorWithRed: 0.551 green: 0.551 blue: 0.551 alpha: 1];
    
    //// Rectangle 2 Drawing
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(54.55, 48, 10.9, 5.8) cornerRadius: 2.9];
    [fillColor7 setFill];
    [rectangle2Path fill];
    
    
    //// Rectangle 3 Drawing
    UIBezierPath* rectangle3Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(14.58, 50.9, 23.25, 2.9) cornerRadius: 1.4];
    [fillColor7 setFill];
    [rectangle3Path fill];
    
    
    //// Rectangle 4 Drawing
    UIBezierPath* rectangle4Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(14.53, 43.65, 14.55, 2.9) cornerRadius: 1.4];
    [fillColor7 setFill];
    [rectangle4Path fill];
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(69, 59.6)];
    [bezierPath addLineToPoint: CGPointMake(11, 59.6)];
    [bezierPath addCurveToPoint: CGPointMake(8, 56.6) controlPoint1: CGPointMake(9.35, 59.6) controlPoint2: CGPointMake(8, 58.26)];
    [bezierPath addLineToPoint: CGPointMake(8, 23.4)];
    [bezierPath addCurveToPoint: CGPointMake(11, 20.4) controlPoint1: CGPointMake(8, 21.74) controlPoint2: CGPointMake(9.35, 20.4)];
    [bezierPath addLineToPoint: CGPointMake(69, 20.4)];
    [bezierPath addCurveToPoint: CGPointMake(72, 23.4) controlPoint1: CGPointMake(70.65, 20.4) controlPoint2: CGPointMake(72, 21.74)];
    [bezierPath addLineToPoint: CGPointMake(72, 26.18)];
    [bezierPath addLineToPoint: CGPointMake(8, 26.18)];
    [bezierPath addLineToPoint: CGPointMake(8, 32)];
    [bezierPath addLineToPoint: CGPointMake(72, 32)];
    [bezierPath addLineToPoint: CGPointMake(72, 56.6)];
    [bezierPath addCurveToPoint: CGPointMake(69, 59.6) controlPoint1: CGPointMake(72, 58.26) controlPoint2: CGPointMake(70.65, 59.6)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(69, 19.4)];
    [bezierPath addLineToPoint: CGPointMake(11, 19.4)];
    [bezierPath addCurveToPoint: CGPointMake(7, 23.4) controlPoint1: CGPointMake(8.8, 19.4) controlPoint2: CGPointMake(7, 21.2)];
    [bezierPath addLineToPoint: CGPointMake(7, 56.6)];
    [bezierPath addCurveToPoint: CGPointMake(11, 60.6) controlPoint1: CGPointMake(7, 58.8) controlPoint2: CGPointMake(8.8, 60.6)];
    [bezierPath addLineToPoint: CGPointMake(69, 60.6)];
    [bezierPath addCurveToPoint: CGPointMake(73, 56.6) controlPoint1: CGPointMake(71.2, 60.6) controlPoint2: CGPointMake(73, 58.8)];
    [bezierPath addLineToPoint: CGPointMake(73, 23.4)];
    [bezierPath addCurveToPoint: CGPointMake(69, 19.4) controlPoint1: CGPointMake(73, 21.2) controlPoint2: CGPointMake(71.2, 19.4)];
    [bezierPath closePath];
    [fillColor7 setFill];
    [bezierPath fill];
}
@end
