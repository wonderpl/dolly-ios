//
//  SYNSearchResultsUserCell.h
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYNSearchResultsCell.h"
#import "SYNSocialActionsDelegate.h"

@interface SYNSearchResultsUserCell : SYNSearchResultsCell

@property (nonatomic, strong) IBOutlet UIImageView* userThumbnailImageView;
@property (nonatomic, strong) IBOutlet UILabel* userNameLabel;
@property (nonatomic, strong) IBOutlet UIButton* followButton;


@end
