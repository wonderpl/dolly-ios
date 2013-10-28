//
//  SYNContainerViewController.m
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
#import "SYNMoodRootViewController.h"
#import "SYNGenreTabViewController.h"
#import "SYNMasterViewController.h"
#import "SYNActivityViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNDiscoverViewController.h"
#import "SYNFriendsViewController.h"
#import "SYNProfileRootViewController.h"
#import "SYNTrackableFrameView.h"
#import "UIFont+SYNFont.h"
#import <QuartzCore/QuartzCore.h>


#define VIEW_CONTROLLER_TRANSITION_DURATION 0.4

@interface SYNContainerViewController () <UIPopoverControllerDelegate, UITextViewDelegate, UIScrollViewDelegate>

@property (nonatomic) BOOL didNotSwipeMessageInbox;
@property (nonatomic, readonly) CGFloat currentScreenOffset;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) UINavigationController *currentViewController;
@property (nonatomic, strong) UIPopoverController *actionButtonPopover;
@property (nonatomic, weak) SYNAppDelegate *appDelegate;
@property (nonatomic, weak) SYNProfileRootViewController *tmpProfileRootView;

@end


@implementation SYNContainerViewController

// Initialise all the elements common to all 4 tabs
#pragma mark - View lifecycle

/* Uncomment to test the frame setting from outside this class
-(void)loadView
{
    self.view = [[SYNTrackableFrameView alloc] initWithFrame:CGRectZero];
}
*/



- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    
    
    // == Feed Page == //
    
    SYNFeedRootViewController *feedRootViewController = [[SYNFeedRootViewController alloc] initWithViewId: kFeedViewId];
    
    UINavigationController *navFeedViewController = [[UINavigationController alloc] initWithRootViewController:feedRootViewController];

    
    // == Channels Page == //
    
    SYNChannelsRootViewController *channelsRootViewController = [[SYNChannelsRootViewController alloc] initWithViewId: kChannelsViewId];
    
    UINavigationController *navChannelsRootViewController = [[UINavigationController alloc] initWithRootViewController:channelsRootViewController];

    
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
    
    UINavigationController *navProfileViewController = [[UINavigationController alloc] initWithRootViewController: profileViewController];
    
    // profileViewController.moveTabDelegate = self;
    
    if (!IS_IPAD)
    {
        profileViewController.hideUserProfile = YES;
    }
    
    profileViewController.channelOwner = self.appDelegate.currentUser;
    

    
    // == Friends Page == //
    
    //SYNFriendsViewController* friendsViewController = [[SYNFriendsViewController alloc] initWithViewId: kFriendsViewId];
    
    // == Activity Page == //
    SYNActivityViewController *activityViewController = [[SYNActivityViewController alloc] initWithViewId: kActivityViewId];
    profileViewController.channelOwner = self.appDelegate.currentUser;
    
    UINavigationController *navActivityViewController = [[UINavigationController alloc] initWithRootViewController:activityViewController];

    // == Discovery (Search) Page == //
    SYNDiscoverViewController *searchViewController = [[SYNDiscoverViewController alloc] initWithViewId: kDiscoverViewId];
    
    UINavigationController *navSearchViewController = [[UINavigationController alloc] initWithRootViewController:searchViewController];

    // == Feed Page == //
    
    SYNMoodRootViewController *moodRootViewController = [[SYNMoodRootViewController alloc] initWithViewId: kMoodViewId];
    
    
    UINavigationController *navMoodRootViewController = [[UINavigationController alloc] initWithRootViewController:moodRootViewController];
    
    // == Hold the vc locally
    self.viewControllers = @[navFeedViewController, navSearchViewController,
                             navMoodRootViewController,
                             navProfileViewController,  navChannelsRootViewController, navActivityViewController];
    
    // == Set the first vc
    self.currentViewController = self.viewControllers[0];
    
    
}


#pragma mark - UIViewController Containment

- (void) setCurrentViewController: (UINavigationController *) currentViewController
{
    if (!currentViewController)
    {
        DebugLog(@"setCurrentViewController: to nil");
        return;
    }
    
    //If the current view is the already showing, dont change.
    if (_currentViewController == currentViewController)
        return;

    
    __weak UINavigationController *toViewController = currentViewController;
    __weak UINavigationController *fromViewController = _currentViewController;
    
    // We need to set this here, as effectively we have commited to the current view controller at this stage
    // and any methods that access this before the transition has completed, need to get the new view controller
    _currentViewController = toViewController;
    
    [fromViewController willMoveToParentViewController: nil]; // remove the current view controller if there is one
    
    [super addChildViewController: toViewController];
    
    // TODO: Remove it when we come up with a good animation
    toViewController.view.frame = CGRectZero;
    
    
    // == Define the completion block == //
    
    void (^ CompleteTransitionBlock)(BOOL) = ^(BOOL finished) {
        [[self view] addSubview: toViewController.view];

        [fromViewController.view removeFromSuperview];
        [fromViewController removeFromParentViewController];
        
        
        for (UIViewController *tmpController in fromViewController.viewControllers) {
            [tmpController.view removeFromSuperview];
        }
        for (UIViewController *tmpController in toViewController.viewControllers) {
            [tmpController didMoveToParentViewController: self];
        }
        
        self.isTransitioning = NO;

    };
    
    __block CGRect correctFrame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    
    // == Do the Transition selectively == //
    if (fromViewController) // if not from first time
    {
        toViewController.view.frame = CGRectZero;
       

        self.isTransitioning = YES;
            [self transitionFromViewController: fromViewController
                              toViewController: toViewController
                                      duration: VIEW_CONTROLLER_TRANSITION_DURATION
                                       options: UIViewAnimationOptionCurveEaseInOut
                                    animations: ^{
                                        toViewController.view.frame = correctFrame;
                                        fromViewController.view.frame = CGRectZero;
                                    }
                                    completion: CompleteTransitionBlock];
        
    }
    else
    {
        toViewController.view.frame = correctFrame;
        CompleteTransitionBlock(YES);
    }
}

- (UINavigationController *) viewControllerByPageName: (NSString *) pageName
{
    UINavigationController *child;
    
    for (child in self.viewControllers)
    {
        if ([pageName isEqualToString: child.title])
        {
            break;
        }
    }
    
    return child;
}


- (NSInteger) indexOfControllerByName: (NSString *) pageName
{
    NSInteger index = 0;
    
    for (SYNAbstractViewController *child in self.viewControllers)
    {
        if ([pageName isEqualToString: child.title])
        {
            break;
        }
        
        index++;
    }
    
    return index;
}

- (void) navigateToPage: (NSInteger) index
{
    
    if (index < 0 || index > self.viewControllers.count)
    {
        self.currentViewController = nil; // will be caught by the setter
    }
    
    
    self.currentViewController = self.viewControllers[index];
    

}


- (void) navigateToPageByName: (NSString *) pageName
{
    self.currentViewController = [self viewControllerByPageName: pageName];
}


#pragma mark - Description

- (NSString *) description
{
    return NSStringFromClass([self class]);
}

@end
