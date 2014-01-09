typedef NS_ENUM(NSInteger, VTCardType) {
    VTCardTypeAMEX,
    VTCardTypeDinersClub,
    VTCardTypeDiscover,
    VTCardTypeMasterCard,
    VTCardTypeVisa,
    VTCardTypeJCB,
    VTCardTypeLaser,
    VTCardTypeMaestro,
    VTCardTypeUnionPay,
    VTCardTypeSolo,
    VTCardTypeSwitch,
    VTCardTypeUKMaestro,
    VTCardTypeUnknown
};

@interface VTPaymentMethodCode : NSObject

@property (nonatomic, assign, readonly) VTCardType cardType;
@property (nonatomic, copy, readonly) NSString *code;

- (id)initWithCode:(NSString *)code withCardType:(NSString *)cardType;

@end

