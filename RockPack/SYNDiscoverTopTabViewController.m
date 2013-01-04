//
//  SYNDiscoverTopTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 16/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "Channel.h"
#import "SYNBottomTabViewController.h"
#import "SYNDiscoverTopTabViewController.h"
#import "SYNImageWellCell.h"
#import "SYNVideoDB.h"
#import "SYNVideoThumbnailWideCell.h"
#import "SYNWallpackCarouseHorizontallLayout.h"
#import "SYNWallpackCarouselCell.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SYNDiscoverTopTabViewController () <UIGestureRecognizerDelegate,
                                               UIScrollViewDelegate>

@property (nonatomic, assign, getter = isLargeVideoViewExpanded) BOOL largeVideoViewExpanded;
@property (nonatomic, strong) IBOutlet UIButton *rockItButton;
@property (nonatomic, strong) IBOutlet UIButton *shareItButton;
@property (nonatomic, strong) IBOutlet UILabel *rockItLabel;
@property (nonatomic, strong) IBOutlet UILabel *rockItNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *shareItLabel;
@property (nonatomic, strong) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIView *largeVideoPanelView;
@property (nonatomic, strong) IBOutlet UIView *videoPlaceholderView;
@property (nonatomic, strong) MPMoviePlayerController *mainVideoPlayerController;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;


@end

@implementation SYNDiscoverTopTabViewController

- (void) viewDidLoad
{
    [super viewDidLoad];


    // Set the labels to use the custom font
    self.titleLabel.font = [UIFont boldRockpackFontOfSize: 24.0f];
    self.subtitleLabel.font = [UIFont rockpackFontOfSize: 17.0f];
    self.rockItLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.shareItLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];
    self.rockItNumberLabel.font = [UIFont boldRockpackFontOfSize: 20.0f];

    // Init video thumbnail collection view
    UINib *videoThumbnailCellNib = [UINib nibWithNibName: @"SYNVideoThumbnailWideCell"
                                             bundle: nil];

    [self.videoThumbnailCollectionView registerNib: videoThumbnailCellNib
         forCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"];
}


- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    
    // TODO: Remove this video download hack once we have real data from the API
    [[SYNVideoDB sharedVideoDBManager] downloadContentIfRequiredDisplayingHUDInView: self.view];

    // Set the first video
    if (self.videoInstanceFetchedResultsController.fetchedObjects.count > 0)
    {
        [self setLargeVideoToIndexPath: [NSIndexPath indexPathForRow: 0
                                                           inSection: 0]];
    }
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    [self.videoThumbnailCollectionView reloadData];
}


- (BOOL) hasImageWell
{
    return TRUE;
}


#pragma mark - Core Data support

// The following 2 methods are called by the abstract class' getFetchedResults controller methods
- (NSPredicate *) videoInstanceFetchedResultsControllerPredicate
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueId == %@", @"1"];
    
    return predicate;
    
    return nil;
}


- (NSArray *) videoInstanceFetchedResultsControllerSortDescriptors
{
    // TODO: This is currently sorted by title, but I suspect that we need to be more sophisticated
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"title"
                                                                   ascending: YES];
    return @[sortDescriptor];
}


- (NSPredicate *) channelFetchedResultsControllerPredicate
{
    // Don't show any user generated channels
    return [NSPredicate predicateWithFormat: @"channelOwner.uniqueId != 666"];
}


- (NSArray *) channelFetchedResultsControllerSortDescriptors
{
    // Sort by index
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"index"
                                                                   ascending: YES];
    return @[sortDescriptor];
}


- (void) setLargeVideoToIndexPath: (NSIndexPath *) indexPath
{
    self.currentIndexPath = indexPath;
    
    [self updateLargeVideoDetailsForIndexPath: indexPath];
    
    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
    NSURL *videoURL = videoInstance.video.localVideoURL;
    
    self.mainVideoPlayerController = [[MPMoviePlayerController alloc] initWithContentURL: videoURL];
    
    self.mainVideoPlayerController.shouldAutoplay = NO;
    [self.mainVideoPlayerController prepareToPlay];
    
    [[self.mainVideoPlayerController view] setFrame: [self.videoPlaceholderView bounds]]; // Frame must match parent view
    
    [self.videoPlaceholderView addSubview: [self.mainVideoPlayerController view]];
    
    // Add dragging to large video view
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                                            action: @selector(longPressLargeVideo:)];
    [self.mainVideoPlayerController.view addGestureRecognizer: longPress];
    
    [self.mainVideoPlayerController pause];
    
}


- (IBAction) longPressLargeVideo: (UIGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        // figure out which item in the table was selected
        
        self.inDrag = YES;
        
        // Store the initial drag point, just in case we have to animate it back if the user misses the drop zone
        self.initialDragCenter = [sender locationInView: self.view];
        
        // Hardcoded for now, eeek!
        CGRect frame = CGRectMake(self.initialDragCenter.x - 63, self.initialDragCenter.y - 36, 127, 72);
        self.draggedView = [[UIImageView alloc] initWithFrame: frame];
        self.draggedView.alpha = 0.7;
        
        Video *video = [self.videoInstanceFetchedResultsController objectAtIndexPath: self.currentIndexPath];
        self.draggedView.image = video.thumbnailImage;
        
        // now add the item to the view
        [self.view addSubview: self.draggedView];
        
        // Highlight the image well
        [self highlightImageWell: TRUE];
    }
    else if (sender.state == UIGestureRecognizerStateChanged && self.inDrag)
    {
        // we dragged it, so let's update the coordinates of the dragged view
        CGPoint point = [sender locationInView: self.view];
        self.draggedView.center = point;
    }
    else if (sender.state == UIGestureRecognizerStateEnded && self.inDrag)
    {
        // Un-highlight the image well
        [self highlightImageWell: FALSE];
        
        // and let's figure out where we dropped it
//        CGPoint point = [sender locationInView: self.dropZoneView];
        CGPoint point = [sender locationInView: self.view];
        
        // If we have dropped it in the right place, then add it to our image well
        if ([self pointInImageWell: point])
            
        {
            // Hide the dragged thumbnail and add new image to image well
            [self.draggedView removeFromSuperview];
            [self addToImageWellFromLargeVideo: nil];
        }
        else
        {
            [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                                  delay: 0.0f
                                options: UIViewAnimationOptionCurveEaseInOut
                             animations: ^
             {
                 // Contract thumbnail view
                 self.draggedView.center = self.initialDragCenter;
                 
             }
                             completion: ^(BOOL finished)
             {
                 [self.draggedView removeFromSuperview];
             }];
        }
    }
}


- (IBAction) addToImageWellFromLargeVideo: (id) sender
{
    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: self.currentIndexPath];
    [self animateImageWellAdditionWithVideo: videoInstance];
}


- (void) updateLargeVideoDetailsForIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
    
    self.titleLabel.text = videoInstance.title;
    self.subtitleLabel.text = videoInstance.channel.title;
    
    [self updateLargeVideoRockpackForIndexPath: indexPath];
}


- (void) updateLargeVideoRockpackForIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
    
    self.rockItNumberLabel.text = [NSString stringWithFormat: @"%@", videoInstance.video.starCount];
    self.rockItButton.selected = videoInstance.video.starredByUserValue;
}



- (void) setSelectedIndex: (NSUInteger) newSelectedIndex
                 animated: (BOOL) animated
{
    if (newSelectedIndex != NSNotFound)
    {
        [self highlightTab: newSelectedIndex];
        
        // We need to change the search criteria here to relect the change in genre
        
        [self.videoThumbnailCollectionView reloadData];
    }
}


- (void) toggleRockItAtIndex: (NSIndexPath *) indexPath
{
    Video *video = [self.videoInstanceFetchedResultsController objectAtIndexPath: indexPath];
    
    if (video.starredByUserValue == TRUE)
    {
        // Currently highlighted, so decrement
        video.starredByUserValue = FALSE;
        video.starCountValue -= 1;
    }
    else
    {
        // Currently highlighted, so increment
        video.starredByUserValue = TRUE;
        video.starCountValue += 1;
    }
    
    [self saveDB];
}


- (void) updateOtherOnscreenVideoAssetsForIndexPath: (NSIndexPath *) indexPath
{
    if ([indexPath isEqual: self.currentIndexPath])
    {
        [self updateLargeVideoRockpackForIndexPath: self.currentIndexPath];
    }
}



- (IBAction) toggleLargeRockItButton: (UIButton *) button
{
    button.selected = !button.selected;
    
    [self toggleRockItAtIndex: self.currentIndexPath];
    [self updateLargeVideoDetailsForIndexPath: self.currentIndexPath];
    [self.videoThumbnailCollectionView reloadData];
    
    [self saveDB];
}


// Buttons activated from scrolling list of thumbnails


- (IBAction) swipeLargeVideoViewLeft: (UISwipeGestureRecognizer *) swipeGesture
{
#ifdef FULL_SCREEN_THUMBNAILS
#ifdef SOUND_ENABLED
    // Play a suitable sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"Scroll"
                                                          ofType: @"aif"];
    
    NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
    AudioServicesPlaySystemSound(sound);
#endif
    
    // Animate the view out onto the screen
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Slide off large video view
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = -1024;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
         
         // Expand thumbnail view
         CGRect thumbailViewFrame = self.thumbnailView.frame;
         thumbailViewFrame.origin.x = 0;
         thumbailViewFrame.size.width = 1024;
         self.thumbnailView.frame =  thumbailViewFrame;
     }
                     completion: ^(BOOL finished)
     {
         // Fix hidden video view
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = -1024;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
         
         // Fix expanded thumbnail view
         CGRect thumbailViewFrame = self.thumbnailView.frame;
         thumbailViewFrame.origin.x = 0;
         thumbailViewFrame.size.width = 1024;
         self.thumbnailView.frame =  thumbailViewFrame;
         
         // Allow it to be expanded again
         self.largeVideoViewExpanded = FALSE;
     }];
#endif
}

#pragma mark - Large video view open animation

- (IBAction) animateLargeVideoViewRight: (id) sender
{
#ifdef FULL_SCREEN_THUMBNAILS
#ifdef SOUND_ENABLED
    // Play a suitable sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource: @"Scroll"
                                                          ofType: @"aif"];
    
    NSURL *soundURL = [NSURL fileURLWithPath: soundPath];
    SystemSoundID sound;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
    AudioServicesPlaySystemSound(sound);
#endif
    
    // Animate the view out onto the screen
    [UIView animateWithDuration: kLargeVideoPanelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Slide on large video view
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = 0;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
         
         // Contract thumbnail view
         CGRect thumbailViewFrame = self.thumbnailView.frame;
         thumbailViewFrame.origin.x = 512;
         thumbailViewFrame.size.width = 512;
         self.thumbnailView.frame =  thumbailViewFrame;
         
     }
                     completion: ^(BOOL finished)
     {
         // Fix on-screen video view
         CGRect largeVideoPanelFrame = self.largeVideoPanelView.frame;
         largeVideoPanelFrame.origin.x = 0;
         self.largeVideoPanelView.frame =  largeVideoPanelFrame;
         
         // Fix contracted thumbnail view
         CGRect thumbailViewFrame = self.thumbnailView.frame;
         thumbailViewFrame.origin.x = 512;
         thumbailViewFrame.size.width = 512;
         self.thumbnailView.frame =  thumbailViewFrame;
     }];
#endif
}


#pragma mark - Collection view support

- (NSInteger) collectionView: (UICollectionView *) cv
      numberOfItemsInSection: (NSInteger) section
{
    // See if this can be handled in our abstract base class
    int items = [super collectionView: cv
              numberOfItemsInSection:  section];
    
    if (items < 0)
    {
        if (cv == self.videoThumbnailCollectionView)
        {
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.videoInstanceFetchedResultsController sections][section];
            items = [sectionInfo numberOfObjects];
        }
        else
        {
            AssertOrLog(@"No valid collection view found");
        }
    }
    
    return items;
}

- (NSInteger) numberOfSectionsInCollectionView: (UICollectionView *) cv
{
    return 1;
}

- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    // See if this can be handled in our abstract base class
    UICollectionViewCell *cell = [super collectionView: cv
                                cellForItemAtIndexPath: indexPath];
    
    // Do we have a valid cell?
    if (!cell)
    {
        AssertOrLog(@"No valid collection view found");
    }
    
    return cell;
}


- (void) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPath: (NSIndexPath *) indexPath
{
    // See if this can be handled in our abstract base class
    BOOL handledInSuperview = [super collectionView: (UICollectionView *) cv
                   didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath];
    
    if (!handledInSuperview)
    {
        // Check to see if is one that we can handle
        if (cv == self.videoThumbnailCollectionView)
        {
#ifdef FULL_SCREEN_THUMBNAILS
            if (self.isLargeVideoViewExpanded == FALSE)
            {
                [self animateLargeVideoViewRight: nil];
                self.largeVideoViewExpanded = TRUE;
            }
#endif
            self.currentIndexPath = indexPath;
            
            [self setLargeVideoToIndexPath: indexPath];
        }
        else
        {
            AssertOrLog(@"Trying to select unexpected collection view");
        }
    }
}


- (void) shiftImageWellUp
{
     CGRect imageWellFrame = self.imageWellView.frame;
     imageWellFrame.origin.y -= kImageWellEffectiveHeight;
     self.imageWellView.frame = imageWellFrame;

     CGRect viewFrame = self.largeVideoPanelView.frame;
     viewFrame.size.height -= kImageWellEffectiveHeight;
     self.largeVideoPanelView.frame = viewFrame;

     viewFrame = self.videoThumbnailCollectionView.frame;
     viewFrame.size.height -= kImageWellEffectiveHeight;
     self.videoThumbnailCollectionView.frame = viewFrame;
}


- (void) shiftImageWellDown
{
    CGRect imageWellFrame = self.imageWellView.frame;
    imageWellFrame.origin.y += kImageWellEffectiveHeight;
    self.imageWellView.frame = imageWellFrame;
    
    // Slide imagewell view downwards (and expand any other dependent visible views)
    CGRect viewFrame = self.largeVideoPanelView.frame;
    viewFrame.size.height += kImageWellEffectiveHeight;
    self.largeVideoPanelView.frame = viewFrame;
    
    viewFrame = self.videoThumbnailCollectionView.frame;
    viewFrame.size.height += kImageWellEffectiveHeight;
    self.videoThumbnailCollectionView.frame = viewFrame;
}

@end
