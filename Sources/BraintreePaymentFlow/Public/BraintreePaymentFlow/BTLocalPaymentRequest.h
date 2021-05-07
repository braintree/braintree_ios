#if __has_include(<Braintree/BraintreePaymentFlow.h>)
#import <Braintree/BTPaymentFlowRequest.h>
#import <Braintree/BTPaymentFlowDriver.h>
#else
#import <BraintreePaymentFlow/BTPaymentFlowRequest.h>
#import <BraintreePaymentFlow/BTPaymentFlowDriver.h>
#endif

@class BTPostalAddress;

NS_ASSUME_NONNULL_BEGIN

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
 The country code of the local payment.

 This value must be one of the supported country codes for a given local payment type listed at the link below. For local payments supported in multiple countries, this value may determine which banks are presented to the customer.

 https://developers.braintreepayments.com/guides/local-payment-methods/client-side-custom/ios/v4#invoke-payment-flow
 */
@property (nonatomic, nullable, copy) NSString *paymentTypeCountryCode;

/**
 Optional: A non-default merchant account to use for tokenization.
 */
@property (nonatomic, nullable, copy) NSString *merchantAccountID;

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
 Optional: Bank Identification Code of the customer (specific to iDEAL transactions).
 */
@property (nonatomic, nullable, copy) NSString *bic;

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
- (void)localPaymentStarted:(BTLocalPaymentRequest *)request paymentID:(NSString *)paymentID start:(void(^)(void))start;;

@end

NS_ASSUME_NONNULL_END
