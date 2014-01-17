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

typedef void (^SearchResultCompleteBlock)(int);

@interface SYNSearchResultsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

// UI stuff
@property (nonatomic, strong) IBOutlet UIView *containerTabs;

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
    self.containerTabs.layer.borderColor = [[UIColor grayColor] CGColor];
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
        
        // protection from being called twice, one for every tab and making the loader dissapear prematurely
        if (wself.searchResultsShowing == SearchResultsShowingVideos)
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
        
        // protection from being called twice, one for every tab and making the loader dissapear prematurely
        if (wself.searchResultsShowing == SearchResultsShowingUsers)
            [wself removePopupMessage];
        
        wself.loadingMoreContent = NO;
        
        
        wself.dataItemsAvailable2 = (NSInteger)count;
        
        [wself.usersCollectionView reloadData];
    };
    
    // Set Initial
    self.searchResultsShowing = SearchResultsShowingVideos;
    
    self.dataRequestRange2 = self.dataRequestRange; // they start off as (0, 48) for both...
    
    if (!IS_IPHONE_5) {
        UIEdgeInsets tmpInsets = self.usersCollectionView.contentInset;
        tmpInsets.bottom += 88;
        self.usersCollectionView.contentInset = tmpInsets;
        
        tmpInsets = self.videosCollectionView.contentInset;
        tmpInsets.bottom += 88;
        self.videosCollectionView.contentInset = tmpInsets;
    }
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSIndexPath *selectedIndexPath = [[self.videosCollectionView indexPathsForSelectedItems] firstObject];
	if (selectedIndexPath) {
		[self.videosCollectionView deselectItemAtIndexPath:selectedIndexPath animated:YES];
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

#pragma mark - SYNVideoCellDelegate

- (void)profileButtonPressedForCell:(UICollectionViewCell *)cell {
	NSIndexPath *indexPath = [self.videosCollectionView indexPathForCell:cell];
	VideoInstance *videoInstance = self.videosArray[indexPath.row];
	
	[self viewProfileDetails:videoInstance.channel.channelOwner];
}

- (void)channelButtonPressedForCell:(UICollectionViewCell *)cell {
	NSIndexPath *indexPath = [self.videosCollectionView indexPathForCell:cell];
	VideoInstance *videoInstance = self.videosArray[indexPath.row];
	
	[self viewChannelDetails:videoInstance.channel];
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
    
    if([_currentSearchGenre isEqualToString: genreId])
    {
        return;
    }
    
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
                                                        completionHandler: self.userSearchCompleteBlock];
}

- (void) searchForTerm: (NSString *) newSearchTerm
{
    
    if ([_currentSearchTerm isEqualToString: newSearchTerm]) // == Don't repeat a search == //
    {
        return;
    }
    
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
                                                                    onComplete: self.videoSearchCompleteBlock];
    
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
        
        // As the followButton needs to be a SYNSocialButton to tie in with the callbacks we just need to style it on the fly
        userCell.followButton.layer.borderWidth = 0.0f;
        userCell.followButton.backgroundColor = [UIColor clearColor];
        userCell.followButton.titleLabel.font = [UIFont lightCustomFontOfSize:20.0f];
        
        if ([[SYNActivityManager sharedInstance] isSubscribedToUserId:userCell.channelOwner.uniqueId]) {
            [userCell.followButton setTitle:(NSLocalizedString(@"unfollow", "unfollow a user, search view controller"))];
        }
        else
        {
            [userCell.followButton setTitle:(NSLocalizedString(@"follow", "follow a user, search view controller"))];
            
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
		UIViewController *viewController = [SYNSearchVideoPlayerViewController viewControllerWithVideoInstance:videoInstance];
		
		SYNSearchResultsVideoCell *videoCell = (SYNSearchResultsVideoCell *)[collectionView cellForItemAtIndexPath:indexPath];
		
		SYNVideoPlayerAnimator *animator = [[SYNVideoPlayerAnimator alloc] init];
		animator.videoInfoCell = videoCell;
		self.videoPlayerAnimator = animator;
		viewController.transitioningDelegate = animator;

		
		[self presentViewController:viewController animated:YES completion:nil];
	}
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
    
    NSLog(@"Fetching Items for Range: %@", NSStringFromRange(self.dataRequestRange2));
    
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
    {
        self.searchResultsShowing = SearchResultsShowingUsers;
    }
}


- (void) setSearchResultsShowing: (SearchResultsShowing) searchResultsShowing
{
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
            
            break;
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



@end
