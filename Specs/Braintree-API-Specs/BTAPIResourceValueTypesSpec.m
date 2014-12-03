#import "BTAPIResource.h"
#import "BTAPIResourceValueType.h"

@interface BTTestValueTypesAPIResource : NSObject
- (void)setBool:(BOOL)value;
- (void)setURL:(NSURL *)url;
@end

@implementation BTTestValueTypesAPIResource
- (void)setBool:(__unused BOOL)value {}
- (void)setURL:(NSURL *)url {}
@end

SpecBegin(BTAPIResourceValueTypes)

describe(@"ValueTypes", ^{
    describe(@"boolean parsing", ^{
        it(@"sets YES for @YES", ^{
            id mockModel = [OCMockObject mockForClass:[BTTestValueTypesAPIResource class]];
            [[mockModel expect] setBool:YES];

            id<BTAPIResourceValueType> v = BTAPIResourceValueTypeBool(@selector(setBool:));

            NSError *error;
            [v setValue:@YES onModel:mockModel error:&error];

            [mockModel verify];
            expect(error).to.beNil();
        });

        it(@"sets NO for @NO", ^{
            id mockModel = [OCMockObject mockForClass:[BTTestValueTypesAPIResource class]];
            [[mockModel expect] setBool:NO];

            id<BTAPIResourceValueType> v = BTAPIResourceValueTypeBool(@selector(setBool:));

            NSError *error;
            [v setValue:@NO onModel:mockModel error:&error];

            [mockModel verify];
            expect(error).to.beNil();
        });

        it(@"accepts valid values", ^{
            id<BTAPIResourceValueType> v = BTAPIResourceValueTypeBool(@selector(setBool:));

            expect([v isValidValue:@YES]).to.beTruthy();
            expect([v isValidValue:@NO]).to.beTruthy();
        });

        it(@"rejects invalid values", ^{
            id<BTAPIResourceValueType> v = BTAPIResourceValueTypeBool(@selector(setBool:));

            expect([v isValidValue:@42]).to.beFalsy();
            expect([v isValidValue:@"invalid-value"]).to.beFalsy();
        });
    });

    describe(@"URL parsing", ^{
        it(@"accepts only valid URL strings", ^{
            id<BTAPIResourceValueType> v = BTAPIResourceValueTypeURL(@selector(setURL:));

            expect([v isValidValue:@"http://example.com:8080/path/to/file?param"]).to.beTruthy();
            expect([v isValidValue:@"🐴://🎄"]).to.beFalsy();
            expect([v isValidValue:@(8)]).to.beFalsy();
        });

        it(@"uses the selector to set the parsed NSURL on the model", ^{
            NSURL *url = [NSURL URLWithString:@"http://example.com:8080/path/to/file?param"];

            id mockModel = [OCMockObject mockForClass:[BTTestValueTypesAPIResource class]];
            [[mockModel expect] setURL:url];

            id<BTAPIResourceValueType> v = BTAPIResourceValueTypeURL(@selector(setURL:));

            NSError *error;
            [v setValue:[url absoluteString] onModel:mockModel error:&error];

            [mockModel verify];
            expect(error).to.beNil();
        });
    });
});

SpecEnd
