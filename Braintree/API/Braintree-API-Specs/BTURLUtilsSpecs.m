#import "BTURLUtils.h"

SpecBegin(BTURLUtils)

describe(@"URLfromURL:withAppendedQueryDictionary:", ^{
    it(@"appends a dictionary to a url as a query string", ^{
        expect([BTURLUtils URLfromURL:[NSURL URLWithString:@"http://example.com:80/path/to/file"] withAppendedQueryDictionary:@{ @"key": @"value" }]).to.equal([NSURL URLWithString:@"http://example.com:80/path/to/file?key=value"]);
    });

    it(@"accepts a nil dictionary", ^{
        expect([BTURLUtils URLfromURL:[NSURL URLWithString:@"http://example.com"] withAppendedQueryDictionary:nil]).to.equal([NSURL URLWithString:@"http://example.com?"]);
    });

    it(@"precent escapes the query parameters", ^{
        expect([BTURLUtils URLfromURL:[NSURL URLWithString:@"http://example.com"] withAppendedQueryDictionary:@{ @"space ": @"sym&bol=" }]).to.equal([NSURL URLWithString:@"http://example.com?space%20=sym%26bol%3D"]);
    });

    it(@"passes a nil URL", ^{
        expect([BTURLUtils URLfromURL:nil withAppendedQueryDictionary:@{ @"space ": @"sym&bol=" }]).to.beNil();
    });

    it(@"accepts relative URLs", ^{
        expect([BTURLUtils URLfromURL:[NSURL URLWithString:@"/relative/path"] withAppendedQueryDictionary:@{ @"key": @"value" }]).to.equal([NSURL URLWithString:@"/relative/path?key=value"]);
    });
});

SpecEnd