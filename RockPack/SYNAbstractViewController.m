//
//  SYNAbstractViewController.m
//  rockpack
//
//  Created by Nick Banks on 27/11/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//
//  Abstract view controller to provide functionality common to all Rockpack view controllers
//
//  To keep the code as DRY as possible, we put as much common stuff in here as possible

#import "AppConstants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "ChannelOwner.h"
#import "NSObject+Blocks.h"
#import "SYNAbstractViewController.h"
#import "SYNAppDelegate.h"
#import "SYNContainerViewController.h"
#import "SYNChannelsDetailViewController.h"
#import "SYNChannelsDetailsCreationViewController.h"
#import "SYNMasterViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNVideoQueueCell.h"
#import "SYNVideoQueueViewController.h"
#import "SYNVideoThumbnailWideCell.h"
#import "UIFont+SYNFont.h"
#import "UIImageView+ImageProcessing.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNChannelsAddVideosViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SYNAbstractViewController ()  <UITextFieldDelegate>

@property (getter = isVideoQueueVisible) BOOL videoQueueVisible;
@property (nonatomic, assign) BOOL shouldPlaySound;
@property (nonatomic, strong) IBOutlet UIImageView *channelOverlayView;
@property (nonatomic, strong) IBOutlet UITextField *channelNameTextField;
@property (nonatomic, assign) NSUInteger selectedIndex;


@property (nonatomic, strong) UIView *dropZoneView;
@property (nonatomic, strong) SYNVideoQueueViewController* videoQVC;
@end


@implementation SYNAbstractViewController


@synthesize fetchedResultsController = fetchedResultsController;
@synthesize selectedIndex = _selectedIndex;

@synthesize tabViewController;

#pragma mark - Custom accessor methods

- (id) init
{
    DebugLog(@"WARNING: init called on Abstract View Controller, call initWithViewId instead");
    return [self initWithViewId: @"NULL"];
}

- (id) initWithViewId: (NSString*) vid
{
    if ((self = [super init]))
    {
        viewId = vid;
    }
    
    return self;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
}

-(void)viewCameToScrollFront
{
    
}

- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    startAnimationDelay = 0.0;
    [self reloadCollectionViews];
}


-(void) reloadCollectionViews
{
    //AssertOrLog (@"Abstract class called 'reloadCollectionViews'");
}

// Helper method: Save the current DB state
- (void) saveDB
{
    NSError *error = nil;
    
    if (![appDelegate.mainManagedObjectContext save: &error])
    {
        NSArray* detailedErrors = [[error userInfo] objectForKey: NSDetailedErrorsKey];
        
        if ([detailedErrors count] > 0)
        {
            for(NSError* detailedError in detailedErrors)
            {
                DebugLog(@" DetailedError: %@", [detailedError userInfo]);
            }
        }
        
        // Bail out if save failed
        error = [NSError errorWithDomain: NSURLErrorDomain
                                    code: NSCoreDataError
                                userInfo: nil];
        
        @throw error;
    }  
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];

    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoQueueHide
                                                        object:self];
}

#pragma mark - Animation support

// Special animation of pushing new view controller onto UINavigationController's stack
- (void) animatedPushViewController: (UIViewController *) vc
{
    self.view.alpha = 1.0f;
    vc.view.alpha = 0.0f;
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
     {
         // Contract thumbnail view
         self.view.alpha = 0.0f;
         vc.view.alpha = 1.0f;
         
     }
     completion: ^(BOOL finished)
     {
         
     }];
    
    [self.navigationController pushViewController:vc animated: NO];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteBackButtonShow object:self];
}


- (void) animatedPopViewController
{
    UIViewController *parentVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
    parentVC.view.alpha = 0.0f;
    
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
         
         self.view.alpha = 0.0f;
         parentVC.view.alpha = 1.0f;
         
     } completion: ^(BOOL finished) {
         
     }];
    
    
    [self.navigationController popViewControllerAnimated:NO];
    
    // Hide back button
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteBackButtonHide object:self];
}


- (void) toggleVideoStarAtIndex: (NSIndexPath *) indexPath
{
    
    NSString *action = nil;
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    if (videoInstance.video.starredByUserValue == TRUE)
    {
        // Currently highlighted, so decrement
        videoInstance.video.starredByUserValue = FALSE;
        videoInstance.video.starCountValue -= 1;
        action = @"unstar";
    }
    else
    {
        // Currently highlighted, so increment
        videoInstance.video.starredByUserValue = TRUE;
        videoInstance.video.starCountValue += 1;
        action = @"star";
    }
    
    [self saveDB];
    
    // Update the star/unstar status on the server
    [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentOAuth2Credentials.userId
                                                     action: action
                                            videoInstanceId: videoInstance.uniqueId
                                          completionHandler: ^(NSDictionary *responseDictionary)
     {
         DebugLog(@"Record action successful");
     }
                                               errorHandler: ^(NSDictionary* errorDictionary)
     {
         DebugLog(@"Record action failed");
     }];
}


- (void) toggleChannelSubscribeAtIndex: (NSIndexPath *) indexPath
{
    Channel *channel = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    if (channel.subscribedByUserValue == TRUE)
    {
        // Currently highlighted, so decrement
        channel.subscribedByUserValue = FALSE;
        channel.subscribersCountValue -= 1;
        
        // Update the star/unstar status on the server
        [appDelegate.oAuthNetworkEngine channelUnsubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
         channelId: channel.uniqueId
         completionHandler: ^(NSDictionary *responseDictionary)
         {
             DebugLog(@"Unsubscribe action successful");
         }
         errorHandler: ^(NSDictionary* errorDictionary)
         {
             DebugLog(@"Unsubscribe action failed");
         }];
    }
    else
    {
        // Currently highlighted, so increment
        channel.subscribedByUserValue = TRUE;
        channel.subscribersCountValue += 1;
        
        // Update the star/unstar status on the server
        [appDelegate.oAuthNetworkEngine channelSubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
         channelURL: channel.resourceURL
         completionHandler: ^(NSDictionary *responseDictionary)
         {
             DebugLog(@"Subscribe action successful");
         }
         errorHandler: ^(NSDictionary* errorDictionary)
         {
             DebugLog(@"Subscribe action failed");
         }];
    }
    
    [self saveDB];
}





// This can be overridden if updating star may cause the videoFetchedResults
- (BOOL) shouldUpdateStarStatus
{
    return TRUE;
}


// This is intended to be subclassed where other video assets (i.e. a Large video view) have information that is dependent on Video attributes
- (void) updateOtherOnscreenVideoAssetsForIndexPath: (NSIndexPath *) indexPath
{
    // By default, do nothing
}


- (IBAction) userTouchedVideoAddItButton: (UIButton *) addItButton
{
   
    
    UIView *v = addItButton.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    [self animateVideoAdditionToVideoQueue: videoInstance];
}


- (IBAction) userTouchedVideoShareItButton: (UIButton *) addItButton
{
    
    
    
}


// Called by invisible button on video view cell

- (void) displayVideoViewerFromView: (UIGestureRecognizer *) sender
{
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: [sender locationInView: self.videoThumbnailCollectionView]];

    [self displayVideoViewerWithSelectedIndexPath: indexPath];
}


- (void) displayVideoViewerWithSelectedIndexPath: (NSIndexPath *) selectedIndexPath
{
    SYNMasterViewController *masterViewController = (SYNMasterViewController*)appDelegate.masterViewController;
    
    [masterViewController addVideoOverlayToViewController: self
                             withFetchedResultsController: self.fetchedResultsController
                                             andIndexPath: selectedIndexPath];
}

- (void) displayCategoryChooser
{
    SYNMasterViewController *masterViewController = (SYNMasterViewController*)appDelegate.masterViewController;
    
    [masterViewController addCategoryChooserOverlayToViewController: self];
}


#pragma mark - Initialisation

- (NSInteger) collectionView: (UICollectionView *) cv
      numberOfItemsInSection: (NSInteger) section
{
    return -1;
}





- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath {
    
    UICollectionViewCell *cell = nil;
    
    if (cv == self.videoThumbnailCollectionView)
    {
        // No, but it was our collection view
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
        SYNVideoThumbnailWideCell *videoThumbnailCell = [cv dequeueReusableCellWithReuseIdentifier: @"SYNVideoThumbnailWideCell"
                                                                                      forIndexPath: indexPath];
        
        videoThumbnailCell.videoImageViewImage = videoInstance.video.thumbnailURL;
        videoThumbnailCell.channelImageViewImage = videoInstance.channel.coverThumbnailSmallURL;
        videoThumbnailCell.videoTitle.text = videoInstance.title;
        videoThumbnailCell.channelName.text = videoInstance.channel.title;
        videoThumbnailCell.usernameText = [NSString stringWithFormat: @"%@", videoInstance.channel.channelOwner.displayName];
        
        
        videoThumbnailCell.viewControllerDelegate = self;
        
        cell = videoThumbnailCell;
    }

    return cell;
}

-(void)refresh
{
    // to implement in subclass
}


- (BOOL) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath
{
    
    return NO;
}

// Create a channel pressed

- (void) createChannel:(Channel*)channel
{
    SYNChannelsDetailsCreationViewController *channelCreationVC = [[SYNChannelsDetailsCreationViewController alloc] initWithChannel: channel];
    
    [self animatedPushViewController: channelCreationVC];
}

- (void) addToChannel:(Channel*)channel
{
    SYNChannelsAddVideosViewController *channelCreationVC = [[SYNChannelsAddVideosViewController alloc] initWithChannel: channel];
    
    [self animatedPushViewController: channelCreationVC];
}

// User touched the channel thumbnail in a video cell
- (IBAction) userTouchedChannelButton: (UIButton *) channelButton
{
    // Get to cell it self (from button subview)
    UIView *v = channelButton.superview.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (indexPath)
    {
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
        [self viewChannelDetails: videoInstance.channel];
    }
}


- (void) viewChannelDetails: (Channel *) channel
{
    SYNChannelsDetailViewController *channelVC = [[SYNChannelsDetailViewController alloc] initWithChannel: channel];
    
    [self animatedPushViewController: channelVC];
}


- (IBAction) userTouchedProfileButton: (UIButton *) profileButton
{
    // Get to cell it self (from button subview)
    UIView *v = profileButton.superview.superview.superview;
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: v.center];
    
    // Bail if we don't have an index path
    if (indexPath)
    {
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
        [self viewProfileDetails: videoInstance.channel.channelOwner];
    }
}

- (void) viewProfileDetails: (ChannelOwner *) channelOwner
{

    [[NSNotificationCenter defaultCenter] postNotificationName:kShowUserChannels object:self userInfo:@{@"ChannelOwner":channelOwner}];
}





- (BOOL) hasTabBar
{
    return TRUE;
}


#pragma mark - Video Queue Methods

- (BOOL) isVideoQueueVisibleOnStart;
{
    return FALSE;
}


- (void) animateVideoAdditionToVideoQueue: (VideoInstance *) videoInstance
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoQueueAdd
                                                        object:self
                                                      userInfo:@{@"VideoInstance" : videoInstance}];
}


- (void) highlightVideoQueue: (BOOL) showHighlight
{
    
}


- (BOOL) pointInVideoQueue: (CGPoint) point
{
    return YES;
}


#pragma mark - Trace

-(NSString*)description
{
    return [NSString stringWithFormat:@"ViewController: %@", viewId];
}


#pragma mark - Tab View Methods

- (void) highlightTab: (int) tabIndex
{
    
}


-(void)setTabViewController:(SYNTabViewController *)newTabViewController
{
    tabViewController = newTabViewController;
    tabViewController.delegate = self;
    [self.view addSubview:tabViewController.tabView];
    
    tabExpanded = NO;
}

#pragma mark - TabViewDelegate

-(void)handleMainTap:(UITapGestureRecognizer *)recogniser
{
    // to be implemented by child
}


-(void)handleSecondaryTap:(UITapGestureRecognizer *)recogniser
{
    // to be implemented by child
}


-(void)handleNewTabSelectionWithId:(NSString*)selectionId
{
    // to be implemented by child
}

-(BOOL)showSubcategories
{
    return YES;
}

@end
