#import "BTDecrypt.h"
#import "NSData+Base64.h"
#import "BTSecKeyWrapper.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation BTDecrypt

+ (NSData*)decryptAES:(NSData*) data withKey:(NSData*)key {
  NSUInteger ivSize = 4*sizeof(uint32_t);
  NSData * iv = [NSData dataWithBytes:[data bytes] length:ivSize];

  NSData * encryptedData = [data subdataWithRange: NSMakeRange(ivSize, [data length] - ivSize)];
  NSUInteger dataLength = [encryptedData length];

  size_t outputBufferSize = dataLength;
  void * outputBuffer = malloc(outputBufferSize);
  bzero(outputBuffer, outputBufferSize);

  size_t numBytesDecrypted = 0;

  CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                        [key bytes], kCCKeySizeAES256,
                                        [iv bytes],
                                        [encryptedData bytes], dataLength,
                                        outputBuffer, outputBufferSize,
                                        &numBytesDecrypted);

  if( cryptStatus == kCCSuccess ){
    return [NSData dataWithBytesNoCopy:outputBuffer length:numBytesDecrypted];
  }

  NSLog(@"AES Decrypt: FAIL %d", cryptStatus);

  free( outputBuffer );
  return nil;
}

+ (SecKeyRef) getPrivateKeyRef:(NSString*) privateKey {
  NSMutableDictionary * peerKeyAttr = [[NSMutableDictionary alloc] init];
  NSString * tag = @"com.braintree.private_key_for_testing";
  NSData * peerTag = [tag dataUsingEncoding: NSUTF8StringEncoding ];
  SecKeyRef privateKeyRef = NULL;
  BTSecKeyWrapper * wrapper = [[BTSecKeyWrapper alloc] init];
  [wrapper removePeerPublicKey:tag];

  NSData * privateKeyData = [NSData dataWithBase64EncodedString: privateKey];

  [peerKeyAttr setObject:(__bridge id)kSecClassKey             forKey:(__bridge id)kSecClass];
  [peerKeyAttr setObject:peerTag                      forKey:(__bridge id)kSecAttrApplicationTag];
  [peerKeyAttr setObject:(__bridge id)kSecAttrKeyTypeRSA       forKey:(__bridge id)kSecAttrKeyType];
	[peerKeyAttr setObject:privateKeyData               forKey:(__bridge id)kSecValueData];
  [peerKeyAttr setObject:(__bridge id)kSecAttrKeyClassPrivate  forKey:(__bridge id)kSecAttrKeyClass];
  [peerKeyAttr setObject:(__bridge id)kCFBooleanTrue           forKey:(__bridge id)kSecReturnRef];

  OSStatus result = SecItemAdd((__bridge CFDictionaryRef)peerKeyAttr, (CFTypeRef*)&privateKeyRef);
  NSAssert(result == errSecSuccess, @"keychain item add failure: %ld", (long)result);

  [peerKeyAttr removeObjectForKey:(__bridge id)kSecValueData];

  result = SecItemCopyMatching((__bridge CFDictionaryRef) peerKeyAttr, (CFTypeRef *)&privateKeyRef);

  NSAssert(privateKeyRef != NULL && result == errSecSuccess, @"keychain data lookup failure: %ld", (long)result);

  return privateKeyRef;
}

+ (NSData*) decryptData:(NSData*)encryptedData withKey:(SecKeyRef)privateKey {
  size_t plainTextLen = [encryptedData length];
  uint8_t * plainText = malloc(sizeof(uint8_t)*plainTextLen);
  memset(plainText, 0, plainTextLen);

  SecKeyDecrypt(privateKey,
                kCCOptionPKCS7Padding,
                (const uint8_t*)[encryptedData bytes],
                [encryptedData length],
                plainText,
                &plainTextLen
                );
  NSData * data = [NSData dataWithBytes:plainText length:plainTextLen];
  free(plainText);
  return data;
}

@end
