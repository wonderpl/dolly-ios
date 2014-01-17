//
//  SYNSearchResultsVideoCell.h
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchResultsCell.h"
#import "VideoInstance.h"
@import UIKit;

@protocol SYNVideoCellDelegate;

@interface SYNSearchResultsVideoCell : SYNSearchResultsCell

@property (nonatomic, strong) IBOutlet UIImageView* iconImageView;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* timeLabel;
@property (nonatomic, strong) IBOutlet UILabel* timeStampLabel;

@property (nonatomic, weak) id<SYNSocialActionsDelegate, SYNVideoCellDelegate> delegate;

@property (nonatomic, weak) VideoInstance* videoInstance;

@end
