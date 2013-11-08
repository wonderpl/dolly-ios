//
//  SYNAggregateCell.h
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "ChannelOwner.h"
#import "SYNAvatarButton.h"
#import "SYNSocialActionsDelegate.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"

@import UIKit;


@interface SYNAggregateCell : UICollectionViewCell <NSObject, UICollectionViewDataSource, SYNSocialActionsDelegate>
{
    NSArray* _collectionData;
    
}

@property (nonatomic, readonly) CGSize sizeForItemAtDefaultPath;
@property (nonatomic, readonly) ChannelOwner* channelOwner;
@property (nonatomic, strong) IBOutlet SYNAvatarButton *userThumbnailButton;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;
@property (nonatomic, strong) IBOutlet SYNButton *actionButton;
@property (nonatomic, strong) NSArray* collectionData;
@property (nonatomic, strong) NSDictionary *lightTextAttributes;
@property (nonatomic, strong) NSDictionary *strongTextAttributes;
@property (nonatomic, strong) NSDictionary *lightCenteredTextAttributes;
@property (nonatomic, strong) NSDictionary *strongCenteredTextAttributes;
@property (nonatomic, strong) NSMutableArray *stringButtonsArray;
@property (nonatomic, weak) id<SYNSocialActionsDelegate> delegate;

@end
