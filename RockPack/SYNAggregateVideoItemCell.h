//
//  SYNAggregateVideoItemCell.h
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSocialActionsDelegate.h"
#import "VideoInstance.h"
#import <UIKit/UIKit.h>

@interface SYNAggregateVideoItemCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UILabel* timeLabel;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

// data related
@property (nonatomic, weak) id<SYNSocialActionsDelegate> delegate;
@property (nonatomic, weak) VideoInstance* videoInstance;

@end
