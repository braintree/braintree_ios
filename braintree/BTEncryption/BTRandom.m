#import "BTRandom.h"

@implementation BTRandom

+ (NSData*) randomWordsAsData:(int) count {
  uint8_t * words = [self randomWords: count];
  return [NSData dataWithBytes:words length: (4* count)];
}

+ (uint8_t*) randomWords:(int) count {
  int keySize = 4 * count;

  uint8_t * randoms = malloc(keySize * sizeof(uint8_t));
  memset((void*)randoms, 0, keySize);

  SecRandomCopyBytes(kSecRandomDefault, keySize, randoms);
  return randoms;
}

@end
