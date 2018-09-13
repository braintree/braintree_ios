#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTPaymentFlowRequest.h"
#import "BTPaymentFlowDriver.h"

NS_ASSUME_NONNULL_BEGIN

@class BTLocalPaymentResult;
@protocol BTLocalPaymentRequestDelegate;

/**
 Used to initialize a local payment flow
 */
@interface BTLocalPaymentRequest : BTPaymentFlowRequest <BTPaymentFlowRequestDelegate>

/**
 The type of payment.
 */
@property (nonatomic, nullable, copy) NSString *paymentType;

/**
 Optional: A non-default merchant account to use for tokenization.
 */
@property (nonatomic, nullable, copy) NSString *merchantAccountId;

/**
 Optional: The address of the customer. An error will occur if this address is not valid.
 */
@property (nonatomic, nullable, copy) BTPostalAddress *address;

/**
 The amount for the transaction.
 */
@property (nonatomic, nullable, copy) NSString *amount;

/**
 Optional: A valid ISO currency code to use for the transaction. Defaults to merchant currency code if not set.
 */
@property (nonatomic, nullable, copy) NSString *currencyCode;

/**
 Optional: Payer email of the customer.
 */
@property (nonatomic, nullable, copy) NSString *email;

/**
 Optional: Given (first) name of the customer.
 */
@property (nonatomic, nullable, copy) NSString *givenName;

/**
 Optional: Surname (last name) of the customer.
 */
@property (nonatomic, nullable, copy) NSString *surname;

/**
 Optional: Phone number of the customer.
 */
@property (nonatomic, nullable, copy) NSString *phone;

/**
 Indicates whether or not the payment needs to be shipped. For digital goods, this should be false. Defaults to false.
 */
@property (nonatomic, getter=isShippingAddressRequired) BOOL shippingAddressRequired;

/**
 A delegate for receiving information about the local payment flow.
 */
@property (nonatomic, nullable, weak) id<BTLocalPaymentRequestDelegate> localPaymentFlowDelegate;

@end

/**
 Protocol for local payment flow
 */
@protocol BTLocalPaymentRequestDelegate

@required

/**
 Required delegate method which returns the payment ID before the flow starts.
 Use this to do any preprocessing and setup for webhooks. Use the `start()` callback to continue the flow.
 */
- (void)localPaymentStarted:(BTLocalPaymentRequest *)request paymentId:(NSString *)paymentId start:(void(^)(void))start;;

@end

NS_ASSUME_NONNULL_END
