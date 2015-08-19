#import <Foundation/Foundation.h>

#import "BTAPIResponseParser.h"

@interface BTClientTokenBooleanValueTransformer : NSObject <BTValueTransforming>

+ (instancetype)sharedInstance;

@end
