//
//  SYNSearchResultsCell.h
//  dolly
//
//  Created by Michael Michailidis on 28/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSocialActionsDelegate.h"
@import UIKit;

@interface SYNSearchResultsCell : UICollectionViewCell
{
    __weak id<SYNSocialActionsDelegate> _delegate;
}

@property (weak, nonatomic) id<SYNSocialActionsDelegate> delegate;

@end
