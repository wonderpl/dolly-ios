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
    
    // == timestamp == //
    
    NSInteger durationSeconds = videoInstance.video.durationValue;
    
    NSMutableString* timeStampString = [[NSMutableString alloc] init];
    NSInteger minutes = (NSInteger)(durationSeconds / 60.0f);
    
    if(minutes < 10)
        [timeStampString appendString:@"0"];
    
    [timeStampString appendFormat:@"%i", minutes];
    
    [timeStampString appendString:@":"];
    
    NSInteger seconds = durationSeconds % 60;
    
    if(seconds < 10)
        [timeStampString appendString:@"0"];
    
    [timeStampString appendFormat:@"%i", seconds];
    
    self.timestampLabel.text = [NSString stringWithString:timeStampString];
    
    
    // == date components == //
    
    NSDateComponents *timeAgoComponents = videoInstance.timeAgo;
    
    if (timeAgoComponents.year)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"Uploaded %i year%@ ago", timeAgoComponents.year, timeAgoComponents.year == 1 ? @"": @"s"];
    }
    else if (timeAgoComponents.month)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"Uploaded %i month%@ ago", timeAgoComponents.month, timeAgoComponents.month == 1 ? @"": @"s"];
    }
    else if (timeAgoComponents.day)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"Uploaded %i day%@ ago", timeAgoComponents.day, timeAgoComponents.day == 1 ? @"": @"s"];
    }
    else if (timeAgoComponents.minute)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"Uploaded %i minute%@ ago", timeAgoComponents.minute, timeAgoComponents.minute == 1 ? @"": @"s"];
    }
    
    
    
    // == buttons == //
    
    self.likeControl.selected = videoInstance.starredByUserValue;
    
    [self.likeControl setTitle: NSLocalizedString(@"like", @"Label for follow button on SYNAggregateVideoItemCell")
                      andCount: videoInstance.video.starCountValue];
    
    NSString *titleString = [NSString stringWithFormat: @"%@\n\n", videoInstance.title];
    self.titleLabel.text = titleString;
}


@end
