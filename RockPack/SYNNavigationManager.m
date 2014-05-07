//
//  SYNNavigationManager.m
//  rockpack
//
//  Created by Michael Michailidis on 17/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNAbstractViewController.h"
#import "SYNContainerViewController.h"
#import "SYNMasterViewController.h"
#import "SYNNavigationManager.h"

#define NAV_BAR_ANIMATION_SPEED 0.3f

@interface SYNNavigationManager ()

@property (nonatomic) BOOL isTabBarHidden;

@end

@implementation SYNNavigationManager


+ (id) manager
{
    return [[SYNNavigationManager alloc] init];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(scrollDetected:)
                                                    name:kScrollMovement
                                                  object:nil];
        self.isTabBarHidden = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kScrollMovement object:nil];
}

- (void)scrollDetected:(NSNotification *)notification
{
 
    // == Check for ipad
    if (IS_IPAD)
        return;
	
	SYNMasterViewController *masterViewController = self.masterController;
    
    NSNumber *numOfScrollDirection = [notification.userInfo objectForKey:kScrollingDirection];
    // == Scrolling down, Hide the tab bar
    if (numOfScrollDirection.intValue == ScrollingDirectionDown && _masterController.tabsView.frame.origin.y == _masterController.view.frame.size.height - _masterController.tabsView.frame.size.height)
    {
        [UIView animateWithDuration:NAV_BAR_ANIMATION_SPEED animations:^{
            CGRect tmpFrame = masterViewController.tabsView.frame;
            tmpFrame.origin.y += masterViewController.tabsView.frame.size.height;
            masterViewController.tabsView.frame = tmpFrame;
        } completion:^(BOOL finished) {
            self.isTabBarHidden = YES;
        }];
    }
    
     // == Scrolling up, Show the tab bar
    if (numOfScrollDirection.intValue == ScrollingDirectionUp && _masterController.tabsView.frame.origin.y == _masterController.view.frame.size.height)
    {
        [UIView animateWithDuration:NAV_BAR_ANIMATION_SPEED animations:^{
            
            CGRect tmpFrame = masterViewController.tabsView.frame;
            tmpFrame.origin.y -= masterViewController.tabsView.frame.size.height;
            masterViewController.tabsView.frame = tmpFrame;
        } completion:^(BOOL finished) {
            self.isTabBarHidden = NO;
        }];
    }

}

- (void)hideTabBar
{
    SYNMasterViewController *masterViewController = self.masterController;
    // == Scrolling down, Hide the tab bar
    if (_masterController.tabsView.frame.origin.y == _masterController.view.frame.size.height - _masterController.tabsView.frame.size.height)
    {
        [UIView animateWithDuration:NAV_BAR_ANIMATION_SPEED animations:^{
            CGRect tmpFrame = masterViewController.tabsView.frame;
            tmpFrame.origin.y += masterViewController.tabsView.frame.size.height;
            masterViewController.tabsView.frame = tmpFrame;
        } completion:^(BOOL finished) {
            self.isTabBarHidden = YES;

        }];
    }
}

- (void)showTabBar
{
    SYNMasterViewController *masterViewController = self.masterController;

    if (_masterController.tabsView.frame.origin.y == _masterController.view.frame.size.height)
    {
        [UIView animateWithDuration:NAV_BAR_ANIMATION_SPEED animations:^{
            
            CGRect tmpFrame = masterViewController.tabsView.frame;
            tmpFrame.origin.y -= masterViewController.tabsView.frame.size.height;
            masterViewController.tabsView.frame = tmpFrame;
        }completion:^(BOOL finished) {
            self.isTabBarHidden = NO;
        }];
    }
}



- (void) navigateToPageByName: (NSString *) pageName
{
    if (!pageName)
    {
        return;
    }
    
    NSInteger index = [self.containerController
                       indexOfControllerByName: pageName];
    
    [self navigateToPage: index];
}


- (void) navigateToPage: (NSInteger) index
{
    
    // == Check the index is within the bounds of the controller's array
    if (index < 0 || index > self.containerController.viewControllers.count)
    {
        return;
    }
    [self.containerController navigateToPage: index];
    
}


- (void)switchToFeed {
	// FIXME: For some stupid reason the indexes in the view controllers array and the tab bar are different
	[self navigateToPage:0];
	
	for (UIButton *button in self.masterController.tabs) {
		button.selected = NO;
	}
    ((UIButton*)[self.masterController.tabs objectAtIndex:1]).selected = YES;
}

- (void) setMasterController: (SYNMasterViewController *) masterController
{
    _masterController = masterController;
    
    for (UIButton *tab in masterController.tabs)
    {
        [tab addTarget: self
                action: @selector(tabPressed:) 
      forControlEvents: UIControlEventTouchUpInside];
        
    }
    
    ((UIButton*)[self.masterController.tabs objectAtIndex:1]).selected = YES;

}


- (void) tabPressed: (UIButton *) tabPressed
{
    
    for (UIButton *tab in self.masterController.tabs)
    {
        tab.highlighted = (BOOL) (tab == tabPressed);
        tab.selected = (BOOL) (tab == tabPressed);
    }
	
	[self navigateToPage:tabPressed.tag];
}


@end
