//
//  SYNCategoryCollectionViewCell.m
//  rockpack
//
//  Created by Michael Michailidis on 16/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCategoryCollectionViewCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNCategoryCollectionViewCell

- (void) awakeFromNib
{
    self.label.font = [UIFont lightCustomFontOfSize: self.label.font.pointSize];
}

@end
