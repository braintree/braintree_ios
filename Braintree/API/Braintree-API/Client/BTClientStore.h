#import <Foundation/Foundation.h>
#import "BTClient.h"

@interface BTClientStore : NSObject

- (instancetype)initWithIdentifier:(NSString *)identifier;

- (void)storeClient:(BTClient *)client;
- (BTClient *)fetchClient;

@end
