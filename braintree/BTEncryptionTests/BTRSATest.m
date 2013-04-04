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
  NSString * plainText = @"test data";
  BTRSA * rsa   = [[BTRSA alloc] initWithKey:publicKey];
  NSData * encryptedData = [rsa encrypt: plainText];

  NSString * plainStr = [BTDecrypt decryptWithKey:(SecKeyRef)[BTDecrypt getPrivateKeyRef:privateKey] Data:encryptedData];

  STAssertEqualObjects(plainStr, @"test data", @"success!");
}

@end
