#import "BTClient.h"
#import "BTHTTP.h"
#import "BTClientToken.h"

@interface BTClient ()
@property (nonatomic, strong, readwrite) BTHTTP *clientApiHttp;
@property (nonatomic, strong, readwrite) BTHTTP *analyticsHttp;
@property (nonatomic, strong) BTClientToken *clientToken;
@end