#import <Foundation/Foundation.h>

extern NSString * const VERSION;

@interface BTEncryption : NSObject {
  NSString * publicKey;
  NSString * applicationTag;

}

- (id) initWithPublicKey: (NSString *) key;
- (NSString *) encryptData: (NSData *) data;
- (NSString *) encryptString: (NSString *) input;
- (NSString*) tokenWithVersion;

@property(nonatomic, retain) NSString * publicKey;
@property(nonatomic, retain) NSString * applicationTag;

@end

