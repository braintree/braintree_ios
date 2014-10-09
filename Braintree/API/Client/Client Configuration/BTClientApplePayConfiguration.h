@import Foundation;
@import PassKit;

@class BTClientToken;

typedef NS_ENUM(NSUInteger, BTClientApplePayStatus) {
    BTClientApplePayStatusOff = 0,
    BTClientApplePayStatusMock = 1,
    BTClientApplePayStatusProduction = 2,
};

@interface BTClientApplePayConfiguration : NSObject

@property (nonatomic, assign) BTClientApplePayStatus status;

@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *currencyCode;
@property (nonatomic, copy) NSString *merchantIdentifier;
@property (nonatomic, copy) NSArray *supportedNetworks;

- (PKPaymentRequest *)paymentRequest;

@end
