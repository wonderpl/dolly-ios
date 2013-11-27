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
#import "Channel.h"
#import "ChannelCover.h"
#import "ChannelOwner.h"
#import "GAI.h"
#import "NSDictionary+Validation.h"
#import "OWActivityViewController.h"
#import "SDWebImageManager.h"
#import "SYNAbstractViewController.h"
#import "SYNChannelDetailsViewController.h"
#import "SYNDeviceManager.h"
#import "SYNMasterViewController.h"
#import "SYNOneToOneSharingController.h"
#import "SYNPopoverBackgroundView.h"
#import "SYNProfileRootViewController.h"
#import "SYNSocialButton.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"


@import AudioToolbox;
@import QuartzCore;

#define kScrollContentOff 100.0f
#define kScrollSpeedBoundary 550.0f

@interface SYNAbstractViewController ()  <UITextFieldDelegate,
                                          UIPopoverControllerDelegate>

@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) SYNOneToOneSharingController* oneToOneViewController;
@property (nonatomic, strong) UIPopoverController *activityPopoverController;
@property (strong, nonatomic) NSMutableDictionary *mutableShareDictionary;
@property (strong, nonatomic) OWActivityView *activityView;
@property (strong, nonatomic) OWActivityViewController *activityViewController;
@property (nonatomic, assign) NSInteger lastContentOffset;
@property (nonatomic, assign) CGPoint startDraggingPoint;
@property (nonatomic, assign) CGPoint endDraggingPoint;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (nonatomic, strong) SYNPopupMessageView* popupMessageView;
@property (nonatomic, assign) ScrollingDirection *scrollDirection;
@property (nonatomic, assign) BOOL scrollerIsNearTop;

@end


@implementation SYNAbstractViewController

@synthesize fetchedResultsController = fetchedResultsController;
@synthesize selectedIndex = _selectedIndex;


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
    
    
    self.automaticallyAdjustsScrollViewInsets = NO; 
    
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
    
    [self setNeedsStatusBarAppearanceUpdate];
        
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

- (void) displayVideoViewerFromCell: (UICollectionViewCell *) cell
                         andSubCell: (UICollectionViewCell *) subCell
                     atSubCellIndex: (NSInteger) subCellIndex
{
    AssertOrLog (@"Shouldn't be calling abstract function");
}

- (void) displayVideoViewerFromCell: (UICollectionViewCell *) cell
{
    AssertOrLog (@"Shouldn't be calling abstract function");
}


- (void) displayVideoViewerWithVideoInstanceArray: (NSArray *) videoInstanceArray
                                 andSelectedIndex: (int) selectedIndex
                                           center: (CGPoint) center
{
    SYNMasterViewController *masterViewController = (SYNMasterViewController *) appDelegate.masterViewController;
    
    [masterViewController addVideoOverlayToViewController: self
                                   withVideoInstanceArray: videoInstanceArray
                                         andSelectedIndex: selectedIndex
                                               fromCenter: center];
}

#pragma mark - UICollectionViewDelegate/Data Source (to be overriden)
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    AssertOrLog(@"Abstract Method Called");
    return 0;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AssertOrLog(@"Abstract Method Called");
    return nil;
}

// User pressed the channel thumbnail in a VideoCell
- (IBAction) channelButtonTapped: (UIButton *) channelButton
{
    NSIndexPath *indexPath = [self indexPathFromVideoInstanceButton: channelButton];
    
    if (indexPath)
    {
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
		[self viewChannelDetails:videoInstance.channel];
    }
}


- (IBAction) profileButtonTapped: (UIButton *) profileButton
{
    NSIndexPath *indexPath = [self indexPathFromVideoInstanceButton: profileButton];
    
    // Bail if we don't have an index path
    if (indexPath)
    {
        VideoInstance *videoInstance = [self.fetchedResultsController objectAtIndexPath: indexPath];
        
        [self viewProfileDetails: videoInstance.channel.channelOwner];
    }
}


#pragma mark - Trace

- (NSString*) description
{
    return [NSString stringWithFormat: @"SYNAbstractViewController of type '%@' and viewId '%@'", NSStringFromClass([self class]), viewId];
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

#pragma mark - Social Actions Delegate

- (void) likeControlPressed: (SYNSocialButton *) socialControl
{
    if (![socialControl.dataItemLinked isKindOfClass: [VideoInstance class]])
    {
        return; // only relates to video instances
    }
    
    // Get the videoinstance associated with the control pressed
    VideoInstance *videoInstance = socialControl.dataItemLinked;
    
    // Track
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"videoStarButtonClick"
                                                            label: @"feed"
                                                            value: nil] build]];
    BOOL didStar = (socialControl.selected == NO);
    
    socialControl.enabled = NO;
    
    // Send
    [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentUser.uniqueId
                                                     action: (didStar ? @"star" : @"unstar")
                                            videoInstanceId: videoInstance.uniqueId
                                          completionHandler: ^(id response) {
                                              BOOL previousStarringState = videoInstance.starredByUserValue;
                                              NSInteger previousStarCount = videoInstance.video.starCountValue;
                                              
                                              if (didStar)
                                              {
                                                  // Currently highlighted, so increment
                                                  videoInstance.starredByUserValue = YES;
                                                  videoInstance.video.starCountValue += 1;
                                                  
                                                  socialControl.selected = YES;
                                                  
                                                  [videoInstance addStarrersObject: appDelegate.currentUser];
                                              }
                                              else
                                              {
                                                  // Currently highlighted, so decrement
                                                  videoInstance.starredByUserValue = NO;
                                                  videoInstance.video.starCountValue -= 1;
                                                  
                                                  socialControl.selected = NO;
                                              }
                                              
                                              NSError *error;
                                              
                                              if (![videoInstance.managedObjectContext save: &error])
                                              {
                                                  videoInstance.starredByUserValue = previousStarringState;
                                                  videoInstance.video.starCountValue = previousStarCount;
                                              }
                                              else
                                              {
                                                  [socialControl setTitle: socialControl.title
                                                                 andCount: videoInstance.video.starCountValue];
                                              }
                                              
                                              socialControl.enabled = YES;
                                          } errorHandler: ^(id error) {
                                              DebugLog(@"Could not star video");
                                              // Re-enable button anyway
                                              socialControl.enabled = YES;
                                          }];
}


- (void) addControlPressed: (SYNSocialButton *) socialControl
{
    if (![socialControl.dataItemLinked
          isKindOfClass: [VideoInstance class]])
    {
        return; // only relates to video instances
    }
    
    VideoInstance *videoInstance = socialControl.dataItemLinked;
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    
    [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                           action: @"videoPlusButtonClick"
                                                            label: nil
                                                            value: nil] build]];
    
    [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentUser.uniqueId
                                                     action: @"select"
                                            videoInstanceId: videoInstance.uniqueId
                                          completionHandler: nil
                                               errorHandler: nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueAdd
                                                        object: self
                                                      userInfo: @{@"VideoInstance": videoInstance}];
}



- (void) shareControlPressed: (SYNSocialButton *) socialControl
{
    
    
    if ([socialControl.dataItemLinked isKindOfClass: [VideoInstance class]])
    {
        // Get the videoinstance associated with the control pressed
        VideoInstance *videoInstance = socialControl.dataItemLinked;
        
        [self requestShareLinkWithObjectType: @"video_instance"
                                    objectId: videoInstance.uniqueId];
        
        [self shareVideoInstance: videoInstance];
    }
    else if ([socialControl.dataItemLinked isKindOfClass: [Channel class]])
    {
        // Get the videoinstance associated with the control pressed
        Channel *channel = socialControl.dataItemLinked;
        
        [self requestShareLinkWithObjectType: @"channel"
                                    objectId: channel.uniqueId];
        
        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
        
        [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"uiAction"
                                                               action: @"channelShareButtonClick"
                                                                label: nil
                                                                value: nil] build]];
        
        [self shareObjectType:  @"channel"
                     objectId: channel.uniqueId
                      isOwner: ([channel.channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId]) ? @(TRUE): @(FALSE)
                      isVideo: @NO
                   usingImage: nil];
        
        
    }
}


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
    
     
    
    [appDelegate.masterViewController addOverlayController:self.oneToOneViewController animated:YES];
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





#pragma mark - Purchase

- (void) performAction: (NSString *) action withObject: (id) object
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


- (VideoInstance *) videoInstanceForIndexPath: (NSIndexPath *) indexPath
{
    AssertOrLog(@"Shouldn't be calling abstract function");
    return  nil;
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

- (void) followControlPressed: (SYNSocialButton *) socialControl
{
    if ([socialControl.dataItemLinked isKindOfClass: [Channel class]])
    {
        // Get the channel associated with the control pressed
        Channel *channel = socialControl.dataItemLinked;
        if(!channel)
            return;
        
        
        // Temporarily disable the button to prevent multiple-clicks
        socialControl.enabled = NO;
        
        // toggle subscription from/to channel //
        if (channel.subscribedByUserValue == NO)
        {
            // Subscribe
            [appDelegate.oAuthNetworkEngine channelSubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
                                                           channelURL: channel.resourceURL
                                                    completionHandler: ^(NSDictionary *responseDictionary) {
                                                        
                                                        id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
                                                        
                                                        [tracker send: [[GAIDictionaryBuilder createEventWithCategory: @"goal"
                                                                                                               action: @"userSubscription"
                                                                                                                label: nil
                                                                                                                value: nil] build]];
                                                        channel.hasChangedSubscribeValue = YES;
                                                        channel.subscribedByUserValue = YES;
                                                        channel.subscribersCountValue += 1;
                                                        
                                                        socialControl.selected = YES;
                                                        socialControl.enabled = YES;
                                                    } errorHandler: ^(NSDictionary *errorDictionary) {
                                                        socialControl.enabled = YES;
                                                    }];
        }
        else
        {
            // Unsubscribe
            [appDelegate.oAuthNetworkEngine channelUnsubscribeForUserId: appDelegate.currentOAuth2Credentials.userId
                                                              channelId: channel.uniqueId
                                                      completionHandler: ^(NSDictionary *responseDictionary) {
                                                          channel.hasChangedSubscribeValue = YES;
                                                          channel.subscribedByUserValue = NO;
                                                          channel.subscribersCountValue -= 1;
                                                          socialControl.selected = NO;
                                                          socialControl.enabled = YES;
                                                      } errorHandler: ^(NSDictionary *errorDictionary) {
                                                          socialControl.enabled = YES;
                                                      }];
        }
    }
    else if ([socialControl.dataItemLinked isKindOfClass: [ChannelOwner class]])
    {
        // Get the owner associated with the control pressed
        ChannelOwner *channelOwner = (ChannelOwner*)socialControl.dataItemLinked;
        
        if(!channelOwner)
            return;
        
        // TODO: Follow all his channels
    }
}




- (void) checkForOnBoarding
{
    // to be implemented in subclass
}


- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - UIScrollView delegates


- (void) scrollViewWillBeginDragging: (UIScrollView *) scrollView
{
    if (scrollView.contentOffset.y<0) {
        return;
    }

    self.startDraggingPoint = scrollView.contentOffset;
    self.startDate = [NSDate date];
}


- (void) scrollViewDidEndDragging: (UIScrollView *) scrollView willDecelerate: (BOOL) decelerate
{
    if (scrollView.contentOffset.y<0) {
        return;
    }

    self.endDraggingPoint = scrollView.contentOffset;
    self.endDate = [NSDate dateWithTimeIntervalSinceNow: self.startDate.timeIntervalSinceNow];
    [self shouldHideTabBar];
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    
    if (scrollView.contentOffset.y<0) {
        return;
    }
    
    if (self.lastContentOffset > scrollView.contentOffset.y)
    {
        self.scrollDirection = ScrollingDirectionUp;
    }
    else
    {
        self.scrollDirection = ScrollingDirectionDown;
    }
    
    self.lastContentOffset = scrollView.contentOffset.y;
    
    if (scrollView.contentOffset.y < kScrollContentOff && !self.scrollerIsNearTop)
    {
        self.scrollerIsNearTop = YES;
        //Notification that tells the navigation manager to show the navigation bar
        [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                            object: [NSNumber numberWithInt: 3]
                                                          userInfo: nil];
    }
    
    if (scrollView.contentOffset.y > kScrollContentOff && self.scrollerIsNearTop)
    {
        self.scrollerIsNearTop = NO;
    }
}


- (void) shouldHideTabBar
{
    CGPoint difference = CGPointMake(self.startDraggingPoint.x - self.endDraggingPoint.x, self.startDraggingPoint.y - self.endDraggingPoint.y);
    
    int check = fabsf(difference.y) / fabsf(self.startDate.timeIntervalSinceNow);
    
    if (check > kScrollSpeedBoundary)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                            object: [NSNumber numberWithInteger: self.scrollDirection]
                                                          userInfo: nil];
    }
}


- (SYNPopupMessageView*) displayPopupMessage: (NSString*) messageKey
                                  withLoader: (BOOL) isLoader
{
    if (self.popupMessageView)
    {
        [self.popupMessageView removeFromSuperview];
        self.popupMessageView = nil;
    }
    
    self.popupMessageView = [SYNPopupMessageView withMessage:NSLocalizedString(messageKey ,nil) andLoader:isLoader];
    
    CGRect messageFrame = self.popupMessageView.frame;
    messageFrame.origin.x = (self.view.frame.size.width * 0.5) - (messageFrame.size.width * 0.5);
    messageFrame.origin.y = (self.view.frame.size.height * 0.5) - (messageFrame.size.height * 0.5) - 20.0f;
    
    messageFrame = CGRectIntegral(messageFrame);
    self.popupMessageView.frame = messageFrame;
    self.popupMessageView.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    [self.view addSubview: self.popupMessageView];
    
    return self.popupMessageView;
}

- (void) removePopupMessage
{
    if (!self.popupMessageView)
        return;
    
    [self.popupMessageView removeFromSuperview];
    
    /* OPTIONAL
     __weak SYNFeedRootViewController* wself = self;
     [UIView animateWithDuration:0.5f
     animations:^{
     wself.emptyGenreMessageView.transform = CGAffineTransformScale( wself.emptyGenreMessageView.transform, 0.8f, 0.8f);
     wself.emptyGenreMessageView.alpha = 0.0f;
     } completion:^(BOOL finished) {
     [wself.emptyGenreMessageView removeFromSuperview];
     }];
     */
}


- (void)viewProfileDetails:(ChannelOwner *)channelOwner {
    
	if (!channelOwner)
		return;

	SYNProfileRootViewController *profileVC = (SYNProfileRootViewController *)[self viewControllerOfClass:[SYNProfileRootViewController class]];
    
	if (profileVC)
    {
		[self.navigationController popToViewController:profileVC animated:YES];
	}
    else
    {
		profileVC = [[SYNProfileRootViewController alloc] initWithViewId:kProfileViewId  andChannelOwner:channelOwner];
		[self.navigationController pushViewController:profileVC animated:YES];
	}
}

- (void)viewChannelDetails:(Channel *)channel
{
    
	if (!channel)
		return;
	

	SYNChannelDetailsViewController *channelVC =
	(SYNChannelDetailsViewController *) [self viewControllerOfClass:[SYNChannelDetailsViewController class]];

    BOOL isChannelCreation = (BOOL)(channel == appDelegate.videoQueue.currentlyCreatingChannel);
    kChannelDetailsMode correctMode = isChannelCreation ? kChannelDetailsModeDisplay : kChannelDetailsModeDisplay;
    
	if (channelVC) // we found a channelVC
    {
		channelVC.channel = channel;
        channelVC.mode = correctMode;
        
		[self.navigationController popToViewController:channelVC animated:YES];
	}
    else
    {
		channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel
                                                                   usingMode:correctMode];
		
		[self.navigationController pushViewController:channelVC animated:YES];
	}
}

- (UIViewController *)viewControllerOfClass:(Class)class {
	static const NSInteger StackLimit = 6;
	if (self.navigationController.viewControllers.count > StackLimit) {
		for (UIViewController *viewController in self.navigationController.viewControllers) {
			if ([viewController isMemberOfClass:class]) {
				return viewController;
			}
		}
	}
	return nil;
}

@end
