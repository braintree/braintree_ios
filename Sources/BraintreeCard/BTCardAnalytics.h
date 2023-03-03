//
//  BTCardAnalytics.h
//  BraintreeCard
//
//  Created by Victoria Park on 3/3/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTCardAnalytics : NSObject

@property (class, nonatomic, assign, readonly) NSString *cardTokenizeStarted;
@property (class, nonatomic, assign, readonly) NSString *cardTokenizeFailed;
@property (class, nonatomic, assign, readonly) NSString *cardTokenizeSucceeded;
@property (class, nonatomic, assign, readonly) NSString *cardTokenizeNetworkConnectionLost;
@end

NS_ASSUME_NONNULL_END
