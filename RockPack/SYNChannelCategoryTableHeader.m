//
//  SYNChannelCategoryTableHeader.m
//  rockpack
//
//  Created by Mats Trovik on 24/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNChannelCategoryTableHeader.h"
#import "UIFont+SYNFont.h"

@implementation SYNChannelCategoryTableHeader

-(id)init
{
    self = [super init];
    if(self)
    {
        UIView* subView = [[NSBundle mainBundle] loadNibNamed: @"SYNChannelCategoryTableHeader"
                                                         owner: self
                                                       options:nil] [0];
        subView.frame = self.bounds;
        self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];
        [self addSubview:subView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}


@end
