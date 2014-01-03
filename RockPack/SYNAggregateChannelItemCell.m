//
//  SYNAggregateChannelItemCell.m
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateChannelItemCell.h"
#import "SYNSocialButton.h"
#import "UIFont+SYNFont.h"
#import "SYNGenreColorManager.h"

@interface SYNAggregateChannelItemCell ()

@property (strong, nonatomic) IBOutlet SYNSocialButton *followControl;
@property (strong, nonatomic) IBOutlet SYNSocialButton *shareControl;

@property (nonatomic, strong) IBOutlet UIView* bg;

@end

@implementation SYNAggregateChannelItemCell

- (void) awakeFromNib
{
    
    self.shareControl.title = NSLocalizedString(@"share", @"Label for follow button on SYNAggregateChannelItemCell");
    
    self.timeLabel.font = [UIFont lightCustomFontOfSize:self.timeLabel.font.pointSize];
    self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];
    self.followersLabel.font = [UIFont lightCustomFontOfSize:self.followersLabel.font.pointSize];
    self.videosLabel.font = [UIFont lightCustomFontOfSize:self.videosLabel.font.pointSize];
    
    self.bg.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.bg.layer.borderWidth = 1.0f;
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
    
    self.titleLabel.text = _channel.title;
    self.followersLabel.text = [NSString stringWithFormat: @"%lli followers", _channel.subscribersCountValue];
    self.videosLabel.text = [NSString stringWithFormat: @"%i videos", _channel.videoInstances.count];
    
    // set time ago...
    NSDateComponents *timeAgoComponents = _channel.timeAgo;
    
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
    
    self.followControl.selected = channel.subscribedByUserValue;
   
    [self.stripView setBackgroundColor:[[SYNGenreColorManager sharedInstance] colorFromID:channel.categoryId]];
}

@end
