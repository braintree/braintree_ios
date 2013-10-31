#import "BTRSATest.h"
#import "BTRSA.h"
#import "BTDecrypt.h"
#import "BTRSAKeysTest.h"

@implementation BTRSATest

- (void) testSetsPropertiesOnInstance {
  BTRSA * rsa   = [[BTRSA alloc] initWithKey:publicKey];
  STAssertEqualObjects([rsa publicKey], publicKey, @"sets the public key");
}

- (void) testRoundTripWithExistingKey {
  NSData *plainText = [@"test data" dataUsingEncoding:NSUTF8StringEncoding];
  BTRSA * rsa   = [[BTRSA alloc] initWithKey:publicKey];
  NSData * encryptedData = [rsa encrypt:plainText];

  NSData * result = [BTDecrypt decryptData:encryptedData withKey:(SecKeyRef)[BTDecrypt getPrivateKeyRef:privateKey]];

  STAssertEqualObjects([NSString stringWithUTF8String:[result bytes]], @"test data", @"success!");
}

@end
