#import "BTHmacTest.h"
#import "BTHmac.h"

#import "NSData+Base64.h"

@implementation BTHmacTest

-(void) testBTHmac {
    NSData *key = [NSData dataWithBase64EncodedString:@"iz5DQzn/XpwXvZ7wY3OGQRVBZTFeVMrEIUljWrIr2Pg="];
    NSData *data = [@"test data" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *signature = [BTHmac sign:data withKey:key];

    STAssertTrue([signature length] == 32, @"matches expected length");
    STAssertEqualObjects([NSData dataWithBase64EncodedString:@"zhHPlhB7v07JedsccO/9lNQOUBxMcOv7ddDIPagh3fc="], signature, @"matches expected signature");
}

@end
