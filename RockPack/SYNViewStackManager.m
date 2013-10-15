//
//  SYNViewStackManager.m
//  rockpack
//
//  Created by Michael Michailidis on 04/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "ChannelOwner.h"
#import "SYNAbstractViewController.h"
#import "SYNChannelDetailViewController.h"
#import "SYNDeviceManager.h"
#import "SYNMasterViewController.h"
#import "SYNProfileRootViewController.h"
#import "SYNSideNavigatorViewController.h"
#import "SYNViewStackManager.h"
#import "SYNSearchBoxViewController.h"
#import "SYNNetworkMessageView.h"
#import "SYNExistingChannelsViewController.h"

#define STACK_LIMIT 6
#define BG_ALPHA_DEFAULT 0.7f


@implementation SYNViewStackManager



+ (id) manager
{
    return [[self alloc] init];
}


#pragma mark - Specific Views Methods

- (void) viewProfileDetails: (ChannelOwner *) channelOwner
{
    if (!channelOwner)
    {
        return;
    }
    
    SYNProfileRootViewController *profileVC =
    (SYNProfileRootViewController *) [self topControllerMatchingTypeString: NSStringFromClass([SYNProfileRootViewController class])];
    
    if (profileVC)
    {
        [self popToController: profileVC];
    }
    else
    {
        profileVC = [[SYNProfileRootViewController alloc] initWithViewId: kProfileViewId];
        
        [self pushController: profileVC];
    }
    
    profileVC.channelOwner = channelOwner;
    
    [self hideSideNavigator];
}


- (void) viewChannelDetails: (Channel *) channel
{
    [self viewChannelDetails: channel
              withAutoplayId: nil];
}


- (void) viewChannelDetails: (Channel *) channel withAutoplayId: (NSString *) autoplayId
{
    if (!channel)
    {
        return;
    }
    
    SYNChannelDetailViewController *channelVC =
    (SYNChannelDetailViewController *) [self topControllerMatchingTypeString: NSStringFromClass([SYNChannelDetailViewController class])];
    
    if (channelVC)
    {
        channelVC.channel = channel;
        channelVC.autoplayVideoId = autoplayId;
        [self popToController: channelVC];
    }
    else
    {
        channelVC = [[SYNChannelDetailViewController alloc] initWithChannel: channel
                                                                  usingMode: kChannelDetailsModeDisplay];
        
        channelVC.autoplayVideoId = autoplayId;
        [self pushController: channelVC];
    }
    
    [self hideSideNavigator];
}


#pragma mark - Navigation Controller Methods

- (void) pushController: (SYNAbstractViewController *) controller
{
    controller.view.alpha = 0.0f;
    
    [self.masterController headerButtonIsActive:controller.needsHeaderButton];
    
    if (self.masterController.videoViewerViewController) // close the video viewer if in view
        [self.masterController removeVideoOverlayController];
    
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         // Contract thumbnail view
                         self.navigationController.topViewController.view.alpha = 0.0;
                         controller.view.alpha = 1.0f;
                     }
                     completion: nil];
    
    
    [self.navigationController pushViewController: controller
                                         animated: NO];
    
    [self hideSideNavigator];
}


- (void) popController
{
    NSInteger viewControllersCount = self.navigationController.viewControllers.count;
    
    if (viewControllersCount < 2) // we must have at least two to pop one
        return;
    
    
    UIViewController* controllerToPopTo = ((UIViewController *) self.navigationController.viewControllers[viewControllersCount - 2]);
    
    __weak SYNViewStackManager* wself = self;
    
    if([controllerToPopTo isKindOfClass:[SYNAbstractViewController class]])
        [self.masterController headerButtonIsActive:((SYNAbstractViewController *) controllerToPopTo).needsHeaderButton];
    else
        [self.masterController headerButtonIsActive:YES];
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
                         wself.navigationController.topViewController.view.alpha = 0.0f;
                         
                         controllerToPopTo.view.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         
                         if(wself.returnBlock)
                             wself.returnBlock();
                         
                         wself.returnBlock = nil;
                         
                         
                         
                     }];
    
    [self.navigationController popViewControllerAnimated: NO];
    
}



- (void) popToRootController
{
    [self popToController: self.navigationController.viewControllers[0]];
}


- (void) popToController: (UIViewController *) controller
{
    NSInteger viewControllersCount = self.navigationController.viewControllers.count;
    
    // we must have at least two to pop one and the controller must be contained in the navigation view stack
    if (viewControllersCount < 2 || ![self.navigationController.viewControllers
                                      containsObject: controller])
    {
        return;
    }
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         self.navigationController.topViewController.view.alpha = 0.0f;
                         
                         controller.view.alpha = 1.0f;
                     }
                     completion: nil];
    
    [self.navigationController popToViewController: controller
                                          animated: NO];
    
    [self hideSideNavigator];
}

#pragma mark - Search Bar Animations

-(void)dismissSearchBar
{
    [self dismissSearchBarTotal:NO];
}

-(void)dismissSearchBarTotal:(BOOL)total
{
    
    if(IS_IPAD) // this function is only for iPhone
        return;
   
    SYNSearchBoxViewController* searchBoxVC = self.sideNavigatorController.searchViewController;
    
    if(self.searchBarOriginSideNavigation && !total) // open up the side navigation
    {
        [self.sideNavigatorController setState:SideNavigationStateHalf animated:NO];
        
        self.masterController.sideNavigationButton.selected = YES;
        
        self.masterController.darkOverlayView.hidden = NO;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             
                             self.masterController.darkOverlayView.alpha = 1.0;
                             
                         } completion:nil];
    }
    
    
    
    if (self.masterController.isInSearchMode)
    {
        
        [self popController];
    }
    
    self.masterController.closeSearchButton.hidden = YES;
    
    self.masterController.sideNavigationButton.hidden = NO;
    
    
    
    [searchBoxVC removeFromParentViewController];
    [self.masterController.view insertSubview:searchBoxVC.searchBoxView belowSubview:self.masterController.overlayView];
    
    
    
    [searchBoxVC.searchBoxView.searchTextField resignFirstResponder];
    searchBoxVC.searchBoxView.searchTextField.text = @"";
    
    [searchBoxVC clear];
    
    searchBoxVC.searchBoxView.searchTextField.delegate = self.sideNavigatorController;
    
    //
    
    [searchBoxVC dismissSearchCategoriesIPhone];
    
    [UIView animateWithDuration: 0.1f
                          delay: 0.3f
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         
                         [searchBoxVC.searchBoxView hideCloseButton];
                         
                     }
                     completion: ^(BOOL finished) {
                         
                         self.sideNavigatorController.mainContentView.hidden = NO;
                         
                         
                         
                         [UIView animateWithDuration: 0.2f
                                               delay: 0.0f
                                             options: UIViewAnimationOptionCurveEaseInOut
                                          animations: ^{
                                              
                                              self.sideNavigatorController.mainContentView.alpha = 1.0f;
                                              
                                              if(IS_IOS_7_OR_GREATER)
                                                  [searchBoxVC.searchBoxView shrinkForiOS7];
                                              
                                              CGRect newFrame = searchBoxVC.searchBoxView.frame;
                                              
                                              if(self.searchBarOriginSideNavigation && !total)
                                              {
                                                  newFrame.origin = CGPointMake(0.0f, 58.0f);
                                              }
                                                  
                                              
                                              else
                                              {
                                                  newFrame.origin = CGPointMake(0.0f, -58.0f);
                                              }
                                              
                                              
                                              searchBoxVC.searchBoxView.frame = newFrame;
                                              
                                          } completion:^(BOOL finished) {
                                              
                                              CGRect newFrame = searchBoxVC.searchBoxView.frame;
                                              newFrame.origin = CGPointMake(0.0f, IS_IOS_7_OR_GREATER ? 10.0f : 0.0f);
                                              searchBoxVC.searchBoxView.frame = newFrame;
                                              
                                              [searchBoxVC.searchBoxView removeFromSuperview];
                                              [searchBoxVC removeFromParentViewController];
                                              
                                              [self.sideNavigatorController addChildViewController:searchBoxVC];
                                              [self.sideNavigatorController.view addSubview:searchBoxVC.searchBoxView];
                                              
                                          }];
                         
                     }];
}


// for iPhone

-(void)presentSearchBar
{
    
    SYNSearchBoxViewController* searchBoxVC = self.sideNavigatorController.searchViewController;
    
    self.searchBarOriginSideNavigation = (self.sideNavigatorController.state != SideNavigationStateHidden);
    
    
    // do the swap...
    
    [searchBoxVC.searchBoxView removeFromSuperview];
    
    [searchBoxVC removeFromParentViewController];
    
    [self.masterController addChildViewController:searchBoxVC];
    
    [self.masterController.view addSubview:searchBoxVC.searchBoxView];
    
    CGRect newFrame = searchBoxVC.searchBoxView.frame;
    
    if(self.searchBarOriginSideNavigation)
    {
        newFrame.origin = CGPointMake(0.0f, 58.0f);
        searchBoxVC.searchTextField.placeholder = @"Find videos, packs and people";
    }

    else
    {
        newFrame.origin = CGPointMake(0.0f, -58.0f);
        searchBoxVC.searchTextField.placeholder = @"What are you into?";
    }
    
    searchBoxVC.searchBoxView.frame = newFrame;
    
    [UIView animateWithDuration: 0.2f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
                         self.sideNavigatorController.mainContentView.alpha = 0.0f;
                         
                         if(IS_IOS_7_OR_GREATER)
                             [searchBoxVC.searchBoxView enlargeForiOS7]; // set the elements for iOS7
                         
                         CGRect endFrame = searchBoxVC.searchBoxView.frame;
                         
                         if(self.searchBarOriginSideNavigation)
                         {
                             endFrame.origin.y -= 58.0f;
                             
                             
                             
                         }
                         else
                         {
                             endFrame.origin.y += 58.0f;
                             endFrame.size.height -= IS_IOS_7_OR_GREATER ? 10.0f : 0.0f;
                         }
                         
                         
                         
                         
                         searchBoxVC.searchBoxView.frame = endFrame;
                         
                     } completion: ^(BOOL finished) {
                         
                         [UIView animateWithDuration: 0.2
                                               delay:0.0
                                             options: UIViewAnimationOptionCurveEaseOut
                                          animations: ^{
                                              
                                              [searchBoxVC.searchBoxView revealCloseButton];
                                              
                                          } completion:^(BOOL finished) {
                                              if(!IS_IPAD)
                                                  [searchBoxVC presentSearchCategoriesIPhone]; // already animated
                                          }];
                         
                     }];
    
    searchBoxVC.searchBoxView.searchTextField.delegate = searchBoxVC;
}

- (void) hideSideNavigator
{
    self.sideNavigatorController.state = SideNavigationStateHidden;
}

- (void) showSideNavigator
{
    [self.masterController showSideNavigation];
}

-(void) openSideNavigatorToIndex:(NSInteger)index
{
    [self showSideNavigator];
    [self.sideNavigatorController openToIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}
#pragma mark - Popover Managment

-(void)presentCoverViewController:(UIViewController*)viewController
{
    currentOverViewController = viewController;
    
    [self.masterController addChildViewController: viewController];
    
    currentOverViewController.view.alpha = 0.0f;
    
    [self.masterController.view addSubview: viewController.view];
    
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         currentOverViewController.view.alpha = 1.0f;
                     }
                     completion: ^(BOOL finished) {
                         
                     }];
    
}
-(void)removeCoverPopoverViewController
{
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         currentOverViewController.view.alpha = 0.0f;
                     }
                     completion: ^(BOOL finished) {
                         [currentOverViewController removeFromParentViewController];
                         [currentOverViewController.view removeFromSuperview];
                         currentOverViewController = nil;
                     }];
}

-(void)presentPopoverView:(UIView *)view
{
    [self presentPopoverView:view withBackgroundAlpha:BG_ALPHA_DEFAULT];
}

- (void) presentPopoverView:(UIView*)view withBackgroundAlpha:(CGFloat)bgAlpha
{
    if(!view)
        return;
    
    CGRect screenRect = [[SYNDeviceManager sharedInstance] currentScreenRect];

    // fade in the background ...
    
    backgroundView = [[UIView alloc] initWithFrame:screenRect];
    backgroundView.alpha = 0.0f;
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.masterController.view addSubview:backgroundView];
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         backgroundView.alpha = bgAlpha;
                     }
                     completion:^(BOOL finished) {
                         UITapGestureRecognizer* tapToCloseGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                             action:@selector(removePopoverView)];
                         [backgroundView addGestureRecognizer:tapToCloseGesture];
                     }];
    
    // ... and then the popover
    [self.masterController.view addSubview:view];
    popoverView = view;
    if(IS_IPAD)    {
        popoverView.alpha = 0.0;
        popoverView.center = CGPointMake(screenRect.size.width * 0.5, screenRect.size.height * 0.5);
        popoverView.frame = CGRectIntegral(view.frame);
        popoverView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [UIView animateWithDuration: 0.3
                              delay: 0.2
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             
                             view.alpha = 1.0f;
                         }
                         completion:nil];
    }
    else // is IPhone
    {
        __block CGRect pvFrame = popoverView.frame;
        pvFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeightWithStatusBar];
        popoverView.frame = pvFrame;
        
        [UIView animateWithDuration: 0.2
                              delay: 0.1
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             pvFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeightWithStatusBar] - pvFrame.size.height;
                             popoverView.frame = pvFrame;
                         }
                         completion:nil];
    }
    
    
}



-(void)removePopoverView
{
    void(^RemovePopoverComplete)(BOOL) = ^(BOOL finished)
    {
        
        [backgroundView removeFromSuperview];
        [popoverView removeFromSuperview];
        popoverView.hidden = YES;
        backgroundView = nil;
        popoverView = nil;
        
    };
    
    if(IS_IPAD)
    {
        [UIView animateWithDuration: 0.3
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             backgroundView.alpha = 0.0;
                             popoverView.alpha = 0.0;
                         }
                         completion:RemovePopoverComplete];
    }
    else
    {
        __block CGRect pvFrame = popoverView.frame;
        
        [UIView animateWithDuration: 0.2
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             pvFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeight];
                             popoverView.frame = pvFrame;
                         }
                         completion:RemovePopoverComplete];
        
    }
    
}


- (void) displaySideNavigatorFromPushNotification
{
    if(IS_IPHONE)
    {
        self.sideNavigatorController.state = SideNavigationStateHalf;
    }
    
    [self.sideNavigatorController displayFromPushNotification];
}


// for iPhone
- (void) presentModallyController: (UIViewController *) controller
{
    currentOverViewController = controller;
    
    [self.masterController addChildViewController: controller];
    [self.masterController.view addSubview: controller.view];
    
    CGRect controllerFrame = controller.view.frame;
    
    controllerFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeightWithStatusBar];
    controllerFrame.size.height = [[SYNDeviceManager sharedInstance] currentScreenHeightWithStatusBar];
    
    controller.view.frame = controllerFrame;
    
    controllerFrame.origin.y = 0.0f;
    
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         self.masterController.view.userInteractionEnabled = NO;
                         controller.view.frame = controllerFrame;
                     }
                     completion: ^(BOOL finished) {
                         self.masterController.view.userInteractionEnabled = YES;
                     }];
}


- (void) hideModalController
{
    CGRect controllerFrame = currentOverViewController.view.frame;
    
    controllerFrame.origin.y = [[SYNDeviceManager sharedInstance] currentScreenHeight];
    
    [UIView animateWithDuration: 0.3
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations: ^{
                         currentOverViewController.view.frame = controllerFrame;
                         
                         self.masterController.view.userInteractionEnabled = NO;
                     }
                     completion: ^(BOOL finished) {
                         self.masterController.view.userInteractionEnabled = YES;
                         [currentOverViewController.view removeFromSuperview];
                         [currentOverViewController removeFromParentViewController];
                     }];
}



#pragma mark - Network Notification Messages (from the bottom)

-(void)presentErrorNotificationWithMessage : (NSString*)message
{
    [self presentNotificationWithMessage:message withType:NotificationMessageTypeError];
}

- (void) presentSuccessNotificationWithMessage : (NSString*) message
{
     [self presentNotificationWithMessage:message withType:NotificationMessageTypeSuccess];
}

-(void)presentNotificationWithMessage:(NSString*)message withType:(NotificationMessageType)type
{
    __block SYNNetworkMessageView* successNotification = [[SYNNetworkMessageView alloc] init];
    successNotification.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"BarSucess"]];
    [successNotification setText: message];
    
    [self.masterController.view addSubview: successNotification];
    
    [UIView animateWithDuration: 0.3f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         CGRect newFrame = successNotification.frame;
                         newFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar] - newFrame.size.height;
                         successNotification.frame = newFrame;
                     }
                     completion: ^(BOOL finished) {
                         
                         [UIView animateWithDuration: 0.3f
                                               delay: 4.0f
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations: ^{
                                              CGRect newFrame = successNotification.frame;
                                              newFrame.origin.y = [SYNDeviceManager.sharedInstance currentScreenHeightWithStatusBar] + newFrame.size.height;
                                              successNotification.frame = newFrame;
                                          }
                                          completion: ^(BOOL finished) {
                                              [successNotification removeFromSuperview];
                                          }];
                     }];
}



#pragma mark - Helper

- (UIViewController *) topControllerMatchingTypeString: (NSString *) classString
{
    UIViewController *lastControllerOfClass;
    
    if(self.navigationController.viewControllers.count >= STACK_LIMIT)
    {
        for (UIViewController *viewControllerOnStack in self.navigationController.viewControllers)
        {
            if ([viewControllerOnStack isKindOfClass: NSClassFromString(classString)] && viewControllerOnStack != self.navigationController.topViewController)
            {
                lastControllerOfClass = viewControllerOnStack;
            }
        }
    }
    
    return lastControllerOfClass;
}

-(BOOL) controllerViewIsVisible:(SYNAbstractViewController*)controllerToTest
{
    if(self.masterController.showingViewController == controllerToTest)
        return YES;
    
    return NO;
}


#pragma mark - Existing Channels

- (void) presentExistingChannelsController
{
    
    SYNExistingChannelsViewController* existingController = [[SYNExistingChannelsViewController alloc] initWithViewId:kExistingChannelsViewId];
    
    [self.masterController addChildViewController:existingController];
    
    [self.masterController.view addSubview:existingController.view];
    
    // animate in //
    
    existingController.view.alpha = 1.0f;
    
    CGRect newFrame = existingController.view.frame;
    newFrame.origin.y = newFrame.size.height;
    existingController.view.frame = newFrame;
    
    [existingController prepareForAppearAnimation]; // this should fade the cells out in preparation for the animation
    
    [UIView animateWithDuration: kAddToChannelAnimationDuration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
                         CGRect newFrame = existingController.view.frame;
                         newFrame.origin.y = 0.0f;
                         existingController.view.frame = newFrame;
                         
                     }
                     completion: ^(BOOL finished) {
                         
                         [existingController runAppearAnimation]; // this should animate the cells in, one by one
                         
                         
                         if (self.masterController.videoViewerViewController)
                         {
                             [self.masterController.videoViewerViewController pauseIfVideoActive];
                         }
                     }];
}


-(void)resumeVideoIfShowing
{
    
    if(self.masterController.videoViewerViewController)
    {
        [self.masterController.videoViewerViewController playIfVideoActive];
    }
}

@end
