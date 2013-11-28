//
//  SYNAggregateVideoCell.m
//  rockpack
//
//  Created by Michael Michailidis on 29/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "ChannelOwner.h"
#import "SYNAbstractViewController.h"
#import "SYNAggregateFlowLayout.h"
#import "SYNAggregateVideoCell.h"
#import "SYNAggregateVideoItemCell.h"
#import "SYNAppDelegate.h"
#import "SYNButton.h"
#import "SYNDeviceManager.h"
#import "UIColor+SYNColor.h"
#import "UIFont+SYNFont.h"
#import "UIImage+Tint.h"
#import "Video.h"
#import "VideoInstance.h"

static NSString* kVideoItemCellIndentifier = @"SYNAggregateVideoItemCell";


@interface SYNAggregateVideoCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet SYNButton* channelNameButton;
@property (nonatomic, weak) Channel* channel;

@end


@implementation SYNAggregateVideoCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self.collectionView registerNib: [UINib nibWithNibName: kVideoItemCellIndentifier bundle: nil]
          forCellWithReuseIdentifier: kVideoItemCellIndentifier];
    
    SYNAggregateFlowLayout *aggregateFlowLayout = [[SYNAggregateFlowLayout alloc] init];
    
    aggregateFlowLayout.itemSize = [self sizeForItemAtDefaultPath];
    
    self.collectionView.collectionViewLayout = aggregateFlowLayout;
    
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    // set fonts
    self.channelNameButton.titleLabel.font = [UIFont lightCustomFontOfSize: self.channelNameButton.titleLabel.font.pointSize];
    
    [self.collectionView reloadData];
}


- (void) setDelegate: (id<SYNSocialActionsDelegate>) delegate
{
    
    [super setDelegate: delegate];
    
    
    // Addtional delegate
    [self.channelNameButton addTarget: self.delegate
                                 action: @selector(channelButtonTapped:)
                       forControlEvents: UIControlEventTouchUpInside];
}


- (void) prepareForReuse
{
    [super prepareForReuse];
    
    self.collectionData = @[];

    [self.collectionView reloadData];
}


- (void) setCollectionData: (NSArray *) collectionData
{
    NSArray *sortedCollectionData = [collectionData sortedArrayUsingComparator: ^NSComparisonResult(VideoInstance* vi1, VideoInstance* vi2) {
        return [vi1.position compare: vi2.position];
    }];
    
    [super setCollectionData: sortedCollectionData];
    
    if (collectionData.count <= 0)
    {
        return;
    }
    
    VideoInstance *firstVideoInstance = collectionData[0];
    
    // Get the Channel from the first videoInstance (as a heuristic)
    self.channel = firstVideoInstance.channel;
    NSString *nameString = self.channel.channelOwner.displayName; // ex 'Dolly Proxima'
    NSString *actionString = [NSString stringWithFormat: @" added %i videos to", _collectionData.count];
    
    NSMutableAttributedString *attributedCompleteString = [[NSMutableAttributedString alloc] init];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: nameString
                                                                                      attributes: self.strongTextAttributes]];
    
    [attributedCompleteString appendAttributedString: [[NSAttributedString alloc] initWithString: actionString
                                                                                      attributes: self.lightTextAttributes]];
    
    self.actionButton.attributedTitle = attributedCompleteString;
    
    self.channelNameButton.title = self.channel.title;
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

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
   sizeForItemAtIndexPath: (NSIndexPath *) indexPath
{
    CGSize correctSize = CGSizeZero;
    
    if (IS_IPHONE)
    {
        correctSize.width = 248.0f;
        correctSize.height = 257.0f;
    }
    else
    {
        correctSize.width = 360.0f;
        correctSize.height = 336.0f;
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
    itemCell.delegate = self.delegate;
    itemCell.videoInstance = videoInstance;
    
    return itemCell;
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell *subCell = [collectionView cellForItemAtIndexPath: indexPath];
    
    [(SYNAbstractViewController *)self.delegate displayVideoViewerFromCell: self
                                                                andSubCell: subCell
                                                            atSubCellIndex: indexPath.item];
}


@end
