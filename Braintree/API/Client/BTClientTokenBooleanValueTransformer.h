@import Foundation;

#import "BTAPIResponseParser.h"

@interface BTClientTokenBooleanValueTransformer : NSObject <BTValueTransforming>

+ (instancetype)sharedInstance;

@end
