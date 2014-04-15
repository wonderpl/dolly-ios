//
//  SYNVideoInfoViewController.m
//  dolly
//
//  Created by Sherman Lo on 10/04/14.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNVideoInfoViewController.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNWebViewCell.h"
#import "SYNVideoCell.h"
#import "SYNVideoActionsCell.h"
#import "SYNVideoClickToMoreCell.h"
#import "VideoInstance.h"
#import "SYNWebViewController.h"
#import "SYNVideoDivider.h"
#import "Video.h"
#import "SYNPagingModel.h"

@interface SYNVideoInfoViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SYNWebViewCellDelegate, SYNVideoActionsDelegate, SYNVideoClickToMoreCellDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (nonatomic, assign) CGFloat descriptionHeight;

@property (nonatomic, strong, readonly) VideoInstance *currentVideoInstance;

@end

@implementation SYNVideoInfoViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.descriptionHeight = 50;
	
	[self.collectionView registerNib:[SYNVideoDivider nib]
		  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
				 withReuseIdentifier:[SYNVideoDivider reuseIdentifier]];
	
	[self.collectionView registerNib:[SYNVideoActionsCell nib]
		  forCellWithReuseIdentifier:[SYNVideoActionsCell reuseIdentifier]];
	
	[self.collectionView registerNib:[SYNVideoClickToMoreCell nib]
		  forCellWithReuseIdentifier:[SYNVideoClickToMoreCell reuseIdentifier]];
	
	[self.collectionView registerNib:[SYNWebViewCell nib]
		  forCellWithReuseIdentifier:[SYNWebViewCell reuseIdentifier]];
	
	[self.collectionView registerNib:[SYNVideoCell nib]
		  forCellWithReuseIdentifier:[SYNVideoCell reuseIdentifier]];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
	_selectedIndex = selectedIndex;
	
	[self.collectionView reloadData];
}

- (VideoInstance *)currentVideoInstance {
	return [self.model itemAtIndex:self.selectedIndex];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	BOOL hasDescription = ([self descriptionSectionIndex] != NSNotFound);
	return (hasDescription ? 4 : 3);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	if (section == [self actionsSectionIndex] || section == [self clickToMoreSectionIndex] || section == [self descriptionSectionIndex]) {
		return 1;
	} else {
		return MIN(3, [self.model itemCount] - (self.selectedIndex + 1));
	}
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == [self actionsSectionIndex]) {
		SYNVideoActionsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNVideoActionsCell reuseIdentifier]
																			  forIndexPath:indexPath];
		
		
		
		
		return cell;
	} else if (indexPath.section == [self clickToMoreSectionIndex]) {
		SYNVideoClickToMoreCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNVideoClickToMoreCell reuseIdentifier]
																				  forIndexPath:indexPath];
		
		cell.title = self.currentVideoInstance.video.linkTitle;
		cell.delegate = self;
		
		return cell;
	} else if (indexPath.section == [self descriptionSectionIndex]) {
		SYNWebViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNWebViewCell reuseIdentifier]
																		 forIndexPath:indexPath];
		
		cell.contentHTML = self.currentVideoInstance.video.videoDescription;
		cell.delegate = self;
		
		return cell;
	} else {
		SYNVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNVideoCell reuseIdentifier]
																	   forIndexPath:indexPath];
		cell.videoInstance = [self.model itemAtIndex:self.selectedIndex + indexPath.row + 1];
		
		return cell;
	}
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == [self upcomingVideosSectionIndex] && [kind isEqualToString:UICollectionElementKindSectionHeader]) {
		UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
																					withReuseIdentifier:[SYNVideoDivider reuseIdentifier]
																						   forIndexPath:indexPath];
		return reusableView;
	}
	return nil;
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
	if (section == [self upcomingVideosSectionIndex]) {
		return CGSizeMake(320, 70);
	}
	return CGSizeZero;
}

#pragma mark - SYNVideoClickToMoreCellDelegate

- (void)clickToMoreButtonPressed {
	Video *video = self.currentVideoInstance.video;
	NSURL *linkURL = [NSURL URLWithString:video.linkURL];
	
	UIViewController *viewController = [SYNWebViewController webViewControllerForURL:linkURL];
	[self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - SYNWebViewCellDelegate

- (void)webViewCellContentLoaded:(SYNWebViewCell *)cell {
	self.descriptionHeight = cell.contentHeight;
	
	[self.collectionView.collectionViewLayout invalidateLayout];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == [self descriptionSectionIndex]) {
		return CGSizeMake(collectionViewLayout.itemSize.width, self.descriptionHeight);
	}
	return collectionViewLayout.itemSize;
}

#pragma mark - Private

- (NSInteger)actionsSectionIndex {
	return 0;
}

- (NSInteger)clickToMoreSectionIndex {
	return 1;
}

- (NSInteger)descriptionSectionIndex {
	return ([self.currentVideoInstance.video.videoDescription length] ? 2 : NSNotFound);
}

- (NSInteger)upcomingVideosSectionIndex {
	BOOL hasDescription = ([self descriptionSectionIndex] != NSNotFound);
	return (hasDescription ? 3 : 2);
}

@end
