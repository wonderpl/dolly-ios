//
//  SYNSearchUsersViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 08/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNSearchUsersViewController.h"
#import "SYNSearchTabView.h"
#import "SYNDeviceManager.h"
#import "SYNIntegralCollectionViewFlowLayout.h"
#import "SYNUserThumbnailCell.h"

@interface SYNSearchUsersViewController () <UICollectionViewDataSource, UICollectionViewDelegate>


@property (nonatomic, weak) NSString* searchTerm;

@end

@implementation SYNSearchUsersViewController

@synthesize itemToUpdate;
@synthesize users;


- (id) initWithViewId: (NSString *) vid
{
    if ((self = [super initWithViewId: vid]))
    {
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleDataModelChange:)
                                                     name: NSManagedObjectContextObjectsDidChangeNotification
                                                   object: appDelegate.searchManagedObjectContext];
    }
    
    return self;
}




- (void) handleDataModelChange: (NSNotification*) dataNotification
{
    
    [self displayUsers];
    
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    
}

- (void) displayUsers
{
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName: @"ChannelOwner"
                                   inManagedObjectContext: appDelegate.searchManagedObjectContext]];
    
    
    [request setPredicate: [NSPredicate predicateWithFormat: @"viewId == %@", self.viewId]];
    
    request.fetchBatchSize = 20;
    
    NSError *error = nil;
    NSArray *resultsArray = [appDelegate.searchManagedObjectContext executeFetchRequest: request
                                                                                  error: &error];
    
    
    if (!resultsArray)
        return;
    
    users = [NSMutableArray arrayWithArray: resultsArray];
    
    [self.usersThumbnailCollectionView reloadData];
}

- (void) performNewSearchWithTerm: (NSString*) term
{
    
    
    if (!appDelegate)
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.dataRequestRange = NSMakeRange(0, kAPIInitialBatchSize);
    
    
    [appDelegate.networkEngine searchUsersForTerm: term
                                         andRange: self.dataRequestRange
                                       onComplete: ^(int itemsCount) {
                                              self.dataItemsAvailable = itemsCount;
                                              if (self.itemToUpdate)
                                                  [self.itemToUpdate setNumberOfItems: self.dataItemsAvailable
                                                                             animated: YES];
                                              
                                          }];
    
    self.searchTerm = term;
}

- (void) loadMoreUsers: (UIButton*) sender
{
    NSInteger nextStart = self.dataRequestRange.location + self.dataRequestRange.length; // one is subtracted when the call happens for 0 indexing
    
    if(nextStart >= self.dataItemsAvailable)
        return;
    
    self.loadingMoreContent = YES;
    
    NSInteger nextSize = (nextStart + STANDARD_REQUEST_LENGTH) >= self.dataItemsAvailable ? (self.dataItemsAvailable - nextStart) : STANDARD_REQUEST_LENGTH;
    
    self.dataRequestRange = NSMakeRange(nextStart, nextSize);
    
    [appDelegate.networkEngine searchUsersForTerm: self.searchTerm
                                         andRange: self.dataRequestRange
                                       onComplete: ^(int itemsCount) {
                                              self.dataItemsAvailable = itemsCount;
                                              self.loadingMoreContent = NO;
                                          }];
}

#pragma mark - UICollectionView Delegate

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 1;
}

- (NSInteger) collectionView: (UICollectionView *) view
      numberOfItemsInSection: (NSInteger) section
{
    return self.users.count;
    
}



- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    ChannelOwner *user = self.users[indexPath.row];
    
    SYNUserThumbnailCell *userThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNUserThumbnailCell"
                                                                                        forIndexPath: indexPath];
    
    
    userThumbnailCell.nameLabel.text = user.displayName;
    
    userThumbnailCell.imageUrlString = user.thumbnailLargeUrl;
    
    [userThumbnailCell setDisplayName:user.displayName andUsername:user.username];
    
    
    return userThumbnailCell;
}

- (void) collectionView: (UICollectionView *) collectionView didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    
    ChannelOwner *channelOwner = (ChannelOwner*)self.users[indexPath.row];
    
    [appDelegate.viewStackManager viewProfileDetails:channelOwner];
}

- (CGSize) itemSize
{
    return [SYNDeviceManager.sharedInstance isIPhone] ? CGSizeMake(120.0f, 152.0f) : CGSizeMake(251.0, 274.0);
}



- (void) dealloc
{
    // Stop observing everything (less error-prone than trying to remove observers individually
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
