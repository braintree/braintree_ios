#import "BTHmac.h"
#import "NSData+Base64.h"
#include "CommonCrypto/CommonHMAC.h"

@implementation BTHmac

+(NSString*) sign:(NSString*) data withKey:(NSString*) key {
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    NSData *hash = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];

    NSString * encoded = [hash base64Encoding];
    return encoded;
}

@end
