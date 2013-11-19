//
//  SYNTopBarViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//

#import "SYNCautionMessageView.h"
#import "SYNDeviceManager.h"
#import "SYNAddToChannelViewController.h"
#import "SYNMasterViewController.h"
#import "SYNNetworkMessageView.h"
#import "SYNPopoverable.h"

@import QuartzCore;


#define kBackgroundOverlayAlpha 0.5f


typedef void(^AnimationCompletionBlock)(BOOL finished);

@interface SYNMasterViewController ()

@property (nonatomic) BOOL searchIsInProgress;
@property (nonatomic) BOOL showingBackButton;

@property (nonatomic, strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) SYNContainerViewController* containerViewController;
@property (nonatomic, strong) SYNNetworkMessageView* networkErrorNotificationView;
@property (nonatomic, strong) SYNVideoViewerViewController *videoViewerViewController;
@property (nonatomic, strong) UIPopoverController *accountSettingsPopover;

@property (nonatomic, weak) UIViewController *overlayController; // keep it weak so that the overlay gets deallocated as soon as it dissapears from screen
@property (nonatomic, strong) UIView* backgroundOverlayView; // darken the screen


@property (nonatomic, strong) IBOutlet UIView* headerContainerView;

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
    self.accountSettingsPopover.delegate = nil;
}


#pragma mark - View lifecycle

- (void) viewDidLoad
{
    
    [super viewDidLoad];
    
    [self addChildViewController:self.containerViewController];
    
    // set the view programmatically, this will call the viewDidLoad of the container through its custom setter
    
    self.containerViewController.view = self.containerView;
    
    
    // == Setup Navigation Manager == (This should be done here because it is dependent on controls) == //
    
    appDelegate.navigationManager.masterController = self;
    appDelegate.navigationManager.containerController = self.containerViewController; // container
    
    
    
    // Listen to Reachability Notifications for no network messages //
    
    self.reachability = [Reachability reachabilityWithHostname:appDelegate.networkEngine.hostName];
    
    self.closeSearchButton.hidden = YES;

    
    // == Set Up Notifications == //
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountSettingsLogout) name:kAccountSettingsLogout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelSuccessfullySaved:) name:kNoteChannelSaved object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSuccessNotificationWithCaution:) name:kNoteSavingCaution object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAccountSettingsPopover) name:kAccountSettingsPressed object:nil];
    
    // add background view //
    
    self.backgroundOverlayView = [[UIView alloc] initWithFrame:CGRectZero];
    self.backgroundOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundOverlayView.backgroundColor = [UIColor darkGrayColor];
    
    
}

// temporary
-(void)hideOrShowNetworkMessages:(NSNotification*)notifcation
{
    
}
#pragma mark - Overlays, Adding and Removing

-(void)addExistingCollectionsOverlayController
{
    SYNAddToChannelViewController* existingController = [[SYNAddToChannelViewController alloc] initWithViewId:kExistingChannelsViewId];
    
    [self addOverlayController:existingController animated:YES];
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
    
    startFrame = endFrame = overlayViewController.view.frame;
    if(IS_IPHONE)
    {
        // push it to the bottom
        startFrame.origin.y = startFrame.size.height;
        
    }
    else
    {
        startFrame.origin.x = [[SYNDeviceManager sharedInstance] currentScreenMiddlePoint].x - startFrame.size.width * 0.5f;
        startFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenMiddlePoint].y - startFrame.size.height * 0.5f;
        
        self.overlayController.view.alpha = 0.0;
        
        self.overlayController.view.layer.cornerRadius = 8.0f;
        [self.overlayController.view setClipsToBounds:YES];
    }
    
    overlayViewController.view.frame = startFrame;
    
    void(^AnimationsBlock)(void) = ^{
        
        self.backgroundOverlayView.alpha = kBackgroundOverlayAlpha;
        
        if(IS_IPHONE)
        {
            endFrame.origin.y = self.view.frame.size.height - startFrame.size.height;
            overlayViewController.view.frame = endFrame;
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
    
    
    // pause video
    
    if (self.videoViewerViewController)
    {
        [self.videoViewerViewController pauseIfVideoActive];
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



#pragma mark - Video Overlay View

- (void) addVideoOverlayToViewController: (SYNAbstractViewController *) originViewController
                  withVideoInstanceArray: (NSArray*) videoInstanceArray
                        andSelectedIndex: (int) selectedIndex
                              fromCenter: (CGPoint)centerPoint
{
    
    if (self.videoViewerViewController)
    {
        //Prevent presenting two video players.
        return;
    }
    
    // Remember the view controller that we came from
 //   self.originViewController = originViewController;
    
    self.videoViewerViewController = [[SYNVideoViewerViewController alloc] initWithVideoInstanceArray: videoInstanceArray selectedIndex: selectedIndex];
    /*
    if ([originViewController isKindOfClass:[SYNChannelDetailViewController class]])
    {
        self.videoViewerViewController.shownFromChannelScreen = YES;
        
    }
    */
  //  [self addChildViewController: self.videoViewerViewController];
    
    
//    self.videoViewerViewController.view.frame = self.overlayView.bounds;
 //   [self.overlayView addSubview: self.videoViewerViewController.view];
    self.videoViewerViewController.overlayParent = self;
   // [self.videoViewerViewController prepareForAppearAnimation];

   // CGPoint delta = [self.originViewController.view convertPoint:centerPoint toView:self.view];
   // CGPoint originalCenter = self.videoViewerViewController.view.center;
   // self.videoViewerViewController.view.center = delta;
   // self.videoViewerViewController.view.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
   // self.videoViewerViewController.view.alpha = 0.0f;
    
    
    
    [self presentViewController:self.videoViewerViewController animated:YES completion:nil];
    /*
    [UIView animateWithDuration: kVideoInAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                                 self.videoViewerViewController.view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                                self.videoViewerViewController.view.center = originalCenter;
                                self.videoViewerViewController.view.alpha = 1.0f;
                     }
                     completion: ^(BOOL finished) {
                         [self.videoViewerViewController runAppearAnimation];
                         self.overlayView.userInteractionEnabled = YES;
    }];
    */
}


- (void) removeVideoOverlayController
{

    [self dismissViewControllerAnimated:YES completion:^{
        self.videoViewerViewController = nil;
    }];

}


#pragma mark - Notification Handlers

- (void) accountSettingsLogout
{
    [appDelegate logout];
}



- (void) reachabilityChanged: (NSNotification*) notification
{
#ifdef PRINT_REACHABILITY
    NSString* reachabilityString;
    if ([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
        reachabilityString = @"WiFi";
    else if ([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
        reachabilityString = @"WWAN";
    else if ([self.reachability currentReachabilityStatus] == NotReachable)
        reachabilityString = @"None";
    
    DebugLog(@"Reachability == %@", reachabilityString);
#endif
    
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
        
        self.networkErrorNotificationView = [self presentNotificationWithMessage:message andType:NotificationMessageTypeError];
    }
}


- (void) channelSuccessfullySaved: (NSNotification*) note
{
    NSString* message = IS_IPHONE ? NSLocalizedString(@"PACK SAVED", nil) : NSLocalizedString(@"YOUR PACK HAS BEEN SAVED", nil);
    
    [self presentNotificationWithMessage:message andType:NotificationMessageTypeSuccess];
}



- (void) accountSettingsLogout: (NSNotification*) notification
{
    [self.accountSettingsPopover dismissPopoverAnimated: NO];
    self.accountSettingsPopover = nil;
    [appDelegate logout];
}


#pragma mark - Message Popups (form Bottom)

- (SYNNetworkMessageView*) presentNotificationWithMessage : (NSString*) message andType:(NotificationMessageType)type
{
    
    __block SYNNetworkMessageView* messageView = [[SYNNetworkMessageView alloc] init];
    messageView.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"BarSucess"]];
    [messageView setText: message];
    
    [self.view addSubview: messageView];
    
    [UIView animateWithDuration: 0.3f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         CGRect newFrame = messageView.frame;
                         newFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar] - newFrame.size.height;
                         messageView.frame = newFrame;
                     }
                     completion: ^(BOOL finished) {
                         
                         [UIView animateWithDuration: 0.3f
                                               delay: 4.0f
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations: ^{
                                              CGRect newFrame = messageView.frame;
                                              newFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar] + newFrame.size.height;
                                              messageView.frame = newFrame;
                                          }
                                          completion: ^(BOOL finished) {
                                              [messageView removeFromSuperview];
                                          }];
                     }];
    
    return messageView;
    
}

-(void)hideNetworkErrorMessageView
{
    if(!self.networkErrorNotificationView)
        return;
    
    [UIView animateWithDuration: 0.3f
                          delay: 4.0f
                        options: UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         CGRect newFrame = self.networkErrorNotificationView.frame;
                         newFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar] + newFrame.size.height;
                         self.networkErrorNotificationView.frame = newFrame;
                     }
                     completion: ^(BOOL finished) {
                         [self.networkErrorNotificationView removeFromSuperview];
                     }];
}


#pragma mark - Caution Presentation

- (void) presentSuccessNotificationWithCaution:(NSNotification*)notification
{
    SYNCaution* caution = [notification userInfo][kCaution];
    if (!caution)
        return;
    
    SYNCautionMessageView* cautionMessageView = [SYNCautionMessageView withCaution:caution];
    
    [cautionMessageView presentInView:self.view];  
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

    if (self.accountSettingsPopover)
    {
        CGRect rect = CGRectMake([SYNDeviceManager.sharedInstance currentScreenWidth] * 0.5,
                                 [SYNDeviceManager.sharedInstance currentScreenHeight] * 0.5, 1, 1);
        
        [self.accountSettingsPopover presentPopoverFromRect: rect
                                                     inView: self.view
                                   permittedArrowDirections: 0
                                                   animated: YES];
    }

}

#pragma mark - Accessors

- (SYNAbstractViewController*) showingViewController
{
    return (SYNAbstractViewController*)(self.containerViewController.currentViewController.topViewController);
}

-(NSArray*)tabs
{
    return self.tabsView.subviews;
}

@end
