//
//  SYNAggregateChannelCell.h
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateCell.h"

@interface SYNAggregateChannelCell : SYNAggregateCell {
    UIView* buttonContainerView;
}
-(NSInteger)indexForButtonPressed:(UIButton*)button;
@end
