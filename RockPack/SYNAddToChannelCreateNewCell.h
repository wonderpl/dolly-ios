//
//  SYNChannelCreateNewCell.h
//  rockpack
//
//  Created by Michael Michailidis on 22/04/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

@interface SYNAddToChannelCreateNewCell : UICollectionViewCell
{
    UIView* separatorTop;
    UIView* separatorBottom;
}

@property (strong, nonatomic) IBOutlet UIButton *createNewButton;
@property (strong, nonatomic) IBOutlet UITextView* descriptionTextView;

@end
