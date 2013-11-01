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
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scrollDetected:) name:kScrollMovement object:nil];
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
    if (!IS_IPHONE)
    {
        return;
    }
    
    NSNumber *numOfScrollDirection = [notification object];
    // == Scrolling down, Hide the tab bar
    if (numOfScrollDirection.intValue == ScrollingDirectionDown && _masterController.tabsView.frame.origin.y == _masterController.view.frame.size.height - _masterController.tabsView.frame.size.height)
    {
        [UIView animateWithDuration:0.5f animations:^{
            CGRect tmpFrame = _masterController.tabsView.frame;
            tmpFrame.origin.y += _masterController.tabsView.frame.size.height;
            _masterController.tabsView.frame = tmpFrame;
        }];
    }
    
     // == Scrolling up, Show the tab bar
    if (numOfScrollDirection.intValue == ScrollingDirectionUp && _masterController.tabsView.frame.origin.y == _masterController.view.frame.size.height)
    {
        [UIView animateWithDuration:0.5f animations:^{
            
            CGRect tmpFrame = _masterController.tabsView.frame;
            tmpFrame.origin.y -= _masterController.tabsView.frame.size.height;
            _masterController.tabsView.frame = tmpFrame;
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


- (void) setMasterController: (SYNMasterViewController *) masterController
{
    _masterController = masterController;
    
    for (UIButton *tab in masterController.tabs)
    {
        [tab addTarget: self
                action: @selector(tabPressed:) 
      forControlEvents: UIControlEventTouchUpInside];
        
    }
    
    ((UIButton*)[self.masterController.tabs objectAtIndex:0]).selected = YES;

}


- (void) tabPressed: (UIButton *) tabPressed
{
    for (UIButton *tab in self.masterController.tabs)
    {
        tab.highlighted = (BOOL) (tab == tabPressed);
        tab.selected = (BOOL) (tab == tabPressed);
    }
    
    if (!self.containerController.isTransitioning)
    {
        [self navigateToPage: tabPressed.tag];
    }
    
}


@end
