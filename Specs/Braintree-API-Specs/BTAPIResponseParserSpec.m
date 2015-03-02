#import "BTAPIResponseParser.h"

SpecBegin(BTAPIResponseParser)

context(@"type safe value parsing", ^{
    __block BTAPIResponseParser *testParser;
    
    beforeEach(^{
        NSData *json = [@"{\
                        \"aString\": \"Hello, JSON 😍!\",\
                        \"anArray\": [1, 2, 3 ],\
                        \"aSetOfValues\": [\"a\", \"b\", \"c\"],\
                        \"aSetWithDuplicates\": [\"a\", \"a\", \"b\", \"b\" ],\
                        \"aLookupDictionary\": {\
                        \"foo\": \{ \"definition\": \"A meaningless word\",\
                        \"letterCount\": 3,\
                        \"meaningful\": false }\
                        },\
                        \"aURL\": \"https://test.example.com:1234/path\",\
                        \"anInvalidURL\": \":™£¢://://://???!!!\",\
                        \"aTrue\": true,\
                        \"aFalse\": false\
                        }" dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonFixtureError;
        testParser = [BTAPIResponseParser parserWithDictionary:[NSJSONSerialization JSONObjectWithData:json
                                                                                               options:0
                                                                                                 error:&jsonFixtureError]];
        NSAssert(jsonFixtureError == nil, @"Failed to parse fixture JSON: %@", jsonFixtureError);
    });
    
    describe(@"stringForKey:", ^{
        it(@"returns the string at the given key", ^{
            expect([testParser stringForKey:@"aString"]).to.equal(@"Hello, JSON 😍!");
        });
        
        it(@"returns nil for absent keys", ^{
            expect([testParser stringForKey:@"notAString"]).to.beNil();
        });
        
        it(@"returns nil for invalid values", ^{
            expect([testParser stringForKey:@"anArray"]).to.beNil();
        });
    });
    
    describe(@"arrayForKey:", ^{
        it(@"returns the array at the given key", ^{
            expect([testParser arrayForKey:@"anArray"]).to.equal((@[@(1), @(2), @(3)]));
        });
        
        it(@"returns nil for absent keys", ^{
            expect([testParser arrayForKey:@"notAnArray"]).to.beNil();
        });
        
        it(@"returns nil for invalid values", ^{
            expect([testParser arrayForKey:@"aString"]).to.beNil();
        });
    });
    
    describe(@"setForKey:", ^{
        it(@"returns the set representation for the array", ^{
            expect([testParser setForKey:@"aSetOfValues"]).to.equal([NSSet setWithArray:@[@"a", @"b", @"c"]]);
        });
        
        it(@"parses arrays as sets, even if there are duplicates", ^{
            expect([testParser setForKey:@"aSetWithDuplicates"]).to.equal([NSSet setWithArray:@[@"a", @"b"]]);
        });
        
        it(@"returns nil for absent keys", ^{
            expect([testParser setForKey:@"notASet"]).to.beNil();
        });
        
        it(@"returns nil for invalid values", ^{
            expect([testParser setForKey:@"aString"]).to.beNil();
        });
    });
    
    describe(@"dictionaryForKey:", ^{
        it(@"returns the parsed dictionary representation for the object", ^{
            NSDictionary *dictionary = [testParser dictionaryForKey:@"aLookupDictionary"];
            expect(dictionary[@"foo"][@"definition"]).to.equal(@"A meaningless word");
            expect(dictionary[@"foo"][@"letterCount"]).to.equal(@(3));
            expect(dictionary[@"foo"][@"meaningful"]).to.beFalsy();
        });
        
        it(@"returns nil for absent keys", ^{
            expect([testParser dictionaryForKey:@"notADictionary"]).to.beNil();
        });
        
        it(@"returns nil for invalid values", ^{
            expect([testParser dictionaryForKey:@"aString"]).to.beNil();
        });
    });
    
    describe(@"URLForKey:", ^{
        it(@"parses and returns the URL at the given string key", ^{
            expect([testParser URLForKey:@"aURL"]).to.equal([NSURL URLWithString:@"https://test.example.com:1234/path"]);
        });
        
        it(@"returns nil for absent keys", ^{
            expect([testParser URLForKey:@"notAURL"]).to.beNil();
        });
        
        it(@"returns nil for invalid values", ^{
            expect([testParser URLForKey:@"aString"]).to.beNil();
        });
        
        it(@"returns nil for invalid URLs", ^{
            expect([testParser URLForKey:@"anInvalidURL"]).to.beNil();
        });
    });
    
    context(@"nested resources", ^{
        describe(@"responseParserForKey:", ^{
            it(@"returns the dictionary at the given key as another response parser object", ^{
                BTAPIResponseParser *parser = [testParser responseParserForKey:@"aLookupDictionary"];
                expect([[parser responseParserForKey:@"foo"] stringForKey:@"definition"]).to.equal(@"A meaningless word");
            });
            
            it(@"returns nil for absent keys", ^{
                expect([testParser responseParserForKey:@"notAKey"]).to.beNil();
            });
            
            it(@"returns nil for invalid values", ^{
                expect([testParser responseParserForKey:@"aString"]).to.beNil();
            });
        });
    });
    
    context(@"value transformation", ^{
        describe(@"objectForKey:withValueTransformer:", ^{
            it(@"interprets the value using the provided value transformer", ^{
                id mockTransformer = [OCMockObject mockForProtocol:@protocol(BTValueTransforming)];
                [[[mockTransformer stub] andReturn:@"Transformed Value"] transformedValue:@"Hello, JSON 😍!"];
                
                NSString *transformedValue = [testParser objectForKey:@"aString" withValueTransformer:mockTransformer];
                expect(transformedValue).to.equal(@"Transformed Value");
            });
        });
        
        describe(@"arrayForKey:withValueTransformer:", ^{
            it(@"maps all values in the array using the provided value transformer", ^{
                id mockTransformer = [OCMockObject mockForProtocol:@protocol(BTValueTransforming)];
                [[[mockTransformer stub] andReturn:@"Transformed Value"] transformedValue:OCMOCK_ANY];
                
                NSArray *transformedValue = [testParser arrayForKey:@"anArray" withValueTransformer:mockTransformer];
                expect(transformedValue).to.equal(@[@"Transformed Value", @"Transformed Value", @"Transformed Value"]);
            });
        });
        
        describe(@"integerForKey:withValueTransformer:", ^{
            it(@"parses the value into an integer using the provided value transformer", ^{
                id mockTransformer = [OCMockObject mockForProtocol:@protocol(BTValueTransforming)];
                [[[mockTransformer stub] andReturn:@(20)] transformedValue:OCMOCK_ANY];
                
                NSInteger transformedValue = [testParser integerForKey:@"aString" withValueTransformer:mockTransformer];
                expect(transformedValue).to.equal(20);
            });
            
            it(@"returns 0 if the value transformer returns an invalid value", ^{
                id mockTransformer = [OCMockObject mockForProtocol:@protocol(BTValueTransforming)];
                [[[mockTransformer stub] andReturn:@"Not a number"] transformedValue:OCMOCK_ANY];
                
                NSInteger transformedValue = [testParser integerForKey:@"aString" withValueTransformer:mockTransformer];
                expect(transformedValue).to.equal(0);
            });
        });
        
        describe(@"boolForKey:withValueTransformer:", ^{
            it(@"parses the value into a boolean using the provided value transformer", ^{
                id mockTransformer = [OCMockObject mockForProtocol:@protocol(BTValueTransforming)];
                [[[mockTransformer stub] andReturn:@(YES)] transformedValue:@(1)];
                [[[mockTransformer stub] andReturn:@(NO)] transformedValue:@(0)];
                
                expect([testParser boolForKey:@"aTrue" withValueTransformer:mockTransformer]).to.equal(YES);
                expect([testParser boolForKey:@"aFalse" withValueTransformer:mockTransformer]).to.equal(NO);
            });
            
            it(@"defaults to false when the value transformer fails to return an NSNumber", ^{
                id mockTransformer = [OCMockObject mockForProtocol:@protocol(BTValueTransforming)];
                [[[mockTransformer stub] andReturn:@"Not a number"] transformedValue:OCMOCK_ANY];
                
                NSInteger transformedValue = [testParser boolForKey:@"aTrue" withValueTransformer:mockTransformer];
                expect(transformedValue).to.equal(NO);
            });
        });
    });
});

describe(@"isEqual:", ^{
    it(@"returns true for two parsers initialized with equal dictionaries", ^{
        NSDictionary *dictionary = @{ @"foo": @"bar" };
        BTAPIResponseParser *parser1 = [BTAPIResponseParser parserWithDictionary:dictionary.copy];
        BTAPIResponseParser *parser2 = [BTAPIResponseParser parserWithDictionary:dictionary.copy];

        expect(parser1).notTo.beIdenticalTo(parser2);
        expect(parser1).to.equal(parser2);
    });

    it(@"returns false for distinct parsers", ^{
        BTAPIResponseParser *parser1 = [BTAPIResponseParser parserWithDictionary:@{ @"name": @"parser1" }];
        BTAPIResponseParser *parser2 = [BTAPIResponseParser parserWithDictionary:@{ @"name": @"parser2" }];

        expect(parser1).notTo.beIdenticalTo(parser2);
        expect(parser1).notTo.equal(parser2);
    });
});

describe(@"NSCoding", ^{
    it(@"roundtrips a response parser", ^{
        NSDictionary *dictionary = @{ @"key": @"value" };
        BTAPIResponseParser *parser1 = [BTAPIResponseParser parserWithDictionary:dictionary.copy];

        NSMutableData *data = [NSMutableData data];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [parser1 encodeWithCoder:archiver];
        [archiver finishEncoding];

        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data.copy];
        BTAPIResponseParser *parser2 = [[BTAPIResponseParser alloc] initWithCoder:unarchiver];
        [unarchiver finishDecoding];

        expect(parser1).notTo.beIdenticalTo(parser2);
        expect(parser1).to.equal(parser2);

        expect([parser2 stringForKey:@"key"]).to.equal(@"value");
    });
});

SpecEnd
