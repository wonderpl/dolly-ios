	//
//  SYNTopBarViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNDeviceManager.h"
#import "SYNAddToChannelViewController.h"
#import "SYNMasterViewController.h"
#import "SYNNetworkMessageView.h"
#import "SYNOAuthNetworkEngine.h"
#import "UIFont+SYNFont.h"
#import "VideoInstance.h"
#import "SYNPopoverable.h"
#import "SYNContainerViewController.h"
#import "SYNGenreManager.h"
#import "SYNRemoteLogger.h"

#define kBackgroundOverlayAlpha 0.5f


@interface SYNMasterViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) SYNContainerViewController* containerViewController;
@property (nonatomic, strong) SYNNetworkMessageView* networkMessageView;

@property (nonatomic, weak) UIViewController *overlayController; // keep it weak so that the overlay gets deallocated as soon as it dissapears from screen
@property (nonatomic, strong) UIView* backgroundOverlayView; // darken the screen

@property (strong, nonatomic) IBOutlet UIView *tabsViewIPad;
@property (nonatomic) CGRect overlayControllerFrame;

@property (nonatomic, strong) NSTimer *tabBarTimer;

@property (nonatomic, assign) float firstX;
@property (nonatomic, assign) float firstY;

@end


@implementation SYNMasterViewController

#pragma mark - Object lifecycle

- (id) initWithContainerViewController: (SYNContainerViewController*) root
{
    if ((self = [super initWithNibName: @"SYNMasterViewController" bundle: nil]))
    {
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        self.containerViewController = root;
        
    }
    
    return self;
}


- (void) dealloc
{
    // Defensive programming
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    
    [super viewDidLoad];
	
    // == Setup Navigation Manager == (This should be done here because it is dependent on controls) == //
    
    appDelegate.navigationManager.masterController = self;
    appDelegate.navigationManager.containerController = self.containerViewController; // container
    
    
    
    // Listen to Reachability Notifications for no network messages //
    
    self.reachability = [Reachability reachabilityWithHostname:appDelegate.networkEngine.hostName];
    
    // == Set Up Notifications == //
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelSuccessfullySaved:) name:kNoteChannelSaved object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    // add background view //
    
    self.backgroundOverlayView = [[UIView alloc] initWithFrame:CGRectZero];
    self.backgroundOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundOverlayView.backgroundColor = [UIColor darkGrayColor];
    
	[self addChildViewController:self.containerViewController];
	self.containerViewController.view = self.containerView;
	
	[appDelegate handlePendingOpenURL];
	
    //Hiding the tab bar before a animation to show it
    //Hiding here to keep the nib more clean
    //Animation is done in ViewDidAppear
    if(IS_IPHONE) {
        CGRect tmpFrame = self.tabsView.frame;
        tmpFrame.origin.y += self.tabsView.frame.size.height;
        self.tabsView.frame = tmpFrame;
    }
    
    if (IS_IPAD) {
        CGRect tmpFrame = self.tabsViewIPad.frame;
        tmpFrame.origin.x -= self.tabsView.frame.size.width;
        self.tabsViewIPad.frame = tmpFrame;
        
//        UIScreenEdgePanGestureRecognizer *leftEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(showTabBar)];
//        leftEdgeGesture.edges = UIRectEdgeLeft;
//        leftEdgeGesture.delegate = self;
//        [self.view addGestureRecognizer:leftEdgeGesture];
//        
//        UIScreenEdgePanGestureRecognizer *bottomEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(showTabBar)];
//        bottomEdgeGesture.edges = UIRectEdgeBottom;
//        bottomEdgeGesture.delegate = self;
//        [self.view addGestureRecognizer:bottomEdgeGesture];

        
//        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideTabBar)];
//        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
//		[self.tabsViewIPad addGestureRecognizer:swipeLeft];

        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveTabBar:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [self.tabsViewIPad addGestureRecognizer:panRecognizer];

    
    }
    
    if (IS_IPHONE) {
        [[NSNotificationCenter defaultCenter] postNotificationName: kScrollMovement
                                                            object: self
                                                          userInfo: @{kScrollingDirection:@(ScrollingDirectionUp)}];
    }
    

}


#pragma mark - Overlays, Adding and Removing

-(void) addExistingCollectionsOverlayControllerForVideoInstance:(VideoInstance *)videoInstance
{
	SYNAddToChannelViewController *viewController = [[SYNAddToChannelViewController alloc] initWithViewId:kExistingChannelsViewId];
	viewController.videoInstance = videoInstance;

	[self addOverlayController:viewController animated:YES];
}

- (void) addOverlayController:(UIViewController<SYNPopoverable>*)overlayViewController animated:(BOOL)animated
{
    if(!overlayViewController)
    {
        AssertOrLog(@"Trying to add nil as an overlay controller");
        return;
    }
    
    
    UITapGestureRecognizer* tapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundOverlayTapped:)];
    
    
    // == Add Background View == //
    
    CGRect bgFrame = CGRectZero;
    bgFrame.size = [[SYNDeviceManager sharedInstance] currentScreenSize];
    self.backgroundOverlayView.frame = bgFrame;
    
    [self.backgroundOverlayView addGestureRecognizer:tapGesture];
    
    self.backgroundOverlayView.alpha = 0.0f;
    
    [self.view addSubview:self.backgroundOverlayView];
    
    [self addChildViewController:overlayViewController];
    
    [self.view addSubview:overlayViewController.view];
    
    
    self.overlayController = overlayViewController;
    
    // == Animate == //
    __block CGRect startFrame, endFrame;
    
    // keep a reference to the frame so as to use it in the rotation code and maintain the size
    self.overlayControllerFrame = startFrame = endFrame = self.overlayController.view.frame;
    if(IS_IPHONE)
    {
        // only iPhone has startFrame since on iPad it appears in place, here we push it to the bottom first
        startFrame.origin.y = startFrame.size.height;
        self.overlayController.view.frame = startFrame;
    }
    else
    {
		endFrame.origin.x = [[SYNDeviceManager sharedInstance] currentScreenMiddlePoint].x - endFrame.size.width * 0.5f;
		endFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenMiddlePoint].y - endFrame.size.height * 0.5f;
        
        self.overlayController.view.alpha = 0.0;
        
        self.overlayController.view.layer.cornerRadius = 8.0f;
        self.overlayController.view.clipsToBounds = YES;
        
        self.overlayController.view.frame = self.overlayControllerFrame = endFrame;
    }
    
    
    
    
    void(^AnimationsBlock)(void) = ^{
        
        self.backgroundOverlayView.alpha = kBackgroundOverlayAlpha;
        
        if(IS_IPHONE)
        {
            endFrame.origin.y = self.view.frame.size.height - startFrame.size.height;
            self.overlayController.view.frame = endFrame;
        }
        else
        {
            self.overlayController.view.alpha = 1.0;
        }
    };
    
    if(animated)
    {
        [UIView animateWithDuration: 0.3f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: AnimationsBlock
                         completion: nil];
    }
    else
    {
        AnimationsBlock();
    }
}

- (void) backgroundOverlayTapped:(UITapGestureRecognizer*)recogniser
{
    
    [self removeOverlayControllerAnimated:YES];
}



-(void)removeOverlayControllerAnimated:(BOOL)animated
{
    
    __weak SYNMasterViewController* wself = self;
    
    void(^AnimationsBlock)(void) = ^{
        
        wself.backgroundOverlayView.alpha = 0.0f;
        
        if(IS_IPHONE)
        {
            CGRect endFrame = self.overlayController.view.frame;
            endFrame.origin.y = self.view.frame.size.height; // push to the bottom
            wself.overlayController.view.frame = endFrame;
        }
        else
        {
            wself.overlayController.view.alpha = 0.0f;
        }
        
    };
    
    void (^FinishedBlock)(BOOL) = ^(BOOL finished) {
      
        UIViewController<SYNPopoverable> *popoverable;
        if([self.overlayController isKindOfClass:[UINavigationController class]])
        {
            UINavigationController* navWrapper = ((UINavigationController*)wself.overlayController);
            popoverable = (UIViewController<SYNPopoverable> *)navWrapper.viewControllers[0];
            
        }
        else
        {
            popoverable = (UIViewController<SYNPopoverable> *)self.overlayController;
        }
        
        // check if it really conforms to the portocol before calling to avoid crashes
        if([popoverable conformsToProtocol:@protocol(SYNPopoverable)])
        {
            [popoverable finishingPresentation];
        }
        
        [wself.overlayController.view removeFromSuperview];
        [wself.overlayController removeFromParentViewController];
        
        [wself.backgroundOverlayView removeFromSuperview];
    };
    
    if(animated)
    {
        [UIView animateWithDuration: 0.3f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: AnimationsBlock
                         completion: FinishedBlock];
    }
    else
    {
        AnimationsBlock();
        FinishedBlock(YES);
    }
    
}

#pragma mark - Notification Handlers


- (void) reachabilityChanged: (NSNotification*) notification
{
    
    if ([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
    {
        [self hideNetworkErrorMessageView];
    }
    else if ([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
    {
        [self hideNetworkErrorMessageView];
    }
    else if ([self.reachability currentReachabilityStatus] == NotReachable)
    {
        NSString* message = IS_IPAD ? NSLocalizedString(@"No_Network_iPad", nil) : NSLocalizedString(@"No_Network_iPhone", nil);
        
        [self presentNotificationWithMessage:message andType:NotificationMessageTypeNetworkError];
    }
    
    DebugLog(@"Network %@Reachable", [self.reachability currentReachabilityStatus] == NotReachable ? @"NOT " : @"");
}


- (void) channelSuccessfullySaved: (NSNotification*) note
{
    NSString* message = IS_IPHONE ? NSLocalizedString(@"COLLECTION_SAVED", nil) : NSLocalizedString(@"YOUR_COLLECTION_HAS_BEEN_SAVED", nil);
    
    [self presentNotificationWithMessage:message andType:NotificationMessageTypeSuccess];
}



- (void) accountSettingsLogout: (NSNotification*) notification
{
	[[SYNRemoteLogger sharedLogger] log:@"Logging out via notification"];
    [appDelegate logout];
}


#pragma mark - Message Popups (form Bottom)

- (void) presentNotificationWithMessage : (NSString*) message andType:(NotificationMessageType)type
{
    
    if(self.networkMessageView)
        return;
    
    self.networkMessageView = [[SYNNetworkMessageView alloc] initWithMessageType:type];
    
    
    [self.networkMessageView setText: message];
	
	UIViewController *topViewController = self;
	while (topViewController.presentedViewController && topViewController.presentedViewController.modalPresentationStyle == UIModalPresentationFullScreen) {
		topViewController = topViewController.presentedViewController;
	}
	
	[topViewController.view addSubview: self.networkMessageView];
    CGRect newFrame = self.networkMessageView.frame;
    newFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeight] - newFrame.size.height;
    
    if (IS_IPHONE) {
        newFrame.origin.y-=newFrame.size.height-2;
    }

    [UIView animateWithDuration: 0.3f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.networkMessageView.frame = newFrame;
                     }
                     completion: ^(BOOL finished) {
                         
                         if (type == NotificationMessageTypeSuccess)
                         {
                             [self performSelector:@selector(hideNetworkErrorMessageView) withObject:nil afterDelay:4.0f];
                         }
                         
                     }];
    
    
}

-(void)hideNetworkErrorMessageView
{
    if(!self.networkMessageView)
        return;
    
    [UIView animateWithDuration: 0.3f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         
                         CGRect messgaeViewFrame = self.networkMessageView.frame;
                         messgaeViewFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeight]; // push to the bottom
                         self.networkMessageView.frame = messgaeViewFrame;
                         
                     }
                     completion: ^(BOOL finished) {
                         
                         [self.networkMessageView removeFromSuperview];
                         self.networkMessageView = nil;
                         
                     }];
}


#pragma mark - Interface Orientation Methods

- (NSUInteger) supportedInterfaceOrientations
{
    if (IS_IPHONE)
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    else
    {
        return UIInterfaceOrientationMaskAll;
    }
}




- (void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                          duration: (NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation: toInterfaceOrientation
                                            duration: duration];
    
    
    if(IS_IPAD && self.overlayController)
    {
        CGRect currentOverlayFrame = self.overlayController.view.frame;
		currentOverlayFrame.size = self.overlayControllerFrame.size;
		currentOverlayFrame.origin.x = [[SYNDeviceManager sharedInstance] currentScreenWidth] * 0.5f - currentOverlayFrame.size.width * 0.5;
		currentOverlayFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeight] * 0.5f - currentOverlayFrame.size.height * 0.5;
        
        self.overlayController.view.frame = currentOverlayFrame;
    }

    

}

#pragma mark - Accessors

- (SYNAbstractViewController*) showingViewController
{
    return (SYNAbstractViewController*)(self.containerViewController.currentViewController.topViewController);
}

- (NSArray*) viewControllers {
    return self.containerViewController.currentViewController.viewControllers;
}

- (SYNAbstractViewController*) rootViewController
{
    int count = [self.containerViewController.currentViewController.viewControllers count]-1;
    
    for (int i = count; i>=0; i--) {
        
        SYNAbstractViewController *viewController = [self.containerViewController.currentViewController.viewControllers objectAtIndex:i];
        NSString *className = NSStringFromClass([viewController class]);
        className = [className lowercaseString];
        
        if (!([className rangeOfString:@"profile"].location == NSNotFound)) {
            return viewController;
        }
        
        if (!([className rangeOfString:@"feed"].location == NSNotFound)) {
            return viewController;
        }
        
        if (!([className rangeOfString:@"activity"].location == NSNotFound)) {
            return viewController;
        }
    }

    return (SYNAbstractViewController*)([self.containerViewController.currentViewController.viewControllers firstObject]);
}

-(NSArray*)tabs
{
    return self.tabsView.subviews;
}

- (SYNActivityTabButton *)activityTab {
	return self.tabs[3];
}

- (void)hideTabBar {
    CGRect frame = self.tabsViewIPad.frame;
    
    frame.origin.x = -180-self.tabsView.frame.size.width;
 
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.6
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.tabsViewIPad.frame = frame;
                     } completion:nil];
}

#pragma mark - Display Notifications Number

- (BOOL)shouldAutomaticallyForwardRotationMethods {
    return YES;
}
- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return YES;
}


#pragma mark - Pangesture

//TODO: fix values

- (void)moveTabBar:(UIPanGestureRecognizer *)recognizer {

    [self.view bringSubviewToFront:[(UIPanGestureRecognizer*)recognizer view]];
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)recognizer translationInView:self.view];
    
    if ([(UIPanGestureRecognizer*)recognizer state] == UIGestureRecognizerStateBegan) {
        self.firstX = [[recognizer view] center].x;
        self.firstY = [[recognizer view] center].y;
    }
    
    translatedPoint = CGPointMake(self.firstX+translatedPoint.x, self.firstY);
    
    NSLog(@"%f", translatedPoint.x);
    
    if (translatedPoint.x >= -130 && translatedPoint.x <= 100) {
        [[recognizer view] setCenter:translatedPoint];
    }
    
    if ([(UIPanGestureRecognizer*)recognizer state] == UIGestureRecognizerStateEnded) {
        CGFloat velocityX = (0.2*[(UIPanGestureRecognizer*)recognizer velocityInView:self.view].x);
        
        CGFloat finalX = translatedPoint.x + velocityX;
        CGFloat finalY = self.firstY;

            if (finalX >= -50) {
                finalX = -22;
            } else {
                finalX = -130;
            }
        
        CGFloat animationDuration = (ABS(velocityX)*.0002)+.6;
        
        [UIView animateWithDuration:animationDuration delay:0
             usingSpringWithDamping:0.3f initialSpringVelocity:0.8f
                            options:0 animations:^{
                                [[recognizer view] setCenter:CGPointMake(finalX, finalY)];
                            } completion:^(BOOL finished) {
                                [self.tabBarTimer invalidate];
                                self.tabBarTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                                                    target:self
                                                                                  selector:@selector(hideTabBar)
                                                                                  userInfo:nil
                                                                                   repeats:NO];
                                

                            }];
    }

}


@end
