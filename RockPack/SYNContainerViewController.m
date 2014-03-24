//
//  SYNContainerViewController.m
//  RockPack
//
//  Created by Nick Banks on 13/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "SYNContainerViewController.h"
#import "SYNAppDelegate.h"
#import "SYNFeedRootViewController.h"
#import "SYNMoodRootViewController.h"
#import "SYNActivityViewController.h"
#import "SYNDiscoverViewController.h"
#import "SYNProfileRootViewController.h"
#import "UIFont+SYNFont.h"
#import "UINavigationBar+Appearance.h"

@import AudioToolbox;
@import QuartzCore;


#define VIEW_CONTROLLER_TRANSITION_DURATION 0.4

@interface SYNContainerViewController ()

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) UINavigationController *currentViewController;
@property (nonatomic, weak) SYNAppDelegate *appDelegate;

@end


@implementation SYNContainerViewController

// Initialise all the elements common to all 4 tabs
#pragma mark - View lifecycle

-(void)setView:(UIView *)view
{
    [super setView:view];
    [self viewDidLoad];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = (SYNAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:nil
                                                                  action:nil];
	
    // == Feed Page == //
    
    SYNFeedRootViewController *feedRootViewController = [[SYNFeedRootViewController alloc] initWithViewId: kFeedViewId];
    feedRootViewController.navigationItem.backBarButtonItem = backButton;
    UINavigationController *navFeedViewController = [[UINavigationController alloc] initWithRootViewController:feedRootViewController];
    
    // == Profile Page == //

    SYNProfileRootViewController *profileViewController = [[SYNProfileRootViewController alloc] initWithViewId: kProfileViewId];
    profileViewController.navigationItem.backBarButtonItem = backButton;
    UINavigationController *navProfileViewController = [[UINavigationController alloc] initWithRootViewController: profileViewController];
    
    
    
    if (!IS_IPAD)
    {
        profileViewController.hideUserProfile = YES;
    }
    
    profileViewController.channelOwner = self.appDelegate.currentUser;
    
    // == Activity Page == //
    
    SYNActivityViewController *activityViewController = [[SYNActivityViewController alloc] initWithViewId: kActivityViewId];
    activityViewController.navigationItem.backBarButtonItem = backButton;
    UINavigationController *navActivityViewController = [[UINavigationController alloc] initWithRootViewController:activityViewController];
    
    // == Discovery (Search) Page == //
    SYNDiscoverViewController *discoveryViewController = [[SYNDiscoverViewController alloc] initWithViewId: kDiscoverViewId];
    discoveryViewController.navigationItem.backBarButtonItem = backButton;
    UINavigationController *navSearchViewController = [[UINavigationController alloc] initWithRootViewController:discoveryViewController];
    
    // == Feed Page == //
    
    SYNMoodRootViewController *moodRootViewController = [[SYNMoodRootViewController alloc] initWithViewId: kMoodViewId];
    moodRootViewController.navigationItem.backBarButtonItem = backButton;
    UINavigationController *navMoodRootViewController = [[UINavigationController alloc] initWithRootViewController:moodRootViewController];
    
    // == Hold the vc locally
    self.viewControllers = @[navFeedViewController, navSearchViewController,
                             navMoodRootViewController,
                             navProfileViewController, navActivityViewController];
    
    
    
    // == Set all navigation bars transparent, the navigation titles are set to @"" in the abstract
    if (IS_IPAD) {
        for (UINavigationController *tmpNav in self.viewControllers) {
            [tmpNav.navigationBar setBackgroundTransparent:YES];
        }
    }
    
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

    UINavigationController *toViewController = currentViewController;
    UINavigationController *fromViewController = _currentViewController;
    
    // We need to set this here, as effectively we have commited to the current view controller at this stage
    // and any methods that access this before the transition has completed, need to get the new view controller
    _currentViewController = toViewController;
    
    [fromViewController willMoveToParentViewController: nil]; // remove the current view controller if there is one
    
    [super addChildViewController: toViewController];
    [self.view addSubview: toViewController.view];
    
    // just make sure on right dimensions
    toViewController.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    
    [fromViewController.view removeFromSuperview];
    [fromViewController removeFromParentViewController];
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
    //If the user taps the current tab they are on, pop to root
    if (self.currentViewController == self.viewControllers[index]) {
        [((UINavigationController*)self.viewControllers[index]) popToRootViewControllerAnimated:YES];
    }

    //Always pop the discovery screen to root
    if(((UINavigationController*)self.viewControllers[1]).viewControllers.count > 1){        [((UINavigationController*)self.viewControllers[1]) popToRootViewControllerAnimated:NO];

    }
    
    self.currentViewController = self.viewControllers[index];
    

}

@end
