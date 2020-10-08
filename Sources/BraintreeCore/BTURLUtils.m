#import "BTURLUtils.h"

@implementation BTURLUtils

+ (NSString *)queryStringWithDictionary:(NSDictionary *)dict {
    NSMutableString *queryString = [NSMutableString string];
    for (id key in dict) {
        NSString *encodedKey = [self stringByURLEncodingAllCharactersInString:[key description]];
        id value = [dict objectForKey:key];
        if([value isKindOfClass:[NSArray class]]) {
            for(id obj in value) {
                [queryString appendFormat:@"%@%%5B%%5D=%@&",
                 encodedKey,
                 [self stringByURLEncodingAllCharactersInString:[obj description]]
                 ];
            }
        } else if([value isKindOfClass:[NSDictionary class]]) {
            for(id subkey in value) {
                [queryString appendFormat:@"%@%%5B%@%%5D=%@&",
                 encodedKey,
                 [self stringByURLEncodingAllCharactersInString:[subkey description]],
                 [self stringByURLEncodingAllCharactersInString:[[value objectForKey:subkey] description]]
                 ];
            }
        } else if([value isKindOfClass:[NSNull class]]) {
            [queryString appendFormat:@"%@=&", encodedKey];
        } else {
            [queryString appendFormat:@"%@=%@&",
             encodedKey,
             [self stringByURLEncodingAllCharactersInString:[value description]]
             ];
        }
    }
    if([queryString length] > 0) {
        [queryString deleteCharactersInRange:NSMakeRange([queryString length] - 1, 1)]; // remove trailing &
    }
    return queryString;
}

+ (NSDictionary<NSString *, NSString *> *)queryParametersForURL:(NSURL *)url {
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    for (NSURLQueryItem *queryItem in components.queryItems) {
        parameters[queryItem.name] = [queryItem.value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    }

    return [NSDictionary dictionaryWithDictionary:parameters];
}

+ (NSString *)stringByURLEncodingAllCharactersInString:(NSString *)aString {
    // See Section 2.2. http://www.ietf.org/rfc/rfc2396.txt
    NSString *reservedCharacters = @";/?:@&=+$,";

    NSMutableCharacterSet *URLQueryPartAllowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [URLQueryPartAllowedCharacterSet removeCharactersInString:reservedCharacters];

    return [aString stringByAddingPercentEncodingWithAllowedCharacters:URLQueryPartAllowedCharacterSet];
}

@end
