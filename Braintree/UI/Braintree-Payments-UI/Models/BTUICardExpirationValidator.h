@import Foundation;

#define kBTUICardExpirationValidatorFarFutureYears 20

@interface BTUICardExpirationValidator : NSObject

+ (BOOL)month:(NSUInteger)month year:(NSUInteger)year validForDate:(NSDate *)date;

@end
