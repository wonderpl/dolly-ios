//
//  SYNChannelCoverImageCell.h
//  rockpack
//
//  Created by Mats Trovik on 08/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

@import UIKit;

@class ALAsset;
@class ALAssetsLibrary;

@interface SYNChannelCoverImageCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView* channelCoverImageView;
@property (nonatomic, weak) IBOutlet UIImageView *glossImage;

- (void) setTitleText: (NSString*) titleText;
- (void) setimageFromAsset: (ALAsset*) asset;

-(void)selectWithoutAnimation;

-(void)deselectWithoutAnimation;

@end
