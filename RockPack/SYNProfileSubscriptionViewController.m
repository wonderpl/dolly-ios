//
//  SYNProfileSubscriptionViewController.m
//  dolly
//
//  Created by Cong Le on 10/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNProfileSubscriptionViewController.h"
#import "SYNChannelMidCell.h"
#import "SYNChannelDetailsViewController.h"
#import "UIColor+SYNColor.h"
#import "SYNActivityManager.h"
#import "SYNProfileHeader.h"
#import "SYNChannelSearchCell.h"
#import "UICollectionReusableView+Helpers.h"
#import "UIFont+SYNFont.h"
#import "SYNDeviceManager.h"
#import "SYNProfileViewController.h"
#import "SYNSearchResultsUserCell.h"
#import "SYNFollowUserButton.h"


static const CGFloat PARALLAX_SCROLL_VALUE = 2.0f;
static const CGFloat SEARCHBAR_Y = 430.0f;
static const CGFloat FULL_NAME_LABEL_IPHONE = 364.0f; // lower is down
static const CGFloat FULL_NAME_LABEL_IPAD_PORTRAIT = 533.0f;
static const CGFloat FULLNAMELABELIPADLANDSCAPE = 412.0f;
static const CGFloat OWNUSERHEADERHEIGHT = 560;

@interface SYNProfileSubscriptionViewController () <UISearchBarDelegate, SYNPagingModelDelegate, SYNChannelMidCellDelegate,SYNSearchResultsUserCellDelegate>

@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *defaultLayout;
@property (nonatomic, strong) IBOutlet UIView *fakeNavigationBar;
@property (nonatomic, strong) IBOutlet UILabel *fakeNavigationBarTitle;
@property (nonatomic, strong) NSArray *filteredSubscriptions;
@property (nonatomic, strong) SYNProfileHeader* headerView;
@property (nonatomic, strong) UISearchBar* searchBar;
@property (nonatomic, strong) SYNProfileSubscriptionModel *model;
@property (nonatomic) BOOL showingDescription;


@end

@implementation SYNProfileSubscriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    [self.cv registerNib: [SYNChannelMidCell nib]
forCellWithReuseIdentifier: [SYNChannelMidCell reuseIdentifier]];
    
    [self.cv registerNib: [SYNProfileHeader nib]
forSupplementaryViewOfKind: UICollectionElementKindSectionHeader
     withReuseIdentifier: [SYNProfileHeader reuseIdentifier]];
    
    
    [self.cv registerNib: [SYNChannelSearchCell nib]
forCellWithReuseIdentifier:[SYNChannelSearchCell reuseIdentifier]];
    
	[self.cv registerNib: [SYNSearchResultsUserCell nib]
forCellWithReuseIdentifier:[SYNSearchResultsUserCell reuseIdentifier]];

	
    [self.cv registerNib:[SYNChannelFooterMoreView nib]
forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
     withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];
    
    self.filteredSubscriptions = [self.channelOwner.userSubscriptionsSet array];
    
    if (self.isUserProfile && IS_IPHONE) {
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, OWNUSERHEADERHEIGHT, CGRectGetWidth(self.cv.frame), 37)];
        self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchBar.delegate = self;
        
        self.searchBar.tintColor = [UIColor colorWithRed: (127.0f / 255.0f)
                                                   green: (127.0f / 255.0f)
                                                    blue: (127.0f / 255.0f)
                                                   alpha: 1.0f];
        self.searchBar.translucent = YES;
        
        self.searchBar.layer.borderWidth = IS_RETINA ? 0.5f: 1.0f;
        self.searchBar.layer.borderColor = [[UIColor dollyMediumGray] CGColor];
        
		
		self.defaultLayout.sectionInset = UIEdgeInsetsMake(self.searchBar.frame.size.height, 0, 70, 0);
		[self.cv setCollectionViewLayout:self.defaultLayout];
        [self.cv addSubview:self.searchBar];
		
    }
    
    self.fakeNavigationBarTitle.font = [UIFont regularCustomFontOfSize:20];
    [self.fakeNavigationBarTitle setText: self.channelOwner.displayName];
    
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    if (IS_IPAD) {
        [self updateLayoutForOrientation: [[SYNDeviceManager sharedInstance] orientation]];
    }
}


- (void)setChannelOwner:(ChannelOwner *)channelOwner {
    _channelOwner = channelOwner;
    self.model = [SYNProfileSubscriptionModel modelWithChannelOwner:channelOwner];
    self.model.delegate = self;
}

- (void)setShowingDescription:(BOOL)showingDescription {
	_showingDescription = showingDescription;
}


#pragma mark - Scrollview delegates

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [super scrollViewWillBeginDragging:scrollView];
    [self hideDescriptionCurrentlyShowing];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    [self coverPhotoAnimation];
	[self moveNameLabelWithOffset:scrollView.contentOffset.y];

}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self moveNameLabelWithOffset:scrollView.contentOffset.y];
}

- (void)coverPhotoAnimation {
    if (self.cv.contentOffset.y<=0) {
        [self.headerView.coverImage setContentMode:UIViewContentModeScaleAspectFill];
        [self.headerView.coverImageTop setConstant:self.cv.contentOffset.y];
    } else {
        [self.headerView.coverImage setContentMode:UIViewContentModeCenter];
        [self.headerView.coverImageTop setConstant:self.cv.contentOffset.y/PARALLAX_SCROLL_VALUE];
    }
}

- (void)moveNameLabelWithOffset :(CGFloat) offset {
    
    float offSetCheck = IS_IPHONE? FULL_NAME_LABEL_IPHONE: UIDeviceOrientationIsPortrait([[SYNDeviceManager sharedInstance] orientation]) ? FULL_NAME_LABEL_IPAD_PORTRAIT: FULLNAMELABELIPADLANDSCAPE;
    
    if (offset > offSetCheck) {
		[self.delegate hideNavigationBar];
	} else {
		[self.delegate showNavigationBar];
    }
}


#pragma mark - UICollectionView DataSource/Delegate

- (NSInteger)collectionView: (UICollectionView *) view numberOfItemsInSection: (NSInteger) section {	
    return self.filteredSubscriptions.count;
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView {
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath {
    
    NSInteger index = indexPath.row;
    
	SYNSearchResultsUserCell *channelThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: [SYNSearchResultsUserCell reuseIdentifier] forIndexPath: indexPath];
	
	ChannelOwner *channelOwner;
	
	if (index < [self.filteredSubscriptions count]) {
		channelOwner = self.filteredSubscriptions[index];
		//text is set in the channelmidcell setChannel method
		channelThumbnailCell.channelOwner = channelOwner;
	}
	
	channelThumbnailCell.followButton.selected = [[SYNActivityManager sharedInstance] isSubscribedToUserId:channelOwner.uniqueId];
	
	channelThumbnailCell.delegate = self;
	
    return channelThumbnailCell;
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath {
	
    if (indexPath.row < [self.filteredSubscriptions count]) {
        ChannelOwner *channelOwner = (ChannelOwner*)(self.filteredSubscriptions[indexPath.row]);
		[self viewProfileDetails:channelOwner];
		[self.searchBar resignFirstResponder];
		self.filteredSubscriptions = [self filteredSubscriptionsForSearchTerm:@""];
	}
    
    return;
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
        self.headerView.channelOwner = self.channelOwner;
        self.headerView.isUserProfile = self.isUserProfile;
        self.headerView.delegate = (SYNProfileViewController*)self.parentViewController;

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


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    // cant seem to get value from the layout
    
    if (IS_IPHONE) {
        if (self.isUserProfile) {
            return CGSizeMake(320, 560);
        } else {
            return CGSizeMake(320, 560);
        }
    } else {
        if (UIDeviceOrientationIsPortrait([[SYNDeviceManager sharedInstance] orientation])) {
            return CGSizeMake(self.view.frame.size.width, 780);
        } else {
            return CGSizeMake(self.view.frame.size.width, 664);
        }
    }
    return CGSizeZero;
}


#pragma mark - Searchbar delegates

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self.cv setContentOffset:CGPointZero animated:YES];
    
        UIEdgeInsets tmp = self.defaultLayout.sectionInset;
        tmp.bottom = 70;
        self.defaultLayout.sectionInset = tmp;
        [self.cv.collectionViewLayout invalidateLayout];
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
	[self.cv reloadData];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.cv reloadData];
    
    if (searchBar.text.length == 0) {
        [self.searchBar setShowsCancelButton:NO animated:YES];
    } else {
        [self.searchBar setShowsCancelButton:YES animated:YES];
    }
    
    self.cv.contentOffset = CGPointMake(0, SEARCHBAR_Y);
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
        
    if (searchBar.text.length == 0) {
        [self.searchBar setShowsCancelButton:NO animated:YES];
    } else {
        self.searchBar.showsCancelButton = YES;
    }

	self.filteredSubscriptions = [self filteredSubscriptionsForSearchTerm:searchBar.text];
    [self.cv reloadData];
	
	[self.searchBar becomeFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)bar {
    
        [UIView animateWithDuration:0.2 animations:^{
            self.cv.contentOffset = CGPointMake(0, SEARCHBAR_Y);
            
        } completion:^(BOOL finished) {
            UIEdgeInsets tmp = self.defaultLayout.sectionInset;
            tmp.bottom = 300;
            self.defaultLayout.sectionInset = tmp;
            [self.cv.collectionViewLayout invalidateLayout];
        }];
        [self.searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (NSArray *)filteredSubscriptionsForSearchTerm:(NSString *)searchTerm {
	if ([searchTerm length]) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"displayName BEGINSWITH[cd] %@", searchTerm];
		return [[self.channelOwner.userSubscriptionsSet array] filteredArrayUsingPredicate:predicate];
	}
	
	return [self.channelOwner.userSubscriptionsSet array];
}


#pragma mark - Gesture reconisers

- (void)dismissKeyboard {
    [self.searchBar resignFirstResponder];
}

#pragma mark - SYNChannelMidCellDelegate
- (void)cellStateChanged {
    [self hideDescriptionCurrentlyShowing];
	self.showingDescription = YES;
}


#pragma mark - bar buttons

- (void)hideDescriptionCurrentlyShowing{
    for (UICollectionViewCell *cell in [self.cv visibleCells]) {
        if ([cell isKindOfClass:[SYNChannelMidCell class]]) {
            if (((SYNChannelMidCell*)cell).state != ChannelMidCellStateAnimating) {
                [((SYNChannelMidCell*)cell) setState:ChannelMidCellStateDefault withAnimation:YES];
            }
        }
    }
	self.showingDescription = NO;
}


#pragma mark - SYNPagingModelDelegate
- (void)pagingModelDataUpdated:(SYNPagingModel *)pagingModel {
	
	self.headerView.channelOwner.subscriptionCountValue = self.model.totalItemCount;
	[self.headerView setSegmentedControllerText];

    [self.cv reloadData];
    [self.headerView.segmentedController setSelectedSegmentIndex:1];
}

- (void)pagingModelErrorOccurred:(SYNPagingModel *)pagingModel {
}

#pragma mark - Orientation change

- (void)willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration {
	
    if (IS_IPHONE) {
        return;
    }

    [self updateLayoutForOrientation: toInterfaceOrientation];
}


- (void)updateLayoutForOrientation: (UIDeviceOrientation) orientation {
    
    if (UIDeviceOrientationIsPortrait(orientation)) {
        self.defaultLayout.sectionInset = UIEdgeInsetsMake(0, 44.0, 70.0, 44.0);
        self.defaultLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 701);
    } else {
        self.defaultLayout.sectionInset = UIEdgeInsetsMake(0.0, 21.0, 70.0, 21.0);
        self.defaultLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 574);
    }
    
    [self.cv.collectionViewLayout invalidateLayout];
}


- (BOOL)isUserProfile {
	return [_channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId];
}

- (void)profileButtonTapped:(UIButton *)button {
	
	
	NSLog(@"PROFILE BUTTON TAPPED");
	
}

- (void)followControlPressed:(UIButton *)button {
	
	NSLog(@"FOLLOW CONTROLL TAPPED");
	
}


@end
