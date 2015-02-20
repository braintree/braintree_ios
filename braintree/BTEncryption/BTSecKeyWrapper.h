#import <CommonCrypto/CommonCryptor.h>
#import <Foundation/Foundation.h>

@interface BTSecKeyWrapper : NSObject {
	CCOptions typeOfSymmetricOpts;
}

- (SecKeyRef) addPeerPublicKey:(NSString *)peerName keyBits:(NSData *)publicKey;
- (void) removePeerPublicKey:(NSString *)peerName;

@end
