#import "BTHmacTest.h"
#import "BTHmac.h"

@implementation BTHmacTest

-(void) testBTHmac {
    NSString *key = @"iz5DQzn/XpwXvZ7wY3OGQRVBZTFeVMrEIUljWrIr2Pg=";
    NSString *data = @"test data";
    NSString *hashedString = [BTHmac sign: data withKey: key];

    STAssertTrue([hashedString length] == 44, @"matches expected length");
}

@end
