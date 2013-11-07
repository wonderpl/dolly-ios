//
//  SYNAggregateCell.h
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "ChannelOwner.h"
#import "SYNButton.h"
#import "SYNSocialActionsDelegate.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+WebCache.h"

@import UIKit;


@interface SYNAggregateCell : UICollectionViewCell <NSObject, UICollectionViewDataSource, SYNSocialActionsDelegate>
{
    NSArray* _collectionData;
    
}

@property (nonatomic, strong) NSArray* collectionData;
@property (nonatomic, readonly) CGSize sizeForItemAtDefaultPath;
@property (nonatomic, readonly) ChannelOwner* channelOwner;
@property (nonatomic, strong) IBOutlet SYNButton *userThumbnailButton;
@property (nonatomic, strong) IBOutlet UICollectionView* collectionView;
@property (nonatomic, strong) IBOutlet UIImageView *userThumbnailImageView;



// main labels from top to bottom
@property (nonatomic, strong) IBOutlet UILabel *actionMessageLabel;


@property (nonatomic, strong) NSDictionary *strongTextAttributes;
@property (nonatomic, strong) NSDictionary *lightTextAttributes;
@property (nonatomic, strong) NSMutableArray *stringButtonsArray;
@property (nonatomic, weak) id<SYNSocialActionsDelegate> delegate;

@end
