//
//  SYNSearchResultsVideoCell.h
//  dolly
//
//  Created by Michael Michailidis on 23/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchResultsCell.h"
#import "VideoInstance.h"
#import "SYNVideoInfoCell.h"
@import UIKit;

@protocol SYNVideoCellDelegate;

@interface SYNSearchResultsVideoCell : SYNSearchResultsCell <SYNVideoInfoCell>

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* timeLabel;
@property (nonatomic, strong) IBOutlet UILabel* timeStampLabel;
@property (nonatomic, strong) IBOutlet UIButton *ownerThumbnailButton;
@property (nonatomic, strong) IBOutlet UIButton *ownerNameButton;
@property (nonatomic, strong) IBOutlet UIButton *channelNameButton;

@property (nonatomic, weak) id<SYNSocialActionsDelegate, SYNVideoCellDelegate> delegate;

@property (nonatomic, weak) VideoInstance* videoInstance;

@end
