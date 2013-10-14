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

@interface SYNContainerViewController () <UIPopoverControllerDelegate,
UITextViewDelegate>

@property (nonatomic) BOOL didNotSwipeMessageInbox;
@property (nonatomic, readonly) CGFloat currentScreenOffset;
@property (nonatomic, strong) UIPopoverController *actionButtonPopover;
@property (nonatomic, weak) SYNAppDelegate *appDelegate;

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


- (void) dealloc
{
    // TODO: nil delegates for tab view
}

#pragma mark - UIViewController Containment

- (void) addChildViewController: (UIViewController *) childController
{
    [self.showingViewController willMoveToParentViewController:nil]; // remove the current view controller if there is one
    
    [childController willMoveToParentViewController: self];
    
    [super addChildViewController: childController];
    
    childController.view.frame = self.view.frame;
    
    [[self view] addSubview:childController.view];
    
    [childController didMoveToParentViewController: self];
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





#pragma mark - Getters/Setters

- (SYNAbstractViewController *) showingViewController
{
    return self.childViewControllers.count > 0 ? (SYNAbstractViewController*)self.childViewControllers[0] : nil;
}



- (NSString *) description
{
    return NSStringFromClass([self class]);
}





@end
