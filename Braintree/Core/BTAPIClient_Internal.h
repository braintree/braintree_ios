#import "BTAPIClient.h"
#import "BTClientMetadata.h"
#import "BTJSON.h"
#import "BTHTTP.h"

@interface BTAPIClient ()
@property (nonatomic, copy) NSString *clientKey;
@property (nonatomic, strong) BTHTTP *http;

/// Client metadata that is used for tracking the client session
@property (nonatomic, readonly, strong) BTClientMetadata *metadata;

@end
