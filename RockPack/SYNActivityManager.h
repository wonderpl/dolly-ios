//
//  SYNActivityManager.h
//  rockpack
//
//  Created by Nick Banks on 25/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

/* SYNAcitivtyManager
 The activity manager stores all user activity, this includes the Loving of videos, The 
 channels/users they follow and recently viewed videos.
 
 At the moment when an "action" has been posted to the server a return of all the user activity 
 gets returned. It would make more sense if less is returned, no point getting extra 
 information about loved videos when a user follows/unfollows a channel.
 
*/

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

- (void) addChannelSubscriptionsObject:(Channel *)channel;
- (void) addUserSubscriptonsObject:(ChannelOwner*)channelOwner;
- (NSUInteger) userFollowingCount;
- (NSString*)trackingCodeForVideoInstance :(VideoInstance*) videoInstance;
- (void)addObjectFromDict :(NSDictionary*) dict;
- (NSString*)trackingCodeForChannel :(Channel*) channel;
- (NSString*)trackingCodeForChannel :(Channel*) channel videoInstance :(VideoInstance*)videoInstance;
- (void) unsubscribeToUser: (ChannelOwner *) channelOwner
             videoInstance: (VideoInstance*) videoInstance
         completionHandler: (MKNKUserSuccessBlock) completionBlock
              errorHandler: (MKNKUserErrorBlock) errorBlock;

- (void) subscribeToUser: (ChannelOwner *) channelOwner
             videoInstance: (VideoInstance*) videoInstance
         completionHandler: (MKNKUserSuccessBlock) completionBlock
            errorHandler: (MKNKUserErrorBlock) errorBlock;


@end
