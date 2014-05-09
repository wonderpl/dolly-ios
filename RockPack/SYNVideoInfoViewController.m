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
#import "VideoAnnotation.h"
#import "SYNPagingModel.h"
#import "SYNOneToOneSharingController.h"
#import "SYNAddToChannelViewController.h"
#import "SYNTrackingManager.h"
#import "SYNVideoActionsBar.h"
#import <SDWebImageManager.h>

static const CGFloat ActionCellHeight = 70.0;
static const CGFloat ClickToMoreCellHeight = 60.0;
static const CGFloat UpcomingVideosDividerHeight = 70.0;

@interface SYNVideoInfoViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate, SYNWebViewCellDelegate, SYNVideoActionsBarDelegate, SYNVideoClickToMoreCellDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (nonatomic, assign) CGFloat descriptionHeight;

@property (nonatomic, strong, readonly) VideoInstance *currentVideoInstance;

@property (nonatomic, strong) NSMutableArray *annotations;

@property (nonatomic, weak) SYNVideoActionsBar *videoActionsBar;

@end

@implementation SYNVideoInfoViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.annotations = [NSMutableArray array];
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

#pragma mark - Public

- (void)addVideoAnnotation:(VideoAnnotation *)annotation {
	BOOL isFirstAnnotation = ([self.annotations count] == 0);
	
	[self.annotations addObject:annotation];
	
	if (isFirstAnnotation) {
		UIButton *button = self.videoActionsBar.shopButton;
		
		button.hidden = NO;
		button.transform = CGAffineTransformMakeScale(0.0, 0.0);
		
		[UIView animateKeyframesWithDuration:0.3
									   delay:0
									 options:0
								  animations:^{
									  
									  [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.8 animations:^{
										  button.transform = CGAffineTransformMakeScale(1.5, 1.5);
									  }];
									  
									  [UIView addKeyframeWithRelativeStartTime:0.8 relativeDuration:1.0 animations:^{
										  button.transform = CGAffineTransformMakeScale(1.0, 1.0);
									  }];
									  
								  } completion:^(BOOL finished) {
									  
								  }];
	}
}

#pragma mark - Getters / Setters

- (void)setSelectedIndex:(NSInteger)selectedIndex {
	BOOL selectedIndexChanged = (_selectedIndex != selectedIndex);
	
	_selectedIndex = selectedIndex;
	
	if (selectedIndexChanged) {
		self.annotations = [NSMutableArray array];
	}
	
	[self.collectionView reloadData];
	self.collectionView.contentOffset = CGPointZero;
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
		cell.actionsBar.favouriteButton.selected = self.currentVideoInstance.starredByUserValue;
		cell.actionsBar.delegate = self;
		cell.actionsBar.shopButton.hidden = ([self.annotations count] == 0);
		
		self.videoActionsBar = cell.actionsBar;
		
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == [self upcomingVideosSectionIndex]) {
		[self.delegate videoInfoViewController:self didSelectVideoAtIndex:self.selectedIndex + indexPath.row + 1];
	}
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
	if (section == [self upcomingVideosSectionIndex]) {
		return CGSizeMake(CGRectGetWidth(collectionView.bounds), UpcomingVideosDividerHeight);
	}
	return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == [self actionsSectionIndex]) {
		return CGSizeMake(collectionViewLayout.itemSize.width, ActionCellHeight);
	}
	if (indexPath.section == [self clickToMoreSectionIndex]) {
		return CGSizeMake(collectionViewLayout.itemSize.width, ClickToMoreCellHeight);
	}
	if (indexPath.section == [self descriptionSectionIndex]) {
		return CGSizeMake(collectionViewLayout.itemSize.width, self.descriptionHeight);
	}
	return collectionViewLayout.itemSize;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self.delegate videoInfoViewController:self didScrollToContentOffset:scrollView.contentOffset];
}

#pragma mark - SYNVideoActionsBarDelegate

- (void)videoActionsBar:(SYNVideoActionsBar *)bar favouritesButtonPressed:(UIButton *)button {
	[self favouriteButtonPressed:button videoInstance:self.currentVideoInstance];
}

- (void)videoActionsBar:(SYNVideoActionsBar *)bar annotationButtonPressed:(UIButton *)button {
	VideoAnnotation *annotation = [self.annotations firstObject];
	NSURL *url = [NSURL URLWithString:annotation.url];
	
	UIViewController *viewController = [SYNWebViewController webViewControllerForURL:url];
	[self presentViewController:viewController animated:YES completion:nil];
}

- (void)videoActionsBar:(SYNVideoActionsBar *)bar addToChannelButtonPressed:(UIButton *)button {
	VideoInstance *videoInstance = [self.model itemAtIndex:self.selectedIndex];
	
	[[SYNTrackingManager sharedManager] trackVideoAddFromScreenName:[self trackingScreenName]];
	
    [appDelegate.oAuthNetworkEngine recordActivityForUserId:appDelegate.currentUser.uniqueId
                                                     action:@"select"
                                            videoInstanceId:videoInstance.uniqueId
                                          completionHandler:nil
                                               errorHandler:nil];
	
	SYNAddToChannelViewController *viewController = [[SYNAddToChannelViewController alloc] initWithViewId:kExistingChannelsViewId];
	viewController.modalPresentationStyle = UIModalPresentationCustom;
	viewController.transitioningDelegate = self;
	viewController.videoInstance = videoInstance;
	
	[self presentViewController:viewController animated:YES completion:nil];
}

- (void)videoActionsBar:(SYNVideoActionsBar *)bar shareButtonPressed:(UIButton *)button {
	VideoInstance *videoInstance = [self.model itemAtIndex:self.selectedIndex];
	
	[self requestShareLinkWithObjectType:@"video_instance" objectId:videoInstance.uniqueId];
	
    // At this point it is safe to assume that the video thumbnail image is in the cache
    UIImage *thumbnailImage = [[[SDWebImageManager sharedManager] imageCache] imageFromMemoryCacheForKey:videoInstance.video.thumbnailURL];
	
	SYNOneToOneSharingController *viewController = [self createSharingViewControllerForObjectType:@"video_instance"
																						 objectId:videoInstance.video.thumbnailURL
																						  isOwner:NO
																						  isVideo:YES
																							image:thumbnailImage];
	viewController.modalPresentationStyle = UIModalPresentationCustom;
	viewController.transitioningDelegate = self;
	
	[self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - SYNVideoClickToMoreCellDelegate

- (void)clickToMoreButtonPressed {
	Video *video = self.currentVideoInstance.video;
	NSURL *linkURL = [NSURL URLWithString:video.linkURL];
	
	UIViewController *viewController = [SYNWebViewController webViewControllerForURL:linkURL withTrackingName:@"Click to more"];
	[self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - SYNWebViewCellDelegate

- (void)webViewCellContentLoaded:(SYNWebViewCell *)cell {
	self.descriptionHeight = cell.contentHeight;
	
	[self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Private

- (NSString *)trackingScreenName {
	return @"Video";
}

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
