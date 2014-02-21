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
#import "SYNSearchResultsVideoCell.h"
#import "SYNSearchResultsViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNChannelFooterMoreView.h"
#import "SYNSearchVideoPlayerViewController.h"
#import "UIColor+SYNColor.h"
#import "UICollectionReusableView+Helpers.h"
#import "ChannelOwner.h"
#import "VideoInstance.h"
#import "SYNActivityManager.h"
#import "SYNVideoPlayerAnimator.h"
#import "SYNGenreManager.h"
#import "UIFont+SYNFont.h"
#import "SYNCarouselVideoPlayerViewController.h"
#import "SYNDeviceManager.h"
#import "SYNMasterViewController.h"
#import "SYNDiscoverOverlayVideoViewController.h"
#import "SYNDiscoverOverlayHighlightsViewController.h"
#import "SYNTrackingManager.h"

typedef NS_ENUM(NSInteger, SYNSearchType) {
	SYNSearchTypeUndefined,
	SYNSearchTypeBrowse,
	SYNSearchTypeSearch
};

typedef void (^SearchResultCompleteBlock)(int);

@interface SYNSearchResultsViewController () <UICollectionViewDataSource, UICollectionViewDelegate, SYNVideoPlayerAnimatorDelegate>

// UI stuff
@property (nonatomic, strong) IBOutlet UIView *containerTabs;
@property (strong, nonatomic) IBOutlet UILabel *noVideosLabel;
@property (strong, nonatomic) IBOutlet UILabel *noUsersLabel;

// search operations
@property (nonatomic, strong) MKNetworkOperation *videoSearchOperation;
@property (nonatomic, strong) MKNetworkOperation *userSearchOperation;

// @property (nonatomic) NSRange dataRequestRange; is from SYNAbstract, here we need a second for users
@property (nonatomic) NSRange dataRequestRange2;
@property (nonatomic) NSInteger dataItemsAvailable2;


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
    
    [self.videosCollectionView registerNib:[SYNSearchResultsVideoCell nib]
                forCellWithReuseIdentifier:[SYNSearchResultsVideoCell reuseIdentifier]];
    
    [self.videosCollectionView registerNib:[SYNChannelFooterMoreView nib]
                forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                       withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];
    
    [self.usersCollectionView registerNib:[SYNSearchResultsUserCell nib]
               forCellWithReuseIdentifier:[SYNSearchResultsUserCell reuseIdentifier]];
    
    [self.usersCollectionView registerNib:[SYNChannelFooterMoreView nib]
               forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                      withReuseIdentifier:[SYNChannelFooterMoreView reuseIdentifier]];
    
    self.containerTabs.layer.cornerRadius = 4.0f;
    self.containerTabs.layer.borderColor = [[UIColor colorWithWhite:152/255.0 alpha:1.0] CGColor];
    self.containerTabs.layer.borderWidth = .5f;
    self.containerTabs.layer.masksToBounds = YES;
    
    
    self.usersTabButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.usersTabButton.titleLabel.font.pointSize];
    self.videosTabButton.titleLabel.font = [UIFont regularCustomFontOfSize:self.videosTabButton.titleLabel.font.pointSize];
    
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
    
    if (!IS_IPHONE_5) {
        UIEdgeInsets tmpInsets = self.usersCollectionView.contentInset;
        tmpInsets.bottom += 88;
        self.usersCollectionView.contentInset = tmpInsets;
        
        tmpInsets = self.videosCollectionView.contentInset;
        tmpInsets.bottom += 88;
        self.videosCollectionView.contentInset = tmpInsets;
    }
    
    
    self.noVideosLabel.text = NSLocalizedString(@"no_videos", @"no videos in search");
    self.noUsersLabel.text = NSLocalizedString(@"no_users", @"no users in search");

    self.noUsersLabel.font = [UIFont regularCustomFontOfSize:18.0f];
    self.noVideosLabel.font = [UIFont regularCustomFontOfSize:18.0f];
    

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSIndexPath *selectedIndexPath = [[self.videosCollectionView indexPathsForSelectedItems] firstObject];
	if (selectedIndexPath) {
		[self.videosCollectionView deselectItemAtIndexPath:selectedIndexPath animated:YES];
	}
    
    [self.usersCollectionView.collectionViewLayout invalidateLayout];
    
    if (self.searchResultsShowing == SearchResultsShowingVideos) {
        [self showVideoOverlay];
    } else {
        [self showUserOverLay];
    }
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

#pragma mark - SYNVideoCellDelegate

- (void)profileButtonPressedForCell:(UICollectionViewCell *)cell {
	NSIndexPath *indexPath = [self.videosCollectionView indexPathForCell:cell];
	VideoInstance *videoInstance = self.videosArray[indexPath.row];
	
	[self viewProfileDetails:videoInstance.channel.channelOwner];
}

- (void)channelButtonPressedForCell:(UICollectionViewCell *)cell {
	NSIndexPath *indexPath = [self.videosCollectionView indexPathForCell:cell];
	VideoInstance *videoInstance = self.videosArray[indexPath.row];
	
	[self viewChannelDetails:videoInstance.channel withAnimation:YES];
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
	NSString *genreName = [[SYNGenreManager sharedInstance] nameFromID:genreId];
	[[SYNTrackingManager sharedManager] setCategoryDimension:genreName];
	
	self.searchType = SYNSearchTypeBrowse;

    //When searching for category, default to show users/highlights
    self.searchResultsShowing = SearchResultsShowingUsers;
    
    [self.usersTabButton setTitle:(NSLocalizedString(@"highlights", @"Highlight, discover tab")) forState:UIControlStateNormal];
    
    if([_currentSearchGenre isEqualToString: genreId])
    {
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
    
    self.videoSearchOperation = [appDelegate.networkEngine videosForGenreId: _currentSearchGenre
                                                                   forRange: self.dataRequestRange
                                                          completionHandler: self.videoSearchCompleteBlock];
    
    self.userSearchOperation = [appDelegate.networkEngine usersForGenreId: _currentSearchGenre
                                                                 forRange: self.dataRequestRange2
                                                        completionHandler:^(int value) {
                                                            self.userSearchCompleteBlock(value);
                                                            [self showUserOverLay];
                                                        }];
    
}

- (void) searchForTerm: (NSString *) newSearchTerm
{
	[[SYNTrackingManager sharedManager] setCategoryDimension:nil];
	
	self.searchType = SYNSearchTypeSearch;

    [self.usersTabButton setTitle:NSLocalizedString(@"users", @"Users in discover tab") forState:UIControlStateNormal];
    
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
                                                                        [self showVideoOverlay];
                                                                    }];
    
    self.userSearchOperation = [appDelegate.networkEngine searchUsersForTerm: _currentSearchTerm
                                                                    andRange: self.dataRequestRange
                                                                  onComplete: self.userSearchCompleteBlock];
    

}

- (BOOL) clearSearchEntities
{
    BOOL success;
    
    
    if (!(success = [appDelegate.searchRegistry clearImportContextFromEntityName: kVideoInstance andViewId:self.viewId]))
        DebugLog(@"Could not clean VideoInstances from search context");
    
    // Call me an amateur but I feel proud of this syntax
    if (!(success &= [appDelegate.searchRegistry clearImportContextFromEntityName: kChannelOwner andViewId:self.viewId]))
        DebugLog(@"Could not clean ChannelOwner from search context");
    
    self.videosArray = @[];
    self.usersArray = @[];
    
    [self.videosCollectionView reloadData];
    [self.usersCollectionView reloadData];
    
    return success;
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
        SYNSearchResultsVideoCell *videoCell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNSearchResultsVideoCell reuseIdentifier]
                                                                                         forIndexPath:indexPath];
        
         
        videoCell.videoInstance = (VideoInstance*)(self.videosArray[indexPath.item]);
        videoCell.delegate = self;
        
        
        cell = videoCell;
    }
    else if (collectionView == self.usersCollectionView)
    {
        SYNSearchResultsUserCell *userCell = [collectionView dequeueReusableCellWithReuseIdentifier:[SYNSearchResultsUserCell reuseIdentifier]
                                                                                       forIndexPath:indexPath];
        
        
        userCell.channelOwner = (ChannelOwner*)(self.usersArray[indexPath.item]);
        
        
        if (IS_IPAD) {
            if (indexPath.row>2) {
                userCell.descriptionLabel.hidden = YES;
            }
        } else {
            if (indexPath.row>1) {
                userCell.descriptionLabel.hidden = YES;
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
        
        
        
		VideoInstance *videoInstance = self.videosArray[indexPath.item];
        
        
        
		UIViewController *viewController;
        
        if (!self.currentSearchTerm) {
            viewController = [SYNCarouselVideoPlayerViewController viewControllerWithVideoInstances:self.videosArray selectedIndex:indexPath.item];

        } else {
            viewController  = [SYNSearchVideoPlayerViewController viewControllerWithVideoInstance:videoInstance];

        }
		
        
		SYNVideoPlayerAnimator *animator = [[SYNVideoPlayerAnimator alloc] init];
		animator.delegate = self;
		animator.cellIndexPath = indexPath;
		self.videoPlayerAnimator = animator;
		viewController.transitioningDelegate = animator;
		
		[self presentViewController:viewController animated:YES completion:nil];
	}
    
    if (collectionView == self.usersCollectionView) {
        ChannelOwner *channelOwner = (ChannelOwner*)(self.usersArray[indexPath.item]);
        [self viewProfileDetails:channelOwner];
    }
}

- (id<SYNVideoInfoCell>)videoCellForIndexPath:(NSIndexPath *)indexPath {
	return (SYNSearchResultsVideoCell *)[self.videosCollectionView cellForItemAtIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.usersCollectionView) {
    
        if (IS_IPHONE) {
            if (indexPath.row<2) {
                return CGSizeMake(320, 195);
            } else {
                return CGSizeMake(320, 113);
            }
        }
        
        if (IS_IPAD) {
            
            if (UIDeviceOrientationIsPortrait([SYNDeviceManager.sharedInstance orientation])) {
                if (indexPath.row == 0) {
                    return CGSizeMake(434, 240);
                } else if (indexPath.row == 1 || indexPath.row == 2) {
                    return CGSizeMake(434, 194);
                } else {
                    return CGSizeMake(434, 113);
                }
            } else {
                
                if (indexPath.row == 0) {
                    return CGSizeMake(616, 240);
                } else if (indexPath.row == 1 || indexPath.row == 2) {
                    return CGSizeMake(300, 194);
                } else {
                    return CGSizeMake(300, 113);
                }
            }
        }
    } else {
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
        
        
        self.footerView.showsLoading = self.isLoadingMoreContent;
        
    }
    
    return supplementaryView;
}



- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [self.usersCollectionView.collectionViewLayout invalidateLayout];
    
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
        
        [self showVideoOverlay];

    }
    else if (self.usersTabButton == sender)
    {
        
        [self showUserOverLay];

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
            
            self.videosTabButton.backgroundColor = [UIColor dollyTabColorSelectedBackground];
            self.videosTabButton.titleLabel.textColor = [UIColor whiteColor];
            
            self.usersTabButton.backgroundColor = [UIColor whiteColor];
            self.usersTabButton.titleLabel.textColor = [UIColor dollyTabColorSelectedText];
            
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
            
            self.videosTabButton.backgroundColor = [UIColor whiteColor];
            self.videosTabButton.titleLabel.textColor = [UIColor dollyTabColorSelectedText];
            
            self.usersTabButton.backgroundColor = [UIColor dollyTabColorSelectedBackground];
            self.usersTabButton.titleLabel.textColor = [UIColor whiteColor];
            
            if (self.usersArray.count == 0) {
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
    

    
        if (self.usersArray.count>=1) {
            
            float value = [[NSUserDefaults standardUserDefaults] integerForKey: kUserDefaultsDiscoverUserFirstTime];
            // display overlay only on the second time they view the highlights overlay
            
            if (value==1)
            {

                
            
            SYNDiscoverOverlayHighlightsViewController* overlay = [[SYNDiscoverOverlayHighlightsViewController alloc] init];
            
            // Set frame to full screen
            CGRect vFrame = overlay.view.frame;
            vFrame.size = [[SYNDeviceManager sharedInstance] currentScreenSize];
            overlay.view.frame = vFrame;
            overlay.view.alpha = 0.0f;
            
            [appDelegate.masterViewController addChildViewController:overlay];
            [appDelegate.masterViewController.view addSubview:overlay.view];
            
            [UIView animateWithDuration:0.3 animations:^{
                overlay.view.alpha = 1.0f;
            }];
                
                value+=1;
                [[NSUserDefaults standardUserDefaults] setInteger:value forKey:kUserDefaultsDiscoverUserFirstTime];

            } else {
                value+=1;
                [[NSUserDefaults standardUserDefaults] setInteger:value forKey:kUserDefaultsDiscoverUserFirstTime];

            }

        }
        
}

- (void) showVideoOverlay {
    
    if (self.videosArray.count>=1) {
        
        
        float value = [[NSUserDefaults standardUserDefaults] integerForKey: kUserDefaultsDiscoverVideoFirstTime];
        
        // display Video overlay only on the third time they view the highlights overlay

        if (value==2)
        {
            SYNDiscoverOverlayVideoViewController* overlay = [[SYNDiscoverOverlayVideoViewController alloc] init];
            
            // Set frame to full screen
            CGRect vFrame = overlay.view.frame;
            vFrame.size = [[SYNDeviceManager sharedInstance] currentScreenSize];
            overlay.view.frame = vFrame;
            overlay.view.alpha = 0.0f;
            
            [appDelegate.masterViewController addChildViewController:overlay];
            [appDelegate.masterViewController.view addSubview:overlay.view];
            
            [UIView animateWithDuration:0.3 animations:^{
                overlay.view.alpha = 1.0f;
            }];
            value+=1;
            [[NSUserDefaults standardUserDefaults] setInteger:value forKey:kUserDefaultsDiscoverVideoFirstTime];

        } else if ( value <2){
            value+=1;
            [[NSUserDefaults standardUserDefaults] setInteger:value forKey:kUserDefaultsDiscoverVideoFirstTime];
        }
        
        

    }
        
    

}

@end
