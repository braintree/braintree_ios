#import <UIKit/UIKit.h>
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>

#import "BTVenmoAppSwitchRequestURL.h"
#import "BTVenmoDriver.h"
#import "BTSpecHelper.h"

SpecBegin(BTVenmoAppSwitchRequestURL)

describe(@"appSwitchURLForMerchantID:returnURLScheme:offline:", ^{

    context(@"when offline is NO", ^{
        it(@"returns a URL that does not contain offline mode", ^{
            NSURL *url = [BTVenmoAppSwitchRequestURL appSwitchURLForMerchantID:@"merchant-id"
                                                               returnURLScheme:@"a.scheme"
                                                             bundleDisplayName:@"An App"
                                                                       offline:NO];

            NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
            BOOL hasOfflineQueryItem = NO;
            for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
                if ([queryItem.name isEqualToString:@"offline"]) {
                    hasOfflineQueryItem = YES;
                }
            }
            XCTAssertFalse(hasOfflineQueryItem);
        });
    });

    context(@"when offline is YES", ^{
        it(@"returns a URL indicating offline mode", ^{
            NSURL *url = [BTVenmoAppSwitchRequestURL appSwitchURLForMerchantID:@"merchant-id"
                                                               returnURLScheme:@"a.scheme"
                                                             bundleDisplayName:@"An App"
                                                                       offline:YES];

            NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
            BOOL hasOfflineQueryItem = NO;
            for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
                if ([queryItem.name isEqualToString:@"offline"]) {
                    hasOfflineQueryItem = YES;
                    XCTAssertEqualObjects(queryItem.value, @"1");
                }
            }
            XCTAssertTrue(hasOfflineQueryItem);
        });
    });
    
});

describe(@"baseAppSwitchURL", ^{
    it(@"returns expected base URL", ^{
        expect([BTVenmoAppSwitchRequestURL baseAppSwitchURL].scheme).to.equal(@"com.venmo.touch.v1");
        expect([BTVenmoAppSwitchRequestURL baseAppSwitchURL].host).to.equal(@"x-callback-url");
        expect([BTVenmoAppSwitchRequestURL baseAppSwitchURL].path).to.equal(@"/vzero/auth");
        expect([BTVenmoAppSwitchRequestURL baseAppSwitchURL].query).to.beNil();
    });
});

SpecEnd
