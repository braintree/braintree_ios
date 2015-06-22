#import "BTClientPayPalPaymentResourceValueTransformer.h"

@implementation BTClientPayPalPaymentResourceValueTransformer

+ (instancetype)sharedInstance {
    static BTClientPayPalPaymentResourceValueTransformer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)transformedValue:(id)value {
    if (![value isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
          
    BTAPIResponseParser *parser = [BTAPIResponseParser parserWithDictionary:value];
    
    BTClientPayPalPaymentResource *paymentResource = [[BTClientPayPalPaymentResource alloc] init];
    
    paymentResource.redirectURL = [parser URLForKey:@"redirectUrl"];
    
    return paymentResource;
}

@end
