#import "BTPayPalApprovalRequest.h"

@implementation BTPayPalApprovalRequest

+ (NSString *)tokenFromApprovalURL:(NSURL *)approvalURL {
    NSDictionary *queryDictionary = [self parseQueryString:[approvalURL query]];
    return queryDictionary[@"token"] ?: queryDictionary[@"ba_token"];
}

+ (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];

    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if (elements.count > 1) {
            NSString *key = [[elements objectAtIndex:0] stringByRemovingPercentEncoding];
            NSString *val = [[elements objectAtIndex:1] stringByRemovingPercentEncoding];
            if (key.length && val.length) {
                dict[key] = val;
            }
        }
    }
    return dict;
}

@end
