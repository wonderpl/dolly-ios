//
//  SYNBottomTabViewController.m
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "AudioToolbox/AudioToolbox.h"
#import "ChannelOwner.h"
#import "GAI.h"
#import "MKNetworkEngine.h"
#import "SYNActivityPopoverViewController.h"
#import "SYNChannelDetailViewController.h"
#import "SYNChannelsRootViewController.h"
#import "SYNContainerViewController.h"
#import "SYNDeviceManager.h"
#import "SYNFeedRootViewController.h"
#import "SYNGenreTabViewController.h"
#import "SYNMasterViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNProfileRootViewController.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>


#define VIEW_CONTROLLER_TRANSITION_DURATION 0.4

@interface SYNContainerViewController () <UIPopoverControllerDelegate, UITextViewDelegate>

@property (nonatomic) BOOL didNotSwipeMessageInbox;
@property (nonatomic, readonly) CGFloat currentScreenOffset;
@property (nonatomic, strong) UIPopoverController *actionButtonPopover;
@property (nonatomic, weak) SYNAppDelegate *appDelegate;

@property (nonatomic, strong) SYNAbstractViewController *currentViewController;

@property (nonatomic, strong) NSArray* viewControllers;

@end


@implementation SYNContainerViewController

// Initialise all the elements common to all 4 tabs
#pragma mark - View lifecycle

-(void)loadView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view = [[UIView alloc] initWithFrame:[[SYNDeviceManager sharedInstance] currentScreenRect]];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    
    // == Feed Page == //
    
    SYNFeedRootViewController *feedRootViewController = [[SYNFeedRootViewController alloc] initWithViewId: kFeedViewId];
    
    // == Channels Page == //
    
    SYNChannelsRootViewController *channelsRootViewController = [[SYNChannelsRootViewController alloc] initWithViewId: kChannelsViewId];
    
    if (IS_IPAD)
    {
        channelsRootViewController.tabViewController = [[SYNGenreTabViewController alloc] initWithHomeButton: @"POPULAR"];
        [channelsRootViewController addChildViewController: channelsRootViewController.tabViewController];
    }
    else
    {
        channelsRootViewController.enableCategoryTable = YES;
    }
    
    // == Profile Page == //
    
    SYNProfileRootViewController *profileViewController = [[SYNProfileRootViewController alloc] initWithViewId: kProfileViewId];
    
    if (!IS_IPAD)
    {
        profileViewController.hideUserProfile = YES;
    }
    
    
    profileViewController.user = self.appDelegate.currentUser;
    
    // == Hold the vc locally
    
    self.viewControllers = @[feedRootViewController, channelsRootViewController, profileViewController];
    
    
    // == Set the first vc
    
    [self addChildViewController:self.viewControllers[0]];
    

    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}


- (void) dealloc
{
    // TODO: nil delegates for tab view
}

#pragma mark - UIViewController Containment

- (void) addChildViewController: (UIViewController *) newViewController
{
    
    __weak SYNAbstractViewController* toViewController = (SYNAbstractViewController*)newViewController;
    __weak SYNAbstractViewController* fromViewController = self.currentViewController;
    
    [toViewController willMoveToParentViewController:nil]; // remove the current view controller if there is one
    
    [super addChildViewController: toViewController];
    
    
    [[self view] addSubview:toViewController.view];
    
    // == Define the completion block == //
    
    void(^CompleteTransitionBlock)(BOOL) = ^(BOOL finished) {
        
        [fromViewController.view removeFromSuperview];
        
        [fromViewController removeFromParentViewController];
        
        [toViewController didMoveToParentViewController: self];
        
        self.currentViewController = toViewController;
    };
    
    // == Do the Transition selectively == //
    
    if(fromViewController) // if not from first time
    {
        
        toViewController.view.frame = CGRectZero;
        
        [self transitionFromViewController:fromViewController
                          toViewController:toViewController
                                  duration:VIEW_CONTROLLER_TRANSITION_DURATION
                                   options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                       
                                       
                                       toViewController.view.frame = self.view.frame;
                                       fromViewController.view.frame = CGRectZero;
                                       
                                   } completion:CompleteTransitionBlock];
    }
    else
    {
        toViewController.view.frame = self.view.frame;
        CompleteTransitionBlock(YES);
    }
    
    
    // == Do the transition == //
    
    
    
    
}









- (void) swipedTo: (UISwipeGestureRecognizerDirection) direction
{
    // TODO: swipe to change view
}



#pragma mark - maintaion orientation

- (void) refreshView
{
    
    // TODO: Notify with kScrollerPageChanged
}





#pragma mark - Notification Methods


- (void) navigateToPageByName: (NSString *) pageName
{
    int page = 0;
    
    for (SYNAbstractViewController *nvc in self.childViewControllers)
    {
        if ([pageName isEqualToString: nvc.title])
        {
            //TODO: Perform the navigation
            break;
        }
        
        page++;
    }
}

-(SYNAbstractViewController*)viewControllerByPageName: (NSString *) pageName
{
    SYNAbstractViewController* child;
    for (child in self.viewControllers)
    {
        if ([pageName isEqualToString: child.title])
            break;
           
    }
    return child;
}

#pragma mark - UIScrollViewDelegate

// TODO: notify with kScrollerPageChanged AND [lastSelectedViewController viewDidScrollToBack]; AND [self.showingViewController viewDidScrollToFront];







- (NSString *) description
{
    return NSStringFromClass([self class]);
}





@end
