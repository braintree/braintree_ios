#import "BTUICardExpirationValidator.h"

SpecBegin(BTUICardExpirationValidator)

describe(@"BTUICardExpirationValidator", ^{

    describe(@"monthYearValidForDate:", ^{
        __block NSDate *today;
        __block NSDate *endOfYearToday;

        before(^{
            NSDateComponents *components = [[NSDateComponents alloc] init];
            components.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            components.day = 2;
            components.month = 5;
            components.year = 2014;
            today = components.date;
        });

        it(@"should return false when the month year are before the provided date ", ^{
            BOOL monthYearValid = [BTUICardExpirationValidator month:4 year: 14 validForDate:today];
            expect(monthYearValid).to.beFalsy();
        });
        it(@"should return true when the month year are the same as the provided date ", ^{
            BOOL monthYearValid = [BTUICardExpirationValidator month:5 year: 14 validForDate:today];
            expect(monthYearValid).to.beTruthy();
        });
        it(@"should return true when the month year are after the provided date ", ^{
            BOOL monthYearValid = [BTUICardExpirationValidator month:8 year: 14 validForDate:today];
            expect(monthYearValid).to.beTruthy();
        });

        describe(@"Year in YYYY", ^{
            it(@"should return true when the month year are after the provided date", ^{
                BOOL monthYearValid = [BTUICardExpirationValidator month:8 year: 2014 validForDate:today];
                expect(monthYearValid).to.beTruthy();
            });
            it(@"should return false when the month year are before the provided date", ^{
                BOOL monthYearValid = [BTUICardExpirationValidator month:4 year: 2014 validForDate:today];
                expect(monthYearValid).to.beFalsy();
            });
        });


        describe(@"Date is at the end of the year", ^{
            before(^{
                NSDateComponents *components = [[NSDateComponents alloc] init];
                components.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                components.day = 1;
                components.month = 12;
                components.year = 2014;
                endOfYearToday = components.date;
            });

            it(@"should return true when the month/year are the same as the provided date", ^{
                BOOL monthYearValid = [BTUICardExpirationValidator month:12 year: 2014 validForDate:endOfYearToday];
                expect(monthYearValid).to.beTruthy();
            });
        });
    });

});

SpecEnd