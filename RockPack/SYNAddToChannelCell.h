//
//  SYNExistingChannelCell.h
//  dolly
//
//  Created by Michael Michailidis on 08/11/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYNAddToChannelCell : UICollectionViewCell
{
    UIColor* defaultTitleColor;
}

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UIView* bottomStripView;


@end
