#import <Foundation/Foundation.h>

#define kBTKCardExpirationValidatorFarFutureYears 20

@interface BTKCardExpirationValidator : NSObject

+ (BOOL)month:(NSUInteger)month year:(NSUInteger)year validForDate:(NSDate *)date;

@end
