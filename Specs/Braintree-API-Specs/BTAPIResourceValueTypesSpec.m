#import "BTAPIResource.h"
#import "BTAPIResourceValueType.h"

@interface BTTestValueTypesAPIResource : NSObject
- (void)setBool:(BOOL)value;
@end

@implementation BTTestValueTypesAPIResource
- (void)setBool:(__unused BOOL)value {
}
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
});

SpecEnd