//
//  SYNSearchResultsCell.m
//  dolly
//
//  Created by Michael Michailidis on 28/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchResultsCell.h"

@implementation SYNSearchResultsCell


-(void)awakeFromNib
{
    
}

-(void)setDelegate:(id<SYNSocialActionsDelegate>)delegate
{
    _delegate = delegate;
    
    // implement the rest in subclass
}


@end
