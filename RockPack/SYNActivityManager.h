//
//  SYNActivityManager.h
//  rockpack
//
//  Created by Nick Banks on 25/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNOAuthNetworkEngine.h"

@import Foundation;

@class Video, Channel;

@interface SYNActivityManager : NSObject

+ (instancetype) sharedInstance;

- (BOOL) isRecentlyStarred:(NSString*)videoInstanceId;
- (BOOL) isSubscribedToChannelId:(NSString*)channelId;
- (BOOL) isSubscribedToUserId:(NSString*)userId;

- (void)registerActivityFromDictionary:(NSDictionary*)dictionary;
- (void) updateActivityForCurrentUserWithReset:(BOOL) reset;

- (void) subscribeToChannel: (Channel *) channel
          completionHandler: (MKNKUserSuccessBlock) completionBlock
               errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) unsubscribeToChannel: (Channel *) channel
            completionHandler: (MKNKUserSuccessBlock) completionBlock
                 errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) subscribeToUser: (ChannelOwner *) channelOwner
       completionHandler: (MKNKUserSuccessBlock) completionBlock
            errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) unsubscribeToUser: (ChannelOwner *) channelOwner
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock;


- (void) addChannelSubscriptionsObject:(Channel *)channel;
- (void) addUserSubscriptonsObject:(ChannelOwner*)channelOwner;
- (NSUInteger) userFollowingCount;
- (NSString*)trackingCodeForVideoInstance :(VideoInstance*) videoInstance;
- (void)addObjectFromDict :(NSDictionary*) dict;
- (NSString*)trackingCodeForChannel :(Channel*) channel;


@end
