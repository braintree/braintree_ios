#import <Foundation/Foundation.h>

@interface BTUIUtil : NSObject

+ (BOOL)luhnValid:(NSString *)cardNumber;

+ (NSString *)stripNonDigits:(NSString *)input;

+ (NSString *)stripNonExpiry:(NSString *)input;

@end
