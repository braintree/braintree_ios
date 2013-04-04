#import <CommonCrypto/CommonCryptor.h>

@interface BTSecKeyWrapper : NSObject {
	CCOptions typeOfSymmetricOpts;
}

- (SecKeyRef) addPeerPublicKey:(NSString *)peerName keyBits:(NSData *)publicKey;
- (void) removePeerPublicKey:(NSString *)peerName;

@end
