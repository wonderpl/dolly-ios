//
//  SYNReportConcernTableCell.m
//  rockpack
//
//  Created by Nick Banks on 14/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNReportConcernTableCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNReportConcernTableCell


- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont lightCustomFontOfSize: self.titleLabel.font.pointSize];
    
    [self.highlightedViewiOS7 removeFromSuperview];
}



@end


