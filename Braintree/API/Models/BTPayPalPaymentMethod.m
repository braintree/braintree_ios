#import "BTPayPalPaymentMethod_Mutable.h"
#import "BTMutablePayPalPaymentMethod.h"

NSString *const kBTAdditionalInformationKeyAccountAddress = @"accountAddress";
NSString *const kBTAdditionalInformationKeyCity = @"city";
NSString *const kBTAdditionalInformationKeyCounty = @"country";
NSString *const kBTAdditionalInformationKeyPostalCode = @"postalCode";
NSString *const kBTAdditionalInformationKeyState = @"state";
NSString *const kBTAdditionalInformationKeyStreet1 = @"street1";
NSString *const kBTAdditionalInformationKeyStreet2 = @"street2";

@implementation BTPayPalPaymentMethod

- (id)mutableCopyWithZone:(__unused NSZone *)zone {
    BTMutablePayPalPaymentMethod *mutablePayPalPaymentMethod = [[BTMutablePayPalPaymentMethod alloc] init];
    mutablePayPalPaymentMethod.additionalInformation = self.additionalInformation;
    mutablePayPalPaymentMethod.email = self.email;
    mutablePayPalPaymentMethod.locked = self.locked;
    mutablePayPalPaymentMethod.nonce = self.nonce;
    mutablePayPalPaymentMethod.challengeQuestions = [self.challengeQuestions copy];
    mutablePayPalPaymentMethod.description = self.description;

    return mutablePayPalPaymentMethod;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p \"%@\" email:%@ nonce:%@ additionalInformation:%@>", NSStringFromClass([self class]), self, self.email, [self description], self.nonce, self.additionalInformation];
}

@end
