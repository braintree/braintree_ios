#import "BTRandomTest.h"
#import "BTRandom.h"
#import "NSData+Base64.h"

@implementation BTRandomTest
-(void) testRandomIsRandom {
  NSData * one = [BTRandom randomWordsAsData:4];
  NSData * two = [BTRandom randomWordsAsData:4];

  STAssertNotNil(one, @"not null!");
  STAssertTrue(one != two, @"");
}

-(void) testRandomLength {
  NSString * randoms = [[BTRandom randomWordsAsData:4] base64Encoding];
  STAssertTrue([randoms length] == 24, @"uses the length argument correctly");
}

@end
