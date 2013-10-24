//
//  SYNSearchResultsViewController.m
//  dolly
//
//  Created by Michael Michailidis on 21/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchResultsViewController.h"
#import "SYNNetworkEngine.h"
#import "SYNSearchResultsVideoCell.h"
#import "SYNSearchResultsUserCell.h"

typedef void(^SearchResultCompleteBlock)(int);

static NSString *kSearchResultVideoCell = @"SYNSearchResultsVideoCell";
static NSString *kSearchResultUserCell = @"SYNSearchResultsUserCell";

@interface SYNSearchResultsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

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

@end

@implementation SYNSearchResultsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // == Initialise the arrays == //
    
    self.videosArray = @[];
    self.usersArray = @[];
    
    [self.videosCollectionView registerNib:[UINib nibWithNibName:kSearchResultVideoCell bundle:nil]
                forCellWithReuseIdentifier:kSearchResultVideoCell];
    
    [self.usersCollectionView registerNib:[UINib nibWithNibName:kSearchResultUserCell bundle:nil]
               forCellWithReuseIdentifier:kSearchResultUserCell];
    
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
    UICollectionViewCell* cell;
    
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
    
    return cell;
    
}

#pragma mark - Tab Delegate

-(IBAction)tabPressed:(id)sender
{
    if(self.videosTabButton == sender)
    {
        self.videosCollectionView.hidden = NO;
        self.usersCollectionView.hidden = YES;
    }
    else if (self.usersTabButton == sender)
    {
        self.videosCollectionView.hidden = YES;
        self.usersCollectionView.hidden = NO;
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
