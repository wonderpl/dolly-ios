//
//  SYNActivityManager.h
//  rockpack
//
//  Created by Nick Banks on 25/03/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import Foundation;

@class Video, Channel;

@interface SYNActivityManager : NSObject

+ (instancetype) sharedInstance;

- (void) updateActivityForCurrentUser;

- (BOOL) isRecentlyStarred:(NSString*)videoInstanceId;
- (BOOL) isRecentlyViewed:(NSString*)videoId;
- (BOOL) isSubscribed:(NSString*)channelId;

-(void)registerActivityFromDictionary:(NSDictionary*)dictionary;

@end
