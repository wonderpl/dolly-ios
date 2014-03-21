//
//  SYNAggregateChannelItemCell.m
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateChannelItemCell.h"
#import "SYNSocialButton.h"
#import "SYNSocialFollowButton.h"
#import "UIFont+SYNFont.h"
#import "SYNGenreManager.h"
#import "SYNActivityManager.h"
#import "SYNAbstractViewController.h"
@interface SYNAggregateChannelItemCell ()

@property (strong, nonatomic) IBOutlet SYNSocialButton *followControl;
@property (strong, nonatomic) IBOutlet SYNSocialButton *shareControl;
@property (strong, nonatomic) IBOutlet UIButton *channelButton;

@property (nonatomic, strong) IBOutlet UIView* bg;

@end

@implementation SYNAggregateChannelItemCell

- (void) awakeFromNib
{
    
    self.shareControl.title = NSLocalizedString(@"share", @"Label for follow button on SYNAggregateChannelItemCell");
    
    self.timeLabel.font = [UIFont lightCustomFontOfSize:self.timeLabel.font.pointSize];
    self.channelButton.titleLabel.font = [UIFont lightCustomFontOfSize:self.channelButton.titleLabel.font.pointSize];
    self.followersLabel.font = [UIFont lightCustomFontOfSize:self.followersLabel.font.pointSize];
    self.videosLabel.font = [UIFont lightCustomFontOfSize:self.videosLabel.font.pointSize];
    
    self.bg.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.bg.layer.borderWidth = 1.0f;
}

- (IBAction)channelControlPressed:(id)sender {
    [(SYNAbstractViewController *)self.delegate viewChannelDetails:self.channel withAnimation:YES];
}

- (IBAction) followControlPressed: (id) sender
{
    [self.delegate followControlPressed: sender];
}


- (IBAction) shareControlPressed: (id) sender
{
    [self.delegate shareControlPressed: sender];
}


#pragma mark - Data Related

- (void) setChannel: (Channel *) channel
{
    _channel = channel;
    
    self.shareControl.dataItemLinked = _channel;
    self.followControl.dataItemLinked = _channel;
    
    if (!_channel)
    {
        return;
    }
    
    [self.channelButton setTitle:[_channel.title uppercaseString] forState:UIControlStateNormal];
    
    if (self.channel.subscribersCountValue == 1)
    {
        self.followersLabel.text = [NSString stringWithFormat: @"%lli follower", _channel.subscribersCountValue];
    }
    else
    {
        self.followersLabel.text = [NSString stringWithFormat: @"%lli followers", _channel.subscribersCountValue];
    }
    
    
    if (self.channel.totalVideosValueValue == 1)
    {
        self.videosLabel.text = [NSString stringWithFormat: @"%lli video", _channel.totalVideosValueValue];
    }
    else
    {
        self.videosLabel.text = [NSString stringWithFormat: @"%lli videos", _channel.totalVideosValueValue];
    }

    
    // set time ago...
    NSDateComponents *timeAgoComponents = _channel.timeAgo;
    
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
    channel.subscribedByUserValue = [SYNActivityManager.sharedInstance isSubscribedToChannelId:channel.uniqueId];

    self.followControl.selected = channel.subscribedByUserValue;
   
    [self.stripView setBackgroundColor:[[SYNGenreManager sharedManager] colorForGenreWithId:channel.categoryId]];
    
    [self.followControl setTitle:@"follow" forState:UIControlStateNormal];
    [self.followControl setTitle:@"unfollow" forState:UIControlStateSelected];
    
}

@end
