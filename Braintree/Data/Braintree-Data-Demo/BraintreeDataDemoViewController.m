#import <Braintree/BTData.h>
#import "BraintreeDataDemoViewController.h"

@interface BraintreeDataDemoViewController () <BTDataDelegate>

/// Retain BTData for entire lifecycle of view controller
@property (nonatomic, strong) BTData *data;
@end

@implementation BraintreeDataDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (IBAction)tappedInitialize
{
    self.data = [BTData defaultDataForEnvironment:BTDataEnvironmentSandbox
                                            delegate:self];
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
