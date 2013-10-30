//
//  SYNAggregateChannelItemCell.m
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateChannelItemCell.h"
#import "SYNSocialControlFactory.h"

@interface SYNAggregateChannelItemCell ()

@property (strong, nonatomic) IBOutlet SYNSocialControl *followControl;
@property (strong, nonatomic) IBOutlet SYNSocialControl *shareControl;

@end

@implementation SYNAggregateChannelItemCell

- (void) awakeFromNib
{
    self.followControl.title = NSLocalizedString(@"follow", @"Label for follow button on SYNAggregateChannelItemCell");
    self.shareControl.title = NSLocalizedString(@"share", @"Label for share button on SYNAggregateChannelItemCell");
}


- (IBAction) followControlPressed: (id) sender
{
    [self.delegate followControlPressed: sender];
}


- (IBAction) shareControlPressed: (id) sender
{
    [self.delegate shareControlPressed: sender];
}


#pragma mark - Date Components

- (void) setTimeAgoComponents: (NSDateComponents *) timeAgoComponents
{
    _timeAgoComponents = timeAgoComponents;
    
    if (!_timeAgoComponents)
    {
        return;
    }
    
    NSString *finalTimeString;
    
    if (_timeAgoComponents.year)
    {
        finalTimeString = [NSString stringWithFormat: @"%i year%@ ago", _timeAgoComponents.year, _timeAgoComponents.year == 1 ? @"": @"s"];
    }
    else if (_timeAgoComponents.month)
    {
        finalTimeString = [NSString stringWithFormat: @"%i month%@ ago", _timeAgoComponents.month, _timeAgoComponents.month == 1 ? @"": @"s"];
    }
    else if (_timeAgoComponents.day)
    {
        finalTimeString = [NSString stringWithFormat: @"%i day%@ ago", _timeAgoComponents.day, _timeAgoComponents.day == 1 ? @"": @"s"];
    }
    else if (_timeAgoComponents.minute)
    {
        finalTimeString = [NSString stringWithFormat: @"%i minute%@ ago", _timeAgoComponents.minute, _timeAgoComponents.minute == 1 ? @"": @"s"];
    }
    
    self.timeLabel.text = finalTimeString;
}


@end
