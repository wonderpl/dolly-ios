//
//  SYNChannelSearchCell.m
//  dolly
//
//  Created by Cong on 31/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNChannelSearchCell.h"
#import "UIColor+SYNColor.h"

@implementation SYNChannelSearchCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)awakeFromNib
{
    [super awakeFromNib];
    
    UITextField *txfSearchField = [self.searchBar valueForKey:@"_searchField"];
    if(txfSearchField)
        txfSearchField.backgroundColor = [UIColor dollySearchBarColor];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
