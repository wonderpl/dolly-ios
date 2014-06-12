//
//  SYNFeedChannelCell.m
//  dolly
//
//  Created by Sherman Lo on 16/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNFeedChannelCell.h"
#import "UIFont+SYNFont.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "SYNActivityManager.h"
#import <UIButton+WebCache.h>

@interface SYNFeedChannelCell ()

@property (nonatomic, strong) IBOutlet UIButton *avatarThumbnailButton;

@property (nonatomic, strong) IBOutlet UILabel *channelOwnerLabel;

@property (nonatomic, strong) IBOutlet UIButton *channelTitleButton;

@property (nonatomic, strong) IBOutlet UIButton *followButton;

@end

@implementation SYNFeedChannelCell

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.channelOwnerLabel.font = [UIFont italicAlternateFontOfSize:self.channelOwnerLabel.font.pointSize];
	
	self.followButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.followButton.titleLabel.font.pointSize];
	
	self.channelTitleButton.titleLabel.numberOfLines = 2;
	self.channelTitleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	self.channelTitleButton.titleLabel.font = [UIFont boldCustomFontOfSize:self.channelTitleButton.titleLabel.font.pointSize];
}

- (void)setChannel:(Channel *)channel {
	_channel = channel;
	
	NSURL *avatarURL = [NSURL URLWithString:channel.channelOwner.thumbnailURL];
	[self.avatarThumbnailButton setImageWithURL:avatarURL
									   forState:UIControlStateNormal
							   placeholderImage:[UIImage imageNamed:@"PlaceholderAvatarProfile"]
										options:SDWebImageRetryFailed];
	
	NSMutableAttributedString *channelOwnerString = [[NSMutableAttributedString alloc]
                                                     initWithString:NSLocalizedString(@"A collection of great new videos from ", nil)];

	NSString *channelOwnerName = channel.channelOwner.displayName;
	UIFont *boldFont = [UIFont boldItalicAlternateFontOfSize:self.channelOwnerLabel.font.pointSize];
	NSDictionary *attributes = @{ NSFontAttributeName : boldFont };
	
    if (channelOwnerName) {
        [channelOwnerString appendAttributedString:[[NSAttributedString alloc] initWithString:channelOwnerName attributes:attributes]];
    }
	
	self.channelOwnerLabel.attributedText = channelOwnerString;
	
	self.followButton.selected = ([[SYNActivityManager sharedInstance] isSubscribedToChannelId:channel.uniqueId]);
	
	[self.channelTitleButton setTitle:channel.title forState:UIControlStateNormal];
}

- (IBAction)avatarThumbnailPressed:(UIButton *)button {
	[self.delegate channelCellAvatarPressed:self];
}

- (IBAction)channelButtonPressed:(UIButton *)button {
	[self.delegate channelCellTitlePressed:self];
}

- (IBAction)followButtonPressed:(UIButton *)button {
	[self.delegate channelCell:self followPressed:button];
}

- (IBAction)shareButtonPressed:(UIButton *)button {
	[self.delegate channelCell:self sharePressed:button];
}

@end
