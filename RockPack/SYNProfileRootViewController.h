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
    modeMyOwnProfile = 0,
    modeOtherUsersProfile,
    modeEditProfile,
} ProfileType;


@interface SYNProfileRootViewController : SYNAbstractViewController <UISearchBarDelegate, UITextViewDelegate>

@property (nonatomic, strong) ChannelOwner* channelOwner;
@property (nonatomic, assign) BOOL hideUserProfile;

- (id) initWithViewId:(NSString*) vid andChannelOwner:(ChannelOwner*)chanOwner;


@end
