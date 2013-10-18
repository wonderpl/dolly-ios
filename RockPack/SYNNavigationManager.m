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
#import "SYNSideNavigatorViewController.h"

@implementation SYNNavigationManager

+ (id) manager
{
    return [[SYNNavigationManager alloc] init];
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
    if (index < 0 || index > self.containerController.viewControllers.count)
    {
        return;
    }
    
    self.sideNavigationController.state = SideNavigationStateHidden;
    
    [self.containerController navigateToPage: index];
    
    // == Set the Τitle == //
    self.masterController.pageTitleLabel.text = [self.containerController.currentViewController.title uppercaseString];
    
    if (self.sideNavigationController.state == SideNavigationStateFull)
    {
        [self.sideNavigationController deselectAllCells];
    }
    else
    {
        NSString *controllerTitle = self.containerController.currentViewController.title;
        
        [self.sideNavigationController setSelectedCellByPageName: controllerTitle];
    }
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
}


- (void) tabPressed: (UIButton *) tabPressed
{
    for (UIButton *tab in self.masterController.tabs)
    {
        tab.highlighted = (BOOL) (tab == tabPressed);
    }
    
    [self navigateToPage: tabPressed.tag];
}


@end
