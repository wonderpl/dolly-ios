//
//  SYNCoverChooserController.m
//  rockpack
//
//  Created by Michael Michailidis on 14/05/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "AppConstants.h"
#import "Channel.h"
#import "ChannelCover.h"
#import "CoverArt.h"
#import "GAI.h"
#import "GKImagePicker.h"
#import "SDWebImageManager.h"
#import "SYNAppDelegate.h"
#import "SYNCameraPopoverViewController.h"
#import "SYNChannelCoverImageCell.h"
#import "SYNChannelCoverImageSelectorViewController.h"
#import "SYNCoverChooserController.h"
#import "SYNCoverRightMoreView.h"
#import "SYNCoverThumbnailCell.h"
#import "SYNNetworkEngine.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPopoverBackgroundView.h"
#import "UIImageView+WebCache.h"


@interface SYNCoverChooserController () 

@property (nonatomic) NSInteger dataItemsAvailable;
@property (nonatomic) NSRange dataRequestRange;
@property (nonatomic, assign) BOOL shouldReloadCollectionView;
@property (nonatomic, assign) BOOL noMoreCovers;
@property (nonatomic, assign) BOOL shouldShowUploadingPlaceholder;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSBlockOperation *blockOperation;
@property (nonatomic, strong) NSFetchedResultsController *rockpackCoverFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *userCoverFetchedResultsController;
@property (nonatomic, strong) NSIndexPath* indexPathSelected;
@property (nonatomic, strong) SYNCoverRightMoreView* coverRightMoreView;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, weak) SYNAppDelegate* appDelegate;

@end


@implementation SYNCoverChooserController

#pragma mark - Object lifcycle

- (id) initWithSelectedImageURL: (NSString *) selectedImageURL
{
    if ((self = [super init]))
    {
        self.appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        self.selectedImageURL = selectedImageURL;
    }
    
    return self;
}

- (void) dealloc
{
    // Defensive programming
    self.collectionView.delegate = nil;
}


#pragma mark - View lifcycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // If we already have itmes in the database, start after the last one of those
    self.dataItemsAvailable = self.rockpackCoverFetchedResultsController.fetchedObjects.count;
    
    // Initialise the span and size of the first data request
    self.dataRequestRange = NSMakeRange(self.dataItemsAvailable, STANDARD_REQUEST_LENGTH);
    
    // Regster video thumbnail cell
    UINib *coverThumbnailCellNib = [UINib nibWithNibName: @"SYNCoverThumbnailCell"
                                                  bundle: nil];
    
    [self.collectionView registerNib: coverThumbnailCellNib
          forCellWithReuseIdentifier: @"SYNCoverThumbnailCell"];
    
    // Register Footer
    UINib *moreViewNib = [UINib nibWithNibName: @"SYNCoverRightMoreView"
                                        bundle: nil];
    
    [self.collectionView registerNib: moreViewNib
          forSupplementaryViewOfKind: UICollectionElementKindSectionFooter
                 withReuseIdentifier: @"SYNCoverRightMoreView"];
    
    self.collectionView.delegate = self;
}


#pragma mark - Delegate

- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    switch (section)
    {     
        case 0:
        {
            // There is always a 'No Cover' option
            return 1;
        }
            
        case 1:
        {
            if (self.shouldShowUploadingPlaceholder)
            {
                // Are we showing a placeholder?
                return 1;
            }
            else if (self.userCoverFetchedResultsController.fetchedObjects.count > 0)
            {
                // Are we displaying the user photo that matches, we should only have a single match or no match
                return 1;
            }
            
            return 0;
            
        }
        break;
            
        case 2:
        {
            return self.rockpackCoverFetchedResultsController.fetchedObjects.count;
        }
        break;
   
    }
    
    return 0;
}


- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) collectionView
{
    return 3;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) collectionView
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    CoverArt *coverArt = nil;
    
    SYNCoverThumbnailCell *coverThumbnailCell = [collectionView dequeueReusableCellWithReuseIdentifier: @"SYNCoverThumbnailCell"
                                                                                          forIndexPath: indexPath];
    switch (indexPath.section)
    {
        case 0:
        {
            coverThumbnailCell.coverImageView.image = [UIImage imageNamed: @"ChannelCreationCoverNone.png"];
            
            if ([self.selectedImageURL isEqualToString: @""])
            {
                coverThumbnailCell.selected = TRUE;
                self.indexPathSelected = indexPath;
            }
        }
        break;
            
        case 1:
        {
            if (self.shouldShowUploadingPlaceholder)
            {
                coverThumbnailCell.coverImageView.image = self.placeholderImage;
            }
            else
            {
                // User channel covers
                coverArt = [self.userCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: 0
                                                                                                         inSection: 0]];
                
                [coverThumbnailCell.coverImageView setImageWithURL: [NSURL URLWithString: coverArt.thumbnailURL]
                                                  placeholderImage: [UIImage imageNamed: @"PlaceholderChannelCreation.png"]
                                                           options: SDWebImageRetryFailed];
            }
            
            if ([coverArt.thumbnailURL isEqualToString: self.selectedImageURL])
            {
                coverThumbnailCell.selected = TRUE;
                self.indexPathSelected = indexPath;
            }
        }
        break;
            
        case 2:
        {
            // Rockpack channel covers
            coverArt = [self.rockpackCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                         inSection: 0]];
            
            [coverThumbnailCell.coverImageView setImageWithURL: [NSURL URLWithString: coverArt.thumbnailURL]
                                              placeholderImage: [UIImage imageNamed: @"PlaceholderChannelCreation.png"]
                                                       options: SDWebImageRetryFailed];
            
            if ([coverArt.thumbnailURL isEqualToString: self.selectedImageURL])
            {
                coverThumbnailCell.selected = TRUE;
                self.indexPathSelected = indexPath;
            }
        }
        break;
    }
    
    // If the user hasn't actually selected a cover, then try to match the cover id with the one for our cell,
    // and select if true
    if (self.indexPathSelected == nil)
    {
        // And we are not on the 'no cover' placeholder
        if (coverArt != nil)
        {
            if ([coverArt.thumbnailURL isEqualToString: self.selectedImageURL] || coverArt == nil)
            {
                coverThumbnailCell.selected = TRUE;
                self.indexPathSelected = indexPath;
            }
            else
            {
                coverThumbnailCell.selected = FALSE;
            }
        }
    }
    
    return coverThumbnailCell;
}


- (void) collectionView: (UICollectionView *) collectionView
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    // check to see that this is not our currently selected indexPath
    if (![self.indexPathSelected isEqual: indexPath])
    {
        NSIndexPath *previouslySelectedIndexPath = self.indexPathSelected;
        self.indexPathSelected = indexPath;
        
        [self.collectionView scrollToItemAtIndexPath: indexPath
                                    atScrollPosition: UICollectionViewScrollPositionNone
                                            animated: YES];
        NSString *imageURLString;
        NSString *remoteId;
        
        // There are two sections for cover thumbnails, the first represents 'no cover' the second contains all images
        switch (indexPath.section)
        {
            case 0:
            {
                [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                                       action: @"channelCoverSelected"
                                                                        label: @"None"
                                                                        value: nil] build]];
                
                imageURLString = @"";
                remoteId = kCoverSetNoCover;
            }
            break;
                
            case 1:
            {
                [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                                       action: @"channelCoverSelected"
                                                                        label: @"Uploaded"
                                                                        value: nil] build]];
                
                if (self.shouldShowUploadingPlaceholder)
                {
                    imageURLString = @"uploading";
                    remoteId = @"";
                }
                else
                {
                    // Rockpack channel covers
                    CoverArt *coverArt = [self.userCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: 0
                                                                                                                          inSection: 0]];
                    imageURLString = coverArt.thumbnailURL;
                    remoteId = coverArt.coverRef;
                }
            }
                break;
                
            case 2:
            {
                [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                                       action: @"channelCoverSelected"
                                                                        label: @"Rockpack"
                                                                        value: nil] build]];
                
                // User channel covers
                CoverArt *coverArt = [self.rockpackCoverFetchedResultsController objectAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row
                                                                                                                       inSection: 0]];
                imageURLString = coverArt.thumbnailURL;
                remoteId = coverArt.coverRef;
            }
            break;  
        }
        
        NSDictionary *userInfo = (self.placeholderImage) ?  @{kCoverArt: imageURLString ,
                                                              kCoverImageReference: remoteId,
                                                              kCoverArtImage: self.placeholderImage}
                                                         :  @{kCoverArt: imageURLString ,
                                                              kCoverImageReference: remoteId};
        
        [[NSNotificationCenter defaultCenter] postNotificationName: kCoverArtChanged
                                                            object: self
                                                          userInfo: userInfo];
        
        if (previouslySelectedIndexPath)
        {
            self.selectedImageURL = imageURLString;
            [collectionView reloadItemsAtIndexPaths: @[previouslySelectedIndexPath]];
        }
    }
}


#pragma mark - Fetched Results Controller

- (NSFetchedResultsController *) rockpackCoverFetchedResultsController
{
    if (_rockpackCoverFetchedResultsController)
        return _rockpackCoverFetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"CoverArt"
                                      inManagedObjectContext: self.appDelegate.mainManagedObjectContext];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat: @"(userUpload == FALSE)", self.selectedImageURL];
    
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    self.rockpackCoverFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                                     managedObjectContext: self.appDelegate.mainManagedObjectContext
                                                                                       sectionNameKeyPath: nil
                                                                                                cacheName: nil];
    
    self.rockpackCoverFetchedResultsController.delegate = self;
    
    
    NSError *error = nil;
    
    if (![_rockpackCoverFetchedResultsController performFetch: &error])
    {
        AssertOrLog(@"Channels Details Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    return _rockpackCoverFetchedResultsController;
}


- (NSFetchedResultsController *) userCoverFetchedResultsController
{
    if (_userCoverFetchedResultsController)
        return _userCoverFetchedResultsController;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    
    fetchRequest.entity = [NSEntityDescription entityForName: @"CoverArt"
                                      inManagedObjectContext: self.appDelegate.mainManagedObjectContext];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat: @"(userUpload == TRUE) AND (thumbnailURL == %@)", self.selectedImageURL];
    
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey: @"position" ascending: YES]];
    
    self.userCoverFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest
                                                                                 managedObjectContext: self.appDelegate.mainManagedObjectContext
                                                                                   sectionNameKeyPath: nil
                                                                                            cacheName: nil];
    self.userCoverFetchedResultsController.delegate = self;
    
    
    NSError *error = nil;
    
    if (![_userCoverFetchedResultsController performFetch: &error])
    {
        AssertOrLog(@"Channels Details Failed: %@\n%@", [error localizedDescription], [error userInfo]);
    }
    return _userCoverFetchedResultsController;
}


#pragma mark - Supplementary views

- (UICollectionReusableView *) collectionView: (UICollectionView *) collectionView
            viewForSupplementaryElementOfKind: (NSString *) kind
                                  atIndexPath: (NSIndexPath *) indexPath
{
    UICollectionReusableView* supplementaryView;
    
    if (collectionView != self.collectionView)
        return nil;

    if (kind == UICollectionElementKindSectionFooter && indexPath.section == 2)
    {        
        self.coverRightMoreView = [self.collectionView dequeueReusableSupplementaryViewOfKind: kind
                                                                          withReuseIdentifier: @"SYNCoverRightMoreView"
                                                                                 forIndexPath: indexPath];
        
        supplementaryView = self.coverRightMoreView;
    }
    
    return supplementaryView;
}


- (CGSize) collectionView: (UICollectionView *) collectionView
           layout: (UICollectionViewLayout*) collectionViewLayout
           referenceSizeForFooterInSection: (NSInteger) section
{
    if (section == 2 && (self.noMoreCovers == FALSE))
    {
        return CGSizeMake(141.0f, 121.0f);
    }
    else
    {
        return CGSizeZero;
    }
    
}


- (void) updateCoverArt
{
//    DebugLog(@"Updating range %d:%d", self.dataRequestRange.location, self.dataRequestRange.length);
    
    // Update the list of cover art
    [self.appDelegate.networkEngine updateCoverArtWithWithStart: self.dataRequestRange.location
                                                           size: self.dataRequestRange.length
                                              completionHandler: ^(NSDictionary *dictionary){
//                                                  DebugLog(@"Success");
                                                  NSNumber* totalNumber = dictionary[@"cover_art"][@"total"];
                                                  if (totalNumber && ![totalNumber isKindOfClass: [NSNull class]])
                                                      self.dataItemsAvailable = [totalNumber integerValue];
                                                  else
                                                      self.dataItemsAvailable = self.dataRequestRange.length;

//                                                  DebugLog (@"Count %d", self.rockpackCoverFetchedResultsController.fetchedObjects.count);
                                                  if ((self.dataRequestRange.location + self.dataRequestRange.length) >= self.dataItemsAvailable)
                                                  {
                                                      self.noMoreCovers = TRUE;
                                                      [self.collectionView reloadData];
                                                      return;
                                                  }

                                                  [self displayLoadMoreMessage];
                                              }
                                                   errorHandler: ^(NSError* error) {
                                                       DebugLog(@"%@", [error debugDescription]);
                                                       [self displayLoadMoreMessage];
                                                   }];
    
    [self.appDelegate.oAuthNetworkEngine updateCoverArtForUserId: self.appDelegate.currentOAuth2Credentials.userId
                                               onCompletion: ^{
//                                                   DebugLog(@"Success");
                                               }
                                                    onError: ^(NSError* error) {
                                                        DebugLog(@"%@", [error debugDescription]);
                                                    }];
}

- (void) createCoverPlaceholder: (UIImage *) image
{
    self.placeholderImage = image;
    self.shouldShowUploadingPlaceholder = TRUE;
    [self.collectionView reloadData];
    
    SYNCoverThumbnailCell *coverThumbnailCell = (SYNCoverThumbnailCell *)[self.collectionView cellForItemAtIndexPath: [NSIndexPath indexPathForItem: 0 inSection: 1]];
    
    coverThumbnailCell.selected = TRUE;                                             
}


#pragma mark - Autorotate Support

- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval) duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    [self.collectionView scrollToItemAtIndexPath: self.indexPathSelected
                                atScrollPosition: UICollectionViewScrollPositionNone
                                        animated: YES];
}

#pragma mark - Paging

- (void) incrementRangeForNextRequest
{
    NSInteger nextStart = self.dataRequestRange.location + self.dataRequestRange.length; // one is subtracted when the call happens for 0 indexing
    
    NSInteger nextSize = (nextStart + STANDARD_REQUEST_LENGTH) >= self.dataItemsAvailable ? (self.dataItemsAvailable - nextStart) : STANDARD_REQUEST_LENGTH;
    
    self.dataRequestRange = NSMakeRange(nextStart, nextSize);
//    DebugLog (@"Incrementing Range to %d:%d", self.dataRequestRange.location, self.dataRequestRange.length);
}


- (void) loadMoreCovers
{
    if (self.coverRightMoreView.loadingIndicatorView.isAnimating == NO)
    {
        [self displayLoadingMessageAndSpinner];
        
        [self incrementRangeForNextRequest];
        
        [self updateCoverArt];
    }
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
//    DebugLog (@"Scrolling");
    // when reaching far right hand side, load a new page
    if (scrollView.contentOffset.x == scrollView.contentSize.width - scrollView.bounds.size.width)
    {
        [self loadMoreCovers];
    }
}


- (void) displayLoadingMessageAndSpinner
{
    [self.coverRightMoreView.loadingIndicatorView startAnimating];
}


- (void) displayLoadMoreMessage
{
    [self.coverRightMoreView.loadingIndicatorView stopAnimating];
}


// Old blunderbuss way of doing things
- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    [self.collectionView reloadData];
}


@end
