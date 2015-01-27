#import "BTHTTPResponse.h"

SpecBegin(BTHTTPResponse)

it(@"represents a successful 2xx response", ^{
    BTHTTPResponse *response = [[BTHTTPResponse alloc] initWithStatusCode:200 responseObject:@{ @"response": @"body" }];
    
    expect(response.isSuccess).to.equal(YES);
    expect(response.rawObject).to.equal(@{@"response": @"body"});
    expect([response.object stringForKey:@"response"]).to.equal(@"body");
});

it(@"represents an unsuccessful 4xx response", ^{
    BTHTTPResponse *response = [[BTHTTPResponse alloc] initWithStatusCode:422 responseObject:@{ @"errors": @"Some client error" }];
    
    expect(response.isSuccess).to.equal(NO);
    expect(response.rawObject).to.equal(@{ @"errors": @"Some client error" });
    expect([response.object stringForKey:@"errors"]).to.equal(@"Some client error");
});

it(@"represents an unsuccessful 5xx response", ^{
    BTHTTPResponse *response = [[BTHTTPResponse alloc] initWithStatusCode:503 responseObject:@{ @"errors": @"Some server error" }];
    
    expect(response.isSuccess).to.equal(NO);
    expect(response.rawObject).to.equal(@{@"errors": @"Some server error"});
    expect([response.object stringForKey:@"errors"]).to.equal(@"Some server error");
});

SpecEnd
