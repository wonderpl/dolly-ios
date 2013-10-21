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

@interface SYNSearchResultsViewController ()

// search operations
@property (nonatomic, strong) MKNetworkOperation* videoSearchOperation;
@property (nonatomic, strong) MKNetworkOperation* userSearchOperation;

@property (nonatomic, strong) NSString* currentSearchTerm;

// completion blocks
@property (nonatomic, copy) SearchResultCompleteBlock videoSearchCompleteBlock;
@property (nonatomic, copy) SearchResultCompleteBlock userSearchCompleteBlock;

@end

@implementation SYNSearchResultsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // == Define Completion Blocks for operations == //
    
    self.videoSearchCompleteBlock = ^(int count) {
        
        // 1. Display the number of results
        // 2. Update Collection View
        
    };
    
    
    self.userSearchCompleteBlock = ^(int count) {
        
        // 1. Display the number of results
        // 2. Update Collection View
        
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
