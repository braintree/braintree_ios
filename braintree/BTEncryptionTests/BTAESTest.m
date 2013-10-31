#import "BTAESTest.h"
#import "BTAES.h"
#import "NSData+Base64.h"
#import "BTDecrypt.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation BTAESTest

-(void) testAESEncryptionWithKeyAndIv {
  NSData * ivData = [NSData dataWithBase64EncodedString:@"AAAAAQAAAAIAAAADAAAABA=="];
  NSData * key = [NSData dataWithBase64EncodedString:@"iz5DQzn/XpwXvZ7wY3OGQRVBZTFeVMrEIUljWrIr2Pg="];

  NSData * plainData = [@"test data" dataUsingEncoding:NSUTF8StringEncoding];
  NSData * encryptedData = [BTAES encrypt: plainData withKey: key Iv: ivData];

  STAssertEqualObjects([encryptedData base64Encoding], @"AAAAAQAAAAIAAAADAAAABJcSo857BMv+cJtJfpF5Pak=", @"matches pre-generated AC");
  STAssertEqualObjects([BTDecrypt decryptAES: encryptedData withKey:key], plainData, @"round trip success");
}

-(void) testBTCryptoAES256WithoutIv {
  NSData * key = [NSData dataWithBase64EncodedString:@"iz5DQzn/XpwXvZ7wY3OGQRVBZTFeVMrEIUljWrIr2Pg="];

  NSData * plainData = [@"test data" dataUsingEncoding: NSUTF8StringEncoding];
  NSData * encryptedString = [BTAES encrypt:plainData withKey:key];

  STAssertTrue([encryptedString length] == 32, @"matches expected length");
}

@end
