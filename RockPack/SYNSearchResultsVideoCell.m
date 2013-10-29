//
//  SYNSearchResultsVideoCell.m
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchResultsVideoCell.h"
#import "SYNSocialControlFactory.h"
#import "UIFont+SYNFont.h"

@implementation SYNSearchResultsVideoCell

-(void)awakeFromNib
{
    self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];
    
    
    // == Create Buttons == //
    
    CGPoint middlePoint = CGPointMake(self.bottomControlsView.frame.size.width * 0.5f, self.bottomControlsView.frame.size.height * 0.5);
    
    likeControl = [[SYNSocialControlFactory defaultFactory] createControlForType: SocialControlTypeDefault
                                                                        forTitle: @"like"
                                                                     andPosition: CGPointMake(middlePoint.x - 60.0f, middlePoint.y)];
    
    [self.bottomControlsView addSubview:likeControl];
    
    addControl = [[SYNSocialControlFactory defaultFactory] createControlForType: SocialControlTypeAdd
                                                                       forTitle: nil
                                                                    andPosition: CGPointMake(middlePoint.x, middlePoint.y)];
    
    [self.bottomControlsView addSubview:addControl];
    
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
    
    [super setDelegate: delegate];
    
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

@end
