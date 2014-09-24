#import "BTAPIResourceValueAdapter.h"

@interface BTAPIResourceValueAdapter ()
@property (nonatomic, copy) BOOL (^validatorBlock)(id rawValue);
@property (nonatomic, copy) id (^transformerBlock)(id rawValue);
@property (nonatomic, copy) void (^setterBlock)(id model, id value);
@end

@implementation BTAPIResourceValueAdapter

- (instancetype)initWithValidator:(BOOL (^)(id))validatorBlock setter:(void (^)(id, id))setterBlock {
    id (^identity)(id) = ^id(id rawValue){
        return rawValue;
    };
    return [self initWithValidator:validatorBlock
                       transformer:identity
                            setter:setterBlock];
}

- (instancetype)initWithValidator:(BOOL (^)(id))validatorBlock
                      transformer:(id (^)(id))transformerBlock
                           setter:(void (^)(id, id))setterBlock {
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

- (void)setValue:(id)value onModel:(id)model {
    if (!self.setterBlock || !self.transformerBlock) {
        return;
    }

    return self.setterBlock(model, self.transformerBlock(value));
}

@end
