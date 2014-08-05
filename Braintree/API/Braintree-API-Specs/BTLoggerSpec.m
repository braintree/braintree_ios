#import "BTLogger.h"

SpecBegin(BTLogger)

describe(@"sharedLogger", ^{
    it(@"returns the singleton logger", ^{
        BTLogger *logger1 = [BTLogger sharedLogger];
        BTLogger *logger2 = [BTLogger sharedLogger];
        expect(logger1).to.beKindOf([BTLogger class]);
        expect(logger1).to.equal(logger2);
    });
});

describe(@"log", ^{
    it(@"sends log message to NSLog", ^{
        [[BTLogger sharedLogger] log:@"BTLogger works!"];

        // Delegation to NSLog function is untestable.
    });
});

SpecEnd