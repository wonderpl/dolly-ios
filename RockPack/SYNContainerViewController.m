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
#import "SYNActivityViewController.h"
#import "SYNOAuthNetworkEngine.h"
#import "SYNDiscoverViewController.h"
#import "SYNFriendsViewController.h"
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
    

    profileViewController.channelOwner = self.appDelegate.currentUser;
    
    // == Friends Page == //
    
    //SYNFriendsViewController* friendsViewController = [[SYNFriendsViewController alloc] initWithViewId: kFriendsViewId];
    
    // == Activity Page == //
    
    SYNActivityViewController* activityViewController = [[SYNActivityViewController alloc] initWithViewId: kActivityViewId];;
    profileViewController.channelOwner = self.appDelegate.currentUser;
    
    // == Discovery (Search) Page == //
    
    SYNDiscoverViewController* searchViewController = [[SYNDiscoverViewController alloc] initWithViewId:kDiscoverViewId];
    
    // == Hold the vc locally
    
    self.viewControllers = @[feedRootViewController, channelsRootViewController, profileViewController, searchViewController, activityViewController];
    
    
    // == Set the first vc
    
    self.currentViewController = self.viewControllers[0];
    

    
    
}



#pragma mark - UIViewController Containment



-(void)setCurrentViewController:(SYNAbstractViewController *)currentViewController
{
    if(!currentViewController)
    {
        DebugLog(@"setCurrentViewController: to nil");
        return;
        
    }
    
    __weak SYNAbstractViewController* toViewController = currentViewController;
    __weak SYNAbstractViewController* fromViewController = _currentViewController;
    
    [toViewController willMoveToParentViewController:nil]; // remove the current view controller if there is one
    
    [super addChildViewController: toViewController];
    
    
    [[self view] addSubview:toViewController.view];
    
    // == Define the completion block == //
    
    void(^CompleteTransitionBlock)(BOOL) = ^(BOOL finished) {
        
        [fromViewController.view removeFromSuperview];
        
        [fromViewController removeFromParentViewController];
        
        [toViewController didMoveToParentViewController: self];
        
        _currentViewController = toViewController;
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

-(NSInteger)indexOfControllerByName: (NSString*) pageName
{
    NSInteger index = 0;
    for (SYNAbstractViewController* child in self.viewControllers)
    {
        if ([pageName isEqualToString: child.title])
            break;
        
        index++;
        
    }
    return index;
}

-(void)navigateToPage:(NSInteger)index
{
    if(index < 0 || index > self.viewControllers.count)
        self.currentViewController = nil; // will be caught by the setter
    
    self.currentViewController = self.viewControllers[index];
}

-(void)navigateToPageByName:(NSString*)pageName
{
    self.currentViewController = [self viewControllerByPageName:pageName];
    
}

#pragma mark - Description

- (NSString *) description
{
    return NSStringFromClass([self class]);
}





@end
