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
#import "SYNCommentingViewController.h"
#import "SYNOnBoardingViewController.h"
#import "SYNGenreColorManager.h"
#import "Genre.h"
#import "SubGenre.h"
#import "SYNLoginManager.h"

@import QuartzCore;


#define kBackgroundOverlayAlpha 0.5f

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

@property (nonatomic, strong) UIImageView* arrowForOverlayImageView;



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
    
    // add background view //
    
    self.backgroundOverlayView = [[UIView alloc] initWithFrame:CGRectZero];
    self.backgroundOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundOverlayView.backgroundColor = [UIColor darkGrayColor];
    
    self.arrowForOverlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ArrowCommentBox"]];
    
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
      
        //Check if the user registed and then show onboarding screen
        if ([SYNLoginManager sharedManager].registrationCheck == YES) {
        
            
            SYNOnBoardingViewController* onBoardingViewController = [[SYNOnBoardingViewController alloc] init];
            [self addChildViewController:onBoardingViewController];
            
            onBoardingViewController.view.frame = [[SYNDeviceManager sharedInstance] currentScreenRect];
            
            [self.view addSubview:onBoardingViewController.view];
            [SYNLoginManager sharedManager].registrationCheck = NO;
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
            
            [[SYNGenreColorManager sharedInstance] registerGenreColorsFromCoreData];
            
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
    [self addOverlayController:overlayViewController animated:animated pointingToRect:CGRectZero];
}
- (void) addOverlayController:(UIViewController<SYNPopoverable>*)overlayViewController
                     animated:(BOOL)animated
               pointingToRect:(CGRect)rectToPoint
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
        
        if(CGRectEqualToRect(rectToPoint, CGRectZero)) // CGZero is passed to diaplay in the middle of the screen
        {
            endFrame.origin.x = [[SYNDeviceManager sharedInstance] currentScreenMiddlePoint].x - endFrame.size.width * 0.5f;
            endFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenMiddlePoint].y - endFrame.size.height * 0.5f;
        }
        else // make it point to a specific part of the screen
        {
            
            endFrame.origin.x = rectToPoint.origin.x - endFrame.size.width - 8.0f;
            endFrame.origin.y = rectToPoint.origin.y - MIN(endFrame.size.height - 50.0f, rectToPoint.origin.y - 20.0f);
            
            self.arrowForOverlayImageView.transform = CGAffineTransformMakeScale(-1.0f, 1.0f);
            
            CGRect arrowFrame = self.arrowForOverlayImageView.frame;
            arrowFrame.origin.x = rectToPoint.origin.x - arrowFrame.size.width + 4.0f;
            arrowFrame.origin.y = rectToPoint.origin.y;
            self.arrowForOverlayImageView.frame = arrowFrame;
            
            self.arrowForOverlayImageView.alpha = 0.0f;
            [self.view addSubview:self.arrowForOverlayImageView];
            
        }
        
        
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
            self.arrowForOverlayImageView.alpha = 1.0f;
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
            
            wself.arrowForOverlayImageView.alpha = 0.0f;
            
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
        
        if(IS_IPAD)
        {
            [wself.arrowForOverlayImageView removeFromSuperview];
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
    
    
    if(IS_IPAD && self.overlayController)
    {
        CGRect currentOverlayFrame = self.overlayController.view.frame;
        if(![self.overlayController isKindOfClass:[SYNCommentingViewController class]])
        {
            
            currentOverlayFrame.size = self.overlayControllerFrame.size;
            currentOverlayFrame.origin.x = [[SYNDeviceManager sharedInstance] currentScreenWidth] * 0.5f - currentOverlayFrame.size.width * 0.5;
            currentOverlayFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeight] * 0.5f - currentOverlayFrame.size.height * 0.5;
            
        }
        else
        {
            currentOverlayFrame.origin.x += UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? -120.0f : 120.0f;
            
            CGRect arrowRect = self.arrowForOverlayImageView.frame;
            arrowRect.origin.x += UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? -120.0f : 100.0f;
            
            self.arrowForOverlayImageView.frame = arrowRect;
        }
        
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
