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
    BOOL expired = [date compare:dateComponents.date] != NSOrderedAscending;
    if (expired) {
        return NO;
    }

    NSDate *farFuture = [date dateByAddingTimeInterval:3600 * 24 * 365.25 * kBTUICardExpirationValidatorFarFutureYears]; // roughly years in the future
    BOOL tooFarInTheFuture = [farFuture compare:dateComponents.date] != NSOrderedDescending;

    return !tooFarInTheFuture;
}




@end
