//
//  SYNAggregateVideoItemCell.h
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNAggregateVideoItemCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UILabel* timeLabel;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

// sets the timeLabel text
@property (nonatomic, weak) NSDateComponents* timeAgoComponents;
@end
