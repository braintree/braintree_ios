#import <UIKit/UIKit.h>

/// Subclassed to easily draw vector art into a scaled UIView.
/// Useful for using generated UIBezierPath code from
/// [PaintCode](http://www.paintcodeapp.com/) verbatim.
@interface BTUIVectorArtView : UIView

/// Subclass and implement this method to draw within a context pre-scaled to the
/// view's size.
- (void)drawArt;

/// This property informs the BTVectorArtView drawRect method of the dimensions
/// of the artwork.
@property (nonatomic, assign) CGSize artDimensions;

- (UIImage *)imageOfSize:(CGSize)size;

@end
