#import "BTAPIResourceValueAdapter.h"

@interface BTAPIResourceValueAdapter ()
@property (nonatomic, copy) BOOL (^validatorBlock)(id rawValue);
@property (nonatomic, copy) id (^transformerBlock)(id rawValue);
@property (nonatomic, copy) BOOL (^setterBlock)(id model, id value, NSError * __autoreleasing *error);
@end

@implementation BTAPIResourceValueAdapter

- (instancetype)initWithValidator:(BOOL (^)(id))validatorBlock setter:(BOOL (^)(id, id, NSError *__autoreleasing*))setterBlock {
    id (^identity)(id) = ^id(id rawValue){
        return rawValue;
    };
    return [self initWithValidator:validatorBlock
                       transformer:identity
                            setter:setterBlock];
}

- (instancetype)initWithValidator:(BOOL (^)(id))validatorBlock
                      transformer:(id (^)(id))transformerBlock
                           setter:(BOOL (^)(id, id, NSError *__autoreleasing*))setterBlock {
    self = [super init];
    if (self) {
        self.validatorBlock = validatorBlock;
        self.transformerBlock = transformerBlock;
        self.setterBlock = setterBlock;
    }
    return self;
}

#pragma mark BTAPIResourceValueType

- (BOOL)isValidValue:(id)value {
    if (!self.validatorBlock) {
        return YES;
    }

    return self.validatorBlock(value);
}

- (BOOL)setValue:(id)value onModel:(id)model error:(NSError *__autoreleasing *)error {
    NSAssert(self.transformerBlock != nil, @"BTAPIResourceValueAdapter must always retain a transformer block.");
    if (!self.setterBlock || !self.transformerBlock) {
        return NO;
    }

    return self.setterBlock(model, self.transformerBlock(value), error);
}

- (NSError *)resourceValueTypeError {
    return nil;
}

@end
