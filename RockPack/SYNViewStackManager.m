//
//  SYNViewStackManager.m
//  rockpack
//
//  Created by Michael Michailidis on 04/07/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "ChannelOwner.h"
#import "SYNAbstractViewController.h"
#import "SYNCollectionDetailsViewController.h"
#import "SYNDeviceManager.h"
#import "SYNMasterViewController.h"
#import "SYNProfileRootViewController.h"
#import "SYNViewStackManager.h"
#import "SYNNetworkMessageView.h"
#import "SYNExistingCollectionsViewController.h"

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
    
}

- (void) viewProfileDetails: (ChannelOwner *) channelOwner withNavigationController:(UINavigationController*) navigationController
{
    if (!channelOwner)
    {
        return;
    }
    
    SYNProfileRootViewController *profileVC =
    (SYNProfileRootViewController *) [self topControllerMatchingTypeString: NSStringFromClass([SYNProfileRootViewController class])];
    
    if (profileVC)
    {
        [navigationController popToViewController: profileVC animated:NO];
    }
    else
    {
        
        profileVC = [[SYNProfileRootViewController alloc] initWithViewId: kProfileViewId WithMode:OtherUsersProfile];

        [navigationController pushViewController:profileVC animated:NO];

    }
    
    profileVC.channelOwner = channelOwner;
    
}



- (void) viewChannelDetails: (Channel *) channel
{
    [self viewChannelDetails: channel withAutoplayId: nil];
}

- (void) viewChannelDetails: (Channel *) channel withNavigationController:(UINavigationController*) navigationController
{
    [self viewChannelDetails: channel withAutoplayId: nil withNavigationController: navigationController];
}



- (void) viewChannelDetails: (Channel *) channel withAutoplayId: (NSString *) autoplayId withNavigationController:(UINavigationController*) navigationController
{
    if (!channel)
    {
        return;
    }
    
    SYNCollectionDetailsViewController *channelVC =
    (SYNCollectionDetailsViewController *) [self topControllerMatchingTypeString: NSStringFromClass([SYNCollectionDetailsViewController class])];
    
    if (channelVC)
    {
        channelVC.channel = channel;
        channelVC.autoplayVideoId = autoplayId;
        [navigationController popToViewController:channelVC animated:nil];
    }
    else
    {
        channelVC = [[SYNCollectionDetailsViewController alloc] initWithChannel: channel
                                                                  usingMode: kChannelDetailsModeDisplay];
        channelVC.autoplayVideoId = autoplayId;
        [navigationController pushViewController:channelVC animated:nil];
    }
}

- (void) viewChannelDetails: (Channel *) channel withAutoplayId: (NSString *) autoplayId
{
    if (!channel)
    {
        return;
    }
    
    SYNCollectionDetailsViewController *channelVC =
    (SYNCollectionDetailsViewController *) [self topControllerMatchingTypeString: NSStringFromClass([SYNCollectionDetailsViewController class])];
    
    if (channelVC)
    {
        channelVC.channel = channel;
        channelVC.autoplayVideoId = autoplayId;
        [self popToController: channelVC];
    }
    else
    {
        channelVC = [[SYNCollectionDetailsViewController alloc] initWithChannel: channel
                                                                  usingMode: kChannelDetailsModeDisplay];
        channelVC.autoplayVideoId = autoplayId;
        [self pushController: channelVC];
    }
    
}


#pragma mark - Navigation Controller Methods

- (void) pushController: (SYNAbstractViewController *) controller
{
    controller.view.alpha = 0.0f;
    
    
    if (self.masterController.videoViewerViewController) // close the video viewer if in view
        [self.masterController removeVideoOverlayController];
    
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut |UIViewAnimationOptionBeginFromCurrentState
                     animations: ^{
                         // Contract thumbnail view
                         self.navigationController.topViewController.view.alpha = 0.0;
                         controller.view.alpha = 1.0f;
                     }
                     completion: nil];
    [self.navigationController pushViewController: controller
                                         animated: YES];
}


- (void) popController
{
    NSInteger viewControllersCount = self.navigationController.viewControllers.count;
    
    if (viewControllersCount < 2) // we must have at least two to pop one
        return;
    
    UIViewController* controllerToPopTo = ((UIViewController *) self.navigationController.viewControllers[viewControllersCount - 2]);
    
    __weak SYNViewStackManager* wself = self;
    
    
    
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         
                         self.navigationController.topViewController.view.alpha = 0.0f;
                         
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
    
    
}

#pragma mark - Search Bar Animations






// for iPhone








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

@end
