//
//  SYNSearchResultsUserCell.m
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNFriendCell.h"
#import "UIFont+SYNFont.h"
#import <UIButton+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "ChannelOwner.h"
#import "SYNSocialButton.h"
#import "SYNAvatarButton.h"
#import "SYNActivityManager.h"

@interface SYNFriendCell ()

@property (nonatomic, weak) id<SYNSearchResultsUserCellDelegate> delegate;

@property (nonatomic, strong) UIView *separatorView;


@property (nonatomic, strong) IBOutlet UIButton *userThumbnailButton;
@property (nonatomic, strong) IBOutlet UIButton *userNameLabelButton;



@end

@implementation SYNFriendCell

#pragma mark -

- (void)awakeFromNib
{
    
	[super awakeFromNib];
	
	if (IS_IPHONE) {
		[self addSubview:self.separatorView];
	}
	
	self.userNameLabelButton.titleLabel.font = [UIFont lightCustomFontOfSize:self.userNameLabelButton.titleLabel.font.pointSize];
	
	[self.userThumbnailButton addTarget:self
                                 action:@selector(profileButtonPressed:)
                       forControlEvents:UIControlEventTouchUpInside];
    
	[self.userNameLabelButton addTarget:self
                                 action:@selector(profileButtonPressed:)
                       forControlEvents:UIControlEventTouchUpInside];
    
	[self.followButton addTarget:self
                          action:@selector(followButtonPressed:)
                forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - Set Data

- (void)setChannelOwner:(ChannelOwner *)channelOwner
{
    
	_channelOwner = channelOwner; // can be friend
	
	if (!_channelOwner) {
		self.userThumbnailButton.imageView.image = [UIImage imageNamed: @"PlaceholderChannelSmall.png"];
		self.userNameLabelButton.titleLabel.text = @"";
		return;
	}
	
    [self.userThumbnailButton setImageWithURL:[NSURL URLWithString: channelOwner.thumbnailURL]
                                     forState:UIControlStateNormal
                             placeholderImage:[UIImage imageNamed: @"PlaceholderAvatarFriends"]
                                      options:SDWebImageRetryFailed];
    
    [self.userNameLabelButton setTitle:channelOwner.displayName forState:UIControlStateNormal];
    self.userNameLabelButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.userNameLabelButton.titleLabel.numberOfLines = 2;
    
    [self setButtonTitleAndResizeText:channelOwner.displayName forLabel:self.userNameLabelButton.titleLabel];    
}

// Could not set word wrapping for a UILabel with multiple lines and set linebreak as NSLineBreakByTruncatingTail so this method calculates a good font size according to the optimal font size and works it way down

-(void) setButtonTitleAndResizeText:(NSString*) text forLabel:(UILabel*) label
{
    
    UIFont *font = [UIFont lightCustomFontOfSize:label.font.pointSize];
    
    //i starts at the ideal font size and shrinks down
    int i;
    for(i = label.font.pointSize; i > 10; i=i-1)
    {
        // Set the new font size.
        font = [font fontWithSize:i];
        CGSize constraintSize = CGSizeMake(self.userNameLabelButton.frame.size.width, MAXFLOAT);
        
        CGRect textRect = [text boundingRectWithSize:constraintSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:font}
                                             context:nil];
        
        CGSize labelSize = textRect.size;
        //need to set the height of the label
        if(labelSize.height <= 33.0f)
            break;
    }
    label.font = font;
    [label setText:text];
    
}

- (UIView *)separatorView
{
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
    [self.delegate followControlPressed:self.followButton withChannelOwner:self.channelOwner completion:nil];
}

@end
