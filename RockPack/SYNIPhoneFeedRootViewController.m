//
//  SYNIPhoneFeedRootViewController.m
//  dolly
//
//  Created by Sherman Lo on 24/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNIPhoneFeedRootViewController.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNFeedVideoCell.h"
#import "SYNFeedChannelCell.h"
#import "FeedItem.h"
#import "VideoInstance.h"
#import "SYNFeedModel.h"

@interface SYNIPhoneFeedRootViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation SYNIPhoneFeedRootViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.feedCollectionView registerNib:[SYNFeedVideoCell nib]
			  forCellWithReuseIdentifier:[SYNFeedVideoCell reuseIdentifier]];
	
	[self.feedCollectionView registerNib:[SYNFeedChannelCell nib]
			  forCellWithReuseIdentifier:[SYNFeedChannelCell reuseIdentifier]];
}

#pragma mark - Overridden

- (SYNFeedChannelCell *)channelCellForIndexPath:(NSIndexPath *)indexPath
								 collectionView:(UICollectionView *)collectionView {
	
	return [collectionView dequeueReusableCellWithReuseIdentifier:[SYNFeedChannelCell reuseIdentifier]
													 forIndexPath:indexPath];
}


- (SYNFeedVideoCell *)videoCellForIndexPath:(NSIndexPath *)indexPath
							 collectionView:(UICollectionView *)collectionView {
	
	return [collectionView dequeueReusableCellWithReuseIdentifier:[SYNFeedVideoCell reuseIdentifier]
													 forIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	FeedItem *feedItem = [self.model feedItemAtindex:indexPath.item];
	
	CGFloat collectionViewWidth = CGRectGetWidth(collectionView.bounds);
	
	BOOL isVideo = (feedItem.resourceTypeValue == FeedItemResourceTypeVideo);
	
	return (isVideo ? CGSizeMake(collectionViewWidth, 401.0) : CGSizeMake(collectionViewWidth, 267.0));
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
	return ([self.model hasMoreItems] ? [self footerSize] : CGSizeZero);
}

@end
