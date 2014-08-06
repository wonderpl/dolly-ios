//
//  SYNIPadFeedRootViewController.m
//  dolly
//
//  Created by Sherman Lo on 24/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNIPadFeedRootViewController.h"
#import "SYNFeedVideoLargeCell.h"
#import "SYNFeedVideoSmallCell.h"
#import "SYNFeedChannelLargeCell.h"
#import "SYNFeedChannelSmallCell.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNFeedModel.h"
#import "FeedItem.h"
#import "VideoInstance.h"
#import "SYNIPadFeedLayout.h"
#import "UINavigationBar+Appearance.h"

@implementation SYNIPadFeedRootViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
//	SYNIPadFeedLayout *layout = (SYNIPadFeedLayout *)self.feedCollectionView.collectionViewLayout;
//	layout.model = self.model;
	
	[self.feedCollectionView registerNib:[SYNFeedVideoLargeCell nib]
			  forCellWithReuseIdentifier:[SYNFeedVideoLargeCell reuseIdentifier]];
	
	[self.feedCollectionView registerNib:[SYNFeedVideoSmallCell nib]
			  forCellWithReuseIdentifier:[SYNFeedVideoSmallCell reuseIdentifier]];
	
	[self.feedCollectionView registerNib:[SYNFeedChannelLargeCell nib]
			  forCellWithReuseIdentifier:[SYNFeedChannelLargeCell reuseIdentifier]];
	
	[self.feedCollectionView registerNib:[SYNFeedChannelSmallCell nib]
			  forCellWithReuseIdentifier:[SYNFeedChannelSmallCell reuseIdentifier]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self.feedCollectionView reloadData];

	[self.navigationController.navigationBar setBackgroundTransparent:NO];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[super scrollViewDidScroll:scrollView];
	
//	layout.blockLocation = (scrollView.contentOffset.y + scrollView.contentInset.top) / scrollView.bounds.size.height;
}

#pragma mark - Overridden

- (SYNFeedChannelCell *)channelCellForIndexPath:(NSIndexPath *)indexPath
								 collectionView:(UICollectionView *)collectionView {
	
	BOOL isLargeCell = [self isLargeCellAtIndexPath:indexPath];
	NSString *reuseIdentifier = [SYNFeedChannelLargeCell reuseIdentifier];
	
	return [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
																forIndexPath:indexPath];
}

- (SYNFeedVideoCell *)videoCellForIndexPath:(NSIndexPath *)indexPath
							 collectionView:(UICollectionView *)collectionView {
	
	BOOL isLargeCell = [self isLargeCellAtIndexPath:indexPath];
	NSString *reuseIdentifier = [SYNFeedVideoLargeCell reuseIdentifier];
	
	return [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
													 forIndexPath:indexPath];
}


- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	
	FeedItem *feedItem = [self.model feedItemAtindex:indexPath.item];
	
	CGFloat collectionViewWidth = CGRectGetWidth(collectionView.bounds);
	BOOL isVideo = (feedItem.resourceTypeValue == FeedItemResourceTypeVideo);
	
    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        return CGSizeMake(674, 1024);
    } else {
        return CGSizeMake(1024, 768);
    }
    
	return CGSizeZero;
}


#pragma mark - Private

- (BOOL)isLargeCellAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger blockNumber = (indexPath.item / 3);
	NSInteger blockOffset = (indexPath.item % 3);
	
	BOOL isEvenBlock = (blockNumber % 2 == 0);
	
	if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
		return (blockOffset == 0);
	} else {
		return (isEvenBlock ? (blockOffset == 0) : (blockOffset == 2));
	}
}

@end
