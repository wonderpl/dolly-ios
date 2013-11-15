//
//  SYNCategoryCollectionViewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 16/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNDiscoverCategoriesCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNDiscoverCategoriesCell

- (void) awakeFromNib
{
    self.label.font = [UIFont lightCustomFontOfSize: self.label.font.pointSize];
    genreColor = [UIColor clearColor]; // set a random default to avoid crashes
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if(selected)
    {
        [super setBackgroundColor: [UIColor blackColor]];
    }
    else
    {
        [super setBackgroundColor: genreColor];
    }
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    genreColor = backgroundColor;
    [super setBackgroundColor: backgroundColor];
}


@end
