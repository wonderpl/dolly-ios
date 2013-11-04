//
//  SYNSearchResultsCell.h
//  dolly
//
//  Created by Michael Michailidis on 28/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNSocialActionsDelegate.h"

@interface SYNSearchResultsCell : UICollectionViewCell

@property (weak, nonatomic) id<SYNSocialActionsDelegate> delegate;

@end
