//
//  SYNSearchResultsVideoCell.h
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNSocialControl.h"

@interface SYNSearchResultsVideoCell : UICollectionViewCell
{
    SYNSocialControl* likeControl;
    SYNSocialControl* addControl;
    SYNSocialControl* shareControl;
}

@property (nonatomic, strong) IBOutlet UIImageView* overlayImageView;
@property (nonatomic, strong) IBOutlet UIImageView* iconImageView;

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UIView* bottomControlsView;

@end
