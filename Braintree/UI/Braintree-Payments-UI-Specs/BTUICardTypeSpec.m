#import <Braintree/BTUICardType.h>
#import "EXPMatchers+haveKerning.h"

SpecBegin(BTUICardType)

describe(@"BTUICardType", ^{

    it(@"should only have one instance of each brand", ^{
        BTUICardType *t1 = [BTUICardType cardTypeForBrand:BTUICardBrandAMEX];
        BTUICardType *t2 = [BTUICardType cardTypeForBrand:BTUICardBrandAMEX];
        expect(t1).to.equal(t2);
    });

    describe(@"card number recognition", ^{

        it(@"should recognize a valid, formatted Visa", ^{
            expect([BTUICardType cardTypeForNumber:@"4111 1111 1111 1111"]).to.equal([BTUICardType cardTypeForBrand:BTUICardBrandVisa]);
        });

        it(@"should recognize an invalid Visa", ^{
            expect([BTUICardType cardTypeForNumber:@"4111 1111 1111 1112"]).to.equal([BTUICardType cardTypeForBrand:BTUICardBrandVisa]);
        });

        it(@"should recognize a non-formatted Visa", ^{
            expect([BTUICardType cardTypeForNumber:@"4111111111111111"]).to.equal([BTUICardType cardTypeForBrand:BTUICardBrandVisa]);
        });

        it(@"should recognize an incomplete Visa", ^{
            expect([BTUICardType cardTypeForNumber:@"4"]).to.equal([BTUICardType cardTypeForBrand:BTUICardBrandVisa]);
        });

        it(@"should recognize a valid MasterCard", ^{
            expect([BTUICardType cardTypeForNumber:@"5555555555554444"]).to.equal([BTUICardType cardTypeForBrand:BTUICardBrandMasterCard]);
        });

        it(@"should recognize a valid American Express", ^{
            expect([BTUICardType cardTypeForNumber:@"378282246310005"]).to.equal([BTUICardType cardTypeForBrand:BTUICardBrandAMEX]);
        });

        it(@"should recognize a valid Discover", ^{
            expect([BTUICardType cardTypeForNumber:@"6011 1111 1111 1117"]).to.equal([BTUICardType cardTypeForBrand:BTUICardBrandDiscover]);
        });

        it(@"should recognize a valid JCB", ^{
            expect([BTUICardType cardTypeForNumber:@"3530 1113 3330 0000"]).to.equal([BTUICardType cardTypeForBrand:BTUICardBrandJCB]);
        });

        it(@"should not recognize a non-number", ^{
            expect([BTUICardType cardTypeForNumber:@"notanumber"]).to.beNil();
        });

        it(@"should not recognize an unrecognizable number", ^{
            expect([BTUICardType cardTypeForNumber:@"notanumber"]).to.beNil();
        });

    });


    describe(@"card number formatting", ^{

        it(@"should format a non-number as an empty string", ^{
            expect([[[BTUICardType cardTypeForBrand:BTUICardBrandVisa] formatNumber:@"notanumber"] string]).to.equal(@"");
        });

        it(@"should return a too-long number without formatting", ^{
            expect([[[BTUICardType cardTypeForBrand:BTUICardBrandVisa] formatNumber:@"00000000000000000"] string]).to.equal(@"00000000000000000");
        });

        it(@"should format a valid, formatted number as a Visa", ^{
            expect([[BTUICardType cardTypeForBrand:BTUICardBrandVisa] formatNumber:@"0000 0000 0000 0000"]).to.haveKerning(@[@3, @7, @11]);
        });

        it(@"should format a non-formatted number as a Visa", ^{
            expect([[BTUICardType cardTypeForBrand:BTUICardBrandVisa] formatNumber:@"0000000000000000"]).to.haveKerning(@[@3, @7, @11]);
        });

        it(@"should format an incomplete number as a Visa", ^{
            expect([[[BTUICardType cardTypeForBrand:BTUICardBrandVisa] formatNumber:@"0"] string]).to.equal(@"0");
        });

        it(@"should format as a MasterCard", ^{
            expect([[BTUICardType cardTypeForBrand:BTUICardBrandMasterCard] formatNumber:@"0000000000000000"]).to.haveKerning(@[@3, @7, @11]);
        });

        it(@"should format as an American Express", ^{
            expect([[BTUICardType cardTypeForBrand:BTUICardBrandAMEX] formatNumber:@"000000000000000"]).to.haveKerning(@[@3, @9]);
        });

        it(@"should format as an incomplete American Express", ^{
            expect([[BTUICardType cardTypeForBrand:BTUICardBrandAMEX] formatNumber:@"00000"]).to.haveKerning(@[@3]);
        });

        it(@"should format as a Discover", ^{
            expect([[BTUICardType cardTypeForBrand:BTUICardBrandDiscover] formatNumber:@"1234123412341234"]).to.haveKerning(@[@3, @7, @11]);
        });

        it(@"should format as a JCB", ^{
            expect([[BTUICardType cardTypeForBrand:BTUICardBrandJCB] formatNumber:@"1234123412341234"]).to.haveKerning(@[@3, @7, @11]);
        });
    });
});

SpecEnd