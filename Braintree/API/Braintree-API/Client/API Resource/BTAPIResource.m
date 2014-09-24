#import "BTAPIResource.h"
#import "BTAPIResourceValueAdapter.h"

NSString *const BTAPIResourceErrorDomain = @"BTAPIResourceError";

id<BTAPIResourceValueType> BTAPIResourceValueTypeString(SEL setter) {
    return [[BTAPIResourceValueAdapter alloc] initWithValidator:^BOOL(id value) {
        return [value isKindOfClass:[NSString class]];
    } setter:^(id model, id value) {
        //        if (!self.modelValueSetter) {
        //            return;
        //        }
        //
        //        if (![model respondsToSelector:self.modelValueSetter]) {
        //            return;
        //        }
        //
        //        if ([[model methodSignatureForSelector:self.modelValueSetter] numberOfArguments] != 1) {
        //            return;
        //        }

        //        if (modelStringSetter) {

        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[model methodSignatureForSelector:setter]];
        [invocation setSelector:setter];
        [invocation setArgument:&value atIndex:2];
        [invocation invokeWithTarget:model];
    }];
}

id<BTAPIResourceValueType> BTAPIResourceValueTypeStringSet(SEL setter) {
    return [[BTAPIResourceValueAdapter alloc] initWithValidator:^BOOL(id value) {
        return [value isKindOfClass:[NSSet class]] || [value isKindOfClass:[NSArray class]];
    } transformer:^id(id rawValue){
        if ([rawValue isKindOfClass:[NSArray class]]) {
            return [NSSet setWithArray:rawValue];
        }
        return rawValue;
    } setter:^(id model, id value) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[model methodSignatureForSelector:setter]];
        [invocation setSelector:setter];
        [invocation setArgument:&value atIndex:2];
        [invocation invokeWithTarget:model];
    }];
}

id<BTAPIResourceValueType> BTAPIResourceValueTypeAPIResource(Class __unused BTAPIResourceClass) {
    return nil;
}

id<BTAPIResourceValueType> BTAPIResourceValueTypeOptional(id<BTAPIResourceValueType> APIResourceValueType) {
    BTAPIResourceValueAdapter *valueType = [[BTAPIResourceValueAdapter alloc] initWithValidator:^BOOL(id value) {
        return value == nil || [value isKindOfClass:[NSNull class]] || [APIResourceValueType isValidValue:value];
    } transformer:^id(id rawValue) {
        return [rawValue isKindOfClass:[NSNull class]] ? nil : rawValue;
    }  setter:^(id model, id value) {
        if (value) {
            [APIResourceValueType setValue:value onModel:model];
        }
    }];

    valueType.optional = YES;

    return valueType;
}

@implementation BTAPIResource

+ (id)resourceWithAPIDictionary:(NSDictionary *)APIDictionary error:(NSError *__autoreleasing *)error {
    id model = [[[self resourceModelClass] alloc] init];

    if (!model) {
        if (error) {
            *error = [self errorWithCode:BTAPIResourceErrorResourceSpecificationInvalid description:@"Expected an allocated BTAPIResource from resourceModel. Got: nil."];
        }
        return nil;
    }

    NSDictionary *APIFormat = [self APIFormat];

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
            [valueType setValue:obj onModel:model];
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

+ (NSDictionary *)APIDictionaryWithResource:(id)resource {
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

