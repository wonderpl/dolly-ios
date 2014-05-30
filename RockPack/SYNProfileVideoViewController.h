//
//  SYNProfileVideoViewController.h
//  dolly
//
//  Created by Cong on 30/05/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNProfileHeader.h"
#import "SYNProfileVideoModel.h"
#import "SYNProfileNavigationBarDelegate.h"


@interface SYNProfileVideoViewController : SYNAbstractViewController

@property (nonatomic, strong) ChannelOwner* channelOwner;
@property (nonatomic) BOOL isUserProfile;
@property (nonatomic, strong) IBOutlet UICollectionView *cv;
@property (nonatomic, readonly) SYNProfileVideoModel *model;
@property (nonatomic, strong, readonly) SYNProfileHeader* headerView;
@property (nonatomic, weak) id<SYNProfileNavigationBarDelegate> delegate;

- (void) coverPhotoAnimation;


@end
