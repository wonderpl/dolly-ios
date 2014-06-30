//
//  SYNSearchResultsViewController.m
//  dolly
//
//  Created by Michael Michailidis on 21/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNetworkEngine.h"
#import "SYNSearchResultsCell.h"
#import "SYNSearchResultsUserCell.h"
#import "SYNSearchResultsViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNChannelFooterMoreView.h"
#import "UIColor+SYNColor.h"
#import "UICollectionReusableView+Helpers.h"
#import "ChannelOwner.h"
#import "VideoInstance.h"
#import "SYNActivityManager.h"
#import "SYNVideoPlayerAnimator.h"
#import "SYNGenreManager.h"
#import "UIFont+SYNFont.h"
#import "SYNDeviceManager.h"
#import "SYNMasterViewController.h"
#import "SYNDiscoverOverlayVideoViewController.h"
#import "SYNDiscoverOverlayHighlightsViewController.h"
#import "SYNTrackingManager.h"
#import "SYNVideoPlayerViewController.h"
#import "SYNStaticModel.h"
#import "SYNSearchVideoCell.h"
#import "SYNSearchVideoLargeCell.h"
#import "SYNSearchVideoSmallCell.h"
#import "SYNSocialButton.h"
#import "SYNVideoPlayerDismissIndex.h"


typedef NS_ENUM(NSInteger, SYNSearchType) {
	SYNSearchTypeUndefined,
	SYNSearchTypeBrowse,
	SYNSearchTypeSearch
};

typedef void (^SearchResultCompleteBlock)(int);

@interface SYNSearchResultsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, SYNVideoPlayerAnimatorDelegate,SYNVideoPlayerDismissIndex>
@property (strong, nonatomic) IBOutlet UIView *segmentedContainer;

// UI stuff
@property (strong, nonatomic) IBOutlet UILabel *noVideosLabel;
@property (strong, nonatomic) IBOutlet UILabel *noUsersLabel;

// search operations
@property (nonatomic, strong) MKNetworkOperation *videoSearchOperation;
@property (nonatomic, strong) MKNetworkOperation *userSearchOperation;

// @property (nonatomic) NSRange dataRequestRange; is from SYNAbstract, here we need a second for users
@property (nonatomic) NSRange dataRequestRange2;
@property (nonatomic) NSInteger dataItemsAvailable2;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topVideoContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topUserContraint;

@property (nonatomic) SearchResultsShowing searchResultsShowing;
@property (nonatomic, strong) NSString *currentSearchTerm;

// completion blocks
@property (nonatomic, copy) SearchResultCompleteBlock videoSearchCompleteBlock;
@property (nonatomic, copy) SearchResultCompleteBlock userSearchCompleteBlock;


// Data Arrays
@property (nonatomic, strong) NSArray *videosArray;
@property (nonatomic, strong) NSArray *usersArray;
@property (nonatomic, strong) NSString* currentSearchGenre;
@property (nonatomic, strong) SYNVideoPlayerAnimator *videoPlayerAnimator;

@property (nonatomic, assign) SYNSearchType searchType;
@property (nonatomic, assign) BOOL shownOverlay;

@end


@implementation SYNSearchResultsViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // == Initialise the arrays == //
    
    self.videosArray = @[];
    self.usersArray = @[];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    
    self.view.autoresizesSubviews = YES;
	
    [self.videosCollectionView registerNib:[SYNSearchVideoCell nib]
                forCellWithReuseIdentifier:[SYNSearchVideoCell reuseIdentifier]];
    
	[self.videosCollectionView registerNib:[SYNSearchVideoLargeCell nib]
                forCellWithReuseIdentifier:[SYNSearchVideoLargeCell reuseIdentifier]];
	
	[self.videosCollectionView registerNib:[SYNSearchVideoSmallCell nib]
                forCellWithReuseIdentifier:[SYNSearchVideoSmallCell reuseIdentifier]];

    [self.videosCollectionView registerNib:[SYNChannelFooterMoreView nib]
                forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                       withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];
    
    [self.usersCollectionView registerNib:[SYNSearchResultsUserCell nib]
               forCellWithReuseIdentifier:[SYNSearchResultsUserCell reuseIdentifier]];
    
    [self.usersCollectionView registerNib:[SYNChannelFooterMoreView nib]
               forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                      withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];
    
    // == Define Completion Blocks for operations == //
    
    SYNSearchResultsViewController *wself = self;
    
    self.videoSearchCompleteBlock = ^(int count) {
        NSArray *fetchedObjects = [wself getSearchEntitiesByName:[VideoInstance entityName]];
        
        if (!fetchedObjects) {
            //handle error
            return;
        }
        
        wself.videosArray = [NSArray arrayWithArray: fetchedObjects];

        if (wself.searchResultsShowing == SearchResultsShowingVideos) {
            if (wself.videosArray.count == 0) {
                wself.noVideosLabel.hidden = NO;
            } else {
                wself.noVideosLabel.hidden = YES;
            }
        }
        // protection from being called twice, one for every tab and making the loader dissapear prematurely
//        if (wself.searchResultsShowing == SearchResultsShowingVideos)
            [wself removePopupMessage];
        
        wself.loadingMoreContent = NO;
        
        wself.dataItemsAvailable = (NSInteger)count;
        
        [wself.videosCollectionView reloadData];
    };
    
    
    self.userSearchCompleteBlock = ^(int count) {
        NSArray *fetchedObjects = [wself getSearchEntitiesByName:[ChannelOwner entityName]];
        
        if (!fetchedObjects) {
            // handle error
            return;
        }
        
        wself.usersArray = [NSArray arrayWithArray: fetchedObjects];
        if (wself.searchResultsShowing == SearchResultsShowingUsers) {
            if (wself.usersArray.count == 0) {
				BOOL searching = (wself.searchType == SYNSearchTypeSearch);
				NSString *message = (searching ? NSLocalizedString(@"no_users", @"no users in search") : NSLocalizedString(@"no_highlights", @"no highlights in search"));
				wself.noUsersLabel.text = message;

                wself.noUsersLabel.hidden = NO;
            } else {
                wself.noUsersLabel.hidden = YES;
            }
        }
        // protection from being called twice, one for every tab and making the loader dissapear prematurely
//        if (wself.searchResultsShowing == SearchResultsShowingUsers)
            [wself removePopupMessage];
        
        wself.loadingMoreContent = NO;
        
        
        wself.dataItemsAvailable2 = (NSInteger)count;
        
        [wself.usersCollectionView reloadData];
    };
    
    // Set Initial
    self.searchResultsShowing = SearchResultsShowingUsers;
    self.dataRequestRange2 = self.dataRequestRange; // they start off as (0, 48) for both...
    
    self.noVideosLabel.text = NSLocalizedString(@"no_videos", @"no videos in search");

    self.noUsersLabel.font = [UIFont regularCustomFontOfSize:18.0f];
    self.noVideosLabel.font = [UIFont regularCustomFontOfSize:18.0f];
    
	[self.videosTabButton.titleLabel setFont:[UIFont regularCustomFontOfSize:self.videosTabButton.titleLabel.font.pointSize]];

	[self.usersTabButton.titleLabel setFont:[UIFont regularCustomFontOfSize:self.usersTabButton.titleLabel.font.pointSize]];
		
	self.segmentedContainer.layer.borderWidth = IS_RETINA ? 0.5 : 1.0;
	self.segmentedContainer.layer.borderColor = [[UIColor dollySegmentedColor] CGColor];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	NSIndexPath *selectedIndexPath = [[self.videosCollectionView indexPathsForSelectedItems] firstObject];
	if (selectedIndexPath) {
		[self.videosCollectionView deselectItemAtIndexPath:selectedIndexPath animated:YES];
	}
    
    [self.usersCollectionView.collectionViewLayout invalidateLayout];
    self.shownOverlay = NO;
    if (self.searchResultsShowing == SearchResultsShowingUsers) {
        [self showUserOverLay];
    }
    // == So the unfollow/follow button gets updated 
 
    [self.usersCollectionView.collectionViewLayout invalidateLayout];
    
    [self.usersCollectionView reloadData];
    [self.videosCollectionView reloadData];
    
}

-(SYNPopupMessageView*) displayPopupMessage:(NSString *)messageKey withLoader:(BOOL)isLoader
{
    SYNPopupMessageView* pMsgView = [super displayPopupMessage:messageKey
                                                    withLoader:isLoader];
    
    CGRect rect = pMsgView.frame;
    rect.origin.y = (self.view.frame.size.height * 0.5) - 100.0f;
    pMsgView.frame = rect;
    
    return pMsgView;
}

- (NSString *)trackingScreenName {
	if (self.searchType == SYNSearchTypeBrowse) {
		return @"Browse";
	}
	if (self.searchType == SYNSearchTypeSearch) {
		return @"Search";
	}
	return nil;
}

#pragma mark - Button Delegates

- (void) profileButtonTapped: (UIButton *) profileButton
{
    if(!profileButton)
    {
        AssertOrLog(@"No profileButton passed");
        return; // did not manage to get the cell
    }
    
    id candidate = profileButton;
    while (![candidate isKindOfClass:[SYNSearchResultsUserCell class]]) {
        candidate = [candidate superview];
    }
    
    if(![candidate isKindOfClass:[SYNSearchResultsUserCell class]])
    {
        AssertOrLog(@"Did not manage to get the cell from: %@", profileButton);
        return; // did not manage to get the cell
    }
    SYNSearchResultsUserCell* searchUserCell = (SYNSearchResultsUserCell*)candidate;
    
    [self viewProfileDetails:searchUserCell.channelOwner];
}

#pragma mark - Load Data

// overload to support the second range
- (void) resetDataRequestRange
{
    // sets the first range
    [super resetDataRequestRange];
    
    //sets the second range
    self.dataRequestRange2 = NSMakeRange(0, STANDARD_REQUEST_LENGTH);
}

- (void) searchForGenre: (NSString *) genreId
{	
	if (IS_IPHONE) {
		self.topVideoContraint.constant = 64;
	} else {
		self.topVideoContraint.constant = 0;
		self.topUserContraint.constant = 19;
	}
	
	self.segmentedContainer.hidden = YES;

	Genre *genre = [[SYNGenreManager sharedManager] genreWithId:genreId];
	[[SYNTrackingManager sharedManager] setCategoryDimension:genre.name];
	
	self.searchType = SYNSearchTypeBrowse;

    //When searching for category, default to show users/highlights
    self.searchResultsShowing = SearchResultsShowingUsers;
    
    [self.usersTabButton setTitle:(NSLocalizedString(@"collections", @"Collections, discover tab")) forState:UIControlStateNormal];
    [self.usersTabButton setTitle:(NSLocalizedString(@"collections", @"Collections, discover tab")) forState:UIControlStateSelected];
    
    if([_currentSearchGenre isEqualToString: genreId]){
        return;
    }
	
    self.noVideosLabel.hidden = YES;
    self.noUsersLabel.hidden = YES;
	
    [self resetDataRequestRange];
    
    // we either store one or the other
    _currentSearchGenre = genreId;
    _currentSearchTerm = nil;
    
    if(!_currentSearchGenre)
        return;
    
    if(![self clearSearchEntities])
        return;
    
    [self displayPopupMessage:@"Searching..." withLoader:YES];
    
    // == Perform Search for Genre == //

    self.userSearchOperation = [appDelegate.networkEngine usersForGenreId: _currentSearchGenre
                                                                 forRange: self.dataRequestRange2
                                                        completionHandler:^(int value) {
                                                            self.userSearchCompleteBlock(value);
                                                            [self showUserOverLay];
                   }];
}

- (void) searchForTerm: (NSString *) newSearchTerm
{
	
	if (IS_IPHONE) {
		self.topVideoContraint.constant = 101;

	} else {
		self.topVideoContraint.constant = 49;
		self.topUserContraint.constant = 53;
	}
	
	self.segmentedContainer.hidden = NO;

	[[SYNTrackingManager sharedManager] setCategoryDimension:nil];
	
	self.searchType = SYNSearchTypeSearch;

    [self.usersTabButton setTitle:NSLocalizedString(@"users", @"Users in discover tab") forState:UIControlStateNormal];
    [self.usersTabButton setTitle:NSLocalizedString(@"users", @"Users in discover tab") forState:UIControlStateSelected];
    
    //searching a term defaults to videos
    self.searchResultsShowing = SearchResultsShowingVideos;


    if ([_currentSearchTerm isEqualToString: newSearchTerm]) // == Don't repeat a search == //
    {
        return;
    }
	
    self.noVideosLabel.hidden = YES;
    self.noUsersLabel.hidden = YES;
    
    // we either store one or the other
    _currentSearchTerm = newSearchTerm;
    _currentSearchGenre = nil;
    
    if (!_currentSearchTerm)
    {
        return;
    }
    
    if(![self clearSearchEntities])
    {
        return;
    }
    
    [self resetDataRequestRange];
    
    [self displayPopupMessage:@"Searching..." withLoader:YES];
    
    // == Perform Search == //
    
    self.videoSearchOperation = [appDelegate.networkEngine searchVideosForTerm: _currentSearchTerm
                                                                       inRange: self.dataRequestRange
                                                                    onComplete:^(int value) {
                                                                        self.videoSearchCompleteBlock(value);
                                                                    }];
    
    self.userSearchOperation = [appDelegate.networkEngine searchUsersForTerm: _currentSearchTerm
                                                                    andRange: self.dataRequestRange
                                                                  onComplete: self.userSearchCompleteBlock];
    

}

- (BOOL) clearSearchEntities {
	
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[AbstractCommon entityName]];
	NSArray *array = [appDelegate.searchManagedObjectContext executeFetchRequest:fetchRequest error:nil];
	for (AbstractCommon *object in array) {
		[appDelegate.searchManagedObjectContext deleteObject:object];
	}
	
	[appDelegate.searchManagedObjectContext save:nil];

	self.videosArray = @[];
	self.usersArray = @[];

	[self.videosCollectionView reloadData];
	[self.usersCollectionView reloadData];

	return YES;
}


- (NSArray *)getSearchEntitiesByName:(NSString *)entityName {
	NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"viewId == %@", self.viewId]];
    fetchRequest.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES] ];
    
    return [appDelegate.searchManagedObjectContext executeFetchRequest:fetchRequest error:nil];
}


#pragma mark - UICollectionView Delegate/Data Source


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}


- (NSInteger) collectionView: (UICollectionView *) collectionView numberOfItemsInSection: (NSInteger) section
{
    NSInteger count = 0;
    
    if (collectionView == self.videosCollectionView)
    {
        count = self.videosArray.count;
    }
    else if (collectionView == self.usersCollectionView)
    {
        count = self.usersArray.count;
    }
    
    return count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNSearchResultsCell *cell;
    
    if (collectionView == self.videosCollectionView)
    {
		
		BOOL isLargeCell = IS_IPAD && UIDeviceOrientationIsLandscape([[SYNDeviceManager sharedInstance] orientation]);
		
		NSString *reuseIdentifier = (isLargeCell ? [SYNSearchVideoLargeCell reuseIdentifier]
									 : [SYNSearchVideoSmallCell reuseIdentifier]);

        SYNSearchVideoCell *videoCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                                         forIndexPath:indexPath];
        
		videoCell.videoInstance = (VideoInstance*)(self.videosArray[indexPath.item]);
			
        return videoCell;
    }
    else if (collectionView == self.usersCollectionView)
    {
        SYNSearchResultsUserCell *userCell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNSearchResultsUserCell reuseIdentifier]
                                                                                       forIndexPath:indexPath];
        
        
        userCell.channelOwner = (ChannelOwner*)(self.usersArray[indexPath.item]);
        
        
        if (IS_IPAD) {
            if (indexPath.row>2) {
                userCell.descriptionLabel.hidden = YES;
            } else {
                userCell.descriptionLabel.hidden = NO;
            }
        } else {
            if (indexPath.row>1) {
                userCell.descriptionLabel.hidden = YES;
            } else {
                userCell.descriptionLabel.hidden = NO;
            }
        }
        // As the followButton needs to be a SYNSocialButton to tie in with the callbacks we just need to style it on the fly
        userCell.followButton.titleLabel.font = [UIFont lightCustomFontOfSize:12.0f];
        
        if ([[SYNActivityManager sharedInstance] isSubscribedToUserId:userCell.channelOwner.uniqueId]) {
            [userCell.followButton setTitle:(NSLocalizedString(@"unfollow", "unfollow a user, search view controller"))];
            userCell.followButton.selected = YES;
        }
        else
        {
            [userCell.followButton setTitle:(NSLocalizedString(@"follow", "follow a user, search view controller"))];
            userCell.followButton.selected = NO;
        }
        // ================= //
        
        cell = userCell;
    }
    
    cell.delegate = self;
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	if (collectionView == self.videosCollectionView) {
        SYNStaticModel *model = [[SYNStaticModel alloc] initWithItems:self.videosArray];
		SYNVideoPlayerViewController *viewController = [SYNVideoPlayerViewController viewControllerWithModel:model
																				   selectedIndex:indexPath.item];
        
		SYNVideoPlayerAnimator *animator = [[SYNVideoPlayerAnimator alloc] init];
		animator.delegate = self;
		animator.cellIndexPath = indexPath;
		self.videoPlayerAnimator = animator;
        viewController.dismissDelegate = self;
		viewController.transitioningDelegate = animator;
		
		[self presentViewController:viewController animated:YES completion:nil];
	}
    
    if (collectionView == self.usersCollectionView) {
        ChannelOwner *channelOwner = (ChannelOwner*)(self.usersArray[indexPath.item]);
        [self viewProfileDetails:channelOwner];
    }
}

- (id<SYNVideoInfoCell>)videoCellForIndexPath:(NSIndexPath *)indexPath {
	return (SYNSearchVideoCell *)[self.videosCollectionView cellForItemAtIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.usersCollectionView) {
    
        if (IS_IPHONE) {
            if (indexPath.row<2) {
                return CGSizeMake(320, 192);
            } else {
                return CGSizeMake(320, 101);
            }
        }
        
        if (IS_IPAD) {
            
            if (UIDeviceOrientationIsPortrait([SYNDeviceManager.sharedInstance orientation])) {
                if (indexPath.row == 0) {
                    return CGSizeMake(360, 210);
                } else if (indexPath.row == 1 || indexPath.row == 2) {
                    return CGSizeMake(360, 165);
                } else {
                    return CGSizeMake(360, 102);
                }
            } else {
                
                if (indexPath.row == 0) {
                    return CGSizeMake(582, 210);
                } else if (indexPath.row == 1 || indexPath.row == 2) {
                    return CGSizeMake(282, 164);
                } else {
                    return CGSizeMake(282, 102);
                }
            }
        }
    } else {
		
		if (IS_IPHONE) {
				return CGSizeMake(320, 85);
		} else {
			
			if (UIDeviceOrientationIsPortrait([SYNDeviceManager.sharedInstance orientation])) {
				return CGSizeMake(386, 90);
			} else {
				return CGSizeMake(604, 148);
			}
		}
		
        return ((UICollectionViewFlowLayout*)self.videosCollectionView.collectionViewLayout).itemSize;
    }
    return CGSizeZero;
}

- (CGSize) collectionView: (UICollectionView *) collectionView
                   layout: (UICollectionViewLayout*) collectionViewLayout
referenceSizeForFooterInSection: (NSInteger) section
{
    if(collectionView == self.videosCollectionView && [self moreItemsToLoad])
    {
        return [self footerSize];
    }
    else if(collectionView == self.usersCollectionView && [self moreItemsToLoad2])
    {
        return [self footerSize];
    }
    
    return CGSizeZero;
}

- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView *supplementaryView = nil;
    
	if (kind == UICollectionElementKindSectionFooter)
    {
        
        self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                             withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]
                                                                    forIndexPath:indexPath];
        supplementaryView = self.footerView;
        
        // only show footer spinner after first load
        NSUInteger count = 0;
        if (collectionView == self.videosCollectionView)
        {
            count = [self.videosArray count];
        }
        else if (collectionView == self.usersCollectionView)
        {
            count = [self.usersArray count];
        }

        if (count>0) {
            self.footerView.showsLoading = self.isLoadingMoreContent;
        }
        
    }
    
    return supplementaryView;
}



- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [self.usersCollectionView.collectionViewLayout invalidateLayout];
	[self.videosCollectionView.collectionViewLayout invalidateLayout];
	[self.usersCollectionView reloadData];
	[self.videosCollectionView reloadData];

    
}

#pragma mark - Scroll view delegates

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    [super scrollViewDidScroll:scrollView];
    
    if(scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - kLoadMoreFooterViewHeight && !self.isLoadingMoreContent)
    {
        // Videos
        
        
        if(scrollView == self.videosCollectionView && self.moreItemsToLoad)
        {
            [self incrementRangeForNextRequest];
            
            if(_currentSearchGenre)
            {
                self.videoSearchOperation = [appDelegate.networkEngine videosForGenreId: _currentSearchGenre
                                                                               forRange: self.dataRequestRange
                                                                      completionHandler: self.videoSearchCompleteBlock];
                
                
                
            }
            else if(_currentSearchTerm)
            {
                self.videoSearchOperation = [appDelegate.networkEngine searchVideosForTerm: _currentSearchTerm
                                                                                   inRange: self.dataRequestRange
                                                                                onComplete: self.videoSearchCompleteBlock];
                
            }
            
        }
        else if (scrollView == self.usersCollectionView && self.moreItemsToLoad2)
        {
            [self incrementRangeForNextRequest2];
            
            
            if(_currentSearchGenre)
            {
                self.userSearchOperation = [appDelegate.networkEngine usersForGenreId: _currentSearchGenre
                                                                             forRange: self.dataRequestRange2
                                                                    completionHandler: self.userSearchCompleteBlock];
            }
            else if(_currentSearchTerm)
            {
                
                self.userSearchOperation = [appDelegate.networkEngine searchUsersForTerm: _currentSearchTerm
                                                                                andRange: self.dataRequestRange2
                                                                              onComplete: self.userSearchCompleteBlock];
            }
        }
    }
    
    
   
}

// extra methods to support second range (users search range)

- (BOOL) moreItemsToLoad2
{
    return (self.dataRequestRange2.location + self.dataRequestRange2.length < self.dataItemsAvailable2);
}

- (void) incrementRangeForNextRequest2
{
    if(!self.moreItemsToLoad2)
        return;
    
    NSInteger nextStart = self.dataRequestRange2.location + self.dataRequestRange2.length;
    
    NSInteger nextSize = MIN(STANDARD_REQUEST_LENGTH, self.dataItemsAvailable2 - nextStart);
    
    self.dataRequestRange2 = NSMakeRange(nextStart, nextSize);
}

#pragma mark - Tabs Delegate

- (IBAction) tabPressed: (id) sender
{
    if (self.videosTabButton == sender)
    {
        self.searchResultsShowing = SearchResultsShowingVideos;

    }
    else if (self.usersTabButton == sender)
    {                                                            [self showUserOverLay];

        self.searchResultsShowing = SearchResultsShowingUsers;
    }
}

- (void) setSearchResultsShowing: (SearchResultsShowing) searchResultsShowing
{
	if (self.searchType == SYNSearchTypeBrowse) {
		if (searchResultsShowing == SearchResultsShowingVideos) {
			[[SYNTrackingManager sharedManager] trackVideoBrowseScreenView];
		} else {
			[[SYNTrackingManager sharedManager] trackUserBrowseScreenView];
		}
	} else if (self.searchType == SYNSearchTypeSearch) {
		if (searchResultsShowing == SearchResultsShowingVideos) {
			[[SYNTrackingManager sharedManager] trackVideoSearchScreenView];
		} else {
			[[SYNTrackingManager sharedManager] trackUserSearchScreenView];
		}
	}
	
    _searchResultsShowing = searchResultsShowing;
    switch (_searchResultsShowing)
    {
        case SearchResultsShowingVideos:
            
            self.videosCollectionView.hidden = NO;
            self.usersCollectionView.hidden = YES;
            
            self.videosTabButton.selected = YES;
            self.usersTabButton.selected = NO;
            
            if (self.videosArray.count == 0) {
                self.noVideosLabel.hidden = NO;
            } else {
                self.noVideosLabel.hidden = YES;
            }
            
            self.noUsersLabel.hidden = YES;
            
            break;
            
        case SearchResultsShowingUsers:
            
            self.videosCollectionView.hidden = YES;
            self.usersCollectionView.hidden = NO;
            
            self.videosTabButton.selected = NO;
            self.usersTabButton.selected = YES;
            
            if (self.usersArray.count == 0) {
				BOOL searching = (self.searchType == SYNSearchTypeSearch);
				NSString *message = (searching ? NSLocalizedString(@"no_users", @"no users in search") : NSLocalizedString(@"no_highlights", @"no highlights in search"));
				self.noUsersLabel.text = message;
                self.noUsersLabel.hidden = NO;
            } else {
                self.noUsersLabel.hidden = YES;
            }
            
            self.noVideosLabel.hidden = YES;
    }
}


#pragma mark - Accessors

- (void) setVideoSearchOperation: (MKNetworkOperation *) runningSearchOperation
{
    if (_videoSearchOperation)
    {
        [_videoSearchOperation cancel];
    }
    
    self.loadingMoreContent = YES;
    
    _videoSearchOperation = runningSearchOperation;
}


- (void) setUserSearchOperation: (MKNetworkOperation *) runningSearchOperation
{
    if (_userSearchOperation)
    {
        [_userSearchOperation cancel];
    }
    
    self.loadingMoreContent = YES;
    
    _userSearchOperation = runningSearchOperation;
}


-(void) showUserOverLay {
    
    float value = [[NSUserDefaults standardUserDefaults] integerForKey: kUserDefaultsDiscoverUserFirstTime];
    if (self.usersArray.count>0 && self.shownOverlay == NO && value<3) {
        // display overlay only on the second time they view the highlights overlay
        
        if ([[SYNActivityManager sharedInstance] userFollowingCount] > 6) {
            
            [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:kUserDefaultsDiscoverUserFirstTime];
            return;
        }
        
        [self.usersCollectionView setContentOffset:CGPointZero];
            SYNDiscoverOverlayHighlightsViewController* overlay = [[SYNDiscoverOverlayHighlightsViewController alloc] init];
            [overlay addToViewController:appDelegate.masterViewController];
        
        value+=1;
        [[NSUserDefaults standardUserDefaults] setInteger:value forKey:kUserDefaultsDiscoverUserFirstTime];
        self.shownOverlay = YES;
    }
}

#pragma mark - SYNVideoPlayerDismissIndex

- (void)dismissPosition:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    self.videoPlayerAnimator.cellIndexPath = indexPath;
    if (UIDeviceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        [self.videosCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollDirectionHorizontal animated:NO];
    } else {
        [self.videosCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollDirectionVertical animated:NO];
    }
}


@end
