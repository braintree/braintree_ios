#import "BTConfiguration.h"
#import "BTClientMetadata.h"
#import "BTJSON.h"

@interface BTConfiguration ()
@property (nonatomic, copy) NSString *clientKey;
@property (nonatomic, strong) NSURL *baseURL;

/// Client metadata that is used for tracking the client session
@property (nonatomic, readonly, strong) BTClientMetadata *clientMetadata;

- (void)fetchOrReturnRemoteConfiguration:(void (^)(BTJSON *remoteConfiguration, NSError *error))completionBlock;

@end
