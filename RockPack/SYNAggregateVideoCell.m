//
//  SYNAggregateVideoCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "ChannelOwner.h"
#import "SYNAggregateFlowLayout.h"
#import "SYNAggregateVideoCell.h"
#import "SYNAggregateVideoItemCell.h"
#import "SYNAppDelegate.h"
#import "SYNDeviceManager.h"
#import "SYNTouchGestureRecognizer.h"
#import "UIColor+SYNColor.h"
#import "UIImage+Tint.h"
#import "Video.h"
#import "VideoInstance.h"


@interface SYNAggregateVideoCell () <UIGestureRecognizerDelegate>

@end

static NSString* kVideoItemCellIndentifier = @"SYNAggregateVideoItemCell";


@implementation SYNAggregateVideoCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.titleLabel.font = [UIFont regularCustomFontOfSize: self.titleLabel.font.pointSize];
    
    
    
    
    
    [self.collectionView registerNib: [UINib nibWithNibName: kVideoItemCellIndentifier bundle: nil]
          forCellWithReuseIdentifier: kVideoItemCellIndentifier];
    
    SYNAggregateFlowLayout *aggregateFlowLayout = [[SYNAggregateFlowLayout alloc] init];
    
    aggregateFlowLayout.itemSize = [self sizeForItemAtDefaultPath];
    
    
    self.collectionView.collectionViewLayout = aggregateFlowLayout;
    

    
    // Attempt to tween scroll rate (doesn't seem to work, anything less than 0.3 is jerky)
//    CGFloat scrollCoefficient = kFeedAggregateScrollCoefficient * (UIScrollViewDecelerationRateNormal - UIScrollViewDecelerationRateFast);
//    
//    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast + scrollCoefficient;
    
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    [self.collectionView reloadData];
}


- (void) prepareForReuse
{
    [super prepareForReuse];
    
    self.collectionData = @[];

    [self.collectionView reloadData];
}





- (void) setCollectionData:(NSArray *)collectionData
{
    [super setCollectionData:collectionData];
    
    if(collectionData.count <= 0)
        return;
    
    VideoInstance* firstVideoInstance = collectionData[0];
    // create string
    
    Channel* heuristicChannel = firstVideoInstance.channel;
    NSString *nameString = heuristicChannel.channelOwner.displayName; // ex 'Dolly Proxima'
    NSString *actionString = [NSString stringWithFormat:@" added %i videos to", _collectionData.count];
    
    
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] init];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: nameString
                                                                                      attributes: self.darkTextAttributes]];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: actionString
                                                                                      attributes: self.lightTextAttributes]];
    
    self.actionMessageLabel.attributedText = attributedCompleteString;
    
    self.channelNameLabel.text = heuristicChannel.title;
    
    // handle like button state
    
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGSize viewSize = self.frame.size;
    CGFloat middleOfView = roundf(viewSize.width * 0.5f); // to avoid pixelation
    
    
    
    // user thumbnail
    self.userThumbnailImageView.center = CGPointMake(middleOfView, self.userThumbnailImageView.center.y);
    self.userThumbnailButton.center = CGPointMake(middleOfView, self.userThumbnailImageView.center.y);
    
    // bottom controls
    self.bottomControlsView.center = CGPointMake(middleOfView, self.bottomControlsView.center.y);
    self.collectionView.center =CGPointMake(middleOfView, self.collectionView.center.y);
    self.actionMessageLabel.center =CGPointMake(middleOfView, self.actionMessageLabel.center.y);
    self.channelNameLabel.center =CGPointMake(middleOfView, self.channelNameLabel.center.y);
}


#pragma mark - UICollectionView DataSource

// utility method (overriding abstract class)
- (CGSize) sizeForItemAtDefaultPath
{
    // TODO: Might be a good idea to cache this, as this might be (relatively) computationally expensive
    return [self collectionView: self.collectionView
                         layout: self.collectionView.collectionViewLayout
         sizeForItemAtIndexPath: [NSIndexPath indexPathForItem: 0 inSection: 0]];
}


- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
   sizeForItemAtIndexPath: (NSIndexPath *) indexPath
{
    CGSize correctSize = CGSizeZero;
    
    if (IS_IPHONE)
    {
        correctSize.width = 248.0f;
        correctSize.height = 139.0f;
    }
    else
    {
        correctSize.width = 360.0f;
        correctSize.height = 339.0f;
    }
    
    return correctSize;
}


- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    
    return self.collectionData.count;
    
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNAggregateVideoItemCell* itemCell = [collectionView dequeueReusableCellWithReuseIdentifier: kVideoItemCellIndentifier
                                                                                    forIndexPath: indexPath];
    
    VideoInstance* videoInstance = self.collectionData[indexPath.item];
    
    
    
    // NOTE: All fields are set through the setVideoInstance setter
    itemCell.delegate = self;
    itemCell.videoInstance = videoInstance;
    
    return itemCell;
}






@end
