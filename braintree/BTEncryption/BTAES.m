#import "BTAES.h"
#import "NSData+Base64.h"
#import "BTRandom.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation BTAES

+(NSData*) encrypt:(NSData*) data withKey:(NSData*) key {
  uint8_t * words = [BTRandom randomWords: 4];
  NSData * ivData = [[NSData alloc] initWithBytes:words length: sizeof(words)];
  return [self encrypt:data withKey:key Iv:ivData];
}

+(NSData*) encrypt:(NSData *) data withKey:(NSData *) key Iv:(NSData *) iv {
  char keyPtr[kCCKeySizeAES256 + 1];
  bzero( keyPtr, sizeof( keyPtr ) );
  [key getBytes:keyPtr];

  size_t ivSize = 4*sizeof(uint32_t);
  char ivBuffer[ivSize + 1];
  void * ivPtr = (void*)&ivBuffer[0];
  bzero( ivPtr, sizeof( ivPtr ) );
  [iv getBytes:ivPtr];

  NSUInteger dataLength = [data length];

  size_t bufferSize = dataLength + kCCBlockSizeAES128;
  void * buffer = malloc( bufferSize + ivSize );
  memcpy(buffer, ivPtr, ivSize);

  size_t numBytesEncrypted = 0;

  CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                        keyPtr, kCCKeySizeAES256,
                                        ivPtr,
                                        [data bytes], dataLength,
                                        buffer + ivSize, bufferSize,
                                        &numBytesEncrypted);
  if(cryptStatus == kCCSuccess){
    return [NSData dataWithBytesNoCopy:buffer length:(numBytesEncrypted + ivSize)];
  }

  free(buffer);
  return nil;
}

@end
