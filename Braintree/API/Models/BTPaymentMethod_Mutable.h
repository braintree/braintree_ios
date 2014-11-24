#import "BTPaymentMethod.h"

@interface BTPaymentMethod ()

@property (nonatomic, readwrite, assign, getter = isLocked) BOOL locked;
@property (nonatomic, readwrite, copy) NSString *nonce;
@property (nonatomic, readwrite, strong) NSSet *challengeQuestions;
@property (nonatomic, readwrite, copy) NSString *description;

@end
