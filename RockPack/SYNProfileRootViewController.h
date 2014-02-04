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
    kModeMyOwnProfile = 0,
    kModeOtherUsersProfile,
    kModeEditProfile,
} ProfileType;


@interface SYNProfileRootViewController : SYNAbstractViewController <UISearchBarDelegate, UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) ChannelOwner* channelOwner;
@property (nonatomic, assign) BOOL hideUserProfile;

- (id) initWithViewId:(NSString*) vid andChannelOwner:(ChannelOwner*)chanOwner;
- (IBAction)editButtonTapped:(id)sender;


@end
