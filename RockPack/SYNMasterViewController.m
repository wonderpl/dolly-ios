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
#import "SYNCarouselVideoPlayerViewController.h"
#import "SYNContainerViewController.h"
#import "SYNOnBoardingViewController.h"

#import "Genre.h"
#import "SubGenre.h"

@import QuartzCore;


#define kBackgroundOverlayAlpha 0.5f


typedef void(^AnimationCompletionBlock)(BOOL finished);

@interface SYNMasterViewController ()
{
    
}

@property (nonatomic) BOOL searchIsInProgress;
@property (nonatomic) BOOL showingBackButton;

@property (nonatomic, strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) SYNContainerViewController* containerViewController;
@property (nonatomic, strong) SYNNetworkMessageView* networkMessageView;
@property (nonatomic, strong) SYNVideoViewerViewController *videoViewerViewController;

@property (nonatomic, weak) UIViewController *overlayController; // keep it weak so that the overlay gets deallocated as soon as it dissapears from screen
@property (nonatomic, strong) UIView* backgroundOverlayView; // darken the screen

@property (nonatomic) CGRect overlayControllerFrame;





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
    
    self.closeSearchButton.hidden = YES;

    
    // == Set Up Notifications == //
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelSuccessfullySaved:) name:kNoteChannelSaved object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAccountSettingsPopover) name:kAccountSettingsPressed object:nil];
    
    // add background view //
    
    self.backgroundOverlayView = [[UIView alloc] initWithFrame:CGRectZero];
    self.backgroundOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundOverlayView.backgroundColor = [UIColor darkGrayColor];
    
    // load basic data like the Genres
    [self loadBasicDataWithComplete:^(BOOL success) {
        
        if(success) // Genres have loaded from the server
        {
            if(!self.hasCreatedPopularGenre) // we have no POPULAR Genre
            {
                [self createPopularGenre]; // create one
                
            }
        }
        
        [self addChildViewController:self.containerViewController];
        
        // set the view programmatically, this will call the viewDidLoad of the container through its custom setter
    
        self.containerViewController.view = self.containerView;
        
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey: kUserDefaultsSeenOnBoarding]) // IS first install
        {
            
            SYNOnBoardingViewController* onBoardingViewController = [[SYNOnBoardingViewController alloc] init];
            [self addChildViewController:onBoardingViewController];
            
            onBoardingViewController.view.frame = [[SYNDeviceManager sharedInstance] currentScreenRect];
            
            // [self.view addSubview:onBoardingViewController.view];
            
            // [[NSUserDefaults standardUserDefaults] setBool: YES forKey: kUserDefaultsSeenOnBoarding];
            
        }
        
    }];
    
}

- (void)loadBasicDataWithComplete:(void(^)(BOOL))CompleteBlock
{
    [appDelegate.networkEngine updateCategoriesOnCompletion: ^(NSDictionary* dictionary){
        
        [appDelegate.mainRegistry performInBackground:^BOOL(NSManagedObjectContext *backgroundContext) {
            
            return [appDelegate.mainRegistry registerCategoriesFromDictionary: dictionary];
            
        } completionBlock:^(BOOL success) {
            
            CompleteBlock(success);
            
        }];
        
        
    } onError:^(NSError* error) {
        
        CompleteBlock(NO);
        
    }];
}

#pragma mark - Popular Genre

-(BOOL)hasCreatedPopularGenre
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = [NSEntityDescription entityForName: kSubGenre
                                                inManagedObjectContext: appDelegate.mainManagedObjectContext];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name == %@", kPopularGenreName];
    
    
    NSError* error;
    
    NSArray* fetchedArray = [appDelegate.mainManagedObjectContext executeFetchRequest: fetchRequest
                                                                                error: &error];
    
    return (BOOL)(fetchedArray.count > 0);
}



-(BOOL)createPopularGenre
{
    
    // Create Genre
    Genre* popularGenre = [Genre insertInManagedObjectContext: appDelegate.mainManagedObjectContext];
    popularGenre.uniqueId = [NSString stringWithString:kPopularGenreUniqueId];
    popularGenre.name = [NSString stringWithString:kPopularGenreName];
    popularGenre.priority = @(100000);
    
    // Create SubGenre
    SubGenre* popularSubGenre = [SubGenre insertInManagedObjectContext:appDelegate.mainManagedObjectContext];
    popularSubGenre.uniqueId = [NSString stringWithString:kPopularGenreUniqueId];
    popularSubGenre.name = [NSString stringWithString:kPopularGenreName];
    popularSubGenre.priority = @(100000);
    
    // NOTE: Since SubGenres are only displayed, the POPULAR Genre needs to have one SubGenre also called POPULAR to display in the list
    [popularGenre.subgenresSet addObject:popularSubGenre];
    
    NSError* error;
    return ([appDelegate.mainManagedObjectContext save:&error]);
}



// temporary
-(void)hideOrShowNetworkMessages:(NSNotification*)notifcation
{
    
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
    
    self.overlayController.view.frame = startFrame;
    
    
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
    
    if (self.videoViewerViewController)  // Prevent presenting two video players.
        return;
    
    
	UIViewController *viewController = [SYNCarouselVideoPlayerViewController viewControllerWithVideoInstances:videoInstanceArray selectedIndex:selectedIndex];
    
	[self presentViewController:viewController animated:YES completion:nil];
	

}


- (void) removeVideoOverlayController
{

    [self dismissViewControllerAnimated:YES completion:^{
        self.videoViewerViewController = nil;
    }];

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
        
        [self presentNotificationWithMessage:message andType:NotificationMessageTypeError];
    }
    
    DebugLog(@"Network %@Reachable", [self.reachability currentReachabilityStatus] == NotReachable ? @"NOT " : @"");
}


- (void) channelSuccessfullySaved: (NSNotification*) note
{
    NSString* message = IS_IPHONE ? NSLocalizedString(@"PACK SAVED", nil) : NSLocalizedString(@"YOUR PACK HAS BEEN SAVED", nil);
    
    [self presentNotificationWithMessage:message andType:NotificationMessageTypeSuccess];
}



- (void) accountSettingsLogout: (NSNotification*) notification
{
    
    [appDelegate logout];
}


#pragma mark - Message Popups (form Bottom)

- (void) presentNotificationWithMessage : (NSString*) message andType:(NotificationMessageType)type
{
    
    if(self.networkMessageView)
        return;
    
    self.networkMessageView = [[SYNNetworkMessageView alloc] initWithMessageType:type];
    
    
    [self.networkMessageView setText: message];
    
    [self.view addSubview: self.networkMessageView];
    
    [UIView animateWithDuration: 0.3f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         CGRect newFrame = self.networkMessageView.frame;
                         newFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeight] - newFrame.size.height;
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
    
    
    if(self.overlayController)
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

-(NSArray*)tabs
{
    return self.tabsView.subviews;
}

#pragma mark - On Boarding

-(void)addOnBoarding
{
    
}
-(void)removeOnBoarding
{
    
}

#pragma mark - Display Notifications Number

-(void)displayNotificationsLoaded:(NSInteger)notificationsCount
{
    
}

@end
