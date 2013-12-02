//
//  SYNSearchResultsUserCell.h
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

@import UIKit;
#import "SYNSearchResultsCell.h"

@class ChannelOwner;
@class SYNSocialButton;
@class SYNAvatarButton;

@interface SYNSearchResultsUserCell : SYNSearchResultsCell

@property (nonatomic, strong) ChannelOwner* channelOwner;
@property (nonatomic, strong) IBOutlet SYNSocialButton* followButton;
@property (nonatomic, strong) IBOutlet SYNAvatarButton *userThumbnailButton;
@property (nonatomic, strong) IBOutlet UIButton* userNameLabelButton;

@property (nonatomic, strong) UIView* separatorView;

@end
