//
//  SYNAggregateChannelItemCell.m
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateChannelItemCell.h"
#import "SYNSocialButton.h"

@interface SYNAggregateChannelItemCell ()

@property (strong, nonatomic) IBOutlet SYNSocialButton *followControl;
@property (strong, nonatomic) IBOutlet SYNSocialButton *shareControl;

@property (nonatomic, strong) IBOutlet UIView* bg;

@end

@implementation SYNAggregateChannelItemCell

- (void) awakeFromNib
{
    [self.followControl setTitle: NSLocalizedString(@"follow", @"Label for follow button on SYNAggregateChannelItemCell")
                        andCount: 666];
    
    self.shareControl.title = NSLocalizedString(@"share", @"Label for follow button on SYNAggregateChannelItemCell");
    
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
        self.timeLabel.text = [NSString stringWithFormat: @"%i year%@ ago", timeAgoComponents.year, timeAgoComponents.year == 1 ? @"": @"s"];
    }
    else if (timeAgoComponents.month)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"%i month%@ ago", timeAgoComponents.month, timeAgoComponents.month == 1 ? @"": @"s"];
    }
    else if (timeAgoComponents.day)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"%i day%@ ago", timeAgoComponents.day, timeAgoComponents.day == 1 ? @"": @"s"];
    }
    else if (timeAgoComponents.minute)
    {
        self.timeLabel.text = [NSString stringWithFormat: @"%i minute%@ ago", timeAgoComponents.minute, timeAgoComponents.minute == 1 ? @"": @"s"];
    }
}

@end
