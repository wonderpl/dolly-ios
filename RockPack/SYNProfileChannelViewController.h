//
//  SYNProfileChannelViewController.h
//  dolly
//
//  Created by Cong Le on 10/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNProfileViewController.h"
#import "SYNProfileChannelModel.h"

@interface SYNProfileChannelViewController : SYNAbstractViewController

@property (nonatomic, strong) ChannelOwner* channelOwner;
@property (nonatomic) BOOL isUserProfile;
@property (strong, nonatomic) IBOutlet UICollectionView *cv;
@property (nonatomic, readonly) SYNProfileChannelModel *model;
@property (nonatomic, strong, readonly) SYNProfileHeader* headerView;


- (void) coverPhotoAnimation;

@end
