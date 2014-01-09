#import "BTSecKeyWrapper.h"
#import <Security/Security.h>

@implementation BTSecKeyWrapper

#if DEBUG
	#define LOGGING_FACILITY(X, Y)	\
					NSAssert(X, Y);

	#define LOGGING_FACILITY1(X, Y, Z)	\
					NSAssert1(X, Y, Z);
#else
	#define LOGGING_FACILITY(X, Y)	\
				if (!(X)) {			\
					NSLog(Y);		\
				}

	#define LOGGING_FACILITY1(X, Y, Z)	\
				if (!(X)) {				\
					NSLog(Y, Z);		\
				}
#endif

- (SecKeyRef)addPeerPublicKey:(NSString *)peerName keyBits:(NSData *)publicKey {
  [self removePeerPublicKey:peerName];

	OSStatus sanityCheck = noErr;
	SecKeyRef peerKeyRef = NULL;

	LOGGING_FACILITY( peerName != nil, @"Peer name parameter is nil." );
	LOGGING_FACILITY( publicKey != nil, @"Public key parameter is nil." );

	NSData * peerTag = [[NSData alloc] initWithBytes:(const void *)[peerName UTF8String] length:[peerName length]];
	NSMutableDictionary * peerPublicKeyAttr = [[NSMutableDictionary alloc] init];

	[peerPublicKeyAttr setObject:(__bridge id)kSecClassKey       forKey:(__bridge id)kSecClass];
	[peerPublicKeyAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
	[peerPublicKeyAttr setObject:peerTag                forKey:(__bridge id)kSecAttrApplicationTag];
	[peerPublicKeyAttr setObject:publicKey              forKey:(__bridge id)kSecValueData];
	[peerPublicKeyAttr setObject:(__bridge id)kCFBooleanTrue     forKey:(__bridge id)kSecReturnRef];

	sanityCheck = SecItemAdd((__bridge CFDictionaryRef) peerPublicKeyAttr, (CFTypeRef *)&peerKeyRef);

	LOGGING_FACILITY1( sanityCheck == noErr, @"Problem adding the public key, OSStatus == %ld.", (long)sanityCheck );

  [peerPublicKeyAttr removeObjectForKey:(__bridge id)kSecValueData];
  sanityCheck = SecItemCopyMatching((__bridge CFDictionaryRef) peerPublicKeyAttr, (CFTypeRef *)&peerKeyRef);

	LOGGING_FACILITY1( sanityCheck == noErr && peerKeyRef != NULL, @"Problem acquiring reference to the public key, OSStatus == %ld.", (long)sanityCheck );

	return peerKeyRef;
}

- (void)removePeerPublicKey:(NSString *)peerName {
	OSStatus sanityCheck = noErr;

	LOGGING_FACILITY( peerName != nil, @"Peer name parameter is nil." );

	NSData * peerTag = [[NSData alloc] initWithBytes:(const void *)[peerName UTF8String] length:[peerName length]];
	NSMutableDictionary * peerPublicKeyAttr = [[NSMutableDictionary alloc] init];

	[peerPublicKeyAttr setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
	[peerPublicKeyAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
	[peerPublicKeyAttr setObject:peerTag forKey:(__bridge id)kSecAttrApplicationTag];

	sanityCheck = SecItemDelete((__bridge CFDictionaryRef) peerPublicKeyAttr);

	LOGGING_FACILITY1( sanityCheck == noErr || sanityCheck == errSecItemNotFound, @"Problem deleting the peer public key from keychain, OSStatus == %ld.", (long)sanityCheck );
}

@end
