#import <Foundation/Foundation.h>

extern NSString * const BTHTTPErrorDomain;

typedef NS_ENUM(NSInteger, BTHTTPErrorCode) {
    BTHTTPErrorCodeUnknown = 0,
    BTHTTPErrorCodeResponseContentTypeNotAcceptable,
    BTHTTPErrorCodeClientError,
    BTHTTPErrorCodeServerError
};

