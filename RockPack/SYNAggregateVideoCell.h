//
//  SYNAggregateVideoCell.h
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAggregateCell.h"

@interface SYNAggregateVideoCell : SYNAggregateCell

@property (nonatomic, strong) IBOutlet UIButton* heartButton;
@property (nonatomic, strong) IBOutlet UIImageView* videoImageView;
@property (nonatomic, strong) IBOutlet UILabel* likesNumberLabel;

@end
