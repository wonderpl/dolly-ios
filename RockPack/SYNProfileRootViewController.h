//
//  SYNYouRootViewController.h
//  rockpack
//
//  Created by Nick Banks on 24/01/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "ChannelOwner.h"
typedef enum : NSInteger {
    MyOwnProfile = 0,
    OtherUsersProfile,
    TestUserProfile,
} ProfileType;


@interface SYNProfileRootViewController : SYNAbstractViewController <UISearchBarDelegate>

@property (nonatomic, strong) ChannelOwner* channelOwner;
@property (nonatomic, assign) BOOL hideUserProfile;


@end
