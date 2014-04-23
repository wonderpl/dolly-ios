//
//  SYNAggregateVideoItemCell.m
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateVideoItemCell.h"
#import "SYNSocialAddButton.h"
#import "SYNSocialButton.h"
#import "SYNSocialCommentButton.h"
#import <UIImageView+WebCache.h>
#import "Video.h"
#import "UIFont+SYNFont.h"
#import "VideoInstance.h"
#import "NSString+Timecode.h"


@interface SYNAggregateVideoItemCell ()

@property (strong, nonatomic) IBOutlet SYNSocialButton *likeControl;
@property (strong, nonatomic) IBOutlet SYNSocialAddButton *addControl;
@property (strong, nonatomic) IBOutlet SYNSocialCommentButton *commentControl;
@property (strong, nonatomic) IBOutlet SYNSocialButton *shareControl;

@end


@implementation SYNAggregateVideoItemCell

- (void) awakeFromNib
{
    [self.likeControl setTitle: NSLocalizedString(@"like", @"Label for follow button on SYNAggregateVideoItemCell")
                      andCount: 0];

    self.shareControl.title = NSLocalizedString(@"share", @"Label for share button on SYNAggregateVideoItemCell");
    
    self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];
    self.timeLabel.font = [UIFont lightCustomFontOfSize:self.timeLabel.font.pointSize];
    
    self.timestampLabel.font = [UIFont lightCustomFontOfSize:self.timestampLabel.font.pointSize];
}

#pragma mark - Delegate Methods

- (IBAction) likeControlPressed: (id) sender
{
    
    [self.delegate likeControlPressed: sender];
}


- (IBAction) addControlPressed: (id) sender
{
    [self.delegate addControlPressed: sender];
}

- (IBAction) commentControlPressed: (id) sender
{
    [self.delegate commentControlPressed: sender];
}

- (IBAction) shareControlPressed: (id) sender
{
    [self.delegate shareControlPressed: sender];
}

#pragma mark - Setting Data Item

- (void) setVideoInstance: (VideoInstance *) videoInstance
{
    _videoInstance = videoInstance;
    
    self.shareControl.dataItemLinked = _videoInstance;
    self.addControl.dataItemLinked = _videoInstance;
    self.likeControl.dataItemLinked = _videoInstance;
    self.commentControl.dataItemLinked = _videoInstance;
    
    if (!_videoInstance)
        return;
    
    [self.imageView setImageWithURL: [NSURL URLWithString: videoInstance.thumbnailURL]     
                   placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                            options: SDWebImageRetryFailed];
    
    // == comment count == //
    
    self.commentControl.count = videoInstance.commentCountValue;
    
    // == timestamp == //
    
    self.timestampLabel.text = [NSString timecodeStringFromSeconds:videoInstance.video.durationValue];
	CGFloat rightOffset = (CGRectGetWidth(self.frame) - CGRectGetMaxX(self.timestampLabel.frame));
	[self.timestampLabel sizeToFit];
	self.timestampLabel.frame = CGRectMake(CGRectGetWidth(self.frame) - (rightOffset + CGRectGetWidth(self.timestampLabel.frame)),
										   CGRectGetMinY(self.timestampLabel.frame),
										   CGRectGetWidth(self.timestampLabel.frame),
										   CGRectGetHeight(self.timestampLabel.frame));
    
    // == date components == //
    
    NSDateComponents *timeAgoComponents = videoInstance.timeAgo;
    
    if (timeAgoComponents.year)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"%@ year%@ ago", @(timeAgoComponents.year), timeAgoComponents.year == 1 ? @"": @"s"];
    }
    else if (timeAgoComponents.month)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"%@ month%@ ago", @(timeAgoComponents.month), timeAgoComponents.month == 1 ? @"": @"s"];
    }
    else if (timeAgoComponents.day)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"%@ day%@ ago", @(timeAgoComponents.day), timeAgoComponents.day == 1 ? @"": @"s"];
    }
    else if (timeAgoComponents.hour)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"%@ hour%@ ago", @(timeAgoComponents.hour),
                               timeAgoComponents.hour == 1 ? @"": @"s"];
    }
    else if (timeAgoComponents.minute)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"%@ minute%@ ago", @(timeAgoComponents.minute), timeAgoComponents.minute == 1 ? @"": @"s"];
    }
    
    
    
    // == buttons == //
    
    self.likeControl.selected = videoInstance.starredByUserValue;
    
    [self.commentControl setTitle:[NSString stringWithFormat:@"%d", videoInstance.commentCountValue] forState:UIControlStateNormal];
    
    NSString *titleString = [NSString stringWithFormat: @"%@\n\n", videoInstance.title];
    self.titleLabel.text = titleString;
}


@end
