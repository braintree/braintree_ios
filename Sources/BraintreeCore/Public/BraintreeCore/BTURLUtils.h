#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
A helper class for converting URL queries to and from dictionaries
*/
@interface BTURLUtils : NSObject

/**
 Converts a key/value dictionary to a valid query string

 @param dict Dictionary of key/value pairs to be encoded into a query string
 @return A URL encoded query string
*/
+ (NSString *)queryStringWithDictionary:(NSDictionary *)dict;

/**
 Extract query parameters from a URL

 @param url URL to parse query paramters from
 @return Query parameters from the URL in a key/value dictionary
*/
+ (NSDictionary<NSString *, NSString *> *)queryParametersForURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
