//
//  SYNCollectionVideoCell.m
//  dolly
//
//  Created by Michael Michailidis on 06/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCollectionVideoCell.h"
#import "UIFont+SYNFont.h"


@implementation SYNCollectionVideoCell


- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];
}




@end
