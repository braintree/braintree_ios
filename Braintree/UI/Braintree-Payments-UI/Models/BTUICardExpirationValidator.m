#import "BTUICardExpirationValidator.h"

@implementation BTUICardExpirationValidator

+ (BOOL)month:(NSUInteger)month year:(NSUInteger)year validForDate:(NSDate *)date {

    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    dateComponents.year = ((year % 2000) + 2000) ;
    dateComponents.month = month;
    NSInteger newMonth = (dateComponents.month + 1);
    if (newMonth > 12) {
        dateComponents.month = newMonth % 12;
        dateComponents.year += 1;
    } else {
        dateComponents.month = newMonth;
    }
    NSComparisonResult result = [date compare:dateComponents.date];
    return result == NSOrderedAscending;

}




@end
