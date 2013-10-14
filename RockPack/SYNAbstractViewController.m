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

@interface SYNAbstractViewController ()  <UITextFieldDelegate,
                                          UIPopoverControllerDelegate>

@property (getter = isVideoQueueVisible) BOOL videoQueueVisible;
@property (nonatomic, assign) BOOL shouldPlaySound;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) IBOutlet UIImageView *channelOverlayView;
@property (nonatomic, strong) IBOutlet UITextField *channelNameTextField;
@property (nonatomic, strong) SYNOneToOneSharingController* oneToOneViewController;
@property (nonatomic, strong) UIPopoverController *activityPopoverController;
@property (nonatomic, strong) UIView *dropZoneView;
@property (strong, nonatomic) NSMutableDictionary *mutableShareDictionary;
@property (strong, nonatomic) OWActivityView *activityView;
@property (strong, nonatomic) OWActivityViewController *activityViewController;
@property (strong, readonly, nonatomic) NSArray *activities;
@property (weak, nonatomic) UIPopoverController *presentingPopoverController;
@property (weak, nonatomic) UIViewController *presentingController;

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
    if ((self = [super init]))
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    // Compensate for iOS7
    

}

- (void) resetDataRequestRange
{
    self.dataRequestRange = NSMakeRange(0, STANDARD_REQUEST_LENGTH);
}

- (void) viewDidScrollToFront
{
//    DebugLog (@"%@ came to front", self.title);
}


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
                                         andSelectedIndex: selectedIndex fromCenter:center];
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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(IS_IOS_7_OR_GREATER)
        [self setNeedsStatusBarAppearanceUpdate];
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
    return [NSString stringWithFormat: @"SYNAbstractViewController '%@'", viewId];
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

- (void) viewDidScrollToBack
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

#pragma mark - Arc menu support


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

- (VideoInstance *) videoInstanceForIndexPath: (NSIndexPath *) indexPath
                            andComponentIndex: (NSInteger) componentIndex
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

#pragma mark - Arc Menu

-(void)arcMenuShowFake:(UILongPressGestureRecognizer*)longPressRecogniser
{
    self.arcMenuIsFakeCell = YES;
    [self arcMenuUpdateState:longPressRecogniser];
}

- (void) arcMenuSelectedCell: (UICollectionViewCell *) selectedCell
           andComponentIndex: (NSInteger) componentIndex
{
    if ([self isChannelCell: selectedCell])
    {
        // Channel
        self.arcMenuIsChannelCell = TRUE;
        self.arcMenuIndexPath = [self indexPathForChannelCell: selectedCell];
    }
    else
    {
        // Video
        self.arcMenuIsChannelCell = FALSE;
        self.arcMenuIndexPath = [self indexPathForVideoCell: selectedCell];
    }

    self.arcMenuComponentIndex = componentIndex;
}


- (void) arcMenuUpdateState: (UIGestureRecognizer *) recognizer
{
    NSArray *menuItems;
    float menuArc, menuStartAngle;
    NSString *analyticsLabel;
    
    if (self.arcMenuIsChannelCell)
    {
        // Channel cell
        analyticsLabel = @"channel";
        
        SYNArcMenuItem *arcMenuItem1 = [[SYNArcMenuItem alloc] initWithImage: [UIImage imageNamed: @"ActionShare"]
                                                            highlightedImage: [UIImage imageNamed: @"ActionShareHighlighted"]
                                                                        name: kActionShareChannel
                                                                   labelText: @"Share it"];
        menuItems = @[arcMenuItem1];

        menuArc = M_PI / 4;
        menuStartAngle = 0;
    }
    else
    {
        // Video cell
        analyticsLabel = @"video";

        VideoInstance *videoInstance = [self videoInstanceForIndexPath: self.arcMenuIndexPath];
        
        // Get resource URL in parallel
        if (recognizer.state == UIGestureRecognizerStateBegan)
        {
            [self requestShareLinkWithObjectType: @"video_instance"
                                        objectId: videoInstance.uniqueId];
        }
        
        // A bit of a hack, but we need to work out whether the user has starred this videoInstance (we can't completely trust starredByUserValue)
        BOOL starredByUser = videoInstance.starredByUserValue;
        
        if (!starredByUser)
        {
            // Double check, by iterating through the list of starrers to see if we are there
            NSArray *starrers = [videoInstance.starrers array];
            
            for (ChannelOwner *channelOwner in starrers)
            {
                if ([channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId])
                {
                    starredByUser = TRUE;
                    videoInstance.starredByUserValue = starredByUser;
                    break;
                }
            }
        }
        
        SYNArcMenuItem *arcMenuItem1 = [[SYNArcMenuItem alloc] initWithImage: [UIImage imageNamed: (starredByUser == FALSE) ? @"ActionLike" : @"ActionUnlike"]
                                                            highlightedImage: [UIImage imageNamed: (starredByUser == FALSE) ? @"ActionLikeHighlighted" : @"ActionUnlikeHighlighted"]
                                                                        name: kActionLike
                                                                   labelText: (starredByUser == FALSE) ? @"Like it" : @"Unlike it"];
        
        SYNArcMenuItem *arcMenuItem2 = [[SYNArcMenuItem alloc] initWithImage: [UIImage imageNamed: @"ActionAdd"]
                                                            highlightedImage: [UIImage imageNamed: @"ActionAddHighlighted"]
                                                                        name: kActionAdd
                                                                   labelText: @"Pack it"];
        
        SYNArcMenuItem *arcMenuItem3 = [[SYNArcMenuItem alloc] initWithImage: [UIImage imageNamed: @"ActionShare"]
                                                            highlightedImage: [UIImage imageNamed: @"ActionShareHighlighted"]
                                                                        name: kActionShareVideo
                                                                   labelText: @"Share it"];
        
        menuItems = @[arcMenuItem1, arcMenuItem2, arcMenuItem3];
        
        menuArc = M_PI / 2;
        menuStartAngle = -M_PI / 4;
    }
    
    [self arcMenuUpdateState: recognizer
          forCellAtIndexPath: self.arcMenuIndexPath
          withComponentIndex: self.arcMenuComponentIndex
                   menuItems: menuItems
                     menuArc: menuArc
              menuStartAngle: menuStartAngle];
    
    // track
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;

    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"pressHold"
                                                            label: analyticsLabel
                                                            value: nil] build]];
}


- (void) arcMenuUpdateState: (UIGestureRecognizer *) recognizer
         forCellAtIndexPath: (NSIndexPath *) cellIndexPath
         withComponentIndex: (NSInteger) componentIndex
                  menuItems: (NSArray *) menuItems
                    menuArc: (float) menuArc
             menuStartAngle: (float) menuStartAngle
{
    UIView *referenceView = appDelegate.masterViewController.view;
    
    CGPoint tapPoint = [recognizer locationInView: referenceView];
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        SYNArcMenuItem *mainMenuItem = [[SYNArcMenuItem alloc] initWithImage: [UIImage imageNamed: @"ActionRingNoTouch"]
                                                            highlightedImage: [UIImage imageNamed: @"ActionRingTouch"]
                                                                        name: kActionNone
                                                                   labelText: nil];
        
        self.arcMenu = [[SYNArcMenuView alloc] initWithFrame: referenceView.bounds
                                                   startItem: mainMenuItem
                                                 optionMenus: menuItems
                                               cellIndexPath: cellIndexPath
                                              componentIndex: componentIndex];
        self.arcMenu.delegate = self;
        self.arcMenu.startPoint = tapPoint;
        self.arcMenu.menuWholeAngle = menuArc;
        self.arcMenu.rotateAngle = menuStartAngle;
        
        CGFloat screenWidth = referenceView.bounds.size.width;
        
        if (tapPoint.x < kRotateThresholdX)
        {
            float proportion = 1 - MAX(tapPoint.x - kRotateBorderX, 0) / kRotateThresholdX;
            
            // The touch is near the left hand size, so rotate the menu angle clockwise proportionally
            if (tapPoint.y > kRotateThresholdY)
            {
                self.arcMenu.rotateAngle += menuArc * proportion;
            }
            else
            {
                self.arcMenu.rotateAngle += M_PI - menuArc * proportion;
            }
        }
        else if (tapPoint.x > (screenWidth - kRotateThresholdX))
        {
            float proportion = 1 - MAX((screenWidth - tapPoint.x - kRotateBorderX), 0) / kRotateThresholdX;
            
            // The touch is near the left hand size, so rotate the menu angle anti-clockwise proportionally
            if (tapPoint.y > kRotateThresholdY)
            {
                self.arcMenu.rotateAngle -= menuArc * proportion;
            }
            else
            {
                self.arcMenu.rotateAngle -= M_PI - menuArc * proportion;
            }
        }
        else if (tapPoint.y < kRotateThresholdY)
        {
            self.arcMenu.rotateAngle += M_PI;
        }
        
        [appDelegate.masterViewController.view addSubview: self.arcMenu];
        
        [self.arcMenu show: YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self.arcMenu show: NO];
        self.arcMenu = nil;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self.arcMenu positionUpdate: tapPoint];
    }
}


- (BOOL) isChannelCell: (UICollectionViewCell *) cell
{
    return ([NSStringFromClass(cell.class) rangeOfString: @"Channel"].location == NSNotFound ? FALSE : TRUE);
}


- (void) arcMenu: (SYNArcMenuView *) menu
         didSelectMenuName: (NSString *) menuName
         forCellAtIndex: (NSIndexPath *) cellIndexPath
         andComponentIndex: (NSInteger) componentIndex
{
    if ([menuName isEqualToString: kActionLike])
    {
        [self toggleStarAtIndexPath: cellIndexPath];
    }
    else if ([menuName isEqualToString: kActionAdd])
    {
        [self addVideoAtIndexPath: cellIndexPath
                    withOperation: kVideoQueueAdd];
    }
    else if ([menuName isEqualToString: kActionShareVideo])
    {
        [self shareVideoAtIndexPath: cellIndexPath];
    }
    else if ([menuName isEqualToString: kActionShareChannel])
    {
        [self shareChannelAtIndexPath: cellIndexPath
                    andComponentIndex: kArcMenuInvalidComponentIndex];
    }
    else
    {
        AssertOrLog(@"Invalid Arc Menu index selected");
    }
}


- (UIView *) arcMenuViewToShade
{
    return appDelegate.masterViewController.view;
}

- (BOOL) needsHeaderButton
{
    return YES;
}

-(void)checkForOnBoarding
{
    // to be implemented in subclass
}

-(UIStatusBarStyle)preferredStatusBarStyle
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

@end
