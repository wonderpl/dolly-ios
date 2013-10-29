//
//  SYNAggregateChannelItemCell.m
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateChannelItemCell.h"
#import "SYNSocialControlFactory.h"

@implementation SYNAggregateChannelItemCell

- (void) awakeFromNib
{
    CGPoint middlePoint = CGPointMake(self.frame.size.width * 0.5f, self.frame.size.height * 0.5);
    
    
    followControl = [[SYNSocialControlFactory defaultFactory] createControlForType: SocialControlTypeDefault
                                                                          forTitle: @"follow"
                                                                       andPosition: CGPointMake(middlePoint.x - 40.0f, self.stripView.frame.origin.y)];
    
    [self addSubview: followControl];
    
    shareControl = [[SYNSocialControlFactory defaultFactory] createControlForType: SocialControlTypeDefault
                                                                         forTitle: @"share"
                                                                      andPosition: CGPointMake(middlePoint.x + 40.0f, self.stripView.frame.origin.y)];
    
    [self addSubview: shareControl];
}


- (void) setDelegate: (id) delegate
{
    // we can remove the targets by setting the delegate to nil
    
    if (_delegate)
    {
        [followControl removeTarget: delegate
                             action: @selector(followControlPressed:)
                   forControlEvents: UIControlEventTouchUpInside];
        
        [shareControl removeTarget: delegate
                            action: @selector(shareControlPressed:)
                  forControlEvents: UIControlEventTouchUpInside];
    }
    
    _delegate = delegate;
    
    if (!_delegate)
    {
        return;
    }
    
    [followControl addTarget: delegate
                      action: @selector(followControlPressed:)
            forControlEvents: UIControlEventTouchUpInside];
    
    [shareControl addTarget: delegate
                     action: @selector(shareControlPressed:)
           forControlEvents: UIControlEventTouchUpInside];
}

#pragma mark - Date Components

-(NSDateComponents*)timeAgoComponents
{
    return _timeAgoComponents;
}
-(void)setTimeAgoComponents:(NSDateComponents *)timeAgoComponents
{
    _timeAgoComponents = timeAgoComponents;
    if(!_timeAgoComponents)
        return;
    
    NSString* finalTimeString;
    if(_timeAgoComponents.year)
        finalTimeString = [NSString stringWithFormat:@"%i year%@ ago", _timeAgoComponents.year, _timeAgoComponents.year == 1 ? @"" : @"s"];
    else if(_timeAgoComponents.month)
        finalTimeString = [NSString stringWithFormat:@"%i month%@ ago", _timeAgoComponents.month, _timeAgoComponents.month == 1 ? @"" : @"s"];
    else if(_timeAgoComponents.day)
        finalTimeString = [NSString stringWithFormat:@"%i day%@ ago", _timeAgoComponents.day, _timeAgoComponents.day == 1 ? @"" : @"s"];
    else if(_timeAgoComponents.minute)
        finalTimeString = [NSString stringWithFormat:@"%i minute%@ ago", _timeAgoComponents.minute, _timeAgoComponents.minute == 1 ? @"" : @"s"];
    
    self.timeLabel.text = finalTimeString;
    
}


@end
