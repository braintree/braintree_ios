#import "BTVenmoAppSwitchURL.h"

SpecBegin(BTVenmoAppSwitchURL)

describe(@"isAppSwitchAvailable", ^{
  it(@"returns true if the Venmo App is installed and the developer has registered a app switch return scheme that returns to this app", ^{

    expect([BTVenmoAppSwitchURL isAppSwitchAvailable]).to.beTruthy();
  });
});

SpecEnd