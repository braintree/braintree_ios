@import Foundation;

extern NSString *const BTVenmoErrorDomain;

NS_ENUM(NSInteger, BTVenmoErrorCode) {
    BTVenmoErrorUnknown = 0,
    BTVenmoErrorAppSwitchDisabled,
};

