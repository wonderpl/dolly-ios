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
		
	[self.feedCollectionView registerNib:[SYNFeedChannelLargeCell nib]
			  forCellWithReuseIdentifier:[SYNFeedChannelLargeCell reuseIdentifier]];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self.feedCollectionView reloadData];
	[self.navigationController.navigationBar setBackgroundTransparent:NO];
}

#pragma mark - Overridden

- (SYNFeedChannelCell *)channelCellForIndexPath:(NSIndexPath *)indexPath
								 collectionView:(UICollectionView *)collectionView {
	return [collectionView dequeueReusableCellWithReuseIdentifier:[SYNFeedChannelLargeCell reuseIdentifier]
																forIndexPath:indexPath];
}

- (SYNFeedVideoCell *)videoCellForIndexPath:(NSIndexPath *)indexPath
							 collectionView:(UICollectionView *)collectionView {
	return [collectionView dequeueReusableCellWithReuseIdentifier:[SYNFeedVideoLargeCell reuseIdentifier]
													 forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	
    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        return CGSizeMake(768, 1024);
    } else {
        return CGSizeMake(1024, 768);
    }
    
	return CGSizeZero;
}

@end
