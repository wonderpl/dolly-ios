//
//  SYNSearchResultsViewController.m
//  dolly
//
//  Created by Michael Michailidis on 21/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchResultsViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNSearchResultsCell.h"
#import "SYNSearchResultsVideoCell.h"
#import "SYNSearchResultsUserCell.h"

typedef void(^SearchResultCompleteBlock)(int);

static NSString *kSearchResultVideoCell = @"SYNSearchResultsVideoCell";
static NSString *kSearchResultUserCell = @"SYNSearchResultsUserCell";

@interface SYNSearchResultsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

// UI stuff
@property (nonatomic, strong) IBOutlet UIView* containerTabs;

// search operations
@property (nonatomic, strong) MKNetworkOperation* videoSearchOperation;
@property (nonatomic, strong) MKNetworkOperation* userSearchOperation;

@property (nonatomic, strong) NSString* currentSearchTerm;

// completion blocks
@property (nonatomic, copy) SearchResultCompleteBlock videoSearchCompleteBlock;
@property (nonatomic, copy) SearchResultCompleteBlock userSearchCompleteBlock;

// Data Arrays
@property (nonatomic, strong) NSArray* videosArray;
@property (nonatomic, strong) NSArray* usersArray;

// Container View (Used for Positioning)
@property (nonatomic, strong) IBOutlet UIView* containerView;

@end

@implementation SYNSearchResultsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // == Initialise the arrays == //
    
    self.videosArray = @[];
    self.usersArray = @[];
    
    self.view.autoresizesSubviews = NO;
    
    [self.videosCollectionView registerNib:[UINib nibWithNibName:kSearchResultVideoCell bundle:nil]
                forCellWithReuseIdentifier:kSearchResultVideoCell];
    
    [self.usersCollectionView registerNib:[UINib nibWithNibName:kSearchResultUserCell bundle:nil]
               forCellWithReuseIdentifier:kSearchResultUserCell];
    
    
    self.containerTabs.layer.cornerRadius = 3.0f;
    self.containerTabs.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.containerTabs.layer.borderWidth = 1.0f;
    
    // == Define Completion Blocks for operations == //
    
    SYNSearchResultsViewController* wself = self;
    
    self.videoSearchCompleteBlock = ^(int count) {
        
        NSError* error;
        NSArray* fetchedObjects = [wself getSearchEntitiesByName: kVideoInstance
                                                       withError: &error];
        
        if(error)
        {
            //handle error
            return ;
        }
        
        wself.videosArray = [NSArray arrayWithArray:fetchedObjects];
        
        [wself.videosCollectionView reloadData];
        
    };
    
    
    self.userSearchCompleteBlock = ^(int count) {
        
        NSError* error;
        NSArray* fetchedObjects = [wself getSearchEntitiesByName: kUser
                                                       withError: &error];
        
        if(error)
        {
            // handle error
            return ;
        }
        
        wself.usersArray = [NSArray arrayWithArray:fetchedObjects];
        
        [wself.usersCollectionView reloadData];
        
    };
    
    
    // Set Initial
    
    self.searchresultsShowing = SearchResultsShowingVideos;
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self repositionContainer];
}

-(void)repositionContainer
{
    // offset from the top
    CGRect containerRect = self.containerView.frame;
    
    
    containerRect.origin.x = (self.view.frame.size.width * 0.5f) - (self.containerView.frame.size.width * 0.5f);
    containerRect.size.height = self.view.frame.size.height;
    self.containerView.frame = CGRectIntegral(containerRect);
}

#pragma mark - Load Data


- (void) searchForString: (NSString *) newSearchTerm
{
    // == Don't repeat a search == //
    if ([_currentSearchTerm isEqualToString: newSearchTerm])
        return;
    
    _currentSearchTerm = newSearchTerm;
    
    if (!_currentSearchTerm)
        return;
    
    // == Clear search context for new search == //
    BOOL success = [appDelegate.searchRegistry clearImportContextFromEntityName: @"VideoInstance"];
    
    if (!success)
    {
        DebugLog(@"Could not clean VideoInstances from search context");
    }
    
    success = [appDelegate.searchRegistry clearImportContextFromEntityName: @"ChannelOwner"];
    
    if (!success)
    {
        DebugLog(@"Could not clean ChannelOwner from search context");
    }
    
    // == Perform Search == //
    
    self.videoSearchOperation = [appDelegate.networkEngine searchVideosForTerm: _currentSearchTerm
                                                                       inRange: self.dataRequestRange
                                                                    onComplete: self.videoSearchCompleteBlock];
    
    self.userSearchOperation = [appDelegate.networkEngine searchVideosForTerm: _currentSearchTerm
                                                                      inRange: self.dataRequestRange
                                                                   onComplete: self.userSearchCompleteBlock];
}


-(NSArray*)getSearchEntitiesByName:(NSString*)entityName withError:(NSError**)error
{
    if(!entityName)
        return nil;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: entityName
                                      inManagedObjectContext: appDelegate.searchManagedObjectContext];
    
    
    [fetchRequest setPredicate: [NSPredicate predicateWithFormat: @"viewId == %@", self.viewId]];
    
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    NSArray* results = [appDelegate.searchManagedObjectContext executeFetchRequest: fetchRequest error: error];
    
    
    
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
    
    if(collectionView == self.videosCollectionView)
        count = self.videosArray.count;
    else if(collectionView == self.usersCollectionView)
        count = self.usersArray.count;
    
    return count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    SYNSearchResultsCell* cell;
    
    if(collectionView == self.videosCollectionView)
    {
        
        SYNSearchResultsVideoCell* videoCell = [collectionView dequeueReusableCellWithReuseIdentifier:kSearchResultVideoCell
                                                                                         forIndexPath:indexPath];
        
        cell = videoCell;
        
        
    }
    else if(collectionView == self.usersCollectionView)
    {
        
        SYNSearchResultsUserCell* userCell = [collectionView dequeueReusableCellWithReuseIdentifier:kSearchResultUserCell
                                                                                       forIndexPath:indexPath];
        
        
        cell = userCell;
    }
    
    cell.delegate = self;
    
    return cell;
    
}
#pragma mark - Social Action Delegate

-(void)followControlPressed:(id)control
{
    
}
-(void)shareControlPressed:(id)control
{
    
}
-(void)likeControlPressed:(id)control
{
    
}
-(void)addControlPressed:(id)control
{
    
}


#pragma mark - Tabs Delegate

-(IBAction)tabPressed:(id)sender
{
    if(self.videosTabButton == sender)
        self.searchresultsShowing = SearchResultsShowingVideos;
    else if (self.usersTabButton == sender)
        self.searchresultsShowing = SearchResultsShowingUsers;
}

-(void)setSearchresultsShowing:(SearchResultsShowing)searchresultsShowing
{
    _searchResultsShowing = searchresultsShowing;
    switch (_searchResultsShowing)
    {
        case SearchResultsShowingVideos:
            self.videosCollectionView.hidden = NO;
            self.usersCollectionView.hidden = YES;
            self.videosTabButton.selected = YES;
            self.usersTabButton.selected = NO;
            break;
            
        case SearchResultsShowingUsers:
            self.videosCollectionView.hidden = YES;
            self.usersCollectionView.hidden = NO;
            self.videosTabButton.selected = NO;
            self.usersTabButton.selected = YES;
            break;
    }
}

#pragma mark - Orientation Delegates

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self repositionContainer];
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
