//
//  SYNAggregateChannelItemCell.h
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SYNCollectionCellButtonControl.h"

@interface SYNAggregateChannelItemCell : UICollectionViewCell
{
    SYNCollectionCellButtonControl* followControl;
    SYNCollectionCellButtonControl* shareControl;
}

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* followersLabel;
@property (nonatomic, strong) IBOutlet UILabel* videosLabel;

@property (nonatomic, weak) id delegate;

@end
