//
//  SYNTopBarViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 20/02/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNMasterViewController.h"
#import "AppConstants.h"
#import "SYNActivityPopoverViewController.h"
#import "SYNSideNavigationViewController.h"
#import "SYNContainerViewController.h"
#import "UIFont+SYNFont.h"
#import "SYNSoundPlayer.h"
#import "SYNAutocompletePopoverBackgroundView.h"
#import "SYNContainerViewController.h"
#import "SYNBackButtonControl.h"

#import "SYNVideoViewerViewController.h"
#import "SYNAccountSettingsMainTableViewController.h"
#import "SYNCategoryChooserViewController.h"
#import "SYNRefreshButton.h"
#import "SYNSearchBoxViewController.h"
#import "SYNDeviceManager.h"
#import "SYNExistingChannelsViewController.h"
#import "SYNDeviceManager.h"

#import <QuartzCore/QuartzCore.h>

#define kMovableViewOffX -58
#define kMovableViewReloadButtonX 70
#define kMovableViewReloadButtonXIPhone 63

#define kSearchBoxShrinkFactor 136.0


typedef void(^AnimationCompletionBlock)(BOOL finished);

@interface SYNMasterViewController ()

@property (nonatomic, strong) SYNBackButtonControl* backButtonControl;

@property (nonatomic, strong) IBOutlet UIButton* closeSearchButton;
@property (nonatomic, strong) IBOutlet UIButton* addToChannelButton;
@property (nonatomic, strong) IBOutlet UIView* overlayView;
@property (nonatomic, strong) IBOutlet UIView* navigatioContainerView;
@property (nonatomic, strong) IBOutlet UIView* dotsView;
@property (nonatomic, strong) IBOutlet UILabel* pageTitleLabel;
@property (nonatomic, strong) IBOutlet UIButton* searchButton;
@property (nonatomic, strong) IBOutlet UIView* movableButtonsContainer;

@property (nonatomic, strong) UIPopoverController* accountSettingsPopover;
@property (nonatomic, strong) IBOutlet UIButton* sideNavigationButton;
@property (nonatomic) CGFloat sideNavigationOriginCenterX;
@property (nonatomic) BOOL buttonLocked;
@property (nonatomic) BOOL isDragging;


@property (nonatomic, strong) SYNRefreshButton* refreshButton;

@property (nonatomic) BOOL showingBackButton;


@property (nonatomic, strong) SYNExistingChannelsViewController* existingChannelsController;


@property (nonatomic) CGRect addToChannelFrame;

@property (nonatomic, strong) SYNSearchBoxViewController* searchBoxController;


@property (nonatomic, strong) SYNVideoViewerViewController *videoViewerViewController;
@property (nonatomic, strong) SYNCategoryChooserViewController *categoryChooserViewController;

@property (nonatomic, strong) SYNSideNavigationViewController* sideNavigationViewController;



@end

@implementation SYNMasterViewController

@synthesize containerViewController;
@synthesize pageTitleLabel;
@synthesize showingBackButton;
@synthesize addToChannelFrame;
@synthesize sideNavigationOriginCenterX;
@synthesize isDragging, buttonLocked;

#pragma mark - Initialise

-(id)initWithContainerViewController:(SYNContainerViewController*)root
{
    if ((self = [super initWithNibName: @"SYNMasterViewController" bundle: nil]))
    {
        appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        self.containerViewController = root;
        [self addChildViewController:root];

        
        // == Side Navigation == //
        
        self.sideNavigationViewController = [[SYNSideNavigationViewController alloc] init];
        CGRect sideNavigationFrame = self.sideNavigationViewController.view.frame;
        sideNavigationFrame.origin.x = 1024.0;
        NSLog(@"Current width: %f", sideNavigationFrame.origin.x);
        sideNavigationFrame.origin.y = 74.0;
        self.sideNavigationViewController.view.frame = sideNavigationFrame;
        self.sideNavigationViewController.user = appDelegate.currentUser;
        self.sideNavigationViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        
        
//        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sideNavigationPanned:)];
//        [self.sideNavigationViewController.view addGestureRecognizer:panGesture];
        
        
        // == Search Box == //
    
        
        self.searchBoxController = [[SYNSearchBoxViewController alloc] init];
        CGRect autocompleteControllerFrame = self.searchBoxController.view.frame;
        autocompleteControllerFrame.origin.x = 10.0;
        autocompleteControllerFrame.origin.y = 10.0;
        self.searchBoxController.view.frame = autocompleteControllerFrame;
        
        
        
        
        
        
        
    }
    return self;
}




#pragma mark - Life Cycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // == Refresh button == //
    
    CGRect movableViewFrame = self.movableButtonsContainer.frame;
    movableViewFrame.origin.x = kMovableViewOffX;
    self.movableButtonsContainer.frame = movableViewFrame;
    
    self.refreshButton = [SYNRefreshButton refreshButton];
    [self.refreshButton addTarget:self action:@selector(refreshButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    CGRect refreshButtonFrame = self.refreshButton.frame;
    refreshButtonFrame.origin.x = [[SYNDeviceManager sharedInstance] isIPad]?kMovableViewReloadButtonX:kMovableViewReloadButtonXIPhone;
    self.refreshButton.frame = refreshButtonFrame;
    [self.movableButtonsContainer addSubview:self.refreshButton];
    
    
    // == Fade in from splash screen (not in AppDelegate so that the Orientation is known) == //
    
    UIImageView *splashView;
    if([[SYNDeviceManager sharedInstance] isIPhone])
    {
        if([[SYNDeviceManager sharedInstance] currentScreenHeight]>480.0f)
        {
            splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Default-568h"]];
        }
        else
        {
            splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Default"]];
        }
        splashView.center = CGPointMake(splashView.center.x, splashView.center.y-20.0f);

    }
    else
    {
        splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"Default"]];
    }
    
	[self.view addSubview: splashView];
    
    [UIView animateWithDuration: kSplashAnimationDuration
                          delay: kSplashViewDuration
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         splashView.alpha = 0.0f;
                     } completion: ^(BOOL finished) {
                         splashView.alpha = 0.0f;
                         [splashView removeFromSuperview];
                     }];
    
    self.navigatioContainerView.userInteractionEnabled = YES;
    
    
    
    // == Add the Root Controller which will contain all others (Tabs in our case) == //

    [self.containerView addSubview:containerViewController.view];
    //self.containerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    self.existingChannelsController = [[SYNExistingChannelsViewController alloc] initWithViewId:kExistingChannelsViewId];
    
    
    
    
    // == Back Button == //
    
    self.backButtonControl = [SYNBackButtonControl backButton];
    [self.movableButtonsContainer addSubview:self.backButtonControl];
    self.backButtonControl.alpha = 0.0;
    
    self.movableButtonsContainer.userInteractionEnabled = YES;
    
    
    
    self.pageTitleLabel.font = [UIFont boldRockpackFontOfSize:30];
    self.pageTitleLabel.textColor = [UIColor colorWithRed:(40.0/255.0)
                                                    green:(45.0/255.0)
                                                     blue:(51.0/255.0)
                                                    alpha:(1.0)];
    
    
    // == Add to Channel Button == //
    
    originalAddButtonX = self.addToChannelButton.frame.origin.x;
    addToChannelFrame = self.addToChannelButton.frame;
    
    
    // == Set up Dots View == //
    
    self.dotsView.backgroundColor = [UIColor clearColor];
    int numberOfDots = [self.containerViewController.childViewControllers count];
    UIImage* dotImage = [UIImage imageNamed:@"NavigationDot"];
    CGPoint center = self.dotsView.center;
    CGRect newFrame = self.dotsView.frame;
    newFrame.size.width = (2*numberOfDots - 1) * dotImage.size.width;
    newFrame.origin.x = round(center.x - newFrame.size.width/2.0f);
    self.dotsView.frame = newFrame;
    CGFloat dotSpacing = 2*dotImage.size.width;
    for(int i = 0; i < numberOfDots; i++)
    {
        UIImageView* dotImageView = [[UIImageView alloc] initWithImage:dotImage];
        CGRect dotImageViewFrame = dotImageView.frame;
        dotImageViewFrame.origin.x = i * dotSpacing;
        dotImageView.frame = dotImageViewFrame;
        [self.dotsView addSubview:dotImageView];
        
        UITapGestureRecognizer* tapGestureRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dotTapped:)];
        [dotImageView addGestureRecognizer:tapGestureRecogniser];
     }
    
    [self pageChanged:self.containerViewController.page];
    
    
    // == Set Up Notifications == //
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonRequested:) name:kNoteBackButtonShow object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backButtonRequested:) name:kNoteBackButtonHide object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollerPageChanged:) name:kScrollerPageChanged object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigateToPage:) name:kNavigateToPage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchTyped:) name:kSearchTyped object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAccountSettingsPopover) name:kAccountSettingsPressed object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountSettingsLogout) name:kAccountSettingsLogout object:nil];
    
    [self.containerViewController.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    
    [self.navigatioContainerView addSubview:self.sideNavigationViewController.view];
    
    
}

-(NSUInteger)supportedInterfaceOrientations
{
    if([[SYNDeviceManager sharedInstance]isIPhone])
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    else
    {
        return UIInterfaceOrientationMaskAll;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // [self.view addSubview:self.existingChannelsController.view];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    originalAddButtonX = self.addToChannelButton.frame.origin.x;
}

-(void)refreshButtonPressed
{
    [self.refreshButton startRefreshCycle];
    
    [self.containerViewController.showingViewController refresh];
}

-(void)scrollerPageChanged:(NSNotification*)notification
{
    NSNumber* pageNumber = [[notification userInfo] objectForKey:kCurrentPage];
    if(!pageNumber)
        return;
    
    [self pageChanged:[pageNumber integerValue]];
    
    
}

-(void)pageChanged:(NSInteger)pageNumber
{
    int totalDots = self.dotsView.subviews.count;
    UIImageView* dotImageView;
    for (int i = 0; i < totalDots; i++)
    {
        dotImageView = (UIImageView*)self.dotsView.subviews[i];
        if (i == pageNumber) {
            dotImageView.image = [UIImage imageNamed:@"NavigationDotCurrent"];
            continue;
        }
        
        dotImageView.image = [UIImage imageNamed:@"NavigationDot"];
        
    }
    
    originalAddButtonX = self.addToChannelButton.frame.origin.x;
    
    self.pageTitleLabel.text = [self.containerViewController.showingViewController.title uppercaseString];
    
    
    
    if(self.sideNavigationViewController.state == SideNavigationStateFull)
    {
        [self.sideNavigationViewController deselectAllCells];
        [self showSideNavigation];
    }
    else
    {
        NSString* controllerTitle = self.containerViewController.showingViewController.title;
        
        [self.sideNavigationViewController setSelectedCellByPageName:controllerTitle];
    }
}




-(IBAction)addToChannelPressed:(id)sender
{
    
    
    
}


#pragma mark - Navigation Panel Methods

-(IBAction)showAndHideSideNavigation:(UIButton*)sender
{
    if(buttonLocked)
        return;
    
    if(self.sideNavigationViewController.state == SideNavigationStateFull
       || self.sideNavigationViewController.state == SideNavigationStateHalf) {
        [self hideSideNavigation];
        sender.highlighted = NO;
    }

    else {
        [self showSideNavigation];
        sender.highlighted = YES;
    }
        
}

- (void) showSideNavigation
{
    
    
    NSString* controllerTitle = self.containerViewController.showingViewController.title;
    
    [self.sideNavigationViewController setSelectedCellByPageName:controllerTitle];
    
    
    [[SYNSoundPlayer sharedInstance] playSoundByName:kSoundNewSlideIn];
    
    
    [UIView animateWithDuration: kRockieTalkieAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         
                         CGRect sideNavigationFrame = self.sideNavigationViewController.view.frame;
                         
                         sideNavigationFrame.origin.x = 1024.0 - 192.0;
                         self.sideNavigationViewController.view.frame =  sideNavigationFrame;
                         
                     } completion: ^(BOOL finished) {
                         
                         self.sideNavigationViewController.state = SideNavigationStateHalf;
                         
                     }];
    
    
}



-(void)sideNavigationSwiped
{
    [self hideSideNavigation];
}
-(void)sideNavigationPanned:(UIPanGestureRecognizer*)recogniser
{
    CGFloat translationX = [recogniser translationInView:self.sideNavigationViewController.view].x;
    
    if(recogniser.state == UIGestureRecognizerStateBegan)
    {
        
        isDragging = YES;
        sideNavigationOriginCenterX = self.sideNavigationViewController.view.center.x;
        
        
    }
    CGFloat newOriginX = sideNavigationOriginCenterX + translationX;
    if(newOriginX < sideNavigationOriginCenterX)
    {
        newOriginX = sideNavigationOriginCenterX;
    }
    
    self.sideNavigationViewController.view.center = CGPointMake( newOriginX ,
                                                                self.sideNavigationViewController.view.center.y);
    
    
    if(recogniser.state == UIGestureRecognizerStateEnded)
    {
        CGFloat border;
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
        {
            border = [[UIScreen mainScreen] bounds].size.height;
        }
        else
        {
            border = [[UIScreen mainScreen] bounds].size.width;
        }
        
        if(border - newOriginX < 20.0)
        {
            [self hideSideNavigation];
        }
        else
        {
            [self showSideNavigation];
        }
        isDragging = NO;
    }
    
}


- (void) hideSideNavigation
{

    
    [[SYNSoundPlayer sharedInstance] playSoundByName: kSoundNewSlideOut];
    
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^ {
                         
                         CGRect sideNavigationFrame = self.sideNavigationViewController.view.frame;
                         sideNavigationFrame.origin.x = 1024;
                         self.sideNavigationViewController.view.frame =  sideNavigationFrame;
                         
                     } completion: ^(BOOL finished) {
                         
                         [self.sideNavigationViewController reset];
                         [self.sideNavigationViewController deselectAllCells];
                         self.sideNavigationViewController.state = SideNavigationStateHidden;
                         
                     }];
}






#pragma mark - Video Overlay View

- (void) addVideoOverlayToViewController: (UIViewController *) originViewController
            withFetchedResultsController: (NSFetchedResultsController*) fetchedResultsController
                            andIndexPath: (NSIndexPath *) indexPath {
    
    // Remember the view controller that we came from
    self.originViewController = originViewController;
    
    
    
    self.videoViewerViewController = [[SYNVideoViewerViewController alloc] initWithFetchedResultsController: fetchedResultsController
                                                                                          selectedIndexPath: (NSIndexPath *) indexPath];
    self.videoViewerViewController.view.frame = self.overlayView.bounds;
    [self.overlayView addSubview:self.videoViewerViewController.view];
    
    self.videoViewerViewController.view.alpha = 0.0f;
    self.videoViewerViewController.overlayParent = self;
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
         self.videoViewerViewController.view.alpha = 1.0f;
     }
     completion: ^(BOOL finished)
     {
        self.overlayView.userInteractionEnabled = YES;
         
         
     }];
}

- (void) removeVideoOverlayController
{
    
    
    UIView* child = self.overlayView.subviews[0];
    
    
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         child.alpha = 0.0f;
                     } completion: ^(BOOL finished) {
                         self.overlayView.userInteractionEnabled = NO;
                         self.videoViewerViewController = nil;
                         [child removeFromSuperview];
                         
                     }];

}

- (void) addCategoryChooserOverlayToViewController: (UIViewController *) originViewController
{
    // Remember the view controller that we came from
    self.originViewController = originViewController;

    self.categoryChooserViewController = [[SYNCategoryChooserViewController alloc] init];
    
    [self.overlayView addSubview: self.categoryChooserViewController.view];
    [originViewController addChildViewController:self.categoryChooserViewController];
    
    self.categoryChooserViewController.view.alpha = 0.0f;
    self.categoryChooserViewController.overlayParent = self;
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         self.categoryChooserViewController.view.alpha = 1.0f;
                     } completion: ^(BOOL finished) {
                         self.overlayView.userInteractionEnabled = YES;
                     }];
}

- (void) removeCategoryChooserOverlayController
{
    
    UIView* child = self.overlayView.subviews[0];
    
    [UIView animateWithDuration: 0.25f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         child.alpha = 0.0f;
                     } completion: ^(BOOL finished) {
                         self.overlayView.userInteractionEnabled = NO;
                         self.videoViewerViewController = nil;
                         [child removeFromSuperview];
                         
                     }];

}


#pragma mark - Search Box Delegate Methods

-(IBAction)showSearchBoxField:(id)sender
{
    
    self.sideNavigationButton.hidden = YES;
    CGRect sboxFrame;
    if(showingBackButton)
    {
        sboxFrame = self.searchBoxController.view.frame;
        
        sboxFrame.origin.x = self.backButtonControl.frame.origin.x + self.backButtonControl.frame.size.width + 16.0;
        
        
    }
    else
    {
        
        sboxFrame.origin.x = 10.0;
    }
    
    sboxFrame.size.width = self.closeSearchButton.frame.origin.x - sboxFrame.origin.x - 8.0;
    sboxFrame.origin.y = 10.0;
    self.searchBoxController.view.frame = sboxFrame;
    
    [self.view addSubview:self.searchBoxController.view];
}

-(void)searchTyped:(NSNotification*)notification
{
    
    
    NSString* termString = [[notification userInfo] objectForKey:kSearchTerm];
    
    if(!termString)
        return;
    
    self.closeSearchButton.hidden = YES;
    self.sideNavigationButton.hidden = NO;
    
    [self.containerViewController showSearchViewControllerWithTerm:termString];
    
    
}

-(IBAction)cancelButtonPressed:(id)sender
{
    [self.searchBoxController clear];
    [self.searchBoxController.view removeFromSuperview];
    
    
    self.sideNavigationButton.hidden = NO;
    
    
}


#pragma mark - Notification Handlers



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        
        CGPoint newContentOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGFloat diff = fabsf(newContentOffset.x - self.containerViewController.currentPageOffset.x);
        diff = diff/[[SYNDeviceManager sharedInstance] currentScreenWidth];
        if (diff >1.0f)
        {
            diff = diff - truncf(diff);
        }
        SYNAbstractViewController* nextViewController = [self.containerViewController nextShowingViewController];
        
        if(nextViewController.needsAddButton && !self.containerViewController.showingViewController.needsAddButton)
        {
            self.addToChannelButton.alpha = diff;
        }
        else if(!nextViewController.needsAddButton && self.containerViewController.showingViewController.needsAddButton)
        {
            self.addToChannelButton.alpha = 1.0f - diff;
        }
        else
        {
            self.addToChannelButton.alpha = self.containerViewController.showingViewController.needsAddButton? 1.0f:0.0f; 
        }

    }
}

-(void)dotTapped:(UIGestureRecognizer*)recogniser
{
    
}

-(void)backButtonRequested:(NSNotification*)notification
{
    
    NSString* notificationName = [notification name];
    
    
    if([notificationName isEqualToString:kNoteBackButtonShow])
    {
        [self.backButtonControl addTarget:containerViewController action:@selector(popCurrentViewController:) forControlEvents:UIControlEventTouchUpInside];
        [self.backButtonControl setBackTitle:self.pageTitleLabel.text];
        if(self.searchBoxController.isOnScreen)
        {
            [UIView animateWithDuration:0.5 animations:^{
                CGRect sboxFrame = self.searchBoxController.view.frame;
                sboxFrame.origin.x = self.backButtonControl.frame.origin.x + self.backButtonControl.frame.size.width + 16.0;
                sboxFrame.size.width = self.closeSearchButton.frame.origin.x - sboxFrame.origin.x - 8.0;
                self.searchBoxController.view.frame = sboxFrame;
            }];
        }
        [self showBackButton:YES];
    }
    else
    {
        [self.backButtonControl removeTarget:containerViewController action:@selector(popCurrentViewController:) forControlEvents:UIControlEventTouchUpInside];
        if(self.searchBoxController.isOnScreen)
        {
            [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
                CGRect sboxFrame = self.searchBoxController.view.frame;
                sboxFrame.origin.x = 10.0;
                sboxFrame.size.width = self.closeSearchButton.frame.origin.x - sboxFrame.origin.x - 8.0;
                self.sideNavigationButton.hidden = YES;
                self.closeSearchButton.hidden = NO;
                self.searchBoxController.view.frame = sboxFrame;
            } completion:nil];
            
        }
        [self showBackButton:NO];
    }
}



-(void)navigateToPage:(NSNotification*)notification
{
    
    NSString* pageName = [[notification userInfo] objectForKey:@"pageName"];
    if(!pageName)
        return;
    
    
    [self.containerViewController navigateToPageByName:pageName];
    
    if(self.sideNavigationViewController.state != SideNavigationStateHidden)
        [self hideSideNavigation];
    
    
    
}

- (void) showBackButton: (BOOL) show
{
    CGRect targetFrame;
    CGFloat targetAlpha;
    
    if (show)
    {
        showingBackButton = YES;
        targetFrame = self.movableButtonsContainer.frame;
        targetFrame.origin.x = 8.0;
        targetAlpha = 1.0;
    }
    else
    {
        showingBackButton = NO;
        targetFrame = self.movableButtonsContainer.frame;
        targetFrame.origin.x = kMovableViewOffX;
        targetAlpha = 0.0;
    }
    
    [UIView animateWithDuration: 0.6f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^
                     {
                         self.movableButtonsContainer.frame = targetFrame;
                         self.backButtonControl.alpha = targetAlpha;
                         self.pageTitleLabel.alpha = !targetAlpha;
                         self.dotsView.alpha = !targetAlpha;
                         self.refreshButton.alpha = !targetAlpha;
                     }
                     completion: ^(BOOL finished)
                     {
                     }];

}



#pragma mark - Helper Methods

-(void)showAddButton
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         
                         self.addToChannelButton.frame = self.addToChannelFrame;
        
                   } completion:^(BOOL finished) {
                       
                       
                
                   }];
    
}

-(void)hideAddButton
{
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         
                         self.addToChannelButton.alpha = 0.0;
                         
                     } completion:^(BOOL finished) {
                         
                         [self moveAddButtonOutOfWay];
                         
                     }];
    
}

-(void)moveAddButtonOutOfWay
{
    
    self.addToChannelButton.frame = CGRectMake(self.view.frame.size.width + 2.0,
                                               addToChannelFrame.origin.y,
                                               addToChannelFrame.size.width,
                                               addToChannelFrame.size.height);
}


#pragma mark - Account Settings

- (void) accountSettingsLogout: (NSNotification*) notification
{
    [self.accountSettingsPopover dismissPopoverAnimated: NO];
    self.accountSettingsPopover = nil;
    [appDelegate logout];
}


- (void) showAccountSettingsPopover
{
    if(self.accountSettingsPopover)
        return;
    
    SYNAccountSettingsMainTableViewController* mainTable = [[SYNAccountSettingsMainTableViewController alloc] init];
    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController: mainTable];
    
    self.accountSettingsPopover = [[UIPopoverController alloc] initWithContentViewController: navigationController];
    self.accountSettingsPopover.popoverContentSize = CGSizeMake(380, 576);
    self.accountSettingsPopover.delegate = self;
    
    self.accountSettingsPopover.popoverBackgroundViewClass = [SYNAccountSettingsPopoverBackgroundView class];
    
    CGRect rect = CGRectMake([[SYNDeviceManager sharedInstance] currentScreenWidth] * 0.5,
                             [[SYNDeviceManager sharedInstance] currentScreenHeight] * 0.5, 1, 1);
    
    [self.accountSettingsPopover presentPopoverFromRect: rect
                                                 inView: self.view
                               permittedArrowDirections: 0
                                               animated: YES];
}


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

@end
