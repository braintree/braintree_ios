#import "BTClientCardRequest.h"

@implementation BTClientCardRequest

@synthesize shouldValidate = _shouldValidate;

- (instancetype)init {
    return self = [super init];
}

- (instancetype)initWithTokenizationRequest:(BTClientCardTokenizationRequest *)tokenizationRequest {
    if (!tokenizationRequest) {
        return nil;
    }
    
    self = [self init];
    if (self) {
        self.number               = tokenizationRequest.number;
        self.expirationYear       = tokenizationRequest.expirationYear;
        self.expirationMonth      = tokenizationRequest.expirationMonth;
        self.expirationDate       = tokenizationRequest.expirationDate;
        self.cvv                  = tokenizationRequest.cvv;
        self.postalCode           = tokenizationRequest.postalCode;
        self.shouldValidate       = tokenizationRequest.shouldValidate;
        self.additionalParameters = tokenizationRequest.additionalParameters;
    }
    return self;
}

- (BOOL)shouldValidate {
    return _shouldValidate;
}

@end
