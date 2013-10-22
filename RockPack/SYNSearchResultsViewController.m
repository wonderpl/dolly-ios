//
//  SYNSearchResultsViewController.m
//  dolly
//
//  Created by Michael Michailidis on 21/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchResultsViewController.h"
#import "SYNNetworkEngine.h"

typedef void(^SearchResultCompleteBlock)(int);

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
        
    };
    
    
    self.userSearchCompleteBlock = ^(int count) {
        
        NSError* error;
        NSArray* fetchedObjects = [wself getSearchEntitiesByName: kUser
                                                       withError: &error];
        
        if(error)
        {
            //handle error
            return ;
        }
        
        wself.usersArray = [NSArray arrayWithArray:fetchedObjects];
        
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
    
    
    return [appDelegate.mainManagedObjectContext executeFetchRequest: fetchRequest error: error];
    
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
        return self.videosArray.count;
    else if(collectionView == self.usersCollectionView)
        return self.usersArray.count;
    
    return count;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    UICollectionViewCell* cell;
    if(collectionView == self.videosCollectionView)
    {
        
        
        
    }
    else if(collectionView == self.usersCollectionView)
    {
        
        
        
        
        
    }
    return cell;
    
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
