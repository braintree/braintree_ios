#import <Foundation/Foundation.h>

#define kBTUIKCardExpirationValidatorFarFutureYears 20

@interface BTUIKCardExpirationValidator : NSObject

+ (BOOL)month:(NSUInteger)month year:(NSUInteger)year validForDate:(NSDate *)date;

@end
