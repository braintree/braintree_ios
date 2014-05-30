#import "BTUIUtil.h"

SpecBegin(BTUIUtil)

describe(@"BTUIUtil", ^{
    describe(@"uiColorFromHex", ^{
        it(@"converts simple valid strings", ^{
            UIColor *red = [BTUIUtil uiColorFromHex:@"#ff0000" alpha:1.0f];
            expect(red).to.equal([UIColor redColor]);
            UIColor *green = [BTUIUtil uiColorFromHex:@"#00ff00" alpha:1.0f];
            expect(green).to.equal([UIColor greenColor]);
            UIColor *blue = [BTUIUtil uiColorFromHex:@"#0000ff" alpha:1.0f];
            expect(blue).to.equal([UIColor blueColor]);
        });

        it(@"converts mixed color strings", ^{
            UIColor *c = [BTUIUtil uiColorFromHex:@"#ffffff" alpha:1.0f];
            expect(CGColorGetNumberOfComponents(c.CGColor)).to.equal(4);
            CGFloat r, g, b, a;
            [c getRed:&r green:&g blue:&b alpha:&a];
            expect(r).to.equal(1.0f);
            expect(g).to.equal(1.0f);
            expect(b).to.equal(1.0f);
            expect(a).to.equal(1.0f);

        });

        it(@"can take an alpha value", ^{
            UIColor *blueClear = [BTUIUtil uiColorFromHex:@"#0000ff" alpha:0.0f];
            expect(blueClear).notTo.equal([UIColor blueColor]);
            expect(CGColorGetNumberOfComponents(blueClear.CGColor)).to.equal(4);
            CGFloat r, g, b, a;
            [blueClear getRed:&r green:&g blue:&b alpha:&a];
            expect(r).to.equal(0.0f);
            expect(g).to.equal(0.0f);
            expect(b).to.equal(1.0f);
            expect(a).to.equal(0.0f);
        });

        it(@"doesn't choke on invalid strings", ^{
            UIColor *c;
            c = [BTUIUtil uiColorFromHex:@"#nnn" alpha:1.0f];
            expect(c).to.equal([UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]);

            c = [BTUIUtil uiColorFromHex:@"#im un ur hex and i am not real" alpha:1.0f];
            expect(c).to.equal([UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]);
        });
    });
});

SpecEnd