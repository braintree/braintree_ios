#import "BTEncryption.h"
#import "BTAES.h"
#import "BTRSA.h"
#import "BTHmac.h"
#import "NSData+Base64.h"
#import "BTRandom.h"

@implementation BTEncryption

@synthesize publicKey;
@synthesize applicationTag;

NSString * const VERSION = @"2.2.2";

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
    NSString * encryptionKey = [[BTRandom randomWordsAsData:8] base64Encoding];
    NSString * signingKey = [[BTRandom randomWordsAsData:8] base64Encoding];
    NSString * combinedKey = [NSString stringWithFormat:@"%@%@", encryptionKey, signingKey];
    BTRSA * rsa = [[BTRSA alloc] initWithKey:publicKey];
    NSString * encryptedKey = [[rsa encrypt: combinedKey] base64Encoding];
    NSString * encryptedData = [BTAES encrypt:data withKey:encryptionKey];
    NSString * signedData = [BTHmac sign:encryptedData withKey:signingKey];

    return [NSString stringWithFormat:@"%@$%@$%@$%@", [self tokenWithVersion], encryptedKey, encryptedData, signedData];
}

@end
