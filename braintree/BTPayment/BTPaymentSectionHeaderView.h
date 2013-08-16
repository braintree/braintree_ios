#import <UIKit/UIKit.h>

#define BT_PAYMENT_SECTION_HEADER_VIEW_HEIGHT 40

@interface BTPaymentSectionHeaderView : UIView

- (void)setTitleText:(NSString *)text;

// If not the top section header, it will hide the top 10px and bump up the title label by 10px.
- (void)setIsTopSectionHeader:(BOOL)isTopSectionHeader;

@end
