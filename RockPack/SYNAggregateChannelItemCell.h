//
//  SYNAggregateChannelItemCell.h
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "Channel.h"
#import "SYNSocialActionsDelegate.h"
@import UIKit;

@interface SYNAggregateChannelItemCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel* timeLabel;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* followersLabel;
@property (nonatomic, strong) IBOutlet UILabel* videosLabel;
@property (nonatomic, strong) IBOutlet UIView* stripView;

// data related
@property (nonatomic, weak) id<SYNSocialActionsDelegate> delegate;
@property (nonatomic, weak) Channel* channel;

@end
