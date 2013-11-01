#import "BTEncryption.h"
#import "BTAES.h"
#import "BTRSA.h"
#import "BTHmac.h"
#import "NSData+Base64.h"
#import "BTRandom.h"

@implementation BTEncryption

@synthesize publicKey;
@synthesize applicationTag;

NSString * const VERSION = @"2.2.4";

-(id)init {
    self = [super init];
    return self;
}

-(id)initWithPublicKey: (NSString *) key {
    self = [super init];
    publicKey = key;
    return self;
}

-(NSString*) tokenWithVersion {
    NSString * formattedVersion = [VERSION stringByReplacingOccurrencesOfString:@"." withString: @"_"];
    return [NSString stringWithFormat: @"$bt4|ios_%@", formattedVersion];
}

-(NSString*) encryptString: (NSString*) input {
    NSData * data = [input dataUsingEncoding:NSUTF8StringEncoding];
    return [self encryptData: data];
}

-(NSString*) encryptData: (NSData*) data {
    NSData * encryptionKey = [BTRandom randomWordsAsData:8];
    NSData * signingKey = [BTRandom randomWordsAsData:8];

    NSMutableData * combinedKey = [[NSMutableData alloc] init];
    [combinedKey appendData:encryptionKey];
    [combinedKey appendData:signingKey];

    NSData * encodedCombinedKey = [[combinedKey base64Encoding] dataUsingEncoding:NSUTF8StringEncoding];
    BTRSA * rsa = [[BTRSA alloc] initWithKey:publicKey];
    NSData * encryptedKeys = [rsa encrypt: encodedCombinedKey];
    NSData * encryptedData = [BTAES encrypt:data withKey:encryptionKey];
    NSData * signature = [BTHmac sign:encryptedData withKey:signingKey];

    return [NSString stringWithFormat:@"%@$%@$%@$%@",
            [self tokenWithVersion],
            [encryptedKeys base64Encoding],
            [encryptedData base64Encoding],
            [signature base64Encoding]];
}

@end
