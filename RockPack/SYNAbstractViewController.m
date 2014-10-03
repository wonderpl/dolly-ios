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
#import "UIFont+SYNFont.h"
#import "Video.h"
#import "VideoInstance.h"
#import "SYNTrackingManager.h"
#import "SYNActivityManager.h"
#import "SYNPopoverAnimator.h"
#import "SYNProfileChannelViewController.h"
#import <TestFlight.h>
#import "SYNAddToChannelViewController.h"

@import QuartzCore;

#define kScrollContentOff 40.0f
#define kScrollSpeedBoundary 0.0f

@interface SYNAbstractViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) NSMutableDictionary *mutableShareDictionary;

@property (nonatomic, assign) NSInteger lastContentOffset;
@property (nonatomic, assign) CGPoint startDraggingPoint;
@property (nonatomic, assign) CGPoint endDraggingPoint;
@property (nonatomic, assign) BOOL scrollerIsNearTop;
@property (nonatomic, assign) ScrollingDirection scrollDirection;
@property (nonatomic, strong) UITapGestureRecognizer *scrollToTopGestureRecognizer;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@property (nonatomic, strong) SYNPopupMessageView* popupMessageView;

@end


@implementation SYNAbstractViewController

@synthesize viewId;

#pragma mark - Object lifecycle

- (id)init {
    return [self initWithViewId: @"Unknown"];
}

- (id) initWithViewId: (NSString*) vid {
    // Check to see if there is a XIB file in the system and initialise accordingly
    
    NSString* classNameString = NSStringFromClass([self class]);
    
    if([[NSBundle mainBundle] pathForResource:classNameString ofType:@"nib"] != nil) {
        self = [super initWithNibName:classNameString bundle:nil];
    } else {
        self = [super init];
    }
    
    if (self) {
        viewId = vid;
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(applicationWillEnterForeground:)
                                                     name: UIApplicationWillEnterForegroundNotification
                                                   object: nil];
    }
    
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    if (IS_IPHONE) {
        [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                            object: self
                                                          userInfo: @{kScrollingDirection:@(ScrollingDirectionUp)}];
    }
	TFLog(@"class : %@", [self class]);
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	// This is a bit dodgy but we're just going to use this method to indicate whether scrolling to the top of the
	// collection view via the navigation bar is supported
	if (([self respondsToSelector:@selector(scrollToTopIPad:)] && IS_IPAD )|| ([self respondsToSelector:@selector(scrollToTopIPhone:)] && IS_IPHONE)) {
        
        [self.scrollToTopGestureRecognizer setCancelsTouchesInView:NO];
        [self.navigationController.navigationBar setUserInteractionEnabled:YES];
		[self.navigationController.navigationBar addGestureRecognizer:self.scrollToTopGestureRecognizer];

    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	if (([self respondsToSelector:@selector(scrollToTopIPad:)] && IS_IPAD )|| ([self respondsToSelector:@selector(scrollToTopIPhone:)] && IS_IPHONE)) {
		[self.navigationController.navigationBar removeGestureRecognizer:self.scrollToTopGestureRecognizer];
	}
}

// TODO: UPDate SYNSearchResultsViewController to use SYNPaging model and remove this from the abstract class.

#pragma mark - Data Request Range

- (void)resetDataRequestRange {
    self.dataRequestRange = NSMakeRange(0, STANDARD_REQUEST_LENGTH);
}

- (BOOL)moreItemsToLoad {
    return (self.dataRequestRange.location + self.dataRequestRange.length < self.dataItemsAvailable);
}

- (void)incrementRangeForNextRequest {
    if(!self.moreItemsToLoad)
        return;
    
    NSInteger nextStart = self.dataRequestRange.location + self.dataRequestRange.length; // one is subtracted when the call happens for 0 indexing
    
    NSInteger nextSize = MIN(STANDARD_REQUEST_LENGTH, self.dataItemsAvailable - nextStart);
    
    self.dataRequestRange = NSMakeRange(nextStart, nextSize);
}

- (void)clearedLocationBoundData {
    // to be implemented by child
}


- (void)setTitle:(NSString *)title {
    abstractTitle = title;
}

- (NSString*)title {
    if(abstractTitle && ![abstractTitle isEqualToString:@""])
        return abstractTitle;
    else
        return viewId;
}

#pragma mark - Social Actions Delegate

- (void)favouriteButtonPressed:(UIButton *)button videoInstance:(VideoInstance *)videoInstance {
    
    [[SYNTrackingManager sharedManager] trackVideoLikeFromScreenName:[self trackingScreenName]];
	BOOL didStar = (button.selected == NO);
    [self starVideoInstance:videoInstance withButton:button didStar:didStar];
    
    [appDelegate.oAuthNetworkEngine recordActivityForUserId: appDelegate.currentUser.uniqueId
                                                     action: (didStar ? @"star" : @"unstar")
                                            videoInstanceId: videoInstance.uniqueId
                                               trackingCode:[[SYNActivityManager sharedInstance] trackingCodeForVideoInstance:videoInstance]
                                          completionHandler: ^(id response) {
                                              BOOL previousStarringState = videoInstance.starredByUserValue;
                                              [self starVideoInstance:videoInstance withButton:button didStar:didStar];
                                              
                                              if (![videoInstance.managedObjectContext save:nil]) {
                                                  videoInstance.starredByUserValue = previousStarringState;
                                              }
                                              
                                          } errorHandler: ^(id error) {
                                              DebugLog(@"Could not star video");
                                          }];
}

- (void)addToChannelButtonPressed:(UIButton *)button videoInstance:(VideoInstance *)videoInstance {

    [[SYNTrackingManager sharedManager] trackVideoAddFromScreenName:[self trackingScreenName]];
    [appDelegate.oAuthNetworkEngine recordActivityForUserId:appDelegate.currentUser.uniqueId
                                                     action:@"select"
                                            videoInstanceId:videoInstance.uniqueId
                                               trackingCode:[[SYNActivityManager sharedInstance] trackingCodeForVideoInstance:videoInstance]
                                          completionHandler:nil
                                               errorHandler:nil];
	
	SYNAddToChannelViewController *viewController = [[SYNAddToChannelViewController alloc] initWithViewId:kExistingChannelsViewId];
	viewController.modalPresentationStyle = UIModalPresentationCustom;
	viewController.transitioningDelegate = self;
	viewController.videoInstance = videoInstance;
    TFLog(@"Channel details: Video instance :%@", videoInstance);
    
	[self presentViewController:viewController animated:YES completion:nil];
}

- (void)starVideoInstance:(VideoInstance*)videoInstance withButton:(UIButton*)button didStar:(BOOL)didStar {
	button.selected = didStar;
    videoInstance.starredByUserValue = didStar;
}

- (void)shareChannel:(Channel *) channel {
	VideoInstance *firstVideoInstance = [channel.videoInstances firstObject];
	UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:firstVideoInstance.thumbnailURL];


    [self requestShareLinkWithObjectType:@"channel" objectId:channel.uniqueId trackingCode:[[SYNActivityManager sharedInstance] trackingCodeForChannel:channel]];

    [self shareObject:channel usingImage:image];
}

- (void)shareVideoInstance:(VideoInstance *)videoInstance {
    
	[self requestShareLinkWithObjectType: @"video_instance"
								objectId: videoInstance.uniqueId
     	trackingCode:[[SYNActivityManager sharedInstance] trackingCodeForVideoInstance:videoInstance]];
    
    // At this point it is safe to assume that the video thumbnail image is in the cache
    UIImage *thumbnailImage = [SDWebImageManager.sharedManager.imageCache imageFromMemoryCacheForKey: videoInstance.video.thumbnailURL];
    [self shareObject:videoInstance usingImage:thumbnailImage];
}


- (void)shareObject:(id)object usingImage:(UIImage *) usingImage {
    SYNOneToOneSharingController *viewController = [self createSharingViewControllerForShareObject:object image:usingImage];
    viewController.modalPresentationStyle = UIModalPresentationCustom;
	viewController.transitioningDelegate = self;
	[self presentViewController:viewController animated:YES completion:nil];
}

- (NSString*)userName {
	NSString *userName = nil;
	User *user = appDelegate.currentUser;
	
	if (user.fullNameIsPublicValue) {
		userName = user.fullName;
	}
	
	if (![userName length]) {
		userName = user.username;
	}
    
    return userName;
}

- (SYNOneToOneSharingController *)createSharingViewControllerForShareObject:(id) shareObject
                                                                      image:(UIImage *)image {
    NSString *subject = @"";
	NSString *userName = [self userName];
	NSString *type = @"";
    BOOL owner = NO;
    
    if ([shareObject isKindOfClass:[VideoInstance class]]) {
        owner = [self isOwnerId:((VideoInstance*)shareObject).originator.uniqueId];
        type = NSLocalizedString(@"video", nil);
    }
    
    if ([shareObject isKindOfClass:[Channel class]]) {
        owner = [self isOwnerId:((Channel*)shareObject).channelOwner.uniqueId];
        type = NSLocalizedString(@"collection", nil);
    }

    if (userName != nil) {
		subject = [NSString stringWithFormat: @"%@ has shared a %@ with you", userName, type];
	}
    
	[self.mutableShareDictionary addEntriesFromDictionary:@{@"owner": @(owner),
															@"video": @([shareObject isKindOfClass:[VideoInstance class]]),
															@"subject": subject}];
	
	// Only add image if we have one
	if (image) {
		[self.mutableShareDictionary addEntriesFromDictionary: @{@"image": image}];
	}
	
	return [[SYNOneToOneSharingController alloc] initWithInfo: self.mutableShareDictionary];
}


- (void) requestShareLinkWithObjectType: (NSString *) objectType
                               objectId: (NSString *) objectId
                           trackingCode: (NSString *) trackingCode {
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
                                               trackingCode: trackingCode
                                          completionHandler: ^(NSDictionary *responseDictionary) {
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
         
     } errorHandler:nil];
}


#pragma mark - Load more footer

// Load more footer

- (CGSize) footerSize {
    return IS_IPHONE ? CGSizeMake(320.0f, 64.0f) : CGSizeMake(1024.0, 64.0);
}


- (void) setLoadingMoreContent: (BOOL) loadingMoreContent {
    // First set the state of our footer spinner
    self.footerView.showsLoading = loadingMoreContent;
    
    // Now set our actual variable
    _loadingMoreContent = loadingMoreContent;
}

- (UITapGestureRecognizer *)scrollToTopGestureRecognizer {
	if (!_scrollToTopGestureRecognizer) {
        
        if (IS_IPHONE) {
            self.scrollToTopGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToTopIPhone:)];
        } else {
            self.scrollToTopGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToTopIPad:)];
        }
	}
	return _scrollToTopGestureRecognizer;
}

#pragma mark UIApplication Callback Notifications

- (void) applicationWillEnterForeground: (UIApplication *) application {
    [self resetDataRequestRange];
    // and then make a class appropriate data call
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - UIScrollView delegates

- (void) scrollViewWillBeginDragging: (UIScrollView *) scrollView {
    self.startDraggingPoint = scrollView.contentOffset;
    self.startDate = [NSDate date];
}

- (void) scrollViewDidEndDragging: (UIScrollView *) scrollView willDecelerate: (BOOL) decelerate {
    self.endDraggingPoint = scrollView.contentOffset;
    self.endDate = [NSDate dateWithTimeIntervalSinceNow: self.startDate.timeIntervalSinceNow];
    [self shouldHideTabBar];
}

- (void) scrollViewDidScroll: (UIScrollView *) scrollView {
    int offset = scrollView.contentOffset.y + self.offsetValue;
    
    if (self.lastContentOffset > offset) {
        self.scrollDirection = ScrollingDirectionUp;
    } else {
        self.scrollDirection = ScrollingDirectionDown;
    }
    
    self.lastContentOffset = offset;
    
    if (scrollView.contentOffset.y < kScrollContentOff && !self.scrollerIsNearTop) {
        self.scrollerIsNearTop = YES;
        //Notification that tells the navigation manager to show the navigation bar
        [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                            object: self
                                                          userInfo: @{kScrollingDirection:@(ScrollingDirectionUp)}];
    }
    
    if (scrollView.contentOffset.y > kScrollContentOff && self.scrollerIsNearTop) {
        self.scrollerIsNearTop = NO;
    }
}

- (NSString *)trackingScreenName {
	return nil;
}

- (void) shouldHideTabBar {
    CGPoint difference = CGPointMake(self.startDraggingPoint.x - self.endDraggingPoint.x, self.startDraggingPoint.y - self.endDraggingPoint.y);
    
    int check = fabsf(difference.y) / fabsf(self.startDate.timeIntervalSinceNow);
    
    if (check > kScrollSpeedBoundary)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                            object: self
                                                          userInfo: @{kScrollingDirection:@(self.scrollDirection)}];
    }
}


- (SYNPopupMessageView*)displayPopupMessage: (NSString*) messageKey
                                 withLoader: (BOOL) isLoader {
    if (self.popupMessageView) {
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

- (void)removePopupMessage {
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
	
	if (channelVC) {
		channelVC.channel = channel;
        channelVC.mode = kChannelDetailsModeDisplay;
        
		[self.navigationController popToViewController:channelVC animated:animated];
	} else {
		channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel
                                                                   usingMode:kChannelDetailsModeDisplay];
		[self.navigationController pushViewController:channelVC animated:animated];
	}
}

- (void) viewVideoInstanceInChannel:(Channel*) channel withVideoId:videoId {
    [self viewVideoInstanceInChannel:channel withVideoId:videoId withClickToMore:NO];
}

- (void) viewVideoInstanceInChannel:(Channel*) channel withVideoId:videoId withClickToMore:(BOOL)clickToMore {
    SYNChannelDetailsViewController *channelVC = [[SYNChannelDetailsViewController alloc] initWithChannel:channel
                                                               usingMode:kChannelDetailsModeDisplay];
    channelVC.autoplayId = videoId;
    channelVC.clickToMore = clickToMore;
    [self.navigationController pushViewController:channelVC animated:YES];
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

- (void)followControlPressed:(UIButton *)button withChannelOwner:(ChannelOwner *)channelOwner withVideoInstace:(VideoInstance*)videoInstance completion :(void (^)(void))callbackBlock {
    
	if ([[SYNActivityManager sharedInstance] isSubscribedToUserId:channelOwner.uniqueId]) {
        [[SYNActivityManager sharedInstance] unsubscribeToUser:channelOwner
                                                 videoInstance:videoInstance
											 completionHandler:^(id responce) {
												 
												 button.selected = NO;
												 button.enabled = YES;
												 [[NSNotificationCenter defaultCenter] postNotificationName:kReloadFeed object:self userInfo:nil];
                                                 
                                                 if (callbackBlock) {
                                                     callbackBlock();
                                                 }
                                                 
												 [button invalidateIntrinsicContentSize];
                                                 
											 } errorHandler:^(id error) {
												 button.enabled = YES;
												 [button invalidateIntrinsicContentSize];
											 }];
	} else {
        
        
        [self followButtonAnimation:button];
        button.selected = YES;
        
        [[SYNActivityManager sharedInstance] subscribeToUser:channelOwner
                                               videoInstance:videoInstance
										   completionHandler: ^(id responce) {
											   
											   button.enabled = YES;
											   
											   [[NSNotificationCenter defaultCenter] postNotificationName:kReloadFeed object:self userInfo:nil];
											   [button invalidateIntrinsicContentSize];
                                               
                                               if (callbackBlock) {
                                                   callbackBlock();
                                               }
                                               
										   } errorHandler: ^(id error) {
											   button.enabled = YES;
                                               button.selected = NO;
                                               
											   [button invalidateIntrinsicContentSize];
										   }];
        
	}
}

- (void)followButtonPressed:(UIButton *)button withChannel:(Channel *)channel completion :(void (^)(void))callbackBlock {

        [[SYNTrackingManager sharedManager] trackCollectionFollowFromScreenName:[self trackingScreenName]];
    
	if ([[SYNActivityManager sharedInstance]isSubscribedToChannelId:channel.uniqueId]) {
        [[SYNActivityManager sharedInstance] unsubscribeToChannel: channel
                                                completionHandler:^(NSDictionary *responseDictionary) {
                                                    
                                                    button.selected = NO;
                                                    button.enabled = YES;
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadFeed object:self userInfo:nil];
                                                    
                                                    
                                                    if (callbackBlock) {
                                                        callbackBlock();
                                                    }

                                                } errorHandler: ^(NSDictionary *errorDictionary) {
                                                    button.enabled = YES;
                                                }];
	} else {
        
        [self followButtonAnimation:button];
        button.selected = YES;

        [[SYNActivityManager sharedInstance] subscribeToChannel: channel
											  completionHandler: ^(NSDictionary *responseDictionary) {
												  [[SYNTrackingManager sharedManager] trackCollectionFollowCompleted];
												  
                                                  button.enabled = YES;
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadFeed object:self userInfo:nil];
                                                  
                                                  if (callbackBlock) {
                                                      callbackBlock();
                                                  }

                                              } errorHandler: ^(NSDictionary *errorDictionary) {
                                                  button.enabled = YES;
                                                  button.selected = NO;

                                              }];
	}

}


- (void) followButtonAnimation :(UIButton *) button {
    
    float totalAnimationTime = 0.35;

    CABasicAnimation* first = [CABasicAnimation animationWithKeyPath:@"transform"];
    first.autoreverses = YES;
    first.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1, 1)];
    [first setDuration:totalAnimationTime*0.15];
    [first setBeginTime:0];
    
    CABasicAnimation* second = [CABasicAnimation animationWithKeyPath:@"transform"];
    second.autoreverses = YES;
    [second setDuration:totalAnimationTime*0.16];
    [second setBeginTime:totalAnimationTime*0.25];
    
    second.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 1, 1)];
    
    CABasicAnimation* third = [CABasicAnimation animationWithKeyPath:@"transform"];
    third.autoreverses = YES;
    [third setDuration:totalAnimationTime*0.35];
    [third setBeginTime:totalAnimationTime*0.4];
    third.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.08, 1, 1)];
    
    
    CABasicAnimation* forth = [CABasicAnimation animationWithKeyPath:@"transform"];
    forth.autoreverses = YES;
    [forth setDuration:totalAnimationTime*0.25];
    [forth setBeginTime:totalAnimationTime*0.75];
    forth.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    [group setDuration:totalAnimationTime];
    [group setAnimations:[NSArray arrayWithObjects:first, second, third,  nil]];
    
    [button.layer addAnimation:group forKey:nil];
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

#pragma mark - rotation

- (BOOL) isOwnerId:(NSString *) unquieId {
	return [unquieId isEqualToString:appDelegate.currentUser.uniqueId];
}

@end
