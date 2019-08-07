#import "BTURLUtils.h"

@implementation BTURLUtils

+ (NSURL *)URLfromURL:(NSURL *)URL withAppendedQueryDictionary:(NSDictionary *)dictionary {
    if (!URL) {
        return nil;
    }

    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
    urlComponents.percentEncodedQuery = [self queryStringWithDictionary:dictionary];
    return urlComponents.URL;
}

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

+ (NSString *)stringByURLEncodingAllCharactersInString:(NSString *)aString {
    // See Section 2.2. http://www.ietf.org/rfc/rfc2396.txt
    NSString *reservedCharacters = @";/?:@&=+$,";

    NSMutableCharacterSet *URLQueryPartAllowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [URLQueryPartAllowedCharacterSet removeCharactersInString:reservedCharacters];

    return [aString stringByAddingPercentEncodingWithAllowedCharacters:URLQueryPartAllowedCharacterSet];
}

+ (NSDictionary *)dictionaryForQueryString:(NSString *)queryString {
    NSURLComponents *comps = [NSURLComponents componentsWithString:queryString];
    NSArray<NSURLQueryItem*> *queryItems = [comps queryItems];
    
    for (NSURLQueryItem *item in queryItems) {
        if ([item.name isEqualToString:@"auth_response"]) {
            return @{@"auth_response": item.value};
        }
    }
    return [NSDictionary dictionary];
}

+ (NSString *)percentDecodedStringForString:(NSString *)string {
    return [[string stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByRemovingPercentEncoding];
}

@end
