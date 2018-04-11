#import <UIKit/UIKit.h>
#import "BTUIThemedView.h"

/**
 Informational view that displays a summary of the shopping cart or other relevant data for checkout experience that user is agreing too.
*/
 @interface BTUISummaryView : BTUIThemedView

/**
 The text to display as the primary description of the purchase.
*/
@property (nonatomic, copy) NSString *slug;

/**
 The text to display as the secondary summary of the purchase.
*/
@property (nonatomic, copy) NSString *summary;

/**
 The textual representation of the dollar amount for the purchase including the currency symbol
*/
@property (nonatomic, copy) NSString *amount;

@end
