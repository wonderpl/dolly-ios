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

@implementation SYNNavigationManager

+(id)manager
{
    return [[SYNNavigationManager alloc] init];
}

-(void)navigateToPage:(NSInteger)index
{
    
}
-(void)navigateToPageByName:(NSString*)pageName
{
    if(!pageName)
        return;
    
    
    
    
    // TODO: Check if it is changed and keep (refactor) accordingly
    //    if (self.showingBackButton)
    //    {
    //        //pop the current section navcontroller to the root controller
    //        [appDelegate.viewStackManager popToRootController];
    //
    //        [self showBackButton:NO];
    //    }
    
    //Scroll to the requested page
    
    [self.containerController navigateToPageByName:pageName];
    
    self.sideNavigationController.state = SideNavigationStateHidden;
}

@end
