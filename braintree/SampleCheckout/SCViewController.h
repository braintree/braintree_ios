//
//  SCViewController.h
//  SampleCheckout
//
//  Created by kortina on 3/28/13.
//  Copyright (c) 2013 Braintree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTPaymentViewController.h" // Don't forget this!

@interface SCViewController : UIViewController <BTPaymentViewControllerDelegate>
// Conform to the BTPaymentViewControllerDelegate protocol

@property (strong, nonatomic) BTPaymentViewController *paymentViewController;
// Create a property to reference the BTPaymentViewController we dsiplay

@end
