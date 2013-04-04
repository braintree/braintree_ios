#import "BTEncryption.h"
#import "BTAES.h"
#import "BTRSA.h"
#import "NSData+Base64.h"
#import "BTRandom.h"

@implementation BTEncryption

@synthesize publicKey;
@synthesize applicationTag;

NSString * const VERSION = @"2.0.0";

- (id)init {
  self = [super init];
  return self;
}

- (id)initWithPublicKey: (NSString *) key {
  self = [super init];

  publicKey = key;

  return self;
}

-(NSString*) encryptData: (NSData*) data {
  NSString * randomKey = [[BTRandom randomWordsAsData:8] base64Encoding];
  BTRSA * rsa = [[BTRSA alloc] initWithKey:publicKey];
  NSString * encryptedKey = [[rsa encrypt: randomKey] base64Encoding];

  NSString * encryptedData = [BTAES encrypt:data withKey:randomKey];

  return [[[[[self tokenWithVersion]
           stringByAppendingString: @"$"]
           stringByAppendingString: encryptedKey]
           stringByAppendingString: @"$"]
           stringByAppendingString: encryptedData];
}

-(NSString*) encryptString: (NSString*) input {
  NSData * data = [input dataUsingEncoding:NSUTF8StringEncoding];
  return [self encryptData: data];
}

-(NSString*) tokenWithVersion {
  NSString * formattedVersion = [VERSION stringByReplacingOccurrencesOfString:@"." withString: @"_"];

  return [NSString stringWithFormat: @"$bt3|ios_%@", formattedVersion];

}

@end
