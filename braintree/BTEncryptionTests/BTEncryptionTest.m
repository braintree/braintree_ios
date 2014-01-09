#import "BTEncryptionTest.h"
#import "NSData+Base64.h"
#import "BTDecrypt.h"
#import "BTRSAKeysTest.h"

@implementation BTEncryptionTest

-(void) testInitProperties {
    BTEncryption * crypto   = [[BTEncryption alloc] initWithPublicKey:@"cryptkeeper"];
    STAssertEqualObjects([crypto publicKey], @"cryptkeeper", @"sets the publicKey property");
}

-(void) testEncryptStartsWithPrefix {
    BTEncryption * crypto   = [[BTEncryption alloc] initWithPublicKey: publicKey];
    NSString  * encryptedData = [crypto encryptData: [@"test data" dataUsingEncoding:NSUTF8StringEncoding]];

    STAssertTrue([encryptedData hasPrefix: @"$bt4|ios"], @"");
}

-(void) testEncryptWithStringFormat {
    BTEncryption * crypto = [[BTEncryption alloc] initWithPublicKey: publicKey];
    NSString *encryptedString = [crypto encryptString: @"test data"];
    NSArray *aesInfo = [[encryptedString stringByReplacingOccurrencesOfString: [crypto tokenWithVersion] withString:@""]
                        componentsSeparatedByString:@"$"];

    NSString *aesKey = [aesInfo objectAtIndex:1];
    NSString *encryptedData = [aesInfo objectAtIndex:2];
    NSString *signature = [aesInfo objectAtIndex:3];
    NSString *version = [VERSION stringByReplacingOccurrencesOfString:@"." withString: @"_"];

    NSString *expectedString = [NSString stringWithFormat:@"$bt4|ios_%@$%@$%@$%@", version, aesKey, encryptedData, signature];
    STAssertTrue([encryptedString isEqualToString: expectedString], @"");
}

-(void) testRoundTrip {
    BTEncryption * crypto = [[BTEncryption alloc] initWithPublicKey: publicKey];
    NSString * encryptedString = [crypto encryptString: @"test data"];
    NSArray * aesInfo = [[encryptedString stringByReplacingOccurrencesOfString: [crypto tokenWithVersion] withString:@""]
                         componentsSeparatedByString:@"$"];

    NSData * encryptedAesKey = [NSData dataWithBase64EncodedString:[aesInfo objectAtIndex:1]];
    NSData * encodedAesKey = [BTDecrypt decryptData:encryptedAesKey withKey:[BTDecrypt getPrivateKeyRef:privateKey]];
    NSString *encodedAesKeyString = [[NSString alloc] initWithBytes:encodedAesKey.bytes length:encodedAesKey.length encoding:NSUTF8StringEncoding];
    NSData * aesKey = [NSData dataWithBase64EncodedString:encodedAesKeyString];
    NSData * decryptedData = [BTDecrypt decryptAES: [NSData dataWithBase64EncodedString:[aesInfo objectAtIndex:2]]
                                           withKey:aesKey];

    STAssertEqualObjects(decryptedData, [@"test data" dataUsingEncoding:NSUTF8StringEncoding], @"round trip!");
}

@end
