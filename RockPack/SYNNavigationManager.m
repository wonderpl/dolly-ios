//
//  SYNNavigationManager.m
//  rockpack
//
//  Created by Michael Michailidis on 17/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNNavigationManager.h"
#import "SYNAbstractViewController.h"
#import "SYNContainerViewController.h"
#import "SYNMasterViewController.h"
#import "SYNSideNavigatorViewController.h"
#import "SYNTabsViewController.h"

@implementation SYNNavigationManager

+(id)manager
{
    return [[SYNNavigationManager alloc] init];
}

-(void)navigateToPageByName:(NSString*)pageName
{
    if(!pageName)
        return;
    
    NSInteger index = [self.containerController indexOfControllerByName:pageName];
    [self navigateToPage:index];
    
    
}

-(void)navigateToPage:(NSInteger)index
{
    if(index < 0 || index > self.containerController.viewControllers.count)
        return;
    
    
    // Set to the correct tab
    // note: it is a little convoluted for tabs to call this class to change itself but it allows for extra checking and synching the views with the state of the app
    
    for (UIButton* tab in self.tabsViewController.tabs)
        tab.highlighted = (BOOL)(tab.tag == index + 1);
    
    
    self.sideNavigationController.state = SideNavigationStateHidden;
    
    [self.containerController navigateToPage:index];
    
    // TODO: Check if it is changed and keep (refactor) accordingly
    //    if (self.showingBackButton)
    //    {
    //        //pop the current section navcontroller to the root controller
    //        [appDelegate.viewStackManager popToRootController];
    //
    //        [self showBackButton:NO];
    //    }
    
    
}


@end
