#import "BTAPIResourceValueTypeError.h"

@interface BTAPIResourceValueTypeError ()
@property (nonatomic, strong) NSError *error;
@end

@implementation BTAPIResourceValueTypeError

- (instancetype)initWithErrorCode:(NSInteger)code description:(NSString *)description {
    self = [super init];
    if (self) {
        self.error = [NSError errorWithDomain:BTAPIResourceErrorDomain
                                             code:code
                                         userInfo:@{ NSLocalizedDescriptionKey: description }];
    }
    return self;
}

+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    BTAPIResourceValueTypeError *error = [[self alloc] initWithErrorCode:code description:[[NSString alloc] initWithFormat:format arguments:args]];
    va_end(args);
    return error;
}

#pragma mark BTAPIResourceValueType

- (BOOL)isValidValue:(__unused id)value {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Cannot validate value with error value type. Any APIFormat containing this value type is invalid."
                                 userInfo:nil];
}

- (BOOL)setValue:(__unused id)value onModel:(__unused id)model error:(__unused NSError *__autoreleasing *)error {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Cannot validate value with error value type. Any APIFormat containing this value type is invalid."
                                 userInfo:nil];
}

- (NSError *)resourceValueTypeError {
    return self.error;
}

@end
