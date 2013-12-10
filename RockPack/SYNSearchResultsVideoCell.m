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
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"
#import <UIImageView+WebCache.h>

@interface SYNSearchResultsVideoCell ()

@property (strong, nonatomic) IBOutlet SYNSocialButton *likeSocialButton;
@property (strong, nonatomic) IBOutlet SYNSocialAddButton *addSocialButton;
@property (strong, nonatomic) IBOutlet SYNSocialButton *shareSocialButton;

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
    
    self.timeStampLabel.text = [NSString stringWithString:timeStampString];
    
    
    // == date components == //
    
    NSDateComponents *timeAgoComponents = videoInstance.timeAgo;
    
    // NSLog(@"%@ -> %@", videoInstance.title, videoInstance.dateAdded);
    
    self.timeLabel.hidden = NO;
    
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
    
    
    [self.iconImageView setImageWithURL: [NSURL URLWithString: _videoInstance.thumbnailURL]
                       placeholderImage: [UIImage imageNamed: @"PlaceholderChannelSmall.png"]
                                options: SDWebImageRetryFailed];
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

@end
