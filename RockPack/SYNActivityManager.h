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
- (void) updateActivityForVideo: (Video *) video;
- (void) updateSubscriptionsForChannel: (Channel *) channel;

@end
