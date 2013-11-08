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

#import "UIColor+SYNColor.h"

#import "ChannelOwner.h"
#import "VideoInstance.h"

typedef void (^SearchResultCompleteBlock)(int);

static NSString *kSearchResultVideoCell = @"SYNSearchResultsVideoCell";
static NSString *kSearchResultUserCell = @"SYNSearchResultsUserCell";

@interface SYNSearchResultsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

// UI stuff
@property (nonatomic, strong) IBOutlet UIView *containerTabs;

// search operations
@property (nonatomic, strong) MKNetworkOperation *videoSearchOperation;
@property (nonatomic, strong) MKNetworkOperation *userSearchOperation;


@property (nonatomic) SearchResultsShowing searchResultsShowing;

@property (nonatomic, strong) NSString *currentSearchTerm;

// completion blocks
@property (nonatomic, copy) SearchResultCompleteBlock videoSearchCompleteBlock;
@property (nonatomic, copy) SearchResultCompleteBlock userSearchCompleteBlock;


// Data Arrays
@property (nonatomic, strong) NSArray *videosArray;
@property (nonatomic, strong) NSArray *usersArray;




@end


@implementation SYNSearchResultsViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // == Initialise the arrays == //
    
    self.videosArray = @[];
    self.usersArray = @[];
    
    
    self.view.autoresizesSubviews = YES;
    
    [self.videosCollectionView registerNib: [UINib nibWithNibName: kSearchResultVideoCell bundle: nil]
                forCellWithReuseIdentifier: kSearchResultVideoCell];
    
    [self.usersCollectionView registerNib: [UINib nibWithNibName: kSearchResultUserCell bundle: nil]
               forCellWithReuseIdentifier: kSearchResultUserCell];
    
    self.containerTabs.layer.cornerRadius = 4.0f;
    self.containerTabs.layer.borderColor = [[UIColor grayColor] CGColor];
    self.containerTabs.layer.borderWidth = .5f;
    self.containerTabs.layer.masksToBounds = YES;
    
    
    // == Define Completion Blocks for operations == //
    
    SYNSearchResultsViewController *wself = self;
    
    self.videoSearchCompleteBlock = ^(int count) {
        
        NSError *error;
        NSArray *fetchedObjects = [wself getSearchEntitiesByName: kVideoInstance
                                                       withError: &error];
        
        if (error)
        {
            //handle error
            return;
        }
        
        wself.videosArray = [NSArray arrayWithArray: fetchedObjects];
        
        // protection from being called twice, one for every tab and making the loader dissapear prematurely
        if (wself.searchResultsShowing == SearchResultsShowingVideos)
            [wself removePopupMessage];
        
        
        [wself.videosCollectionView reloadData];
    };
    
    
    self.userSearchCompleteBlock = ^(int count) {
        
        NSError *error;
        NSArray *fetchedObjects = [wself getSearchEntitiesByName: kChannelOwner
                                                       withError: &error];
        
        if (error)
        {
            // handle error
            return;
        }
        
        wself.usersArray = [NSArray arrayWithArray: fetchedObjects];
        
        // protection from being called twice, one for every tab and making the loader dissapear prematurely
        if (wself.searchResultsShowing == SearchResultsShowingUsers)
            [wself removePopupMessage];
        
        [wself.usersCollectionView reloadData];
    };
    
    
    
    // Set Initial
    self.searchResultsShowing = SearchResultsShowingVideos;
    
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
    
    [appDelegate.viewStackManager viewProfileDetails: searchUserCell.channelOwner
                            withNavigationController: self.navigationController];
}

#pragma mark - Load Data

- (void) searchForGenre: (NSString *) genreId
{
    [self clearSearchEntities];
    
    [self displayPopupMessage:@"Searching..." withLoader:YES];
    
    self.videoSearchOperation = [appDelegate.networkEngine videosForGenreId:genreId
                                                          completionHandler:self.videoSearchCompleteBlock];
    
    self.userSearchOperation = [appDelegate.networkEngine usersForGenreId:genreId
                                                         completionHandler:self.userSearchCompleteBlock];
}

- (void) searchForTerm: (NSString *) newSearchTerm
{
    
    if ([_currentSearchTerm isEqualToString: newSearchTerm]) // == Don't repeat a search == //
    {
        return;
    }
    
    _currentSearchTerm = newSearchTerm;
    
    if (!_currentSearchTerm)
    {
        return;
    }
    
    if(![self clearSearchEntities])
    {
        return;
    }
    
    [self displayPopupMessage:@"Searching..." withLoader:YES];
    
    // == Perform Search == //
    
    self.videoSearchOperation = [appDelegate.networkEngine searchVideosForTerm: _currentSearchTerm
                                                                       inRange: self.dataRequestRange
                                                                    onComplete: self.videoSearchCompleteBlock];
    
    self.userSearchOperation = [appDelegate.networkEngine searchUsersForTerm: _currentSearchTerm
                                                                    andRange: self.dataRequestRange
                                                                 byAppending: NO
                                                                  onComplete: self.userSearchCompleteBlock];
}

- (BOOL) clearSearchEntities
{
    BOOL success;
    
    
    if (!(success = [appDelegate.searchRegistry clearImportContextFromEntityName: kVideoInstance]))
        DebugLog(@"Could not clean VideoInstances from search context");
    
    // Call me an amateur but I feel proud of this syntax
    if (!(success &= [appDelegate.searchRegistry clearImportContextFromEntityName: kChannelOwner]))
        DebugLog(@"Could not clean ChannelOwner from search context");
    
    self.videosArray = @[];
    self.usersArray = @[];
    
    [self.videosCollectionView reloadData];
    [self.usersCollectionView reloadData];
    
    return success;
}


- (NSArray *) getSearchEntitiesByName: (NSString *) entityName withError: (NSError **) error
{
    if (!entityName)
    {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: entityName
                                      inManagedObjectContext: appDelegate.searchManagedObjectContext];
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"viewId == %@", self.viewId]];
    
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position"
                                                                 ascending: YES]];
    
    NSArray *results = [appDelegate.searchManagedObjectContext
                        executeFetchRequest: fetchRequest
                        error: error];
    
    return results;
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
        DebugLog(@"Search video count = %d", count);
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
        SYNSearchResultsVideoCell *videoCell = [collectionView dequeueReusableCellWithReuseIdentifier: kSearchResultVideoCell
                                                                                         forIndexPath: indexPath];
        
         
        videoCell.videoInstance = (VideoInstance*)(self.videosArray[indexPath.item]);
        videoCell.delegate = self;
        
        
        cell = videoCell;
    }
    else if (collectionView == self.usersCollectionView)
    {
        SYNSearchResultsUserCell *userCell = [collectionView dequeueReusableCellWithReuseIdentifier: kSearchResultUserCell
                                                                                       forIndexPath: indexPath];
        
        
        userCell.channelOwner = (ChannelOwner*)(self.usersArray[indexPath.item]);
        
        // As the followButton needs to be a SYNSocialButton to tie in with the callbacks we just need to style it on the fly
        userCell.followButton.layer.borderWidth = 0.0f;
        userCell.followButton.backgroundColor = [UIColor clearColor];
        userCell.followButton.titleLabel.font = [UIFont lightCustomFontOfSize:20.0f];
        // ================= // 
        
        cell = userCell;
    }
    
    cell.delegate = self;
    
    return cell;
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    if (collectionView == self.videosCollectionView)
    {
        CGPoint center;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
        
        if (cell)
        {
            center = [self.view convertPoint: cell.center
                                    fromView: cell.superview];
        }
        else
        {
            center = self.view.center;
        }
        
        [self displayVideoViewerWithVideoInstanceArray: self.videosArray
                                      andSelectedIndex: indexPath.item
                                                center: center];
    }
    else if (collectionView == self.usersCollectionView)
    {
        NSLog(@"SYNSearchResultsCollectionType:didDeselectItemAtIndexPath users collection type currently unsupported") ;
    }
    else
    {
        AssertOrLog(@"SYNSearchResultsCollectionType:didDeselectItemAtIndexPath unknown collection type");
    }
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
            
            self.videosTabButton.backgroundColor = [UIColor dollyTabColorSelected];
            self.videosTabButton.titleLabel.textColor = [UIColor whiteColor];
            
            self.usersTabButton.backgroundColor = [UIColor whiteColor];
            self.usersTabButton.titleLabel.textColor = [UIColor dollyTabColorSelected];
            
            break;
            
        case SearchResultsShowingUsers:
            
            self.videosCollectionView.hidden = YES;
            self.usersCollectionView.hidden = NO;
            
            self.videosTabButton.selected = NO;
            self.usersTabButton.selected = YES;
            
            self.videosTabButton.backgroundColor = [UIColor whiteColor];
            self.videosTabButton.titleLabel.textColor = [UIColor dollyTabColorSelected];
            
            self.usersTabButton.backgroundColor = [UIColor dollyTabColorSelected];
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
    
    _videoSearchOperation = runningSearchOperation;
}


- (void) setUserSearchOperation: (MKNetworkOperation *) runningSearchOperation
{
    if (_userSearchOperation)
    {
        [_userSearchOperation cancel];
    }
    
    _userSearchOperation = runningSearchOperation;
}



@end
