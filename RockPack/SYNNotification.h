//
//  SYNRockpackNotification.h
//  rockpack
//
//  Created by Michael Michailidis on 10/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "User.h"
@import Foundation;

typedef NS_ENUM(NSInteger, kNotificationObjectType) {
    kNotificationObjectTypeUserLikedYourVideo,
    kNotificationObjectTypeUserSubscibedToYourChannel,
    kNotificationObjectTypeFacebookFriendJoined,
    kNotificationObjectTypeUserAddedYourVideo, // Repack
    kNotificationObjectTypeYourVideoNotAvailable, // One of your videos is no longer available
    kNotificationObjectTypeCommentMention, // Comment
	kNotificationObjectTypeShareVideo,
	kNotificationObjectTypeShareChannel,

    kNotificationObjectTypeUnknown = NSNotFound
};

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
