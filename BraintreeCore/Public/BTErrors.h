#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BTError) {
    BTErrorUnknown = 0,
    BTErrorCustomerInputInvalid,
};

#pragma mark NSError userInfo Keys

/// NSError userInfo key for validation errors.
extern NSString * _Nonnull const BTCustomerInputBraintreeValidationErrorsKey;
