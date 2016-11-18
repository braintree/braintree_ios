//
//  PPOTAnalyticsTracker.h
//  PayPalOneTouch
//
//  Copyright © 2014 PayPal, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPOTAnalyticsTracker : NSObject

/// Retrieves singleton instance.
+ (nonnull PPOTAnalyticsTracker *)sharedManager;

/*!
 @brief Tracks a "page"/action taken.

 @param pagename the page or "action" taken
 @param environment the environment (production, sandbox, etc.)
 @param clientID the client ID of the request
 @param error an optional error that occurred
 @param hermesToken web token
*/
- (void)trackPage:(nonnull NSString *)pagename
      environment:(nonnull NSString *)environment
         clientID:(nullable NSString *)clientID
            error:(nullable NSError *)error
      hermesToken:(nullable NSString *)hermesToken;
@end

// Notes for using PPOTCAnalyticsTracker:
//
// We always want to track whenever something significant happens.
//
// "Page" is analytics-talk for "Screen", but we'll hijack it to mean "something significant happened".
//
//
// THERE IS 1 CASE YOU NEED TO TRACK.
//
// THERE IS ALSO A SPREADSHEET THAT NEEDS TO BE KEPT UP TO DATE.
// (OTC : docs-internal : "OTC pagenames with tracking notes.xlsx")
// The spreadsheet is in a form familiar to PayPal's SiteCatalyst folks.
// Once we're off Site Catalyst, perhaps we can simplify it a bit.
// In any case, the spreadsheet provides us with a common source of Truth
// for both iOS and Android, so it's important to keep it up to date.
//
//
// (1) SOMETHING SIGNIFICANT HAPPENS (spreadsheet: add a new "header" line, plus a new entry line for your new "page")
//
//      [[PPOTCAnalyticsTracker sharedManager] trackPage:kAnalyticsWhatIsHappening
//                                            environment:request.environment
//                                               clientID:request.clientID
//                                                 error:nil
//                                           hermesToken:request.hermesToken];
//
//  The "page" name comes from that spreadsheet, and is declared in PPAnalyticsDefines.h.
//  Set the `error` parameter to an NSError if there's an error to report.
//  If you have a Hermes token (e.g., Express Checkout Token), you should provide it. Otherwise `nil`.
//  If you need to construct an NSError, you can use `kAnalyticsErrorDomain`.
