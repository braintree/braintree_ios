//
//  SCViewController.m
//  SampleCheckout
//
//  Created by kortina on 3/28/13.
//  Copyright (c) 2013 Braintree. All rights reserved.
//

#import "SCViewController.h"

@interface SCViewController ()

@end

@implementation SCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addPayButton];
}

#pragma mark - PayButton

// Add a PayButton that will present a BTPaymentViewController when tapped
- (void)addPayButton {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    UIButton *payButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
#else
    UIButton *payButton = [UIButton buttonWithType:UIButtonTypeSystem];
#endif
    [payButton setTitle:@"Pay" forState:UIControlStateNormal];
    [payButton setEnabled:YES];
    [payButton setUserInteractionEnabled:YES];
    [payButton addTarget:self action:@selector(payButtonTapped:) forControlEvents:UIControlEventTouchDown];
    payButton.frame = CGRectMake(100, 100, 120, 50);
    [self.view addSubview:payButton];
}

// Create and present a BTPaymentViewController (that has a cancel button)
- (void)payButtonTapped:(UIButton *)button {
    NSLog(@"payButtonTapped");
    
    self.paymentViewController =
    [BTPaymentViewController paymentViewControllerWithVenmoTouchEnabled:YES];
    self.paymentViewController.delegate = self;
    
    // Add paymentViewController to a navigation controller.
    UINavigationController *paymentNavigationController =
    [[UINavigationController alloc] initWithRootViewController:self.paymentViewController];

    // Add the cancel button
    self.paymentViewController.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:paymentNavigationController
     action:@selector(dismissModalViewControllerAnimated:)];
    
    [self presentModalViewController:paymentNavigationController animated:YES];
}

#pragma mark - BTPaymentViewControllerDelegate

// When a user types in their credit card information correctly, the BTPaymentViewController sends you
// card details via the `didSubmitCardWithInfo` delegate method.
//
// NB: you receive raw, unencrypted info in the `cardInfo` dictionary, but
// for easy PCI Compliance, you should use the `cardInfoEncrypted` dictionary
// to securely pass data through your servers to the Braintree Gateway.
- (void)paymentViewController:(BTPaymentViewController *)paymentViewController
        didSubmitCardWithInfo:(NSDictionary *)cardInfo
         andCardInfoEncrypted:(NSDictionary *)cardInfoEncrypted {
    NSLog(@"didSubmitCardWithInfo %@ andCardInfoEncrypted %@", cardInfo, cardInfoEncrypted);
    [self savePaymentInfoToServer:cardInfoEncrypted]; // send card through your server to Braintree Gateway
}

// When a user adds a saved card from Venmo Touch to your app, the BTPaymentViewController sends you
// a paymentMethodCode that you can pass through your servers to the Braintree Gateway to
// add the full card details to your Vault.
- (void)paymentViewController:(BTPaymentViewController *)paymentViewController
didAuthorizeCardWithPaymentMethodCode:(NSString *)paymentMethodCode {
    NSLog(@"didAuthorizeCardWithPaymentMethodCode %@", paymentMethodCode);
    // Create a dictionary of POST data of the format
    // {"payment_method_code": "[encrypted payment_method_code data from Venmo Touch client]"}
    NSMutableDictionary *paymentInfo = [NSMutableDictionary dictionaryWithObject:paymentMethodCode
                                                                          forKey:@"payment_method_code"];
    [self savePaymentInfoToServer:paymentInfo]; // send card through your server to Braintree Gateway
}

#pragma mark - Networking

// The following example code demonstrates how to pass encrypted card data from the app to your
// server (your server will then have to send it to the Braintree Gateway). For a fully working
// example of how to proxy data through your server to the Braintree Gateway, see:
//    1. the braintree_ios Server Side Integration tutorial [https://touch.venmo.com/server-integration-tutorial/]
//    2. and the sample-checkout-heroku Github project [link]

#define SAMPLE_CHECKOUT_BASE_URL @"http://venmo-sdk-sample-two.herokuapp.com"
//#define SAMPLE_CHECKOUT_BASE_URL @"http://localhost:4567"

// Pass payment info (eg card data) from the client to your server (and then to the Braintree Gateway).
// If card data is valid and added to your Vault, display a success message, and dismiss the BTPaymentViewController.
// If saving to your Vault fails, display an error message to the user via `BTPaymentViewController showErrorWithTitle`
// Saving to your Vault may fail, for example when
// * CVV verification does not pass
// * AVS verification does not pass
// * The card number was a valid Luhn number, but nonexistent or no longer valid
- (void) savePaymentInfoToServer:(NSDictionary *)paymentInfo {
    
    NSURL *url;
    if ([paymentInfo objectForKey:@"payment_method_code"]) {
        url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/card/payment_method_code", SAMPLE_CHECKOUT_BASE_URL]];
    } else {
        url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/card/add", SAMPLE_CHECKOUT_BASE_URL]];
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // You need a customer id in order to save a card to the Braintree vault.
    // Here, for the sake of example, we set customer_id to device id.
    // In practice, this is probably whatever user_id your app has assigned to this user.
    NSString *customerId = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    [paymentInfo setValue:customerId forKey:@"customer_id"];
    
    request.HTTPBody = [self postDataFromDictionary:paymentInfo];
    request.HTTPMethod = @"POST";
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *body, NSError *requestError)
     {
         NSError *err = nil;
         if (!response && requestError) {
             NSLog(@"requestError: %@", requestError);
             [self.paymentViewController showErrorWithTitle:@"Error" message:@"Unable to reach the network."];
             return;
         }

         NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:body options:kNilOptions error:&err];
         NSLog(@"saveCardToServer: paymentInfo: %@ response: %@, error: %@", paymentInfo, responseDictionary, requestError);
         
         if ([[responseDictionary valueForKey:@"success"] isEqualToNumber:@1]) { // Success!
             // Don't forget to call the cleanup method,
             // `prepareForDismissal`, on your `BTPaymentViewController`
             [self.paymentViewController prepareForDismissal];
             // Now you can dismiss and tell the user everything worked.
             [self dismissViewControllerAnimated:YES completion:^(void) {
                 [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Saved your card!" delegate:nil
                                   cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                 [[VTClient sharedVTClient] refresh];
             }];
             
         } else { // The card did not save correctly, so show the error from server with convenenience method `showErrorWithTitle`
             [self.paymentViewController showErrorWithTitle:@"Error saving your card" message:[self messageStringFromResponse:responseDictionary]];
         }
     }];
}

// Some boiler plate networking code below.

- (NSString *) messageStringFromResponse:(NSDictionary *)responseDictionary {
    return [responseDictionary valueForKey:@"message"];
}

// Construct URL encoded POST data from a dictionary
- (NSData *)postDataFromDictionary:(NSDictionary *)params {
    NSMutableString *data = [NSMutableString string];
    
    for (NSString *key in params) {
        NSString *value = [params objectForKey:key];
        if (value == nil) {
            continue;
        }
        if ([value isKindOfClass:[NSString class]]) {
            value = [self URLEncodedStringFromString:value];
        }
        
        [data appendFormat:@"%@=%@&", [self URLEncodedStringFromString:key], value];
    }
    
    return [data dataUsingEncoding:NSUTF8StringEncoding];
}

// This, from CSKit, is free for use:
// https://github.com/codenauts/CNSKit/blob/master/Classes/Categories/NSString%2BCNSStringAdditions.m
// NSString *encoded = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$&’()*+,;='"), kCFStringEncodingUTF8);

- (NSString *) URLEncodedStringFromString: (NSString *)string {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[string UTF8String];
    size_t sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}


@end
