//
//  SYNSearchResultsUserCell.m
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchResultsUserCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNSearchResultsUserCell

-(void) awakeFromNib
{
    
    self.userNameLabel.font = [UIFont lightCustomFontOfSize:self.userNameLabel.font.pointSize];
    
    
    
}

-(void)setDelegate:(id<SYNSocialActionsDelegate>)delegate
{
    [super setDelegate:delegate];
    
    
}

@end
