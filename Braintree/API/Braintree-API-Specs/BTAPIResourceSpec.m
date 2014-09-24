@import Foundation;

#import "BTAPIResource.h"

@interface BTTestModel : NSObject
@property (nonatomic, copy) NSString *string;
@property (nonatomic, copy) NSString *readOnly;
@property (nonatomic, copy) NSString *optionalString;
@property (nonatomic, strong) NSSet *stringSet;
@property (nonatomic, strong) BTTestModel *nestedModel;
@end

@implementation BTTestModel
@end


@interface BTTestAPIResource : BTAPIResource

+ (NSDictionary *)sampleValidAPIDictionaryForTest;

@end

@implementation BTTestAPIResource

+ (Class)resourceModelClass {
    return [BTTestModel class];
}

+ (NSDictionary *)APIFormat {
    return @{
             @"api-key-with-string-value": BTAPIResourceValueTypeString(@selector(setString:)),
             @"api-key-with-string-set-value": BTAPIResourceValueTypeStringSet(@selector(setStringSet:)),
             @"api-key-with-optional-string-value": BTAPIResourceValueTypeOptional(BTAPIResourceValueTypeString(@selector(setOptionalString:)))
             };
}

+ (NSDictionary *)sampleValidAPIDictionaryForTest {
    return @{ @"api-key-with-string-value": @"a string",
              @"api-key-with-string-set-value": @[ @"first string", @"second string" ],
              @"api-key-with-optional-string-value": @"an optional string" };
}

@end

SpecBegin(BTAPIResource)

fdescribe(@"API Response object parsing", ^{
    it(@"parses a valid response dictionary, returning the well-formed model object", ^{
        NSDictionary *APIDictionary = [BTTestAPIResource sampleValidAPIDictionaryForTest];
        NSError *error;
        BTTestModel *resource = [BTTestAPIResource resourceWithAPIDictionary:APIDictionary
                                                                       error:&error];

        expect(error).to.beNil();
        expect(resource).to.beKindOf([BTTestModel class]);
        expect(resource.string).to.equal(@"a string");
        expect(resource.stringSet).to.equal([NSSet setWithObjects:@"first string", @"second string", nil]);
        expect(resource.optionalString).to.equal(@"an optional string");
    });

    xit(@"nil APIDictionary");
    xit(@"non-dictionary APIDictionary");

    it(@"rejects incomplete API dictionaries that are missing keys because specified keys imply required keys", ^{
        NSMutableDictionary *APIDictionary = [[BTTestAPIResource sampleValidAPIDictionaryForTest] mutableCopy];
        [APIDictionary removeObjectForKey:@"api-key-with-string-value"];
        NSError *error;
        BTTestModel *resource = [BTTestAPIResource resourceWithAPIDictionary:APIDictionary
                                                                       error:&error];

        expect(resource).to.beNil();
        expect(error.domain).to.equal(BTAPIResourceErrorDomain);
        expect(error.code).to.equal(BTAPIResourceErrorResourceDictionaryMissingKey);
    });

    it(@"parses incomplete API dictionaries that are missing optional keys", ^{
        NSMutableDictionary *APIDictionary = [[BTTestAPIResource sampleValidAPIDictionaryForTest] mutableCopy];
        [APIDictionary removeObjectForKey:@"api-key-with-optional-string-value"];
        NSError *error;
        BTTestModel *resource = [BTTestAPIResource resourceWithAPIDictionary:APIDictionary
                                                                       error:&error];

        expect(error).to.beNil();
        expect(resource.string).to.equal(@"a string");
        expect(resource.stringSet).to.equal([NSSet setWithObjects:@"first string", @"second string", nil]);
        expect(resource.optionalString).to.beNil();
    });

    it(@"parses API dictionaries with extraneous information (aka backwards compatible additions)", ^{
        NSMutableDictionary *APIDictionary = [[BTTestAPIResource sampleValidAPIDictionaryForTest] mutableCopy];
        APIDictionary[@"new-thing"] = @"extra string";
        NSError *error;
        BTTestModel *resource = [BTTestAPIResource resourceWithAPIDictionary:APIDictionary
                                                                       error:&error];

        expect(error).to.beNil();
        expect(resource.string).to.equal(@"a string");
        expect(resource.stringSet).to.equal([NSSet setWithObjects:@"first string", @"second string", nil]);
        expect(resource.optionalString).to.equal(@"an optional string");
    });

    it(@"rejects API dictionaries with values of an unexpected invalid type", ^{
        id invalidValue = [OCMockObject niceMockForClass:[NSObject class]];
        NSMutableDictionary *APIDictionary = [[BTTestAPIResource sampleValidAPIDictionaryForTest] mutableCopy];
        APIDictionary[@"api-key-with-string-value"] = invalidValue;
        NSError *error = nil;
        BTTestModel *resource = [BTTestAPIResource resourceWithAPIDictionary:APIDictionary
                                                                       error:&error];

        expect(resource).to.beNil();
        expect(error.domain).to.equal(BTAPIResourceErrorDomain);
        expect(error.code).to.equal(BTAPIResourceErrorResourceDictionaryInvalid);
    });

    describe(@"an explicit null value", ^{
        it(@"is treated like a missing value", ^{
            NSMutableDictionary *APIDictionary = [[BTTestAPIResource sampleValidAPIDictionaryForTest] mutableCopy];
            APIDictionary[@"api-key-with-string-value"] = [NSNull null];
            NSError *error;
            BTTestModel *resource = [BTTestAPIResource resourceWithAPIDictionary:APIDictionary
                                                                           error:&error];

            expect(resource).to.beNil();
            expect(error.domain).to.equal(BTAPIResourceErrorDomain);
            expect(error.code).to.equal(BTAPIResourceErrorResourceDictionaryMissingKey);
        });

        it(@"is treated like an omitted value for optional keys", ^{
            NSMutableDictionary *APIDictionary = [[BTTestAPIResource sampleValidAPIDictionaryForTest] mutableCopy];
            APIDictionary[@"api-key-with-optional-string-value"] = [NSNull null];
            NSError *error;
            BTTestModel *resource = [BTTestAPIResource resourceWithAPIDictionary:APIDictionary
                                                                           error:&error];

            expect(error).to.beNil();
            expect(resource.string).to.equal(@"a string");
            expect(resource.stringSet).to.equal([NSSet setWithObjects:@"first string", @"second string", nil]);
            expect(resource.optionalString).to.beNil();
        });
    });

    it(@"ignores keys that are not strings", ^{
        id invalidKey = @42;
        NSMutableDictionary *APIDictionary = [[BTTestAPIResource sampleValidAPIDictionaryForTest] mutableCopy];
        APIDictionary[invalidKey] = @"Ignored value";
        NSError *error;
        BTTestModel *resource = [BTTestAPIResource resourceWithAPIDictionary:APIDictionary
                                                                       error:&error];

        expect(error).to.beNil();
        expect(resource.string).to.equal(@"a string");
        expect(resource.stringSet).to.equal([NSSet setWithObjects:@"first string", @"second string", nil]);
        expect(resource.optionalString).to.equal(@"an optional string");
    });

    pending(@"APIFormat validation", ^{
        pending(@"pass invalid selectors with wrong number of arguments");
        pending(@"invalid values");
        pending(@"not a dictionary");
    });

    pending(@"nested resources");
    
});

pending(@"API Request object generation", ^{
    
});

SpecEnd