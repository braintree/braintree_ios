#import <Foundation/Foundation.h>

@interface BTRSA : NSObject {
  NSString * publicKey;
  SecKeyRef publicKeyRef;
  NSString * applicationTag;
}

- (id) initWithKey: (NSString*) key;
- (id) initWithKeyRef: (SecKeyRef) key;

- (NSData*) encrypt:(NSString*) data;
- (SecKeyRef) getKeychainPublicKeyRef;

@property(nonatomic, retain) NSString * publicKey;
@property(nonatomic) SecKeyRef publicKeyRef;
@property(nonatomic, retain) NSString * applicationTag;

@end
