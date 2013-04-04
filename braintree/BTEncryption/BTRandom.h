#import <Foundation/Foundation.h>

@interface BTRandom : NSObject

+ (NSData*) randomWordsAsData:(int) count;
+ (uint8_t*) randomWords:(int) count;

@end
