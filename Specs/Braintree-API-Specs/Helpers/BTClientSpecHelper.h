@import Foundation;
@class BTClient;

@interface BTClientSpecHelper : NSObject

+ (BTClient *)asyncClientForTestCase:(XCTestCase *)testCase withOverrides:(NSDictionary *)overrides;

+ (BTClient *)deprecatedClientForTestCase:(XCTestCase *)testCase withOverrides:(NSDictionary *)overrides;

+ (NSArray *)clientsForTestCase:(XCTestCase *)testCase withOverrides:(NSDictionary *)overrides;

@end
