//
//  SYNProfileVideoViewController.m
//  dolly
//
//  Created by Cong on 30/05/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNProfileVideoViewController.h"
#import "UICollectionReusableView+Helpers.h"
#import "SYNProfileViewController.h"
#import "SYNDeviceManager.h"
#import "SYNCollectionVideoCell.h"
#import "SYNTrackingManager.h"
#import "SYNAddToChannelViewController.h"
#import "SYNVideoPlayerViewController.h"
#import "SYNVideoPlayerAnimator.h"
#import "UINavigationBar+Appearance.h"
#import <TestFlight.h>

static const CGFloat PARALLAX_SCROLL_VALUE = 2.0f;
static const CGFloat ProfileHeaderHeightIPhone = 523;
static const CGFloat ProfileHeaderHeightIPadPort = 780;
static const CGFloat ProfileHeaderHeightIPadLand = 664;


@interface SYNProfileVideoViewController () <UIViewControllerTransitioningDelegate, SYNCollectionVideoCellDelegate,SYNVideoPlayerAnimatorDelegate, SYNPagingModelDelegate,SYNVideoPlayerDismissIndex>
@property (nonatomic, strong) SYNProfileHeader* headerView;
@property (nonatomic, strong) SYNProfileVideoModel *model;
@property (nonatomic, strong) SYNVideoPlayerAnimator *videoPlayerAnimator;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *defaultLayout;

@end

@implementation SYNProfileVideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.cv registerNib:[SYNCollectionVideoCell nib]
                        forCellWithReuseIdentifier:[SYNCollectionVideoCell reuseIdentifier]];
    
    [self.cv registerNib:[SYNChannelFooterMoreView nib]
forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
     withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];

    [self.cv registerNib: [SYNProfileHeader nib]
forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
     withReuseIdentifier:[SYNProfileHeader reuseIdentifier]];

    if (IS_IPAD) {
        [self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
        [self.navigationController.navigationBar setBackgroundTransparent:YES];
        self.navigationController.navigationBarHidden = YES;
    }
    
    self.model.delegate = self;

}


#pragma mark - Scrollview delegates

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [super scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    [self coverPhotoAnimation];
}


- (void)coverPhotoAnimation {
    
    if (IS_IPHONE) {
        if (self.cv.contentOffset.y >= 570) {
            return;
        }
    }
    
    if (IS_IPAD) {
        if (self.cv.contentOffset.y >= 750) {
            return;
        }
    }
    
    if (self.cv.contentOffset.y<=0) {
        [self.headerView.coverImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.headerView.coverImageTop setConstant:self.cv.contentOffset.y];
    } else {
        [self.headerView.coverImage setContentMode:UIViewContentModeCenter];
        [self.headerView.coverImageTop setConstant:self.cv.contentOffset.y/PARALLAX_SCROLL_VALUE];
    }
}

- (void)setChannelOwner:(ChannelOwner*)channelOwner {
    _channelOwner = channelOwner;
    self.model = [SYNProfileVideoModel modelWithChannelOwner:_channelOwner];
}


#pragma mark - UICollectionView delegates


- (NSInteger)collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section {
    return self.model.itemCount;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *) collectionView {
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath {
    
    SYNCollectionVideoCell *videoThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNCollectionVideoCell reuseIdentifier]
                                                                                           forIndexPath:indexPath];
    
	VideoInstance *videoInstance = [self.model itemAtIndex:indexPath.item];
    
    if (videoInstance) {
        [videoThumbnailCell setEditable:NO];
        [videoThumbnailCell setVideoInstance:videoInstance];
        [videoThumbnailCell setDelegate:self];
    }
    
    return videoThumbnailCell;
}

- (void)collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath {
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return ((UICollectionViewFlowLayout*)self.cv.collectionViewLayout).itemSize;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    // cant seem to get value from the layout
    
    
    if (section != 0) {
        return CGSizeZero;
    }
    if (IS_IPHONE) {
        if (self.isUserProfile) {
            return CGSizeMake(320, ProfileHeaderHeightIPhone);
        } else {
            return CGSizeMake(320, ProfileHeaderHeightIPhone);
        }
    } else {
        if (UIDeviceOrientationIsPortrait([[SYNDeviceManager sharedInstance] orientation])) {
            return CGSizeMake(self.view.frame.size.width, ProfileHeaderHeightIPadPort);
        } else {
            return CGSizeMake(self.view.frame.size.width, ProfileHeaderHeightIPadLand);
        }
    }
    return CGSizeZero;
}


- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath {
    UICollectionReusableView *supplementaryView = nil;
	if (kind == UICollectionElementKindSectionHeader) {
        
        supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                               withReuseIdentifier: [SYNProfileHeader reuseIdentifier]
                                                                      forIndexPath: indexPath];
        self.headerView = ((SYNProfileHeader*)supplementaryView);
        self.headerView.isUserProfile = self.isUserProfile;
        self.headerView.channelOwner = self.channelOwner;
        self.headerView.delegate = ((SYNProfileViewController*)self.parentViewController);
        supplementaryView = self.headerView;
    }
    
	if (kind == UICollectionElementKindSectionFooter) {
		self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                             withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]
                                                                    forIndexPath:indexPath];
        supplementaryView = self.footerView;
		if ([self.model hasMoreItems]) {
			self.footerView.showsLoading = YES;
			
			[self.model loadNextPage];
		}
    }
    
    return supplementaryView;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
	return ((collectionView == self.cv && [self.model hasMoreItems]) ? [self footerSize] : CGSizeZero);
}

#pragma mark - SYNCollectionVideoCellDelegate

- (void)videoCell:(SYNCollectionVideoCell *)cell favouritePressed:(UIButton *)button {
	[self favouriteButtonPressed:button videoInstance:cell.videoInstance];
}


// TODO: abstract this call, Copy paste from Feed Root.
- (void)videoCell:(SYNCollectionVideoCell *)cell addToChannelPressed:(UIButton *)button {
    
    VideoInstance *videoInstance = cell.videoInstance;
	
    NSIndexPath *indexPath = [self.cv indexPathForCell:cell];
    TFLog(@"Feed: Video Instance from model :%@", [self.model itemAtIndex:indexPath.row]);

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
    TFLog(@"ProfileVideoViewController: Video instance :%@", videoInstance);

	[self presentViewController:viewController animated:YES completion:nil];
    
}

- (void)videoCell:(SYNCollectionVideoCell *)cell sharePressed:(UIButton *)button {
    [self shareVideoInstance:cell.videoInstance];
}

- (void)showVideoForCell:(SYNCollectionVideoCell *)cell {
    UIView *candidateCell = cell;
    
    while (![candidateCell isKindOfClass: [SYNCollectionVideoCell class]])
    {
        candidateCell = candidateCell.superview;
    }
    
    
    SYNCollectionVideoCell *selectedCell = (SYNCollectionVideoCell *) candidateCell;
    NSIndexPath *indexPath = [self.cv indexPathForItemAtPoint: selectedCell.center];
	
	SYNVideoPlayerViewController *viewController = [SYNVideoPlayerViewController viewControllerWithModel:self.model
																			   selectedIndex:indexPath.item];
	
	SYNVideoPlayerAnimator *animator = [[SYNVideoPlayerAnimator alloc] init];
	animator.delegate = self;
	animator.cellIndexPath = indexPath;
	
	self.videoPlayerAnimator = animator;
    viewController.dismissDelegate = self;
    
	viewController.transitioningDelegate = animator;
	[self presentViewController:viewController animated:YES completion:nil];
    
}

#pragma mark animation delegate

- (id<SYNVideoInfoCell>)videoCellForIndexPath:(NSIndexPath *)indexPath {
	return (SYNCollectionVideoCell *)[self.cv cellForItemAtIndexPath:indexPath];
}


#pragma mark - orientation change 

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    if (IS_IPAD) {
        [self updateLayoutForOrientation: toInterfaceOrientation];
    }
}


- (void) updateLayoutForOrientation: (UIDeviceOrientation) orientation
{
    if (IS_IPAD) {
        if (UIDeviceOrientationIsPortrait(orientation))
        {
            self.defaultLayout.sectionInset = UIEdgeInsetsMake(0, 36, 70, 36);
        }
        else
        {
            self.defaultLayout.sectionInset = UIEdgeInsetsMake(0, 20, 70, 20);
        }
        
        [self.cv.collectionViewLayout invalidateLayout];
    }
}

#pragma mark - SYNPagingModelDelegate

- (void)pagingModelDataUpdated:(SYNPagingModel *)pagingModel {
    
    
    
    [self.cv reloadData];
}

- (void)pagingModelErrorOccurred:(SYNPagingModel *)pagingModel {
	
}


#pragma mark - SYNVideoPlayerDismissIndex

- (void)dismissPosition:(NSInteger)index {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    self.videoPlayerAnimator.cellIndexPath = indexPath;


	[self.cv scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollDirectionVertical animated:NO];

    [self updateLayoutForOrientation: [[UIApplication sharedApplication] statusBarOrientation]];
    [self.cv.collectionViewLayout invalidateLayout];
    
    if (index+1<[self.model totalItemCount] && IS_IPHONE) {
        indexPath = [NSIndexPath indexPathForItem:index+1 inSection:0];
    }
    
    CGPoint point = [self calculateOffsetFromIndex:index];
 	[self.cv setContentOffset:point animated:NO];

}

- (CGPoint) calculateOffsetFromIndex :(NSInteger) index {
    float cellHeight = ((UICollectionViewFlowLayout*)self.cv.collectionViewLayout).itemSize.height;

    if (IS_IPHONE) {
        return CGPointMake(0, (index * cellHeight)+ProfileHeaderHeightIPhone+100);
    }

    
    if (IS_IPAD) {
        if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            
            if (index<2) {
                return CGPointMake(0, 80);
            }
            
            if (index<4) {
                return CGPointMake(0, 398);
            }
            
            if (index<6) {
                return CGPointMake(0, 714);
            }
            
            if (index + 2 > [self.model itemCount]) {
                index-=2;
            }
            
            return CGPointMake(0, (index/2 * cellHeight)+ProfileHeaderHeightIPadPort);
            
        } else {
            
            if (index<3) {
                return CGPointMake(0, 220);
            }
            
            if (index<6) {
                return CGPointMake(0, 540);
            }
            
            if (index+3 > [self.model itemCount]) {
                index-=3;
            }
            return CGPointMake(0, (index/3 * cellHeight) +ProfileHeaderHeightIPadLand);
        }
    }
    
    return CGPointZero;
}

@end
