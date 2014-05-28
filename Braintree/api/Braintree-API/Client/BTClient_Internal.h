#import "BTClient.h"
#import "BTHTTP.h"
#import "BTClientToken.h"

@interface BTClient ()
@property (nonatomic, strong, readwrite) BTHTTP *http;
@property (nonatomic, strong) BTClientToken *clientToken;
@end