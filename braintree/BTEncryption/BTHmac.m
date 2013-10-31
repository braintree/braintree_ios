#import "BTHmac.h"
#import "NSData+Base64.h"
#include "CommonCrypto/CommonHMAC.h"

@implementation BTHmac

+(NSData*) sign:(NSData*) data withKey:(NSData*) key {
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, [key bytes], [key length], [data bytes], [data length], cHMAC);

    return [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
}

@end
