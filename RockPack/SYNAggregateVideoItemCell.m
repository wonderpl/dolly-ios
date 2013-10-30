//
//  SYNAggregateVideoItemCell.m
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateVideoItemCell.h"
#import "SYNSocialControlFactory.h"
#import "SYNSocialLikeControl.h"
#import "SYNSocialAddControl.h"

@interface SYNAggregateVideoItemCell ()

@property (strong, nonatomic) IBOutlet SYNSocialLikeControl *likeControl;
@property (strong, nonatomic) IBOutlet SYNSocialAddControl *addControl;
@property (strong, nonatomic) IBOutlet SYNSocialControl *shareControl;

@end

@implementation SYNAggregateVideoItemCell

-(void)awakeFromNib
{
    self.likeControl.title = NSLocalizedString(@"follow", @"Label for follow button on SYNAggregateChannelItemCell");
    // no title for the add button
    self.shareControl.title = NSLocalizedString(@"share", @"Label for share button on SYNAggregateChannelItemCell");
}

- (void) setDelegate: (id<SYNSocialActionsDelegate>) delegate
{
    if(_delegate)
    {
        [self.likeControl removeTarget: _delegate
                           action: @selector(likeControlPressed:)
                 forControlEvents: UIControlEventTouchUpInside];
        
        [self.addControl removeTarget: _delegate
                          action: @selector(addControlPressed:)
                forControlEvents: UIControlEventTouchUpInside];
        
        [self.shareControl removeTarget: _delegate
                            action: @selector(shareControlPressed:)
                  forControlEvents: UIControlEventTouchUpInside];
    }
    
    _delegate = delegate;
    
    if(!_delegate)
        return;
    
    [self.likeControl addTarget: _delegate
                    action: @selector(likeControlPressed:)
          forControlEvents: UIControlEventTouchUpInside];
    
    [self.addControl addTarget: _delegate
                   action: @selector(addControlPressed:)
         forControlEvents: UIControlEventTouchUpInside];
    
    [self.shareControl addTarget: _delegate
                     action: @selector(shareControlPressed:)
           forControlEvents: UIControlEventTouchUpInside];
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
