#import "BTOCMockHelper.h"
@import OCMock;
@import UIKit;

@implementation BTOCMockHelper

- (void)stubApplicationCanOpenURL {
    id stubApplication = OCMPartialMock(UIApplication.sharedApplication);
    OCMStub([stubApplication canOpenURL:[OCMArg any]]).andReturn(YES);
}

@end
