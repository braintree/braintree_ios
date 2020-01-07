#import "BTThreeDSecureV1BrowserSwitchHelper.h"

static NSString *const BTThreeDSecureAssetsPath = @"/mobile/three-d-secure-redirect/0.2.0";

@implementation BTThreeDSecureV1BrowserSwitchHelper

+ (NSURL *)urlWithScheme:(NSString *)appReturnURLScheme
               assetsURL:(NSString *)assetsURL
     threeDSecureRequest:(BTThreeDSecureRequest *)threeDSecureRequest
      threeDSecureLookup:(BTThreeDSecureLookup *)threeDSecureLookup {
    
    NSString *rfc3986UnreservedCharacters = @"-._~";
    NSMutableCharacterSet *unreservedCharacters = NSMutableCharacterSet.alphanumericCharacterSet;
    [unreservedCharacters addCharactersInString:rfc3986UnreservedCharacters];
    
    NSURLComponents *redirectURLComponents = [[NSURLComponents alloc] init];
    redirectURLComponents.scheme = appReturnURLScheme;
    redirectURLComponents.host = @"x-callback-url";
    redirectURLComponents.path = @"/braintree/threedsecure";
    
    // Trailing question mark is required so that we can append 3DS result to redirect URL.
    NSString *redirectURL = [NSString stringWithFormat:@"%@?", redirectURLComponents.URL.absoluteString];
    
    NSURLComponents *returnURLComponents = [NSURLComponents componentsWithString:assetsURL];
    returnURLComponents.path = [BTThreeDSecureAssetsPath stringByAppendingString:@"/redirect.html"];
    
    NSMutableString *returnURLQuery = [@"" mutableCopy];
    if (threeDSecureRequest.v1UICustomization) {
        if (threeDSecureRequest.v1UICustomization.redirectButtonText) {
            NSString *encodedButtonText = [threeDSecureRequest.v1UICustomization.redirectButtonText stringByAddingPercentEncodingWithAllowedCharacters:unreservedCharacters];
            [returnURLQuery appendFormat:@"b=%@&", encodedButtonText];
        }
        if (threeDSecureRequest.v1UICustomization.redirectDescription) {
            NSString *encodedDescription = [threeDSecureRequest.v1UICustomization.redirectDescription stringByAddingPercentEncodingWithAllowedCharacters:unreservedCharacters];
            [returnURLQuery appendFormat:@"d=%@&", encodedDescription];
        }
    }
    
    // redirect_url must be last query parameter in returnUrl
    [returnURLQuery appendFormat:@"redirect_url=%@", [redirectURL stringByAddingPercentEncodingWithAllowedCharacters:unreservedCharacters]];
    
    // The return url's query string needs to be encoded
    returnURLComponents.percentEncodedQuery = [returnURLQuery stringByAddingPercentEncodingWithAllowedCharacters:unreservedCharacters];
    NSString *encodedReturnURL = [returnURLComponents.URL.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:unreservedCharacters];
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:assetsURL];
    urlComponents.path = [BTThreeDSecureAssetsPath stringByAppendingString:@"/index.html"];
    
    NSString *encodedAcsURL = [threeDSecureLookup.acsURL.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:unreservedCharacters];
    NSString *encodedPAReq = [threeDSecureLookup.PAReq stringByAddingPercentEncodingWithAllowedCharacters:unreservedCharacters];
    NSString *encodedMD = [threeDSecureLookup.MD stringByAddingPercentEncodingWithAllowedCharacters:unreservedCharacters];
    NSString *encodedTermURL = [threeDSecureLookup.termURL.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:unreservedCharacters];
    
    urlComponents.percentEncodedQuery = [NSString stringWithFormat:@"AcsUrl=%@&PaReq=%@&MD=%@&TermUrl=%@&ReturnUrl=%@",
                                         encodedAcsURL,
                                         encodedPAReq,
                                         encodedMD,
                                         encodedTermURL,
                                         encodedReturnURL];
    return urlComponents.URL;
}

@end
