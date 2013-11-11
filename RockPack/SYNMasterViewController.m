//
//  SYNTopBarViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) Rockpack Ltd. All rights reserved.
//


#import "AppConstants.h"
#import "GAI.h"
#import "SYNAccountSettingsMainTableViewController.h"
#import "SYNAccountSettingsModalContainer.h"
#import "SYNActivityPopoverViewController.h"
#import "SYNCaution.h"
#import "SYNCautionMessageView.h"
#import "SYNCollectionDetailsViewController.h"
#import "SYNContainerViewController.h"
#import "SYNDeviceManager.h"
#import "SYNExistingCollectionsViewController.h"
#import "SYNFacebookManager.h"
#import "SYNMasterViewController.h"
#import "SYNNetworkMessageView.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNSoundPlayer.h"
#import "SYNVideoPlaybackViewController.h"
#import "UIFont+SYNFont.h"
#import "VideoInstance.h"
@import QuartzCore;


#define kBackgroundOverlayAlpha 0.5f


typedef void(^AnimationCompletionBlock)(BOOL finished);

@interface SYNMasterViewController ()

@property (nonatomic) BOOL searchIsInProgress;
@property (nonatomic) BOOL showingBackButton;
@property (nonatomic, strong) IBOutlet UIButton* headerButton;

@property (nonatomic, strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) SYNAccountSettingsModalContainer* modalAccountContainer;
@property (nonatomic, strong) SYNContainerViewController* containerViewController;
@property (nonatomic, strong) SYNNetworkMessageView* networkErrorView;
@property (nonatomic, strong) SYNVideoViewerViewController *videoViewerViewController;
@property (nonatomic, strong) UIPopoverController* accountSettingsPopover;
@property (nonatomic, strong) UIView* accountSettingsCoverView;

@property (nonatomic, weak) UIViewController* overlayController; // keep it weak so that the overlay gets deallocated as soon as it dissapears from screen
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
    
    appDelegate.viewStackManager.masterController = self;
    
    
    // == Fade in from splash screen (not in AppDelegate so that the Orientation is known) == //
    
    UIImageView *splashView;
    if (IS_IPHONE)
    {
        if ([SYNDeviceManager.sharedInstance currentScreenHeight]>480.0f)
        {
            splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Default-568h"]];
        }
        else
        {
            splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Default"]];
        }
        splashView.center = CGPointMake(160.0f, splashView.center.y - 20.0f);
    }
    else
    {
        splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Default"]];
    }
    
    // == Listen to Reachability Notifications for no network messages == //
    
    
    self.reachability = [Reachability reachabilityWithHostname:appDelegate.networkEngine.hostName];
    
    self.accountSettingsCoverView = [[UIView alloc] initWithFrame:self.view.frame];
    self.accountSettingsCoverView.backgroundColor = [UIColor darkGrayColor];
    self.accountSettingsCoverView.alpha = 0.5;
    self.accountSettingsCoverView.hidden = YES;
    
    
    self.closeSearchButton.hidden = YES;

    
    // == Set Up Notifications == //
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountSettingsLogout) name:kAccountSettingsLogout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelSuccessfullySaved:) name:kNoteChannelSaved object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideOrShowNetworkMessages:) name:kNoteHideNetworkMessages object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideOrShowNetworkMessages:) name:kNoteShowNetworkMessages object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSuccessNotificationWithCaution:) name:kNoteSavingCaution object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAccountSettingsPopover) name:kAccountSettingsPressed object:nil];
    
    // add background view //
    self.backgroundOverlayView = [[UIView alloc] initWithFrame:self.view.frame];
    self.backgroundOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundOverlayView.backgroundColor = [UIColor darkGrayColor];
    
    
}




- (void) headerTapped: (UIGestureRecognizer*) recogniser
{
    [self.showingViewController headerTapped];
}

#pragma mark - Overlays, Adding and Removing

-(void)addExistingCollectionsOverlayController
{
    SYNExistingCollectionsViewController* existingController = [[SYNExistingCollectionsViewController alloc] initWithViewId:kExistingChannelsViewId];
    
    [self addOverlayController:existingController animated:YES];
}


-(void) addOverlayController: (SYNAbstractViewController*) abstractViewController
{
    [self addOverlayController:abstractViewController animated:NO];
}

- (void) addOverlayController:(SYNAbstractViewController *)abstractViewController animated:(BOOL)animated
{
    if(!abstractViewController)
    {
        AssertOrLog(@"Trying to add nil as an overlay controller");
        return;
    }
    
    self.backgroundOverlayView.alpha = 0.0f;
    [self.view addSubview:self.backgroundOverlayView];
    
    [self addChildViewController:abstractViewController];
    
    [self.view addSubview:abstractViewController.view];
    
    self.overlayController = abstractViewController;
    
    
    
    // animate in //
    
    CGRect startFrame = abstractViewController.view.frame;
    startFrame.origin.y = startFrame.size.height; // push it to the bottom
    abstractViewController.view.frame = startFrame;
    
    
    [UIView animateWithDuration: 0.3f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
                         self.backgroundOverlayView.alpha = kBackgroundOverlayAlpha;
                         
                         if(IS_IPHONE)
                         {
                             CGRect endFrame = abstractViewController.view.frame;
                             endFrame.origin.y = self.view.frame.size.height - startFrame.size.height;
                             abstractViewController.view.frame = endFrame;
                         }
                         
                         
                     }
                     completion: ^(BOOL finished) {
                         
                         
                     }];
    
    // pause video
    
    if (self.videoViewerViewController)
    {
        [self.videoViewerViewController pauseIfVideoActive];
    }
}

-(void)removeOverlayController
{
    [self removeOverlayControllerAnimated:NO];
}

-(void)removeOverlayControllerAnimated:(BOOL)animated
{
    [UIView animateWithDuration: 0.3f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
                         self.backgroundOverlayView.alpha = 0.0f;
                         
                         if(IS_IPHONE)
                         {
                             CGRect endFrame = self.overlayController.view.frame;
                             endFrame.origin.y = self.view.frame.size.height; // push to the bottom
                             self.overlayController.view.frame = endFrame;
                         }
                     }
                     completion: ^(BOOL finished) {
                         
                         [self.backgroundOverlayView removeFromSuperview];
                         
                     }];
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
        if (self.networkErrorView)
        {
            [self hideNetworkErrorView];
        }
    }
    else if ([self.reachability currentReachabilityStatus] == ReachableViaWWAN)
    {
        if (self.networkErrorView)
        {
            [self hideNetworkErrorView];
        }
    }
    else if ([self.reachability currentReachabilityStatus] == NotReachable)
    {
        NSString* message = IS_IPAD ? NSLocalizedString(@"No_Network_iPad", nil)
                                                                       : NSLocalizedString(@"No_Network_iPhone", nil);
        
        [self presentSuccessNotificationWithMessage:message andType:NotificationMessageTypeError];
    }
}



- (void) hideNetworkErrorView
{
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        
        CGRect erroViewFrame = self.networkErrorView.frame;
        erroViewFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeight];
        self.networkErrorView.frame = erroViewFrame;
        
    } completion:^(BOOL finished) {
        
        [self.networkErrorView removeFromSuperview];
        self.networkErrorView = nil;
        
    }];
}




- (void) channelSuccessfullySaved: (NSNotification*) note
{
    NSString* message = IS_IPHONE ? NSLocalizedString(@"PACK SAVED", nil) : NSLocalizedString(@"YOUR PACK HAS BEEN SAVED", nil);
    
    [self presentSuccessNotificationWithMessage:message andType:NotificationMessageTypeSuccess];
}


- (void) hideOrShowNetworkMessages: (NSNotification*) note
{
    if ([note.name isEqualToString: kNoteShowNetworkMessages])
    {
        self.errorContainerView.hidden = NO;
        [UIView animateWithDuration: 0.3f
                              delay: 0.0f
                            options: UIViewAnimationCurveEaseOut
                         animations: ^{
                             CGRect newFrame = self.errorContainerView.frame;
                             newFrame.origin.y = 0.0f;
                             self.errorContainerView.frame = newFrame;
                         }
                         completion:nil];
    }
    else
    {
        [UIView animateWithDuration: 0.3f
                              delay: 0.0f
                            options: UIViewAnimationCurveEaseIn
                         animations: ^{
                             CGRect newFrame = self.errorContainerView.frame;
                             newFrame.origin.y = 60.0f;
                             self.errorContainerView.frame = newFrame;
                         }
                         completion: ^(BOOL finished){
                             if (finished)
                             {
                                 self.errorContainerView.hidden = YES;
                             }
                         }];
    }
}






- (void) modalAccountContainerDismiss
{
    CGRect hiddenFrame = self.modalAccountContainer.view.frame;
    hiddenFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeight];
    [UIView animateWithDuration:0.5 animations:^{
        
        self.accountSettingsCoverView.alpha = 0.0;
        self.modalAccountContainer.view.frame = hiddenFrame;    
    } completion:^(BOOL finished) {
        
        self.accountSettingsCoverView.hidden = YES;
        
        [self.modalAccountContainer.view removeFromSuperview];
        self.modalAccountContainer = nil; 
    }];
}


- (void) accountSettingsLogout: (NSNotification*) notification
{
    [self.accountSettingsPopover dismissPopoverAnimated: NO];
    self.accountSettingsPopover = nil;
    [appDelegate logout];
}


#pragma mark - Popover Methods

- (void) hideAutocompletePopover
{
    
    if (!self.accountSettingsPopover)
        return;
    
    [self.accountSettingsPopover dismissPopoverAnimated: YES];
}


- (void) popoverControllerDidDismissPopover: (UIPopoverController *) popoverController
{
    if (popoverController == self.accountSettingsPopover)
    {
        
        self.accountSettingsPopover = nil;
    }
}


#pragma mark - Message Popups (form Bottom)

- (void) presentSuccessNotificationWithMessage : (NSString*) message andType:(NotificationMessageType)type
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

- (UINavigationController*) showingViewController
{
    return self.containerViewController.currentViewController;
}

-(NSArray*)tabs
{
    return self.tabsView.subviews;
}

@end
