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
#import "Channel.h"
#import "ChannelCover.h"
#import "ChannelOwner.h"
#import "GAI.h"
#import "NSDictionary+Validation.h"
#import "NSObject+Blocks.h"
#import "OWActivityViewController.h"
#import "SDWebImageManager.h"
#import "SYNAbstractViewController.h"
#import "SYNAppDelegate.h"
#import "SYNChannelDetailViewController.h"
#import "SYNContainerViewController.h"
#import "SYNDeviceManager.h"
#import "SYNImplicitSharingController.h"
#import "SYNMasterViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNPopoverBackgroundView.h"
#import "SYNProfileRootViewController.h"
#import "SYNVideoThumbnailWideCell.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "SYNOneToOneSharingController.h"
#import "VideoInstance.h"
#import <QuartzCore/QuartzCore.h>

#define kScrollContentOff 100.0f
#define kScrollSpeedBoundary 550.0f

@interface SYNAbstractViewController ()  <UITextFieldDelegate,
                                          UIPopoverControllerDelegate>

@property (getter = isVideoQueueVisible) BOOL videoQueueVisible;
@property (nonatomic, assign) BOOL shouldPlaySound;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) SYNOneToOneSharingController* oneToOneViewController;
@property (nonatomic, strong) UIPopoverController *activityPopoverController;
@property (nonatomic, strong) UIView *dropZoneView;
@property (strong, nonatomic) NSMutableDictionary *mutableShareDictionary;
@property (strong, nonatomic) OWActivityView *activityView;
@property (strong, nonatomic) OWActivityViewController *activityViewController;
@property (strong, readonly, nonatomic) NSArray *activities;
@property (weak, nonatomic) UIPopoverController *presentingPopoverController;
@property (weak, nonatomic) UIViewController *presentingController;
@property (nonatomic, assign) NSInteger lastContentOffset;
@property (nonatomic, assign) CGPoint startDraggingPoint;
@property (nonatomic, assign) CGPoint endDraggingPoint;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (nonatomic, assign) ScrollingDirection *scrollDirection;
@property (nonatomic, assign) BOOL scrollerIsNearTop;

@end


@implementation SYNAbstractViewController

@synthesize fetchedResultsController = fetchedResultsController;
@synthesize selectedIndex = _selectedIndex;

@synthesize tabViewController;

@synthesize viewId;

#pragma mark - Object lifecycle

- (id) init
{
    return [self initWithViewId: @"Unknown"];
}


- (id) initWithViewId: (NSString*) vid
{
    // Check to see if there is a XIB file in the system and initialise accordingly
    
    NSString* classNameString = NSStringFromClass([self class]);
    
    if([[NSBundle mainBundle] pathForResource:classNameString ofType:@"nib"] != nil)
    {
        self = [super initWithNibName:classNameString bundle:nil];
    }
    else
    {
        self = [super init];
    }
    if (self)
    {
        viewId = vid;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationWillEnterForeground:)
                                                     name: UIApplicationWillEnterForegroundNotification
                                                   object: nil];
    }
    
    return self;
}


- (void) dealloc
{
    // Defensive programming
    tabViewController.delegate = nil;
    self.activityPopoverController.delegate = nil;
    
    if (self.activityPopoverController)
    {
        [self.activityPopoverController dismissPopoverAnimated: NO];
    }
    // Stop observing everything
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(clearedLocationBoundData)
                                                 name: kClearedLocationBoundData
                                               object: nil];
    
    appDelegate = (SYNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // for loading data
    
    [self resetDataRequestRange];
    
    self.view.multipleTouchEnabled = NO;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(IS_IOS_7_OR_GREATER)
        [self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    // Compensate for iOS7
    

}

#pragma mark - Data Request Range

- (void) resetDataRequestRange
{
    self.dataRequestRange = NSMakeRange(0, STANDARD_REQUEST_LENGTH);
}

- (BOOL) moreItemsToLoad
{
    
    return (self.dataRequestRange.location + self.dataRequestRange.length < self.dataItemsAvailable);
}

- (void) incrementRangeForNextRequest
{
    if(!self.moreItemsToLoad)
        return;
    
    NSInteger nextStart = self.dataRequestRange.location + self.dataRequestRange.length; // one is subtracted when the call happens for 0 indexing
    
    NSInteger nextSize = MIN(STANDARD_REQUEST_LENGTH, self.dataItemsAvailable - nextStart);
    
    self.dataRequestRange = NSMakeRange(nextStart, nextSize);
}

#pragma mark -


- (void) controllerDidChangeContent: (NSFetchedResultsController *) controller
{
    [self reloadCollectionViews];
}


- (void) reloadCollectionViews
{
    //AssertOrLog (@"Abstract class called 'reloadCollectionViews'");
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






- (NSIndexPath *) indexPathFromVideoInstanceButton: (UIButton *) button
{
    UIView* target = button;
    while (target && ![target isKindOfClass:[UICollectionViewCell class]])
    {
        target = [target superview];
    }
    NSIndexPath *indexPath = [self.videoThumbnailCollectionView indexPathForItemAtPoint: target.center];
    
    return indexPath;
}


- (IBAction) userTouchedVideoShareButton: (UIButton *) videoShareButton
{
    NSIndexPath *indexPath = [self indexPathFromVideoInstanceButton: videoShareButton];
    VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    [self shareVideoInstance: videoInstance];
}


- (void) displayVideoViewerFromView: (UIButton *) videoViewButton
{
    NSIndexPath *indexPath = [self indexPathFromVideoInstanceButton: videoViewButton];
    
    id selectedVideo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSArray* videoArray =  self.fetchedResultsController.fetchedObjects;
    CGPoint center;
    if(videoViewButton)
    {
        center = [self.view convertPoint:videoViewButton.center fromView:videoViewButton.superview];
    }
    else
    {
        center = self.view.center;
    }
    [self displayVideoViewerWithVideoInstanceArray: videoArray
                                  andSelectedIndex: [videoArray indexOfObject:selectedVideo] center:center];
}


- (void) displayVideoViewerWithVideoInstanceArray: (NSArray *) videoInstanceArray
                                andSelectedIndex: (int) selectedIndex
                                           center:(CGPoint)center
{
    SYNMasterViewController *masterViewController = (SYNMasterViewController*)appDelegate.masterViewController;
        
    [masterViewController addVideoOverlayToViewController: self
                                   withVideoInstanceArray: videoInstanceArray
                                         andSelectedIndex: selectedIndex
                                               fromCenter: center];
}


#pragma mark - UICollectionView Data Source Stubs

// To be implemented by subclasses
- (NSInteger) collectionView: (UICollectionView *) cv
      numberOfItemsInSection: (NSInteger) section
{
    AssertOrLog(@"Shouldn't be calling abstract class method");
    return 0;
}


- (UICollectionViewCell *) collectionView: (UICollectionView *) cv
                   cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    AssertOrLog(@"Shouldn't be calling abstract class method");
    return nil;
}


- (BOOL) collectionView: (UICollectionView *) cv
         didSelectItemAtIndexPathAbstract: (NSIndexPath *) indexPath
{
    AssertOrLog(@"Shouldn't be calling abstract class method");
    return NO;
}


- (void) refresh
{
    AssertOrLog(@"Shouldn't be calling abstract class method");
}


// User pressed the channel thumbnail in a VideoCell
- (IBAction) channelButtonTapped: (UIButton *) channelButton
{
    NSIndexPath *indexPath = [self indexPathFromVideoInstanceButton: channelButton];
    
    if (indexPath)
    {
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
        [appDelegate.viewStackManager viewChannelDetails:videoInstance.channel];
    }
}


- (void) videoOverlayDidDissapear
{
    // to be implemented by child
}


- (IBAction) profileButtonTapped: (UIButton *) profileButton
{
    NSIndexPath *indexPath = [self indexPathFromVideoInstanceButton: profileButton];
    
    // Bail if we don't have an index path
    if (indexPath)
    {
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
        [appDelegate.viewStackManager viewProfileDetails: videoInstance.channel.channelOwner];
    }
}





#pragma mark - Trace

- (NSString*) description
{
    return [NSString stringWithFormat: @"SYNAbstractViewController of type '%@' and viewId '%@'", NSStringFromClass([self class]), viewId];
}


#pragma mark - Tab View Methods

- (void) setTabViewController: (SYNTabViewController *) newTabViewController
{
    tabViewController = newTabViewController;
    tabViewController.delegate = self;
    [self.view addSubview: tabViewController.tabView];
    
    tabExpanded = NO;
}

#pragma mark - TabViewDelegate

- (void) handleMainTap: (UITapGestureRecognizer *) recogniser
{
    // to be implemented by child
    DebugLog(@"WARNING: Abstract method called");
}


- (void) handleSecondaryTap: (UITapGestureRecognizer *) recogniser
{
    // to be implemented by child
    DebugLog(@"WARNING: Abstract method called");
}


- (void) handleNewTabSelectionWithId: (NSString*) selectionId
{
    // to be implemented by child
    DebugLog(@"WARNING: Abstract method called");
}

- (void) handleNewTabSelectionWithGenre: (Genre*) name
{
    // to be implemented by child
    DebugLog(@"WARNING: Abstract method called");
}

-(void)clearedLocationBoundData
{
    // to be implemented by child
}
- (BOOL) showSubGenres
{
    return YES;
}



-(void)setTitle:(NSString *)title
{
    abstractTitle = title;
}

-(NSString*)title
{
    if(abstractTitle && ![abstractTitle isEqualToString:@""])
        return abstractTitle;
    else
        return viewId;
}

#pragma mark - Social network sharing

- (void) shareVideoInstance: (VideoInstance *) videoInstance
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"videoShareButtonClick"
                                                            label: nil
                                                            value: nil] build]];
    
    // At this point it is safe to assume that the video thumbnail image is in the cache
    UIImage *thumbnailImage = [SDWebImageManager.sharedManager.imageCache imageFromMemoryCacheForKey: videoInstance.video.thumbnailURL];
    
    [self shareObjectType: @"video_instance"
                 objectId: videoInstance.uniqueId
                  isOwner: @NO
                  isVideo: @YES
               usingImage: thumbnailImage];
}


- (void) shareChannel: (Channel *) channel
              isOwner: (NSNumber *) isOwner
           usingImage: (UIImage *) image
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"channelShareButtonClick"
                                                            label: nil
                                                            value: nil] build]];
    
    [self shareObjectType:  @"channel"
                 objectId: channel.uniqueId
                  isOwner: isOwner
                  isVideo: @NO
               usingImage: image];
}


- (void) shareObjectType: (NSString *) objectType
                objectId: (NSString *) objectId
                 isOwner: (NSNumber *) isOwner
                 isVideo: (NSNumber *) isVideo
              usingImage: (UIImage *) usingImage
{
    if ([objectType isEqualToString: @"channel"])
    {
        if (!usingImage)
        {
            // Capture screen image if we weren't passed an image in
            UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
            CGRect keyWindowRect = [keyWindow bounds];
            UIGraphicsBeginImageContextWithOptions(keyWindowRect.size, YES, 0.0f);
            CGContextRef context = UIGraphicsGetCurrentContext();
            [keyWindow.layer
             renderInContext: context];
            UIImage *capturedScreenImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIInterfaceOrientation orientation = [SYNDeviceManager.sharedInstance orientation];
            
            switch (orientation)
            {
                case UIDeviceOrientationPortrait:
                    orientation = UIImageOrientationUp;
                    break;
                    
                case UIDeviceOrientationPortraitUpsideDown:
                    orientation = UIImageOrientationDown;
                    break;
                    
                case UIDeviceOrientationLandscapeLeft:
                    orientation = UIImageOrientationLeft;
                    break;
                    
                case UIDeviceOrientationLandscapeRight:
                    orientation = UIImageOrientationRight;
                    break;
                    
                default:
                    orientation = UIImageOrientationRight;
                    DebugLog(@"Unknown orientation");
                    break;
            }
            
            UIImage *fixedOrientationImage = [UIImage  imageWithCGImage: capturedScreenImage.CGImage
                                                                  scale: capturedScreenImage.scale
                                                            orientation: orientation];
            usingImage = fixedOrientationImage;
        }
    }
    
    NSString *userName = nil;
    NSString *subject = @"";
    
    User *user = appDelegate.currentUser;
    
    if (user.fullNameIsPublicValue)
    {
        userName = user.fullName;
    }
    
    if (userName.length < 1)
    {
        userName = user.username;
    }
    
    if (userName != nil)
    {
        NSString *what = @"pack of videos";
        
        if (isVideo.boolValue == TRUE)
        {
            what = @"video";
        }
        
        subject = [NSString stringWithFormat: @"%@ has shared a %@ with you", userName, what];
    }
    
    
    [self.mutableShareDictionary addEntriesFromDictionary:@{@"owner": isOwner,
                                                            @"video": isVideo,
                                                            @"subject": subject}];
   
    
    // Only add image if we have one
    if (usingImage)
    {
        [self.mutableShareDictionary addEntriesFromDictionary: @{@"image": usingImage}];
    }
 
    self.oneToOneViewController = [[SYNOneToOneSharingController alloc] initWithInfo: self.mutableShareDictionary];
    
     
    
    [appDelegate.viewStackManager presentPopoverView: self.oneToOneViewController.view];
}


- (void) requestShareLinkWithObjectType: (NSString *) objectType
                               objectId: (NSString *) objectId
{
    // Get share link
    
    self.mutableShareDictionary = @{@"type" : objectType,
                                    @"object_id" : objectId,
                                    @"text" : @"",
                                    @"text_email" : @"",
                                    @"text_twitter" : @"",
                                    @"text_facebook" : @"",
                                    @"url" : [NSNull null] }.mutableCopy; // url is the critial element to check for
    
    
    [appDelegate.oAuthNetworkEngine shareLinkWithObjectType: objectType
                                                   objectId: objectId
                                          completionHandler: ^(NSDictionary *responseDictionary)
     {
         NSString *resourceURLString = [responseDictionary objectForKey: @"resource_url"
                                                            withDefault: @"http://rockpack.com"];
         
         NSString *message = [responseDictionary objectForKey: @"message"
                                                  withDefault: @""];
         
         NSString *messageEmail = [responseDictionary objectForKey: @"message_email"
                                                       withDefault: @""];
         
         NSString *messageTwitter = [responseDictionary objectForKey: @"message_twitter"
                                                         withDefault: @""];
         
         NSString *messageFacebook = [responseDictionary objectForKey: @"message_facebook"
                                                          withDefault: @""];
         
         NSURL *resourceURL = [NSURL URLWithString: resourceURLString];
         
         self.mutableShareDictionary[@"type"] = objectType;
         self.mutableShareDictionary[@"object_id"] = objectId;
         self.mutableShareDictionary[@"text"] = message;
         self.mutableShareDictionary[@"text_email"] = messageEmail;
         self.mutableShareDictionary[@"text_twitter"] = messageTwitter;
         self.mutableShareDictionary[@"text_facebook"] = messageFacebook;
         self.mutableShareDictionary[@"url"] = resourceURL;
         
         [[NSNotificationCenter defaultCenter] postNotificationName:kShareLinkForObjectObtained
                                                             object:self];
         
     } errorHandler: ^(NSDictionary *errorDictionary) {
         
         
     }];
}


#pragma mark - Purchase

- (void) initiatePurchaseAtURL: (NSURL *) purchaseURL
{
    if ([[UIApplication sharedApplication] canOpenURL: purchaseURL])
	{
		[[UIApplication sharedApplication] openURL: purchaseURL];
	}
}

- (void) headerTapped
{
    // to be implemented by subclass
}


-(void)performAction:(NSString*)action withObject:(id)object
{
    // to be implemented by subclass 
}
#pragma mark - Load more footer

// Load more footer

- (CGSize) footerSize
{
    return IS_IPHONE ? CGSizeMake(320.0f, 64.0f) : CGSizeMake(1024.0, 64.0);
}


- (void) setLoadingMoreContent: (BOOL) loadingMoreContent
{
    // First set the state of our footer spinner
    self.footerView.showsLoading = loadingMoreContent;
    
    // Now set our actual variable
    _loadingMoreContent = loadingMoreContent;
}


#pragma mark UIApplication Callback Notifications

- (void) applicationWillEnterForeground: (UIApplication *) application
{
    [self resetDataRequestRange];
    
    // and then make a class appropriate data call

}

- (NavigationButtonsAppearance) navigationAppearance
{
    // return the standard and overide in subclass for special cases such as the ChannelDetails Section
    return NavigationButtonsAppearanceBlack;
}

- (BOOL) alwaysDisplaysSearchBox
{
    return NO;
}


- (void) addVideoAtIndexPath: (NSIndexPath *) indexPath
               withOperation: (NSString *) operation
{
    VideoInstance *videoInstance = [self videoInstanceForIndexPath: indexPath];
    
    if (videoInstance)
    {
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        
        [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                               action: @"videoPlusButtonClick"
                                                                label: nil
                                                                value: nil] build]];
        
        [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentUser.uniqueId
                                                         action: @"select"
                                                videoInstanceId: videoInstance.uniqueId
                                              completionHandler: ^(id response) {
                                              }
                                                   errorHandler: ^(id error) {
                                                       DebugLog(@"Could not record videoAddButtonTapped: activity");
                                                   }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: operation
                                                            object: self
                                                          userInfo: @{@"VideoInstance": videoInstance}];
    }
}


- (IBAction) toggleStarAtIndexPath: (NSIndexPath *) indexPath
{
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"videoStarButtonClick"
                                                            label: nil
                                                            value: nil] build]];
    
    __weak VideoInstance *videoInstance = [self videoInstanceForIndexPath: indexPath];
    
    
    NSString *starAction = videoInstance.starredByUserValue ? @"unstar" : @"star" ;
    
    //    int starredIndex = self.currentSelectedIndex;
    
    [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentUser.uniqueId
                                                     action: starAction
                                            videoInstanceId: videoInstance.uniqueId
                                          completionHandler: ^(id response) {
                                              
                                              if (videoInstance.starredByUserValue)
                                              {
                                                  // Currently highlighted, so decrement
                                                  videoInstance.starredByUserValue = NO;
                                                  videoInstance.video.starCountValue -= 1;
                                                  
                                                  Channel* parentChannel = videoInstance.channel;
                                                  if(parentChannel &&
                                                     parentChannel.favouritesValue &&
                                                     [parentChannel.channelOwner.uniqueId isEqualToString:appDelegate.currentUser.uniqueId])
                                                  {
                                                      // the video belonged to favorites
                                                      
                                                      [parentChannel removeVideoInstancesObject:videoInstance];
                                                      
                                                      
                                                      
                                                  }
                                              }
                                              else
                                              {
                                                  // Currently highlighted, so increment
                                                  videoInstance.starredByUserValue = YES;
                                                  videoInstance.video.starCountValue += 1;
                                                  [Appirater userDidSignificantEvent: FALSE];
                                              }

                                              [appDelegate saveContext: YES];
  
                                          } errorHandler: ^(id error) {
                                              DebugLog(@"Could not star video");
                                          }];
}


- (void) shareVideoAtIndexPath: (NSIndexPath *) indexPath
{
    VideoInstance *videoInstance = [self videoInstanceForIndexPath: indexPath];
    
    [self shareVideoInstance: videoInstance];
}

- (void) shareChannelAtIndexPath: (NSIndexPath *) indexPath
               andComponentIndex: (NSInteger) componentIndex
{
    
    Channel *channel = [self channelInstanceForIndexPath: indexPath
                                       andComponentIndex: componentIndex];
    
    // Try and find a suitable image
    UIImage *thumbnailImage = [SDWebImageManager.sharedManager.imageCache imageFromMemoryCacheForKey: channel.channelCover.imageLargeUrl];
    
    if (!thumbnailImage)
    {
        thumbnailImage = [SDWebImageManager.sharedManager.imageCache imageFromMemoryCacheForKey: channel.channelCover.imageUrl];
    }
    
    [self shareChannel: channel
               isOwner: ([channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId]) ? @(TRUE): @(FALSE)
            usingImage: thumbnailImage
     ];
}


- (VideoInstance *) videoInstanceForIndexPath: (NSIndexPath *) indexPath
{
    AssertOrLog(@"Shouldn't be calling abstract function");
    return  nil;
}


- (NSIndexPath *) indexPathForVideoCell: (UICollectionViewCell *) cell
{
    return [self.videoThumbnailCollectionView indexPathForCell: cell];
}


- (Channel *) channelInstanceForIndexPath: (NSIndexPath *) indexPath
                        andComponentIndex: (NSInteger) componentIndex
{
    AssertOrLog(@"Shouldn't be calling abstract function");
    return  nil;
}


- (NSIndexPath *) indexPathForChannelCell: (UICollectionViewCell *) cell
{
    AssertOrLog(@"Shouldn't be calling abstract function");
    return  nil;
}


- (BOOL) needsHeaderButton
{
    return YES;
}


- (void) checkForOnBoarding
{
    // to be implemented in subclass
}


- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void) createAndDisplayNewChannel
{
    
    SYNChannelDetailViewController *channelCreationVC =
    [[SYNChannelDetailViewController alloc] initWithChannel: appDelegate.videoQueue.currentlyCreatingChannel
                                                  usingMode: kChannelDetailsModeCreate] ;
    
    
    if(IS_IPHONE)
    {
        
        CGRect newFrame = channelCreationVC.view.frame;
        newFrame.size.height = self.view.frame.size.height;
        channelCreationVC.view.frame = newFrame;
        CATransition *animation = [CATransition animation];
        
        [animation setType: kCATransitionMoveIn];
        [animation setSubtype: kCATransitionFromRight];
        
        [animation setDuration: 0.30];
        [animation setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
        
        [self.view.window.layer addAnimation: animation
                                      forKey: nil];
        
        [self presentViewController: channelCreationVC
                           animated: NO
                         completion: nil];
    }
    else
    {
        [appDelegate.viewStackManager pushController:channelCreationVC];
    }
    
}

-(EntityType)associatedEntity
{
    return EntityTypeAny;
}


#pragma mark - UIScrollView delegates


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.startDraggingPoint = scrollView.contentOffset;
    self.startDate = [NSDate date];
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    self.endDraggingPoint = scrollView.contentOffset;
    self.endDate = [NSDate dateWithTimeIntervalSinceNow:self.startDate.timeIntervalSinceNow];
    [self shouldHideTabBar];
}

- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    
        if (self.lastContentOffset > scrollView.contentOffset.y)
        {
            self.scrollDirection = ScrollingDirectionUp;
        }
        else {
            self.scrollDirection = ScrollingDirectionDown;
        }
        
        self.lastContentOffset = scrollView.contentOffset.y;
 
    
    if (scrollView.contentOffset.y<kScrollContentOff && !self.scrollerIsNearTop) {
        self.scrollerIsNearTop = YES;
        //Notification that tells the navigation manager to show the navigation bar
        [[NSNotificationCenter defaultCenter] postNotificationName:kScrollMovement object:[NSNumber numberWithInt:3]  userInfo:nil];

    }
    
    
    if (scrollView.contentOffset.y>kScrollContentOff && self.scrollerIsNearTop) {
        self.scrollerIsNearTop = NO;
    }
}

-(void) shouldHideTabBar{
    
    CGPoint difference = CGPointMake(self.startDraggingPoint.x - self.endDraggingPoint.x, self.startDraggingPoint.y - self.endDraggingPoint.y);
    
    int check =fabsf(difference.y)/fabsf(self.startDate.timeIntervalSinceNow);

    if (check > kScrollSpeedBoundary) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kScrollMovement object:[NSNumber numberWithInteger:self.scrollDirection]  userInfo:nil];
    }
    
}



@end
