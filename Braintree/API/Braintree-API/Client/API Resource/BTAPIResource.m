#import "BTAPIResource.h"
#import "BTLogger.h"
#import "BTAPIResourceValueAdapter.h"
#import "BTAPIResourceValueTypeError.h"
#import "BTAPIResourceValueType.h"

NSString *const BTAPIResourceErrorDomain = @"BTAPIResourceError";


BTAPIResourceValueTypeError *BTAPIResourceValueTypeValidateSetter(SEL setter) {
    NSMutableString *setterString = [NSStringFromSelector(setter) mutableCopy];
    NSInteger setterNumberOfArguments = [setterString replaceOccurrencesOfString:@":"
                                                                      withString:@":"
                                                                         options:0
                                                                           range:NSMakeRange(0, [setterString length])];
    if (setterNumberOfArguments != 1) {
        return [BTAPIResourceValueTypeError errorWithCode:BTAPIResourceErrorResourceSpecificationInvalid
                                              description:@"Selector passed to BTAPIResourceValueTypeString must take exactly one argument. Got: (%@), which takes (%d).", setterString, setterNumberOfArguments];
    }
    
    return nil;
}

id<BTAPIResourceValueType> BTAPIResourceValueTypeString(SEL setter) {
    BTAPIResourceValueTypeError *error = BTAPIResourceValueTypeValidateSetter(setter);
    if (error) {
        return error;
    }

    BTAPIResourceValueAdapter *valueAdapter = [[BTAPIResourceValueAdapter alloc] initWithValidator:^BOOL(id value) {
        return [value isKindOfClass:[NSString class]];
    } setter:^BOOL(id model, id value, NSError **error){
        if (!setter || ![model respondsToSelector:setter]) {
            if (error) {
                *error = [NSError errorWithDomain:BTAPIResourceErrorDomain
                                             code:BTAPIResourceErrorResourceSpecificationInvalid
                                         userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Model (%@) does not respond to the selector (%@) passed to BTAPIResourceValueTypeString.", model, NSStringFromSelector(setter)] }];
            }
            return NO;
        }

        NSMethodSignature *signature = [model methodSignatureForSelector:setter];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setSelector:setter];
        [invocation setArgument:&value atIndex:2];
        [invocation invokeWithTarget:model];
        return YES;
    }];

    return valueAdapter;
}

id<BTAPIResourceValueType> BTAPIResourceValueTypeStringSet(SEL setter) {
    BTAPIResourceValueTypeError *error = BTAPIResourceValueTypeValidateSetter(setter);
    if (error) {
        return error;
    }

    return [[BTAPIResourceValueAdapter alloc] initWithValidator:^BOOL(id value) {
        return [value isKindOfClass:[NSSet class]] || [value isKindOfClass:[NSArray class]];
    } transformer:^id(id rawValue, __unused NSError * __autoreleasing *error){
        if ([rawValue isKindOfClass:[NSArray class]]) {
            return [NSSet setWithArray:rawValue];
        }
        return rawValue;
    } setter:^BOOL(id model, id value, __unused NSError * __autoreleasing * error) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[model methodSignatureForSelector:setter]];
        [invocation setSelector:setter];
        [invocation setArgument:&value atIndex:2];
        [invocation invokeWithTarget:model];
        return YES;
    }];
}

id<BTAPIResourceValueType> BTAPIResourceValueTypeAPIResource(SEL setter, Class BTAPIResourceClass) {
    BTAPIResourceValueTypeError *error = BTAPIResourceValueTypeValidateSetter(setter);
    if (error) {
        return error;
    }

    return [[BTAPIResourceValueAdapter alloc] initWithValidator:^BOOL(id value) {
        return [value isKindOfClass:[NSDictionary class]];
    } transformer:^id(id rawValue, NSError * __autoreleasing *error) {
        NSError *nestedResourceError;
        id nestedResource = [BTAPIResourceClass modelWithAPIDictionary:rawValue
                                                                 error:&nestedResourceError];

        if (nestedResourceError && error) {
            *error = [NSError errorWithDomain:BTAPIResourceErrorDomain
                                         code:BTAPIResourceErrorResourceDictionaryNestedResourceInvalid
                                     userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Value in API Dictionary for nested resource of type (%@) is invalid. Got: (%@).", BTAPIResourceClass, rawValue],
                                                     NSUnderlyingErrorKey: nestedResourceError }];
        }

        return nestedResource;
    } setter:^BOOL(id model, id value, __unused NSError * __autoreleasing *error) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[model methodSignatureForSelector:setter]];
        [invocation setSelector:setter];
        [invocation setArgument:&value atIndex:2];
        [invocation invokeWithTarget:model];
        return YES;
    }];
}

id<BTAPIResourceValueType> BTAPIResourceValueTypeOptional(id<BTAPIResourceValueType> APIResourceValueType) {
    BTAPIResourceValueAdapter *valueType = [[BTAPIResourceValueAdapter alloc] initWithValidator:^BOOL(id value) {
        return value == nil || [value isKindOfClass:[NSNull class]] || [APIResourceValueType isValidValue:value];
    } transformer:^id(id rawValue, __unused NSError * __autoreleasing *error) {
        return [rawValue isKindOfClass:[NSNull class]] ? nil : rawValue;
    }  setter:^BOOL(id model, id value, NSError *__autoreleasing* error) {
        return [APIResourceValueType setValue:value onModel:model error:error];
    }];

    valueType.optional = YES;

    return valueType;
}

@implementation BTAPIResource

+ (id)modelWithAPIDictionary:(NSDictionary *)APIDictionary error:(NSError *__autoreleasing *)error {

    if (!APIDictionary) {
        if (error) {
            *error = [self errorWithCode:BTAPIResourceErrorResourceDictionaryInvalid
                             description:@"Expected a value for APIDictionary. Got nil."];
        }

        return nil;
    }

    if (![APIDictionary isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error = [self errorWithCode:BTAPIResourceErrorResourceDictionaryInvalid
                             description:@"Expected an NSDictionary for APIDictionary. Got (%@).", APIDictionary];
        }

        return nil;
    }

    id model = [[[self resourceModelClass] alloc] init];

    if (!model) {
        if (error) {
            *error = [self errorWithCode:BTAPIResourceErrorResourceSpecificationInvalid
                             description:@"Expected an allocated BTAPIResource from resourceModel. Got: nil."];
        }
        return nil;
    }

    NSDictionary *APIFormat = [self APIFormat];

    if (![APIFormat isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error = [self errorWithCode:BTAPIResourceErrorResourceSpecificationInvalid
                             description:@"APIFormat must return an NSDictionary. Got (%@).", APIFormat];
        }
        return nil;
    }

    for (id key in APIFormat) {
        id obj = APIFormat[key];
        if (![obj conformsToProtocol:@protocol(BTAPIResourceValueType)]) {
            if (error) {
                *error = [self errorWithCode:BTAPIResourceErrorResourceSpecificationInvalid
                                 description:@"The specified API Format is invalid. Got (%@). Invalid key: %@.", APIFormat, key];
                return nil;
            }
        } else if ([obj resourceValueTypeError] != nil) {
            if (error) {
                *error = [NSError errorWithDomain:BTAPIResourceErrorDomain
                                             code:BTAPIResourceErrorResourceSpecificationInvalid
                                         userInfo:@{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The specified API Format is invalid. Got (%@). Invalid key: %@.", APIFormat, key],
                                                     NSUnderlyingErrorKey: [obj resourceValueTypeError] }];
                return nil;
            }
        }
    }

    NSSet *allRequiredFormatKeys = [APIFormat keysOfEntriesPassingTest:^BOOL(__unused id key, id obj, __unused BOOL *stop) {
        if ([obj respondsToSelector:@selector(optional)]) {
            return ![obj optional];
        }

        return YES;
    }];

    NSSet *allDictionaryKeys = [APIDictionary keysOfEntriesPassingTest:^BOOL(__unused id key, __unused id obj, __unused BOOL *stop) {
        return ![obj isKindOfClass:[NSNull class]];
    }];

    if (![allRequiredFormatKeys isSubsetOfSet:allDictionaryKeys]) {
        if (error) {
            *error = [self errorWithCode:BTAPIResourceErrorResourceDictionaryMissingKey
                             description:@"Expected APIDictionary to contain all keys in APIFormat (%@). Got (%@).", allRequiredFormatKeys, allDictionaryKeys];
        }
        return nil;
    }

    for (id key in [APIDictionary keyEnumerator]) {
        id<BTAPIResourceValueType> valueType = APIFormat[key];

        if (!valueType) {
            // Ignore keys that are not in the APIFormat.
            continue;
        }

        id obj = APIDictionary[key];

        if ([valueType isValidValue:obj]) {
            if (![valueType setValue:obj onModel:model error:error]) {
                return nil;
            }
        } else {
            if (error) {
                *error = [self errorWithCode:BTAPIResourceErrorResourceDictionaryInvalid
                                 description:@"Actual type for value (%@) does not match the type specified in APIFormat for key (%@). ", obj, key];
            }
            return nil;
        }
    }

    return model;
}

+ (NSDictionary *)APIDictionaryWithModel:(id)resource {
    NSLog(@"%@", resource);
    return nil;
}

#pragma mark -

+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description, ... {
    va_list args;
    va_start(args, description);
    NSString *interpolatedDescription = [[NSString alloc] initWithFormat:description arguments:args];
    va_end(args);

    return [NSError errorWithDomain:BTAPIResourceErrorDomain
                               code:code
                           userInfo:@{ NSLocalizedDescriptionKey: interpolatedDescription }];
}

#pragma mark Methods to Override

+ (Class)resourceModelClass {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"BTAPIResource subclasses must override +resourceModelClass"
                                 userInfo:nil];
}

+ (NSSet *)keys {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"BTAPIResource subclasses must override +keys"
                                 userInfo:nil];
}

+ (NSDictionary *)APIFormat {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"BTAPIResource subclasses must override +APIFormat:"
                                 userInfo:nil];
}

@end
