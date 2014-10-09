#import <Braintree/BTData.h>
#import "BraintreeDataDemoViewController.h"
#import <Braintree/BTClient.h>
#import <Braintree/BTClient+Offline.h>

@interface BraintreeDataDemoViewController () <BTDataDelegate>

/// Retain BTData for entire lifecycle of view controller
@property (nonatomic, strong) BTData *data;

@property (nonatomic, strong) BTClient *client;
@end

@implementation BraintreeDataDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.client = [[BTClient alloc] initWithClientToken:[BTClient offlineTestClientTokenWithAdditionalParameters:@{}]];
}

- (IBAction)tappedInitialize
{
    self.data = [[BTData alloc] initWithClient:self.client
                                   environment:BTDataEnvironmentSandbox];
    self.data.delegate = self;
    NSLog(@"Initialized data %@", self.data);
}

- (IBAction)tappedCollect
{
    NSString *deviceData = [self.data collectDeviceData];

    NSLog(@"Collected data %@", deviceData);
}

- (void)btDataDidStartCollectingData:(BTData *)data
{
    NSLog(@"BTData:%@ didStartCollectingData", data);

}

- (void)btDataDidComplete:(BTData *)data
{
    NSLog(@"BTData:%@ didComplete", data);
}

- (void)btData:(BTData *)data didFailWithErrorCode:(int)errorCode error:(NSError *)error
{
    NSLog(@"BTData:%@ didFailWithErrorCode:%d error:%@", data, errorCode, error);
}

@end
