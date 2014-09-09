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
#import "SYNTrackingManager.h"
#import "SYNVideoPlayerViewController.h"
#import "SYNVideoPlayerAnimator.h"
#import "UINavigationBar+Appearance.h"
#import <TestFlight.h>
#import "SYNFeedVideoCell.h"
#import "SYNFeedVideoLargeCell.h"
#import "ChannelOwner.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNWebViewController.h"
#import "SYNDescriptionViewController.h"
#import "SYNYouTubeWebVideoPlayer.h"

static const CGFloat PARALLAX_SCROLL_VALUE = 2.0f;
static const CGFloat ProfileHeaderHeightIPhone = 523;
static const CGFloat ProfileHeaderHeightIPadPort = 780;
static const CGFloat ProfileHeaderHeightIPadLand = 664;


@interface SYNProfileVideoViewController () <UIViewControllerTransitioningDelegate, SYNVideoPlayerAnimatorDelegate, SYNPagingModelDelegate, SYNVideoPlayerDismissIndex, SYNFeedVideoCellDelegate, SYNVideoPlayerDelegate>
@property (strong, nonatomic) SYNProfileHeader* headerView;
@property (strong, nonatomic) SYNProfileVideoModel *model;
@property (strong, nonatomic) SYNVideoPlayerAnimator *videoPlayerAnimator;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *defaultLayout;
@property (strong, nonatomic) SYNVideoPlayer *currentVideoPlayer;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, retain) IBOutlet UIPopoverController *descriptionPopOver;
@property (nonatomic, assign) UIDeviceOrientation videoOrientation;

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
    
    [self.cv registerNib:[SYNFeedVideoCell nib] forCellWithReuseIdentifier:[SYNFeedVideoCell reuseIdentifier]];
    [self.cv registerNib:[SYNFeedVideoLargeCell nib] forCellWithReuseIdentifier:[SYNFeedVideoLargeCell reuseIdentifier]];

    [self.cv registerNib:[SYNChannelFooterMoreView nib] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];

    [self.cv registerNib: [SYNProfileHeader nib] forSupplementaryViewOfKind: UICollectionElementKindSectionHeader withReuseIdentifier:[SYNProfileHeader reuseIdentifier]];

    if (IS_IPAD) {
	//[self updateLayoutForOrientation: [SYNDeviceManager.sharedInstance orientation]];
        [self.navigationController.navigationBar setBackgroundTransparent:YES];
        self.navigationController.navigationBarHidden = YES;
    }
    
    self.model.delegate = self;
    self.selectedIndex = -1;
    
    if (IS_IPHONE) {
		self.videoOrientation = [[UIDevice currentDevice] orientation];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(deviceOrientationChanged:)
													 name:UIDeviceOrientationDidChangeNotification
												   object:nil];
	}

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.currentVideoPlayer) {
        self.currentVideoPlayer.delegate = self;
    }
    
    if (self.currentVideoPlayer.state == SYNVideoPlayerStatePlaying) {
		[self.currentVideoPlayer play];
    }


}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.cv reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.currentVideoPlayer pause];
}

#pragma mark - Scrollview delegates

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [super scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    NSLog(@"%f", scrollView.contentOffset.y);
    [self coverPhotoAnimation];
    
    [super scrollViewDidScroll:scrollView];
    
    BOOL isCurrentVideoPlayerOffScreen = NO;
    for (UICollectionViewCell *cell in [self.cv visibleCells]) {
        if ([self.cv indexPathForCell:cell].row == self.selectedIndex) {
            isCurrentVideoPlayerOffScreen = YES;
        }
    }
    
    if (!isCurrentVideoPlayerOffScreen) {
        if (self.currentVideoPlayer.state == SYNVideoPlayerStatePrePlaying) {
            if ([self.currentVideoPlayer isKindOfClass:[SYNYouTubeWebVideoPlayer class]]) {
                [((SYNYouTubeWebVideoPlayer*)self.currentVideoPlayer).reloadVideoTimer invalidate];
            }
        }
        [self.currentVideoPlayer pause];
    }

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
    
    SYNFeedVideoCell *cell;

    NSString *reuseId = IS_IPHONE ? [SYNFeedVideoCell reuseIdentifier] : [SYNFeedVideoLargeCell reuseIdentifier];
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier: reuseId
                                                     forIndexPath:indexPath];
    
	VideoInstance *videoInstance = [self.model itemAtIndex:indexPath.item];
    
    if (videoInstance) {
        cell.videoInstance = videoInstance;
        cell.delegate = self;
        if (indexPath.item == self.selectedIndex && self.currentVideoPlayer) {
            cell.videoPlayerCell.videoPlayer = self.currentVideoPlayer;
            cell.videoPlayerCell.hidden = NO;
        } else {
            cell.videoPlayerCell.hidden = YES;
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
				  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_IPAD) {
        if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            return CGSizeMake(768, 738);
        } else {
            return CGSizeMake(1024, 768);
        }
    }
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

#pragma mark animation delegate

- (id<SYNVideoInfoCell>)videoCellForIndexPath:(NSIndexPath *)indexPath {
	return (SYNFeedVideoCell *)[self.cv cellForItemAtIndexPath:indexPath];
}


#pragma mark - orientation change 

- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration {
	if (IS_IPAD) {
        [self updateLayoutForOrientation: toInterfaceOrientation];
    }
}


- (void)updateLayoutForOrientation: (UIDeviceOrientation) orientation {
    if (IS_IPAD) {
        if (UIDeviceOrientationIsPortrait(orientation)) {
//            self.defaultLayout.sectionInset = UIEdgeInsetsMake(0, 55, 70, 55);
        } else {
//            self.defaultLayout.sectionInset = UIEdgeInsetsMake(0, 30, 70, 30);
        }
        [self.cv.collectionViewLayout invalidateLayout];
    }
}


- (void)deviceOrientationChanged:(NSNotification *)notification {
	UIDevice *device = [notification object];
	
	if (device.orientation == UIDeviceOrientationPortrait) {
	} else if (UIDeviceOrientationIsLandscape(device.orientation)) {
		self.videoOrientation = device.orientation;
        
        if (IS_IPHONE) {
            if ([self isVideoOnScreen]) {
            	[self videoPlayerMaximise];
            }
        }
    }
}

- (BOOL)isVideoOnScreen {
    NSArray *arr = [self.cv visibleCells];
    for (UICollectionViewCell *cell in arr) {
        if ([self.cv indexPathForCell:cell].row == self.selectedIndex) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - SYNPagingModelDelegate

- (void)pagingModelDataUpdated:(SYNPagingModel *)pagingModel {
    [self.cv reloadData];
}

- (void)pagingModelErrorOccurred:(SYNPagingModel *)pagingModel {
	
}


#pragma mark - SYNVideoPlayerDismissIndex

- (void) dismissPosition:(NSInteger)index :(SYNVideoPlayer *)videoPlayer {
    self.currentVideoPlayer = videoPlayer;
    self.currentVideoPlayer.delegate = self;
    self.selectedIndex = index;
    [self dismissPosition:index];
}

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

    if (IS_IPAD) {
        if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            cellHeight = 768;
        } else {
            cellHeight = 738;
        }
    }

    if (IS_IPHONE) {
        return CGPointMake(0, (index * cellHeight)+ProfileHeaderHeightIPhone+100);
    }

    if (IS_IPAD) {
        if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            return CGPointMake(0, (cellHeight*index) + ProfileHeaderHeightIPadPort);
        } else {
            return CGPointMake(0, (cellHeight*index) + ProfileHeaderHeightIPadLand);
        }
    }
    
    return CGPointZero;
}


#pragma mark - SYNFeedVideoCellDelegate

- (void)videoCellAvatarPressed:(SYNFeedVideoCell *)cell {
	VideoInstance *videoInstance = cell.videoInstance;
	[[SYNTrackingManager sharedManager] trackVideoOriginatorPressed:videoInstance.originator.displayName];
    
    [self.currentVideoPlayer pause];
	[self viewProfileDetails:videoInstance.originator];
}

- (void)videoCellThumbnailPressed:(SYNFeedVideoCell *)cell {
    
    if (self.selectedIndex == [[self.cv indexPathForCell:cell] row]) {
        return;
    }
    
    [self playVideoInCell:cell];
}

- (void)playVideoInCell:(SYNFeedVideoCell*) cell{
    
    cell.videoPlayerCell.hidden = NO;
    cell.playButton.hidden = YES;
    
    [self.currentVideoPlayer stop];
    SYNVideoPlayer *videoPlayer = [SYNVideoPlayer playerForVideoInstance:cell.videoInstance];
    cell.videoPlayerCell.videoPlayer = videoPlayer;
	[videoPlayer play];
	self.currentVideoPlayer = videoPlayer;
    self.currentVideoPlayer.delegate = self;
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if (self.selectedIndex > 0) {
        [arr addObject: [NSIndexPath indexPathForItem:self.selectedIndex inSection:0]];
    }
    [arr addObject:[NSIndexPath indexPathForItem:[[self.cv indexPathForCell:cell] row] inSection:0]];
    self.selectedIndex = [[self.cv indexPathForCell:cell] row];
    [self.cv reloadItemsAtIndexPaths:arr];
}

- (void)videoCell:(SYNFeedVideoCell *)cell favouritePressed:(UIButton *)button {
	[self favouriteButtonPressed:button videoInstance:cell.videoInstance];
}

- (void)videoCell:(SYNFeedVideoCell *)cell addToChannelPressed:(UIButton *)button {
    NSIndexPath *indexPath = [self.cv indexPathForCell:cell];
	TFLog(@"Feed: Video Instance from model :%@", [self.model itemAtIndex:indexPath.row]);
    [self addToChannelButtonPressed:button videoInstance:cell.videoInstance];
}

- (void)videoCell:(SYNFeedVideoCell *)cell sharePressed:(UIButton *)button {
	[self shareVideoInstance:cell.videoInstance];
}

- (void)videoCell:(SYNFeedVideoCell *)cell clickToMorePressed:(UIButton *)button {
    Video *video = cell.videoInstance.video;
	NSURL *linkURL = [NSURL URLWithString:video.linkURL];
	
	UIViewController *viewController = [SYNWebViewController webViewControllerForURL:linkURL withTrackingName:@"Click to more"];
    
	[self presentViewController:viewController animated:YES completion:nil];
    
    [[SYNTrackingManager sharedManager] trackClickToMoreWithTitle:cell.videoInstance.title
                                                              URL:video.linkURL];
    
}


- (void)videoCell:(SYNFeedVideoCell *)cell followButtonPressed:(UIButton *)button {
	[self followControlPressed:button withChannelOwner:cell.videoInstance.originator withVideoInstace:cell.videoInstance completion:nil];
}

- (void)videoCell:(SYNFeedVideoCell *)cell descriptionButtonTapped:(UIButton *)button {
        SYNDescriptionViewController *viewController = [[SYNDescriptionViewController alloc ]init];
        viewController.contentHTML = cell.videoInstance.video.videoDescription;
        viewController.modalPresentationStyle = UIModalPresentationCustom;
        viewController.transitioningDelegate = self;
        [self presentViewController:viewController animated:YES completion:nil];
}

- (void)videoCell:(SYNFeedVideoCell *)cell addedByPressed:(UIButton *)button {
	VideoInstance *videoInstance = cell.videoInstance;
	
	[[SYNTrackingManager sharedManager] trackVideoAddedByPressed:videoInstance.channel.channelOwner.displayName];
    [self.currentVideoPlayer pause];
	[self viewProfileDetails:videoInstance.channel.channelOwner];
}

#pragma mark - 

- (void)videoCell:(SYNFeedVideoCell *)cell maximiseVideoPlayer:(UIButton *)button {
	NSIndexPath *indexPath = [self.cv indexPathForCell:cell];
    
	// We need to convert it to the index in the array of videos since the player doesn't know about channels
	//	NSInteger itemIndex = [self.model itemIndexForFeedIndex:indexPath.row];
    
	SYNVideoPlayerViewController *viewController = [SYNVideoPlayerViewController viewControllerWithModel:self.model
                                                                                           selectedIndex:[self.cv indexPathForCell:cell].row];
    
    viewController.currentVideoPlayer = self.currentVideoPlayer;
    
    //    [viewController.videosCollectionView reloadData];
    
	SYNVideoPlayerAnimator *animator = [[SYNVideoPlayerAnimator alloc] init];
	animator.delegate = self;
	animator.cellIndexPath = indexPath;
	self.videoPlayerAnimator = animator;
	viewController.transitioningDelegate = animator;
	viewController.dismissDelegate = self;
	[self presentViewController:viewController animated:YES completion:nil];
}

- (void)videoPlayerStartedPlaying {
    
}

- (void)videoPlayerVideoViewed {
    
}

- (void)videoPlayerFinishedPlaying {
}

- (void)videoPlayerErrorOccurred:(NSString *)reason {
    
}

- (void)videoPlayerAnnotationSelected:(VideoAnnotation *)annotation button:(UIButton *)button {
    
}

- (void)videoPlayerMinimise {
}

- (void)videoPlayerMaximise {
	// We need to convert it to the index in the array of videos since the player doesn't know about channels
    
	SYNVideoPlayerViewController *viewController = [SYNVideoPlayerViewController viewControllerWithModel:self.model
                                                                                           selectedIndex:self.selectedIndex];
    
    viewController.currentVideoPlayer = self.currentVideoPlayer;
    viewController.currentVideoPlayer.delegate = viewController;
	SYNVideoPlayerAnimator *animator = [[SYNVideoPlayerAnimator alloc] init];
	animator.delegate = self;
	animator.cellIndexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
	self.videoPlayerAnimator = animator;
	viewController.transitioningDelegate = animator;
	viewController.dismissDelegate = self;
	[self presentViewController:viewController animated:NO completion:nil];
}

- (void)pauseCurrentVideo {
    [self.currentVideoPlayer pause];
}

@end
