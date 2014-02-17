//
//  SYNRockpackNotification.h
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "User.h"
@import Foundation;

typedef enum : NSInteger
{
    kNotificationObjectTypeUserLikedYourVideo = 0,
    kNotificationObjectTypeUserSubscibedToYourChannel = 1,
    kNotificationObjectTypeFacebookFriendJoined = 2,
    kNotificationObjectTypeUserAddedYourVideo = 3, // Repack
    kNotificationObjectTypeYourVideoNotAvailable = 4, // One of your videos is no longer available
    kNotificationObjectTypeUnknown = 666
} kNotificationObjectType;

@interface SYNNotification : NSObject

@property (nonatomic) BOOL read;
@property (nonatomic) NSInteger identifier;
@property (nonatomic, readonly) kNotificationObjectType objectType;
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

@property (nonatomic, strong, readonly) NSString *thumbnailUrl;

@property (nonatomic) NSInteger timeElapsesd;

- (id) initWithNotificationData: (NSDictionary *) data;
+ (id) notificationWithDictionary: (NSDictionary *) dictionary;

@end
