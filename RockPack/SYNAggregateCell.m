//
//  SYNAggregateCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateCell.h"

@implementation SYNAggregateCell

-(void)awakeFromNib
{
    self.messageLabel.font = [UIFont rockpackFontOfSize:self.messageLabel.font.pointSize];
}

-(void)setCoverImageWithString:(NSString*)imageString
{
    // to be implemented in subclass
}


-(void)setCoverImageWithArray:(NSArray*)imageArray
{
    // to be implemented in subclass
}


-(void)setTitleMessageWithDictionary:(NSDictionary*)messageDictionary
{
    // to be implemented in subclass
}

-(void)setViewControllerDelegate:(UIViewController *)viewControllerDelegate
{
    _viewControllerDelegate = viewControllerDelegate;
    
    
    [self.coverButton addTarget: self.viewControllerDelegate
                         action: @selector(pressedAggregateCellCoverButton:)
               forControlEvents: UIControlEventTouchUpInside];
}

@end
