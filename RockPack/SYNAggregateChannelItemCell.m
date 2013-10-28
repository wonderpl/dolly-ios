//
//  SYNAggregateChannelItemCell.m
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateChannelItemCell.h"

@implementation SYNAggregateChannelItemCell

-(void)awakeFromNib
{
    
    CGPoint middlePoint = CGPointMake(self.frame.size.width * 0.5f, self.frame.size.height * 0.5);
    
    followControl = [SYNCollectionCellButtonControl buttonControl];
    followControl.title = @"follow";
    followControl.center = CGPointMake(middlePoint.x - 40.0f, middlePoint.y + 40.0f);
    [self addSubview:followControl];
    
    shareControl = [SYNCollectionCellButtonControl buttonControl];
    shareControl.center = CGPointMake(middlePoint.x + 40.0f, middlePoint.y + 40.0f);
    shareControl.title = @"share";
    [self addSubview:shareControl];
    
}

-(void)setDelegate:(id)delegate
{
    // we can remove the targets by setting the delegate to nil
    
    if(_delegate)
    {
        [followControl removeTarget:delegate
                             action:@selector(followControlPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
        
        [shareControl removeTarget:delegate
                            action:@selector(shareControlPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    _delegate = delegate;
    
    if(!_delegate)
        return;
    
    [followControl addTarget:delegate
                      action:@selector(followControlPressed:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [shareControl addTarget:delegate
                     action:@selector(shareControlPressed:)
           forControlEvents:UIControlEventTouchUpInside];
}

@end
