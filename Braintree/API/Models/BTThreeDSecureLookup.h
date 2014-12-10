#import <Foundation/Foundation.h>

@interface BTThreeDSecureLookup : NSObject
@property (nonatomic, copy) NSString *nonce;
@property (nonatomic, copy) NSString *PAReq;
@property (nonatomic, copy) NSURL *acsURL;
@property (nonatomic, copy) NSURL *termURL;

- (BOOL)requiresUserAuthentication;

@end
