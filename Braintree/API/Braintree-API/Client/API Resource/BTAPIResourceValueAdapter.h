@import Foundation;

#import "BTAPIResource.h"

@interface BTAPIResourceValueAdapter : NSObject <BTAPIResourceValueType>

- (instancetype)initWithValidator:(BOOL (^)(id value))validatorBlock setter:(void (^)(id model, id value))setterBlock;

- (instancetype)initWithValidator:(BOOL (^)(id rawValue))validatorBlock transformer:(id (^)(id rawValue))transformerBlock setter:(void (^)(id model, id value))setterBlock NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign) BOOL optional;

@end
