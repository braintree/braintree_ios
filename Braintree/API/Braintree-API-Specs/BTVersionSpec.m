#import "BTClient.h"

SpecBegin(BTVersionSpec)

it(@"returns the current version", ^{
    expect([BTClient libraryVersion]).to.match(@"\\d+\\.\\d+\\.\\d+");
});

SpecEnd
