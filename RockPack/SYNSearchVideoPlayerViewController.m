//
//  SYNSearchVideoPlayerViewController.m
//  dolly
//
//  Created by Sherman Lo on 29/11/13.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchVideoPlayerViewController.h"
#import "SYNVideoPlayerViewController+Protected.h"
#import "VideoInstance.h"
#import "Video.h"
#import "SYNChannelMidCell.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNSearchResultsUserCell.h"
#import "UIFont+SYNFont.h"
#import "SYNNetworkEngine.h"
#import "SYNMasterViewController.h"
#import "SYNSearchVideoChannelsModel.h"
#import "SYNSearchVideoLikesModel.h"
#import "UINavigationBar+Appearance.h"
@import MediaPlayer;

@interface SYNSearchVideoPlayerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, SYNPagingModelDelegate, SYNChannelMidCellDelegate>

@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) NSArray *channels;

@property (nonatomic, strong) IBOutlet UICollectionView *channelsCollectionView;
@property (nonatomic, strong) IBOutlet UICollectionView *likesCollectionView;

@property (nonatomic, strong) IBOutlet UIView *headerView;

@property (nonatomic, strong) SYNPagingModel *channelsModel;
@property (nonatomic, strong) SYNPagingModel *likesModel;

@end

@implementation SYNSearchVideoPlayerViewController

#pragma mark - Public class

+ (UIViewController *)viewControllerWithVideoInstance:(VideoInstance *)videoInstance {
	NSString *suffix = (IS_IPAD ? @"ipad" : @"iphone");
	NSString *filename = [NSString stringWithFormat:@"%@_%@", NSStringFromClass(self), suffix];
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:filename bundle:nil];
	
	UINavigationController *navigationController = [storyboard instantiateInitialViewController];
	SYNSearchVideoPlayerViewController *viewController = (SYNSearchVideoPlayerViewController *)navigationController.topViewController;
	viewController.videoInstance = videoInstance;
	return navigationController;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.segmentedControl setTitleTextAttributes:@{ NSFontAttributeName : [UIFont regularCustomFontOfSize:14.0] }
										 forState:UIControlStateNormal];
	
    [self.channelsCollectionView registerNib:[SYNChannelMidCell nib]
				  forCellWithReuseIdentifier:[SYNChannelMidCell reuseIdentifier]];
	[self.channelsCollectionView registerNib:[SYNChannelFooterMoreView nib]
				  forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
						 withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];
	
	[self.likesCollectionView registerNib:[SYNSearchResultsUserCell nib]
			   forCellWithReuseIdentifier:[SYNSearchResultsUserCell reuseIdentifier]];
	[self.likesCollectionView registerNib:[SYNChannelFooterMoreView nib]
			   forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
					  withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];
	
	if (IS_IPHONE) {
		self.channelsCollectionView.scrollIndicatorInsets = UIEdgeInsetsMake(CGRectGetHeight(self.headerView.frame), 0, 0, 0);
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	if (IS_IPAD) {
		// We need to invalidate the layout to make sure that the section insets are changed for the iPad to make sure the cells
		// are always centered
		[self.channelsCollectionView.collectionViewLayout invalidateLayout];
		[self.likesCollectionView.collectionViewLayout invalidateLayout];
	}
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	SYNPagingModel *model = [self modelForCollectionView:collectionView];
	return [model itemCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	if (collectionView == self.channelsCollectionView) {
		SYNChannelMidCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNChannelMidCell reuseIdentifier]
																			forIndexPath:indexPath];
		cell.channel = [self.channelsModel itemAtIndex:indexPath.item];
		
		return cell;
	} else {
		SYNSearchResultsUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNSearchResultsUserCell reuseIdentifier]
																				   forIndexPath:indexPath];
		
		cell.channelOwner = [self.likesModel itemAtIndex:indexPath.item];
		cell.followButton.hidden = YES;
		
		return cell;
	}
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
		SYNChannelFooterMoreView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
																				  withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]
																						 forIndexPath:indexPath];
		footerView.showsLoading = YES;
		SYNPagingModel *model = [self modelForCollectionView:collectionView];
		if ([model hasMoreItems]) {
			[model loadNextPage];
		}
		
		return footerView;
	}
	return nil;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	if (collectionView == self.channelsCollectionView) {
		Channel *channel = [self.channelsModel itemAtIndex:indexPath.item];
		SYNMasterViewController *masterViewController = (SYNMasterViewController *)self.presentingViewController;
		SYNAbstractViewController *abstractViewController = masterViewController.showingViewController;
		[self dismissViewControllerAnimated:YES completion:^{
			[abstractViewController viewChannelDetails:channel withAnimation:YES];
		}];
	}
	if (collectionView == self.likesCollectionView) {
		ChannelOwner *channelOwner = [self.likesModel itemAtIndex:indexPath.item];
		SYNMasterViewController *masterViewController = (SYNMasterViewController *)self.presentingViewController;
		SYNAbstractViewController *abstractViewController = masterViewController.showingViewController;
		[self dismissViewControllerAnimated:YES completion:^{
			[abstractViewController viewProfileDetails:channelOwner];
		}];
	}
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
						layout:(UICollectionViewFlowLayout *)collectionViewFlowLayout
		insetForSectionAtIndex:(NSInteger)section {
	if (IS_IPHONE) {
		// Leave room for our header view
		return UIEdgeInsetsMake(CGRectGetHeight(self.headerView.frame), 0, 0, 0);
	} else {
		CGFloat cellWidth = collectionViewFlowLayout.itemSize.width;
		CGFloat separatorWidth = collectionViewFlowLayout.minimumLineSpacing;
		NSInteger numberOfCells = [collectionView numberOfItemsInSection:0];
		
		CGFloat sectionWidth = 0.0;
		if (numberOfCells) {
			sectionWidth = (numberOfCells * cellWidth) + ((numberOfCells - 1) * separatorWidth);
			
			if (sectionWidth < CGRectGetWidth(collectionView.frame)) {
				// Since the cells are taking up less room than the width of collection view we want to
				// center them by adding insets before/after
				CGFloat insetWidth = (CGRectGetWidth(collectionView.frame) - sectionWidth) / 2;
				return UIEdgeInsetsMake(0, insetWidth, 0, insetWidth);
			}
		}
		
		return UIEdgeInsetsMake(0, separatorWidth, 0, separatorWidth);
	}
}

- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewFlowLayout *)collectionViewFlowLayout
referenceSizeForFooterInSection:(NSInteger)section {
	SYNPagingModel *model = [self modelForCollectionView:collectionView];
	return ([model hasMoreItems] ? collectionViewFlowLayout.itemSize : CGSizeZero);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (IS_IPHONE) {
		// Keep the collection views in sync for iPhone since the header view is common and we want them
		// to be at the same scroll offset when they scroll
		if (scrollView == self.channelsCollectionView) {
			self.likesCollectionView.contentOffset = scrollView.contentOffset;
		} else {
			self.channelsCollectionView.contentOffset = scrollView.contentOffset;
		}
		
		// Only need to transform the header view within 0 and its height since it'll be hidden then
		CGFloat yOffset = MIN(MAX(0, scrollView.contentOffset.y), CGRectGetHeight(self.headerView.frame));
		self.headerView.transform = CGAffineTransformMakeTranslation(0, MIN(0, -yOffset));
	}
}

#pragma mark - SYNPagingModelDelegate

- (void)pagingModelDataUpdated:(SYNPagingModel *)pagingModel {
	if (pagingModel == self.likesModel) {
		NSString *segmentedControlTitle = [NSString stringWithFormat:@"%@ by (%d)", NSLocalizedString(@"liked", nil), [pagingModel totalItemCount]];
		[self.segmentedControl setTitle:segmentedControlTitle forSegmentAtIndex:1];
		[self.likesCollectionView reloadData];
	}
	if (pagingModel == self.channelsModel) {
		NSString *segmentedControlTitle = [NSString stringWithFormat:@"Appears in (%d)", [pagingModel totalItemCount]];
		[self.segmentedControl setTitle:segmentedControlTitle forSegmentAtIndex:0];
		[self.channelsCollectionView reloadData];
	}
}

- (void)pagingModelErrorOccurred:(SYNPagingModel *)pagingModel {
	
}

#pragma mark - SYNChannelMidCellDelegate

- (void)followButtonTapped:(SYNChannelMidCell *)cell {
	[self followButtonPressed:cell.followButton withChannel:self.videoInstance.channel];
}

- (void)deleteChannelTapped:(SYNChannelMidCell *)cell {
	// We don't support delete on the cell
}

#pragma mark - Getters / Setters

- (SYNPagingModel *)channelsModel {
	if (!_channelsModel) {
		SYNPagingModel *model = [SYNSearchVideoChannelsModel modelWithVideoId:self.videoInstance.video.uniqueId];
		model.delegate = self;
		
		_channelsModel = model;
	}
	return _channelsModel;
}

- (SYNPagingModel *)likesModel {
	if (!_likesModel) {
		SYNPagingModel *model = [SYNSearchVideoLikesModel modelWithVideoId:self.videoInstance.video.uniqueId];
		model.delegate = self;
		
		_likesModel = model;
	}
	return _likesModel;
}

#pragma mark - IBActions

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl {
	if (segmentedControl.selectedSegmentIndex == 0) {
		self.channelsCollectionView.hidden = NO;
		self.likesCollectionView.hidden = YES;
	} else {
		self.channelsCollectionView.hidden = YES;
		self.likesCollectionView.hidden = NO;
	}
}

#pragma mark - Private

- (SYNPagingModel *)modelForCollectionView:(UICollectionView *)collectionView {
	return (collectionView == self.channelsCollectionView ? self.channelsModel : self.likesModel);
}

- (UICollectionView *)collectionViewForModel:(SYNPagingModel *)model {
	return (model == self.channelsModel ? self.channelsCollectionView : self.likesCollectionView);
}

@end
