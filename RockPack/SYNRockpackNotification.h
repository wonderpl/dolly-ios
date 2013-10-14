//
//  SYNRockpackNotification.h
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

typedef enum : NSInteger
{
    kNotificationObjectTypeUserLikedYourVideo = 0,
    kNotificationObjectTypeUserSubscibedToYourChannel = 1,
    kNotificationObjectTypeFacebookFriendJoined = 2,
    kNotificationObjectTypeUnknown = 666
} kNotificationObjectType;

@interface SYNRockpackNotification : NSObject

@property (nonatomic) BOOL read;
@property (nonatomic) NSInteger identifier;
@property (nonatomic, readonly) kNotificationObjectType objectType;
@property (nonatomic, strong) NSDate *dateCreated;
@property (nonatomic, strong) NSString *dateDifferenceString;
@property (nonatomic, strong) NSString *messageType;

// Video Notification
@property (nonatomic, strong) NSString *videoId;
@property (nonatomic, strong) NSString *videoThumbnailUrl;

// Channel notification
@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *channelResourceUrl;
@property (nonatomic, strong) NSString *channelThumbnailUrl;

// User Data
@property (nonatomic, strong) ChannelOwner *channelOwner;
@property (nonatomic, strong) Channel *channel;



@property (nonatomic) NSInteger timeElapsesd;

- (id) initWithNotificationData: (NSDictionary *) data;
+ (id) notificationWithDictionary: (NSDictionary *) dictionary;

@end
