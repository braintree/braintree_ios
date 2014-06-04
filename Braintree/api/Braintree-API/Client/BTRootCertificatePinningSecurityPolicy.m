#import "BTRootCertificatePinningSecurityPolicy.h"

// Equivalent of macro to AF_Require_noErr
#ifndef BT_Require_noErr
#define BT_Require_noErr(errorCode, exceptionLabel)                        \
do {                                                                    \
if (__builtin_expect(0 != (errorCode), 0)) {                        \
goto exceptionLabel;                                            \
}                                                                   \
} while (0)
#endif

static BOOL BTServerTrustIsValid(SecTrustRef serverTrust) {
    BOOL isValid = NO;
    SecTrustResultType result;
    BT_Require_noErr(SecTrustEvaluate(serverTrust, &result), _out);

    isValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);

_out:
    return isValid;
}

@implementation BTRootCertificatePinningSecurityPolicy

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain {
    NSAssert(self.SSLPinningMode == AFSSLPinningModeCertificate, @"BTRootCertificatePinningSecurityPolicy only supports certificate based pinning");
    NSAssert(self.validatesCertificateChain == NO, @"BTRootCertificatePinningSecurityPolicy only supports root certificate pinning");
    NSAssert(self.validatesDomainName == YES, @"BTRootCertificatePinningSecurityPolicy only supports domain name validation");

    NSArray *policies = @[(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];

    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);

    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
    if (certificateCount == 0) {
        return NO;
    }

    NSData *serverRootCertificate = (__bridge_transfer NSData *)SecCertificateCopyData(SecTrustGetCertificateAtIndex(serverTrust, certificateCount-1));

    NSMutableArray *pinnedCertificates = [NSMutableArray array];
    for (NSData *certificateData in self.pinnedCertificates) {
        [pinnedCertificates addObject:(__bridge_transfer id)SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData)];
    }
    SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)pinnedCertificates);

    if (!BTServerTrustIsValid(serverTrust)) {
        return NO;
    }

    return [self.pinnedCertificates containsObject:serverRootCertificate];
}

@end
