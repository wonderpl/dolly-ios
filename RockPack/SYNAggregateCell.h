//
//  SYNAggregateCell.h
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "ChannelOwner.h"
#import "SYNSocialActionsDelegate.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"
#import <UIKit/UIKit.h>


@interface SYNAggregateCell : UICollectionViewCell <NSObject, UICollectionViewDataSource, SYNSocialActionsDelegate>

@property (nonatomic, readonly) CGSize sizeForItemAtDefaultPath;
@property (nonatomic, readonly) ChannelOwner* channelOwner;
@property (nonatomic, strong) IBOutlet UIButton *userThumbnailButton;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;
@property (nonatomic, strong) IBOutlet UIImageView *userThumbnailImageView;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIView* backgroundView;
@property (nonatomic, strong) IBOutlet UIView* bottomControlsView;
@property (nonatomic, strong) NSArray* collectionData;
@property (nonatomic, strong) NSDictionary *boldTextAttributes;
@property (nonatomic, strong) NSDictionary *lightTextAttributes;
@property (nonatomic, strong) NSMutableArray *stringButtonsArray;
@property (nonatomic, weak) id<SYNSocialActionsDelegate> delegate;

@end
