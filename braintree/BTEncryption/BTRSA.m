#import "BTRSA.h"
#import "BTSecKeyWrapper.h"
#import "NSData+Base64.h"

#include <CommonCrypto/CommonCryptor.h>
#include <Security/Security.h>

@implementation BTRSA

@synthesize publicKey;
@synthesize publicKeyRef;
@synthesize applicationTag;

-(id)init {
    self = [super init];
    return self;
}

-(id) initWithKeyRef: (SecKeyRef) key {
    self = [super init];
    publicKeyRef = key;
    applicationTag = @"com.braintree.public_encryption_key";
    return self;
}

-(id) initWithKey: (NSString*) key {
    self = [super init];
    publicKey = key;
    applicationTag = @"com.braintree.public_encryption_key";
    return self;
}

-(SecKeyRef) getKeychainPublicKeyRef {
    if(publicKeyRef != NULL)
        return publicKeyRef;

    NSData * publicKeyData  = [NSData dataWithBase64EncodedString: publicKey];
#ifdef TARGET_OS_IPHONE 
    BTSecKeyWrapper * wrapper = [[BTSecKeyWrapper alloc] init];

    return [wrapper addPeerPublicKey:applicationTag keyBits: publicKeyData];
#elif
	    CFDataRef cfdata = CFDataCreate(NULL, [publicKeyData bytes], [publicKeyData length]);
	    SecItemImportExportKeyParameters params;
	    CFArrayRef temparray = nil;
	    OSStatus oserr = 0;

	    params.version = SEC_KEY_IMPORT_EXPORT_PARAMS_VERSION;
	    params.flags = 0; // See SecKeyImportExportFlags for details.
	    params.passphrase = NULL;
	    params.alertTitle = NULL;
	    params.alertPrompt = NULL;
	    params.accessRef = NULL;

	    /* These two values are for import. */
	    params.keyUsage = NULL;
	    params.keyAttributes = NULL;
	    SecExternalItemType itemType = kSecItemTypePublicKey;
	    SecExternalFormat externalFormat = kSecFormatBSAFE;
	    int flags = 0;
	    oserr = SecItemImport(cfdata,
	                        NULL, // filename or extension
	                        &externalFormat, // See SecExternalFormat for details
	                        &itemType, // item type
	                        flags, // See SecItemImportExportFlags for details
	                        &params,
	                        NULL, // Don't import into a keychain
	                        &temparray);
	    if(oserr != 0) NSLog(@"Secure Key Encryption Failed With Error: %ld", result);

	    return (SecKeyRef)CFArrayGetValueAtIndex(temparray, 0);
#endif
}

-(NSData*) encrypt:(NSData*) data {
    uint8_t* plainText = (uint8_t *) [data bytes];

    SecKeyRef keyRef = [self getKeychainPublicKeyRef];

    size_t cipherTextSize = SecKeyGetBlockSize(keyRef);
    uint8_t *cipherTextBuf = NULL;

    cipherTextBuf = malloc(cipherTextSize);
    memset(cipherTextBuf, 0, cipherTextSize);

    OSStatus result = SecKeyEncrypt(keyRef, kCCOptionPKCS7Padding, plainText, [data length], cipherTextBuf, &cipherTextSize);

    if(result != noErr)
        NSLog(@"Secure Key Encryption Failed With Error: %ld", result);

    NSData *cipherText = [[NSData alloc] initWithBytes: cipherTextBuf length:cipherTextSize];
    free(cipherTextBuf);

    return cipherText;
}
@end
