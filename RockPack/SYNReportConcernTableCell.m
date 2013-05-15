//
//  SYNReportConcernTableCell.m
//  rockpack
//
//  Created by Nick Banks on 14/05/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNReportConcernTableCell.h"
#import "UIFont+SYNFont.h"

@implementation SYNReportConcernTableCell


- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont rockpackFontOfSize: self.titleLabel.font.pointSize];
}



@end


