#import "NSDataBase64Test.h"

@implementation NSDataBase64Test

-(void) testSimpleString {
  NSData * testData = [@"Man" dataUsingEncoding:NSUTF8StringEncoding];
  NSString * encodedData = [testData base64Encoding];

  STAssertEqualObjects(encodedData, @"TWFu", @"encoded to Base64");
}

@end
