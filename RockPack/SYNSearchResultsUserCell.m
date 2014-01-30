//
//  SYNSearchResultsUserCell.m
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchResultsUserCell.h"
#import "UIFont+SYNFont.h"
#import <UIButton+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "ChannelOwner.h"
#import "SYNSocialButton.h"
#import "SYNAvatarButton.h"
#import "SYNActivityManager.h"

@interface SYNSearchResultsUserCell ()

@property (nonatomic, weak) id<SYNSearchResultsUserCellDelegate> delegate;

@property (nonatomic, strong) UIView *separatorView;

@property (nonatomic, strong) IBOutlet SYNSocialButton *followButton;
@property (nonatomic, strong) IBOutlet SYNAvatarButton *userThumbnailButton;
@property (nonatomic, strong) IBOutlet UIButton* userNameLabelButton;
@property (strong, nonatomic) UIAlertView *followAllAlertView;
@property (strong, nonatomic) UIButton* alertViewButton;

@end

@implementation SYNSearchResultsUserCell

#pragma mark -

- (void)awakeFromNib {
	[super awakeFromNib];
	
	if (IS_IPHONE) {
		[self addSubview:self.separatorView];
	}
	
	self.userNameLabelButton.titleLabel.font = [UIFont lightCustomFontOfSize:self.userNameLabelButton.titleLabel.font.pointSize];
	
	[self.userThumbnailButton addTarget:self action:@selector(profileButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.userNameLabelButton addTarget:self action:@selector(profileButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.followButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Set Data

- (void)setChannelOwner:(ChannelOwner *)channelOwner {
	_channelOwner = channelOwner; // can be friend
	
	if (!_channelOwner) {
		self.userThumbnailButton.imageView.image = [UIImage imageNamed: @"PlaceholderChannelSmall.png"];
		self.userNameLabelButton.titleLabel.text = @"";
		return;
	}
	
	self.followButton.dataItemLinked = channelOwner;
    
    [self.userThumbnailButton setImageWithURL:[NSURL URLWithString: channelOwner.thumbnailURL]
                                     forState:UIControlStateNormal
                             placeholderImage:[UIImage imageNamed: @"PlaceholderAvatarFriends"]
                                      options:SDWebImageRetryFailed];
    
    [self.userNameLabelButton setTitle:channelOwner.displayName forState:UIControlStateNormal];
    
    channelOwner.subscribedByUserValue = [[SYNActivityManager sharedInstance] isSubscribedToUserId:channelOwner.uniqueId];
    
    if (channelOwner.subscribedByUserValue == NO) {
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
    else
    {
        [self.followButton setTitle:@"Unfollow" forState:UIControlStateSelected];
    }
}

- (UIView *)separatorView {
	if (!_separatorView) {
		UIView *view = [[UIView alloc] init];
		view.backgroundColor = [UIColor colorWithRed:(172.0f/255.0f) green:(172.0f/255.0f) blue:(172.0f/255.0f) alpha:1.0f];
		view.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth);
		
		self.separatorView = view;
	}
	return _separatorView;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (IS_IPHONE) {
		self.separatorView.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - 0.5, CGRectGetWidth(self.bounds), 0.5);
	}
}

- (void)profileButtonPressed:(UIButton *)button {
	[self.delegate profileButtonTapped:button];
}

- (void)followButtonPressed:(UIButton *)button {
    
    self.followAllAlertView = [[UIAlertView alloc]initWithTitle:@"Follow All?" message:nil delegate:self cancelButtonTitle:[self noButtonTitle] otherButtonTitles:[self yesButtonTitle], nil];
    
    NSString *message;
    
    if (self.channelOwner.subscribedByUserValue) {
        self.followAllAlertView.title = @"Unfollow All?";
        message = @"Are you sure you want to unfollow all";
        message =  [message stringByAppendingString:@" "];
        message =  [message stringByAppendingString:[self.channelOwner.displayName stringByReplacingOccurrencesOfString:@" " withString:@""]];
        
        
        message =  [message stringByAppendingString:@"'s collections"];
        
    } else {
        NSLog(@"display name:%@.", self.channelOwner.displayName);
        
        self.followAllAlertView.title = @"Follow All?";
        message = @"Are you sure you want to follow all";
        message =  [message stringByAppendingString:@" "];
        
        
        //        message =  [message stringByAppendingString:self.channelOwner.displayName];
        
        message =  [message stringByAppendingString:[self.channelOwner.username stringByReplacingOccurrencesOfString:@" " withString:@""]];
        
        
        message =  [message stringByAppendingString:@"'s collections"];
        
    }
    
    
    self.alertViewButton = button;
    [self.followAllAlertView setMessage:message];
    [self.followAllAlertView show];

}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.followAllAlertView)
    {
        [self.delegate followControlPressed:self.alertViewButton];
        
    }
}

- (NSString *) yesButtonTitle{
    return NSLocalizedString(@"Yes", @"Yes to following/unfollowing a user");
}
- (NSString *) noButtonTitle{
    return NSLocalizedString(@"Cancel", @"cancel following/unfollowing a user");
}

@end
