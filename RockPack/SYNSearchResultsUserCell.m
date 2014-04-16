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
#import "UIImageView+WebCache.h"
#import "SYNFollowDiscoverButton.h"

@interface SYNSearchResultsUserCell ()

@property (nonatomic, weak) id<SYNSearchResultsUserCellDelegate> delegate;

@property (nonatomic, strong) UIView *separatorView;

@property (nonatomic, strong) IBOutlet SYNSocialButton *followButton;
@property (nonatomic, strong) IBOutlet SYNAvatarButton *userThumbnailButton;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) UIAlertView *followAllAlertView;
@property (strong, nonatomic) IBOutlet UIImageView *coverImage;
@property (strong, nonatomic) UIButton* alertViewButton;

@end

@implementation SYNSearchResultsUserCell

#pragma mark -

- (void)awakeFromNib {
	[super awakeFromNib];
	
	if (IS_IPHONE) {
		[self addSubview:self.separatorView];
	}
	
	
	[self.userThumbnailButton addTarget:self action:@selector(profileButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.followButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
 
    self.followButton.layer.cornerRadius = self.followButton.frame.size.width/2;
    self.followButton.layer.masksToBounds = YES;
    
    
    [self.userNameLabel setFont:[UIFont semiboldCustomFontOfSize:self.userNameLabel.font.pointSize]];
}

#pragma mark - Set Data

- (void)setChannelOwner:(ChannelOwner *)channelOwner {
	_channelOwner = channelOwner; // can be friend
	
	if (!_channelOwner) {
		self.userThumbnailButton.imageView.image = [UIImage imageNamed: @"PlaceholderChannelSmall.png"];
		return;
	}
	
	self.followButton.dataItemLinked = channelOwner;
    
    [self.userNameLabel setText: channelOwner.displayName];
    
    [self.descriptionLabel setText:channelOwner.channelOwnerDescription];
    
    NSString *coverPhotoURL = _channelOwner.coverPhotoURL;
    
    
    //Default is thumbnail_medium, which is the url used in iphone
    if (IS_IPAD) {
        coverPhotoURL = [coverPhotoURL stringByReplacingOccurrencesOfString: @"thumbnail_medium"
                                                                 withString: @"ipad_highlight"];
        
    }
    
 __weak SYNSearchResultsUserCell *weakSelf = self;
    [self.coverImage setImageWithURL:[NSURL URLWithString: coverPhotoURL]
                    placeholderImage:[UIImage imageNamed: @"PlaceholderVideoBottom"]
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                               if (image && cacheType == SDImageCacheTypeNone)
                               {
                                   weakSelf.coverImage.alpha = 0.0;
                                   [UIView animateWithDuration:1.0 animations:^{
                                       weakSelf.coverImage.alpha = 1.0;
                                   }];
                               }
                           }];


    channelOwner.subscribedByUserValue = [[SYNActivityManager sharedInstance] isSubscribedToUserId:channelOwner.uniqueId];
    
    if (!channelOwner.subscribedByUserValue) {
        [self.followButton setTitle:NSLocalizedString(@"follow", "follow discover screen") forState:UIControlStateNormal];
    }
    else
    {
        [self.followButton setTitle:NSLocalizedString(@"unfollow", "unfollow discover screen") forState:UIControlStateSelected];
    }
}


// Could not set word wrapping for a UILabel with multiple lines and set linebreak as NSLineBreakByTruncatingTail so this method calculates a good font size according to the optimal font size and works it way down

-(void) setButtonTitleAndResizeText:(NSString*) text forLabel:(UILabel*) label
{
//    
//    UIFont *font = [UIFont lightCustomFontOfSize:label.font.pointSize];
//    
//    //i starts at the ideal font size and shrinks down
//    int i;
//    for(i = label.font.pointSize; i > 10; i=i-1)
//    {
//        // Set the new font size.
//        font = [font fontWithSize:i];
//        CGSize constraintSize = CGSizeMake(self.userNameLabelButton.frame.size.width
//                                           , MAXFLOAT);
//        
//        CGRect textRect = [text boundingRectWithSize:constraintSize
//                                                  options:NSStringDrawingUsesLineFragmentOrigin
//                                               attributes:@{NSFontAttributeName:font}
//                                                  context:nil];
//        
//        CGSize labelSize = textRect.size;
//        //need to set the height of the label
//        if(labelSize.height <= 33.0f)
//            break;
//    }
//    label.font = font;
//    [label setText:text];

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
        message =  [message stringByAppendingString:self.channelOwner.displayName];
        
        
        message =  [message stringByAppendingString:@"'s collections"];
        
    } else {
        self.followAllAlertView.title = @"Follow All?";
        message = @"Are you sure you want to follow all";
        message =  [message stringByAppendingString:@" "];
        message =  [message stringByAppendingString:self.channelOwner.displayName];
        message =  [message stringByAppendingString:@"'s collections"];
        
    }
    
    
    self.alertViewButton = button;
    [self.followAllAlertView setMessage:message];
    [self.followAllAlertView show];

}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];

    if (alertView == self.followAllAlertView && [buttonTitle isEqualToString:[self yesButtonTitle]])
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
