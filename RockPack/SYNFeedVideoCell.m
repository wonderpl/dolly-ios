//
//  SYNFeedVideoCell.m
//  dolly
//
//  Created by Sherman Lo on 15/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNFeedVideoCell.h"
#import "UIFont+SYNFont.h"
#import "VideoInstance.h"
#import "Video.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "NSString+Timecode.h"
#import "SYNVideoActionsBar.h"
#import <UIButton+WebCache.h>

@interface SYNFeedVideoCell () <SYNVideoActionsBarDelegate>

@property (nonatomic, strong) IBOutlet UIButton *avatarThumbnailButton;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) IBOutlet UILabel *labelLabel;
@property (nonatomic, strong) IBOutlet UILabel *curatedByLabel;

@property (nonatomic, strong) IBOutlet UILabel *durationLabel;

@property (nonatomic, strong) IBOutlet UIButton *videoThumbnailButton;

@property (nonatomic, strong) IBOutlet UIView *videoActionsContainer;

@property (nonatomic, strong) SYNVideoActionsBar *actionsBar;

@end

@implementation SYNFeedVideoCell

- (void)awakeFromNib {
	[super awakeFromNib];
	
	self.labelLabel.font = [UIFont italicAlternateFontOfSize:self.labelLabel.font.pointSize];
	self.curatedByLabel.font = [UIFont italicAlternateFontOfSize:self.curatedByLabel.font.pointSize];
	
	self.durationLabel.font = [UIFont regularCustomFontOfSize:self.durationLabel.font.pointSize];
	
	self.titleLabel.font = [UIFont boldCustomFontOfSize:self.titleLabel.font.pointSize];
	
	[self.videoActionsContainer addSubview:self.actionsBar];
}

- (UIImageView *)imageView {
	return self.videoThumbnailButton.imageView;
}

- (void)setVideoInstance:(VideoInstance *)videoInstance {
	_videoInstance = videoInstance;
	
	BOOL hasLabel = ([videoInstance.label length]);
	if (hasLabel) {
		self.labelLabel.text = videoInstance.label;
		self.curatedByLabel.text = nil;
	} else {
		self.labelLabel.text = nil;
		NSMutableAttributedString *curatedByString = [[NSMutableAttributedString alloc] initWithString:@"Added by "];
		
		NSString *channelOwnerName = videoInstance.channel.channelOwner.displayName;
		NSDictionary *attributes = @{ NSFontAttributeName : [UIFont boldItalicAlternateFontOfSize:self.labelLabel.font.pointSize] };
		
		[curatedByString appendAttributedString:[[NSAttributedString alloc] initWithString:channelOwnerName attributes:attributes ]];
		
		self.curatedByLabel.attributedText = curatedByString;
	}
	self.durationLabel.text = [NSString friendlyLengthFromTimeInterval:videoInstance.video.durationValue];
	
	self.titleLabel.text = videoInstance.title;
	
	NSURL *avatarURL = [NSURL URLWithString:self.videoInstance.originator.thumbnailURL];
	[self.avatarThumbnailButton setImageWithURL:avatarURL forState:UIControlStateNormal];
	
	NSURL *thumbnailURL = [NSURL URLWithString:videoInstance.thumbnailURL];
	[self.videoThumbnailButton setImageWithURL:thumbnailURL forState:UIControlStateNormal];
}

- (SYNVideoActionsBar *)actionsBar {
	if (!_actionsBar) {
		SYNVideoActionsBar *bar = [SYNVideoActionsBar bar];
		bar.delegate = self;
		
		self.actionsBar = bar;
	}
	return _actionsBar;
}

- (void)videoActionsBar:(SYNVideoActionsBar *)bar favouritesButtonPressed:(UIButton *)button {
	[self.delegate videoCell:self favouritePressed:button];
}

- (void)videoActionsBar:(SYNVideoActionsBar *)bar addToChannelButtonPressed:(UIButton *)button {
	[self.delegate videoCell:self addToChannelPressed:button];
}

- (void)videoActionsBar:(SYNVideoActionsBar *)bar shareButtonPressed:(UIButton *)button {
	[self.delegate videoCell:self sharePressed:button];
}

- (IBAction)avatarThumbnailPressed:(UIButton *)button {
	[self.delegate videoCellAvatarPressed:self];
}

- (IBAction)videoThumbnailPressed:(UIButton *)button {
	[self.delegate videoCellThumbnailPressed:self];
}

@end
