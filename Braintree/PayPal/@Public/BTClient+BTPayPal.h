#import "BTClient.h"
#import "BTClientPayPalPaymentResource.h"
#import "BTPayPalCheckout.h"

typedef void (^BTClientPayPalPaymentResourceBlock)(BTClientPayPalPaymentResource *paymentResource);

@interface BTClient (PayPal)
- (void)createPayPalPaymentResourceWithCheckout:(BTPayPalCheckout *)checkout
                                    redirectUri:(NSString *)redirectUri
                                      cancelUri:(NSString *)cancelUri
                               clientMetadataID:(NSString *)clientMetadataID
                                        success:(BTClientPayPalPaymentResourceBlock)successBlock
                                        failure:(BTClientFailureBlock)failureBlock;
@end
