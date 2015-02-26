#import <coinbase-official/CoinbaseOAuth.h>

SpecBegin(BTCoinbase)

it(@"integrates with the coinbase sdk", ^{
    expect([CoinbaseOAuth class]).to.beKindOf([NSObject class]);
});

SpecEnd
