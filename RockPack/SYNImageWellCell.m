//
//  SYNImageWellCell.m
//  rockpack
//
//  Created by Nick Banks on 19/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNImageWellCell.h"

@implementation SYNImageWellCell

- (id) initWithFrame: (CGRect) frame
{
    if ((self = [super initWithFrame: frame]))
    {
        // Initialization code
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed: @"SYNImageWellCell"
                                                              owner: self
                                                            options: nil];
        
        if ([arrayOfViews count] < 1)
        {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex: 0] isKindOfClass: [UICollectionViewCell class]])
        {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex: 0];
    }
    
    return self;
}

@end
