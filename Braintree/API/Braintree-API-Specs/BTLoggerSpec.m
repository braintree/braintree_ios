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

describe(@"logger", ^{

    __block BTLogger *logger;

    beforeEach(^{
        logger = [[BTLogger alloc] init];
    });

    describe(@"log", ^{
        it(@"sends log message to NSLog", ^{
            [logger log:@"BTLogger probably works!"];
            // Can't mock NSLog
        });

        it(@"sends log message to logBlock if defined", ^AsyncBlock{
            NSString *messageLogged = @"BTLogger logBlock works!";
            logger.logBlock = ^(NSString *messageReceived) {
                expect(messageReceived).to.equal(messageLogged);
                done();
            };
            [logger log:messageLogged];
        });
    });

    describe(@"level", ^{
        it(@"defaults to 'info'", ^{
            expect(logger.level).to.equal(BTLoggerLevelInfo);
        });

        it(@"allows logging if logged at or below level", ^{

            for (int level = BTLoggerLevelNone; level <= BTLoggerLevelDebug; level++) {
                NSString *message = [NSString stringWithFormat:@"test %d", level];
                NSMutableArray *messagesLogged = [NSMutableArray array];
                logger.logBlock = ^(NSString *messageReceived) {
                    [messagesLogged addObject:messageReceived];
                };

                logger.level = level;
                [logger critical:message];
                [logger error:message];
                [logger warning:message];
                [logger info:message];
                [logger debug:message];
                expect(messagesLogged.count).to.equal(level);
            }
        });
        
    });
    
});

SpecEnd