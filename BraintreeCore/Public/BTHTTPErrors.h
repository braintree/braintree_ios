#import <Foundation/Foundation.h>

extern NSString * const BTHTTPErrorDomain;

/// BTHTTP error codes
typedef NS_ENUM(NSInteger, BTHTTPErrorCode) {
    /// Unknown error (reserved)
    BTHTTPErrorCodeUnknown = 0,
    /// The response had a Content-Type header that is not supported
    BTHTTPErrorCodeResponseContentTypeNotAcceptable,
    /// The response was a 4xx error, e.g. 422, indicating a problem with the client's request
    BTHTTPErrorCodeClientError,
    /// The response was a 403 server error
    BTHTTPErrorCodeServerError,
    /// The BTHTTP instance was missing a base URL
    BTHTTPErrorCodeMissingBaseURL
};
