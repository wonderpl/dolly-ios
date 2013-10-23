//
//  SYNSearchResultsVideoCell.m
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchResultsVideoCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNSearchResultsVideoCell

-(void)awakeFromNib
{
    self.titleLabel.font = [UIFont lightCustomFontOfSize:self.titleLabel.font.pointSize];
}
@end
