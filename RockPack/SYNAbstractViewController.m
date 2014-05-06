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
#import "ChannelOwner.h"
#import "NSDictionary+Validation.h"
#import "SDWebImageManager.h"
#import "SYNAbstractViewController.h"
#import "SYNChannelDetailsViewController.h"
#import "SYNDeviceManager.h"
#import "SYNMasterViewController.h"
#import "SYNOneToOneSharingController.h"
#import "SYNProfileRootViewController.h"
#import "SYNSocialButton.h"
#import "SYNCommentingViewController.h"
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNTrackingManager.h"
#import "SYNActivityManager.h"
#import "SYNRotatingPopoverController.h"
#import "SYNPopoverAnimator.h"
#import "SYNSocialCommentButton.h"
#import "SYNProfileChannelViewController.h"

@import QuartzCore;

#define kScrollContentOff 40.0f
#define kScrollSpeedBoundary 0.0f

@interface SYNAbstractViewController () <UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) NSMutableDictionary *mutableShareDictionary;
@property (nonatomic, assign) NSInteger lastContentOffset;
@property (nonatomic, assign) CGPoint startDraggingPoint;
@property (nonatomic, assign) CGPoint endDraggingPoint;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (nonatomic, strong) SYNPopupMessageView* popupMessageView;
@property (nonatomic, assign) ScrollingDirection scrollDirection;
@property (nonatomic, assign) BOOL scrollerIsNearTop;
@property (nonatomic, strong) SYNRotatingPopoverController *commentingPopoverController;

@end


@implementation SYNAbstractViewController

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
    
    
    //IPad has no navigation titles
    if (IS_IPAD) {
        self.navigationItem.title = @"";
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (IS_IPHONE) {
        [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                            object: self
                                                          userInfo: @{kScrollingDirection:@(ScrollingDirectionUp)}];
    }
    
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

-(void)clearedLocationBoundData
{
    // to be implemented by child
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

- (void) likeControlPressed:(SYNSocialButton *)socialControl {
	if (![socialControl.dataItemLinked isKindOfClass: [VideoInstance class]]) {
		return; // only relates to video instances
	}
	
	// Get the videoinstance associated with the control pressed
	VideoInstance *videoInstance = socialControl.dataItemLinked;
	
	[self favouriteButtonPressed:socialControl videoInstance:videoInstance];
}

- (void)favouriteButtonPressed:(UIButton *)button videoInstance:(VideoInstance *)videoInstance {
	[[SYNTrackingManager sharedManager] trackVideoLikeFromScreenName:[self trackingScreenName]];
	
    BOOL didStar = (button.selected == NO);
    
    button.enabled = NO;
	
	ChannelOwner *currentUser = appDelegate.currentUser;
    
    [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentUser.uniqueId
                                                     action: (didStar ? @"star" : @"unstar")
                                            videoInstanceId: videoInstance.uniqueId
                                          completionHandler: ^(id response) {
                                              BOOL previousStarringState = videoInstance.starredByUserValue;
                                              
                                              if (didStar) {
                                                  // Currently highlighted, so increment
                                                  videoInstance.starredByUserValue = YES;
                                                  
                                                  button.selected = YES;
                                                  
                                                  [videoInstance addStarrersObject:currentUser];
                                              } else {
                                                  // Currently highlighted, so decrement
                                                  videoInstance.starredByUserValue = NO;
                                                  
                                                  button.selected = NO;
                                              }
                                              
                                              if (![videoInstance.managedObjectContext save:nil]) {
                                                  videoInstance.starredByUserValue = previousStarringState;
                                              }
                                              
                                              button.enabled = YES;
                                          } errorHandler: ^(id error) {
                                              DebugLog(@"Could not star video");
											  
                                              button.enabled = YES;
                                          }];
}

- (void) addControlPressed: (SYNSocialButton *) socialControl
{
    if (![socialControl.dataItemLinked isKindOfClass: [VideoInstance class]])
    {
        return; // only relates to video instances
    }
    
    VideoInstance *videoInstance = socialControl.dataItemLinked;
	
	[[SYNTrackingManager sharedManager] trackVideoAddFromScreenName:[self trackingScreenName]];
	
    [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentUser.uniqueId
                                                     action: @"select"
                                            videoInstanceId: videoInstance.uniqueId
                                          completionHandler: nil
                                               errorHandler: nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: kVideoQueueAdd
                                                        object: self
                                                      userInfo: @{@"VideoInstance": videoInstance}];
}


- (void) commentControlPressed:(SYNSocialButton *)socialButton {

}

- (void) shareControlPressed: (SYNSocialButton *) socialControl
{
    
    if ([socialControl.dataItemLinked isKindOfClass: [VideoInstance class]])
    {
        // Get the videoinstance associated with the control pressed
        VideoInstance *videoInstance = socialControl.dataItemLinked;
        
        [self shareVideoInstance: videoInstance];
    }
    else if ([socialControl.dataItemLinked isKindOfClass: [Channel class]])
    {
        Channel *channel = socialControl.dataItemLinked;
		[self shareChannel:channel];
	}
}

- (void)shareChannel:(Channel *)channel {
	VideoInstance *firstVideoInstance = [channel.videoInstances firstObject];
	
	UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:firstVideoInstance.thumbnailURL];
	
	BOOL isOwner = [channel.channelOwner.uniqueId isEqualToString:appDelegate.currentUser.uniqueId];
	[self shareChannel:channel isOwner:@(isOwner) usingImage:image];
}

- (void) shareVideoInstance: (VideoInstance *) videoInstance
{
	[self requestShareLinkWithObjectType: @"video_instance"
								objectId: videoInstance.uniqueId];
	
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
              usingImage: (UIImage *) usingImage {
	SYNOneToOneSharingController *viewController = [self createSharingViewControllerForObjectType:objectType
																						 objectId:objectId
																						  isOwner:[isOwner boolValue]
																						  isVideo:[isVideo boolValue]
																							image:usingImage];
	viewController.modalPresentationStyle = UIModalPresentationCustom;
	viewController.transitioningDelegate = self;
	
	[self presentViewController:viewController animated:YES completion:nil];
}

- (SYNOneToOneSharingController *)createSharingViewControllerForObjectType:(NSString *)objectType
																   objectId:(NSString *)objectId
																	isOwner:(BOOL)isOwner
																	isVideo:(BOOL)isVideo
																	  image:(UIImage *)image {
	NSString *userName = nil;
	NSString *subject = @"";
	
	User *user = appDelegate.currentUser;
	
	if (user.fullNameIsPublicValue) {
		userName = user.fullName;
	}
	
	if (![userName length]) {
		userName = user.username;
	}
	
	if (userName != nil) {
		NSString *what = @"collection";
		if (isVideo) {
			what = @"video";
		}
		subject = [NSString stringWithFormat: @"%@ has shared a %@ with you", userName, what];
	}
	
	[self.mutableShareDictionary addEntriesFromDictionary:@{@"owner": @(isOwner),
															@"video": @(isVideo),
															@"subject": subject}];
	
	
	// Only add image if we have one
	if (image) {
		[self.mutableShareDictionary addEntriesFromDictionary: @{@"image": image}];
	}
	
	return [[SYNOneToOneSharingController alloc] initWithInfo: self.mutableShareDictionary];
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

- (void)shareChannel:(Channel *)channel isOwner:(NSNumber *)isOwner usingImage:(UIImage *)image {
	[self requestShareLinkWithObjectType:@"channel" objectId:channel.uniqueId];
	
	[self shareObjectType:@"channel"
				 objectId:channel.uniqueId
				  isOwner:isOwner
				  isVideo:@NO
			   usingImage:image];
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



- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - UIScrollView delegates


- (void) scrollViewWillBeginDragging: (UIScrollView *) scrollView
{

    self.startDraggingPoint = scrollView.contentOffset;
    self.startDate = [NSDate date];
}


- (void) scrollViewDidEndDragging: (UIScrollView *) scrollView willDecelerate: (BOOL) decelerate
{

    self.endDraggingPoint = scrollView.contentOffset;
    self.endDate = [NSDate dateWithTimeIntervalSinceNow: self.startDate.timeIntervalSinceNow];
    [self shouldHideTabBar];
}


- (void) scrollViewDidScroll: (UIScrollView *) scrollView
{
    
    int offset = scrollView.contentOffset.y + self.offsetValue;
    
    if (self.lastContentOffset > offset)
    {
        self.scrollDirection = ScrollingDirectionUp;
    }
    else
    {
        self.scrollDirection = ScrollingDirectionDown;
    }
    
    self.lastContentOffset = offset;
    
    if (scrollView.contentOffset.y < kScrollContentOff && !self.scrollerIsNearTop)
    {
        self.scrollerIsNearTop = YES;
        //Notification that tells the navigation manager to show the navigation bar
        [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                            object: self
                                                          userInfo: @{kScrollingDirection:@(ScrollingDirectionUp)}];
    }
    
    if (scrollView.contentOffset.y > kScrollContentOff && self.scrollerIsNearTop)
    {
        self.scrollerIsNearTop = NO;
    }
}

- (NSString *)trackingScreenName {
	return nil;
}

- (void) shouldHideTabBar
{
    CGPoint difference = CGPointMake(self.startDraggingPoint.x - self.endDraggingPoint.x, self.startDraggingPoint.y - self.endDraggingPoint.y);
    
    int check = fabsf(difference.y) / fabsf(self.startDate.timeIntervalSinceNow);
    
    if (check > kScrollSpeedBoundary)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                            object: self
                                                          userInfo: @{kScrollingDirection:@(self.scrollDirection)}];
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
    
    UIViewController *profileVC = [SYNProfileViewController viewControllerWithChannelOwner:channelOwner];
    
    [self.navigationController pushViewController:profileVC animated:YES];

}

- (void)viewChannelDetails:(Channel *)channel withAnimation:(BOOL)animated {
    if (!channel)
		return;
	
    
	SYNChannelDetailsViewController *channelVC =
	(SYNChannelDetailsViewController *) [self viewControllerOfClass:[SYNChannelDetailsViewController class]];
	
	if (channelVC) // we found a channelVC
    {
		channelVC.channel = channel;
        channelVC.mode = kChannelDetailsModeDisplay;
        
		[self.navigationController popToViewController:channelVC animated:animated];
	}
    else
    {
		channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel
                                                                   usingMode:kChannelDetailsModeDisplay];
		[self.navigationController pushViewController:channelVC animated:animated];
	}
}

- (void) viewVideoInstanceInChannel:(Channel*) channel withVideoId:videoId
{
//    [self viewChannelDetails:channel withAnimation:NO];
    SYNChannelDetailsViewController *channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel
                                                               usingMode:kChannelDetailsModeDisplay];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.navigationController pushViewController:channelVC animated:NO];
        
    } completion:^(BOOL finished) {
        channelVC.autoplayId = videoId;
    }];
    


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


- (void)followControlPressed:(UIButton *)button withChannelOwner:(ChannelOwner *)channelOwner completion :(void (^)(void))callbackBlock {
	
	if(!channelOwner)
		return;
	
	BOOL isCurrentUser = (BOOL)[channelOwner.uniqueId isEqualToString: appDelegate.currentUser.uniqueId];
	
	if (isCurrentUser) {
		return;
	}
	
	[[SYNTrackingManager sharedManager] trackUserCollectionsFollowFromScreenName:[self trackingScreenName]];
	
	if(channelOwner.subscribedByUserValue == NO)
	{
		button.enabled = NO;
		
		[[SYNActivityManager sharedInstance] subscribeToUser:channelOwner
										   completionHandler: ^(id responce) {
											   
											   button.selected = YES;
											   button.enabled = YES;
											   
											   [[NSNotificationCenter defaultCenter] postNotificationName:kReloadFeed object:self userInfo:nil];
											   callbackBlock();

											   
											   
											   
										   } errorHandler: ^(id error) {
											   button.enabled = YES;
										   }];
	}
	else
	{
		
		button.enabled = NO;
		
		[[SYNActivityManager sharedInstance] unsubscribeToUser:channelOwner
											 completionHandler:^(id responce) {
												 
												 button.selected = NO;
												 button.enabled = YES;
												 [[NSNotificationCenter defaultCenter] postNotificationName:kReloadFeed object:self userInfo:nil];
												 
												 callbackBlock();

												 
											 } errorHandler:^(id error) {
												 button.enabled = YES;
											 }];
	}
}


- (void)followButtonPressed:(UIButton *)button withChannel:(Channel *)channel {
	button.enabled = NO;
	
	[[SYNTrackingManager sharedManager] trackCollectionFollowFromScreenName:[self trackingScreenName]];
	
	channel.subscribedByUserValue = [[SYNActivityManager sharedInstance]isSubscribedToChannelId:channel.uniqueId];
    
	if (channel.subscribedByUserValue) {
        [[SYNActivityManager sharedInstance] unsubscribeToChannel: channel
												  completionHandler:^(NSDictionary *responseDictionary) {
													  
													  button.selected = NO;
													  button.enabled = YES;
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:kReloadFeed object:self userInfo:nil];

												  } errorHandler: ^(NSDictionary *errorDictionary) {
													  button.enabled = YES;
												  }];
	} else {
        [[SYNActivityManager sharedInstance] subscribeToChannel: channel
											  completionHandler: ^(NSDictionary *responseDictionary) {
												  [[SYNTrackingManager sharedManager] trackCollectionFollowCompleted];
												  
													button.selected = YES;
													button.enabled = YES;
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadFeed object:self userInfo:nil];

												} errorHandler: ^(NSDictionary *errorDictionary) {
													button.enabled = YES;
												}];
	}
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
																  presentingController:(UIViewController *)presenting
																	  sourceController:(UIViewController *)source {
	return [SYNPopoverAnimator animatorForPresentation:YES];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	return [SYNPopoverAnimator animatorForPresentation:NO];
}

@end
