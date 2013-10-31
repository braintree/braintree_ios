#import <Foundation/Foundation.h>

@interface BTDecrypt : NSObject
+ (NSData*) decryptAES:(NSData*) data withKey:(NSData*)key;
+ (SecKeyRef) getPrivateKeyRef:(NSString*) privateKey;
+ (NSData*) decryptData:(NSData*)encryptedData withKey:(SecKeyRef)privateKey;

@end
