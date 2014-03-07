//
//  SYNSearchResultsVideoCell.m
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//


#import "SYNSearchResultsVideoCell.h"
#import "SYNSocialAddButton.h"
#import "SYNSocialButton.h"
#import "SYNSocialCommentButton.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"
#import "Channel.h"
#import "ChannelOwner.h"
#import "NSString+Timecode.h"
#import "SYNVideoCellDelegate.h"
#import <UIImageView+WebCache.h>
#import <UIButton+WebCache.h>

@interface SYNSearchResultsVideoCell ()


@property (nonatomic, strong) IBOutlet SYNSocialButton *likeSocialButton;
@property (nonatomic, strong) IBOutlet SYNSocialAddButton *addSocialButton;
@property (nonatomic, strong) IBOutlet SYNSocialButton *shareSocialButton;
@property (nonatomic, strong) IBOutlet SYNSocialCommentButton *commentSocialButton;

@end

@implementation SYNSearchResultsVideoCell

- (void) awakeFromNib
{
    self.titleLabel.font = [UIFont lightCustomFontOfSize: self.titleLabel.font.pointSize];
    
    self.timeLabel.font = [UIFont lightCustomFontOfSize: self.timeLabel.font.pointSize];
    
    self.timeStampLabel.font = [UIFont lightCustomFontOfSize: self.timeStampLabel.font.pointSize];
    
    [self.likeSocialButton setTitle: NSLocalizedString(@"like", @"Label for follow button on SYNAggregateChannelItemCell")
                           andCount: 0];
    
    // no title for the add button
    self.shareSocialButton.title = NSLocalizedString(@"share", @"Label for share button on SYNAggregateChannelItemCell");
}


#pragma mark - Setting Data

- (void) setVideoInstance: (VideoInstance *) videoInstance
{
    
    
    
    _videoInstance = videoInstance;
    
    if (!_videoInstance)
        return;
    
	NSURL *thumbnailURL = [NSURL URLWithString:videoInstance.channel.channelOwner.thumbnailURL];
	[self.ownerThumbnailButton setImageWithURL:thumbnailURL
									  forState:UIControlStateNormal
							  placeholderImage:[UIImage imageNamed:@"PlaceholderAvatarProfile"]
									   options:SDWebImageRetryFailed];
	
	[self.ownerNameButton setTitle:videoInstance.channel.channelOwner.displayName
						  forState:UIControlStateNormal];
    [self.channelNameButton setTitle:videoInstance.channel.title forState:UIControlStateNormal];
    [self.commentSocialButton setTitle:[NSString stringWithFormat:@"%d", videoInstance.commentCountValue] forState:UIControlStateNormal];
    [self.likeSocialButton setTitle: NSLocalizedString(@"like", @"Label for follow button on SYNAggregateChannelItemCell")
                           andCount: videoInstance.video.starCountValue];
    // == timestamp == //
    
	self.timeStampLabel.text = [NSString timecodeStringFromSeconds:videoInstance.video.durationValue];
	CGFloat rightOffset = (CGRectGetWidth(self.frame) - CGRectGetMaxX(self.timeStampLabel.frame));
	[self.timeStampLabel sizeToFit];
	self.timeStampLabel.frame = CGRectMake(CGRectGetWidth(self.frame) - (rightOffset + CGRectGetWidth(self.timeStampLabel.frame)),
										   CGRectGetMinY(self.timeStampLabel.frame),
										   CGRectGetWidth(self.timeStampLabel.frame),
										   CGRectGetHeight(self.timeStampLabel.frame));
    
    // == date components == //
    
    NSDateComponents *timeAgoComponents = videoInstance.timeAgo;
    
    // NSLog(@"%@ -> %@", videoInstance.title, videoInstance.dateAdded);
    
    self.timeLabel.hidden = NO;
    
    if (timeAgoComponents.year)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"Added %i year%@ ago", timeAgoComponents.year, timeAgoComponents.year == 1 ? @"": @"s"];
    }
    else if (timeAgoComponents.month)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"Added %i month%@ ago", timeAgoComponents.month, timeAgoComponents.month == 1 ? @"": @"s"];
    }
    else if (timeAgoComponents.day)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"Added %i day%@ ago", timeAgoComponents.day, timeAgoComponents.day == 1 ? @"": @"s"];
    }
    else if (timeAgoComponents.hour)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"Added %i hour%@ ago", timeAgoComponents.hour,
                               timeAgoComponents.hour == 1 ? @"": @"s"];
    }
    else if (timeAgoComponents.minute)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"Added %i minute%@ ago", timeAgoComponents.minute, timeAgoComponents.minute == 1 ? @"": @"s"];
    }
    else
    {
        self.timeLabel.hidden = YES;
    }
    
    // == Methods like sizeWithFont failed so first shrink and then get the correct height == //
    CGRect titleLabelFrame = self.titleLabel.frame;
    self.titleLabel.text = _videoInstance.title;
    [self.titleLabel sizeToFit];
    titleLabelFrame.size.height = self.titleLabel.frame.size.height;
    self.titleLabel.frame = titleLabelFrame;
    
    
    // == Set Social Buttons == //
    self.likeSocialButton.dataItemLinked = _videoInstance;
    self.addSocialButton.dataItemLinked = _videoInstance;
    self.shareSocialButton.dataItemLinked = _videoInstance;
    self.commentSocialButton.dataItemLinked = _videoInstance;
    
    [self.imageView setImageWithURL:[NSURL URLWithString: _videoInstance.thumbnailURL]
				   placeholderImage:[UIImage imageNamed: @"PlaceholderChannelSmall.png"]
							options:SDWebImageRetryFailed];
}

- (IBAction)channelButtonTapped:(UIButton *)button {
	[self.delegate channelButtonPressedForCell:self];
}

- (IBAction)profileButtonTapped:(UIButton *)button {
	[self.delegate profileButtonPressedForCell:self];
}

- (IBAction) likeControlPressed: (id) sender
{
    [self.delegate likeControlPressed: sender];
}


- (IBAction) addControlPressed: (id) sender
{
    [self.delegate addControlPressed: sender];
}


- (IBAction) shareControlPressed: (id) sender
{
    [self.delegate shareControlPressed: sender];
}
- (IBAction)commentControlPressed:(id)sender {

    [self.delegate commentControlPressed: sender];

}


@end
