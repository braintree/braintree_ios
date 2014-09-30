@import Foundation;

#import "BTAPIResource.h"
#import "BTAPIResourceValueType.h"

@interface BTAPIResourceValueAdapter : NSObject <BTAPIResourceValueType>

- (instancetype)initWithValidator:(BOOL (^)(id value))validatorBlock setter:(BOOL (^)(id model, id value, NSError *__autoreleasing *))setterBlock;

- (instancetype)initWithValidator:(BOOL (^)(id rawValue))validatorBlock transformer:(id (^)(id rawValue, NSError * __autoreleasing *))transformerBlock setter:(BOOL (^)(id model, id value, NSError *__autoreleasing*))setterBlock NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign) BOOL optional;

@end
