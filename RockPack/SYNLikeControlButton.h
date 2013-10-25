//
//  SYNLikeControlButton.h
//  dolly
//
//  Created by Michael Michailidis on 25/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNCollectionCellButtonControl.h"

@interface SYNLikeControlButton : SYNCollectionCellButtonControl
{
    @private UILabel* numberLabel;
}

@property (nonatomic) NSInteger numberOfLikes;

@end
