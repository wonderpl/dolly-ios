//
//  SYNAggregateVideoItemCell.m
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateVideoItemCell.h"
#import "SYNSocialControlFactory.h"

@implementation SYNAggregateVideoItemCell

-(void)awakeFromNib
{
    // == Create Buttons == //
    
    CGPoint middlePoint = CGPointMake(self.bottomControlsView.frame.size.width * 0.5f, self.bottomControlsView.frame.size.height * 0.5);
    
    likeControl = [[SYNSocialControlFactory defaultFactory] createControlForType: SocialControlTypeDefault
                                                                        forTitle: @"like"
                                                                     andPosition: CGPointMake(middlePoint.x - 60.0f, middlePoint.y)];
    
    [self.bottomControlsView addSubview: likeControl];
    
    addControl = [[SYNSocialControlFactory defaultFactory] createControlForType: SocialControlTypeAdd
                                                                       forTitle: nil
                                                                    andPosition: CGPointMake(middlePoint.x, middlePoint.y)];
    
    [self.bottomControlsView addSubview: addControl];
    
    shareControl = [[SYNSocialControlFactory defaultFactory] createControlForType: SocialControlTypeDefault
                                                                         forTitle: @"share"
                                                                      andPosition: CGPointMake(middlePoint.x + 60.0f, middlePoint.y)];
    
    [self.bottomControlsView addSubview:shareControl];
}

- (void) setDelegate: (id<SYNSocialActionsDelegate>) delegate
{
    if(_delegate)
    {
        [likeControl removeTarget: _delegate
                           action: @selector(likeControlPressed:)
                 forControlEvents: UIControlEventTouchUpInside];
        
        [addControl removeTarget: _delegate
                          action: @selector(addControlPressed:)
                forControlEvents: UIControlEventTouchUpInside];
        
        [shareControl removeTarget: _delegate
                            action: @selector(shareControlPressed:)
                  forControlEvents: UIControlEventTouchUpInside];
    }
    
    _delegate = delegate;
    
    if(!_delegate)
        return;
    
    [likeControl addTarget: _delegate
                    action: @selector(likeControlPressed:)
          forControlEvents: UIControlEventTouchUpInside];
    
    [addControl addTarget: _delegate
                   action: @selector(addControlPressed:)
         forControlEvents: UIControlEventTouchUpInside];
    
    [shareControl addTarget: _delegate
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
