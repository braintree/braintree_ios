/*
 * Venmo SDK - Version 2.2.7
 *
 ******************************
 ******************************
 * VTClient_CardIssuers.h
 ******************************
 ******************************
 *
 * VTClient header file for methods specific to card issuers. Typical VenmoTouch integrations will
 * not need to use the methods provided by this file and can safely ignore it.
 */

#import <Foundation/Foundation.h>

// Most VenmoTouch implementations will not need to use this enum.
//
// When checking for a card on VenmoTouch using
// isCardOnFileAsyncWithBin:lastFour:expirationYear:expirationMonth:completionBlock,
// your callback will receive one of these values. Yes if the card is on file,
// No if it is not, and Failed if the information is unavailable (for example, due
// to a networking failure).
typedef NS_ENUM(NSInteger, VTCardOnFileStatus) {
    VTCardOnFileStatusNo = 0,
    VTCardOnFileStatusYes = 1,
    VTCardOnFileStatusFailed = -1,
};

@interface VTClient ()

// This method provides a mechanism to verify whether a
// given card is already on file in Venmo Touch.
//
// If you provide:
//   - the six-digit bin number (i.e. the first six digits of the card
//      number, which denote the issuing bank),
//   - the last four digits of the card number,
//   - the two digit expiration month and
//   - the four digit expiration year,
// then this method will asynchronously return VTCardOnFileStatusYes if the
// card is on file or VTCardOnFileStatusNo if it is not (via the completion
// block). VTCardOnFileStatusFailed implies that there was an issue with data
// validation or networking.
//
// Example usage:
//    // After the client is initialized...
//    [[VTClient sharedVTClient]
//     isCardOnFileAsyncWithBin:@"4"
//     lastFour:@"1111"
//     expirationMonth:@"12"
//     expirationYear:@"15"
//     completionBlock:^(VTCardOnFileStatus isCardOnFile){
//         if (isCardOnFile) {
//             NSLog(@"YES - card is on file.");
//         } else {
//             NSLog(@"NO - card is not on file.");
//         }
//     }];
- (void)isCardOnFileAsyncWithBin:(NSString *)bin
                        lastFour:(NSString *)lastFour expirationMonth:(NSString *)expirationMonth
                  expirationYear:(NSString *)year
                 completionBlock:(void(^)(VTCardOnFileStatus isCardOnFile))completion;

@end
