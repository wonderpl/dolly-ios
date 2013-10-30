//
//  SYNAggregateVideoItemCell.h
//  dolly
//
//  Created by Michael Michailidis on 18/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNSocialControl.h"
#import "SYNSocialActionsDelegate.h"

@interface SYNAggregateVideoItemCell : UICollectionViewCell
{
    SYNSocialControl* likeControl;
    SYNSocialControl* addControl;
    SYNSocialControl* shareControl;
}
@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UILabel* timeLabel;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;


@property (nonatomic, strong) IBOutlet UIView* bottomControlsView;

// sets the timeLabel text
@property (nonatomic, weak) NSDateComponents* timeAgoComponents;

@property (nonatomic, weak) id<SYNSocialActionsDelegate> delegate;
@end
