//
//  SYNProfileSubscriptionViewController.h
//  dolly
//
//  Created by Cong Le on 10/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNProfileSubscriptionModel.h"
#import "SYNProfileHeader.h"

@interface SYNProfileSubscriptionViewController : SYNAbstractViewController
@property (nonatomic, strong) ChannelOwner* channelOwner;
@property (nonatomic, strong) IBOutlet UICollectionView *cv;
@property (nonatomic) BOOL isUserProfile;
@property (nonatomic, strong, readonly) SYNProfileHeader* headerView;

@property (nonatomic, readonly) SYNProfileSubscriptionModel *model;


- (void) coverPhotoAnimation;

@end
