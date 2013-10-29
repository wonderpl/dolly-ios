//
//  SYNAggregateChannelItemCell.h
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SYNSocialControl.h"

@interface SYNAggregateChannelItemCell : UICollectionViewCell
{
    SYNSocialControl* followControl;
    SYNSocialControl* shareControl;
    NSDateComponents* _timeAgoComponents;
}
@property (nonatomic, strong) IBOutlet UILabel* timeLabel;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* followersLabel;
@property (nonatomic, strong) IBOutlet UILabel* videosLabel;

@property (nonatomic, strong) IBOutlet UIView* stripView;

// sets the timeLabel text
@property (nonatomic, weak) NSDateComponents* timeAgoComponents;
@property (nonatomic, weak) id delegate;

@end
