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


- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scrollDetected:) name:@"ScrollDetected" object:nil];

    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ScrollDetected" object:nil];
}

- (void)scrollDetected:(NSNotification *)notification
{
 
    //Worse case check for ipad
    if (!IS_IPHONE) {
        return;
    }
    
    NSNumber *numOfScrollDirection = [notification object];
        
    if (numOfScrollDirection.intValue == ScrollingDirectionDown && _masterController.tabsView.frame.origin.y == 519.0f) {
        [UIView animateWithDuration:0.5f animations:^{
            CGRect tmpFrame = _masterController.tabsView.frame;
            tmpFrame.origin.y += _masterController.tabsView.frame.size.height;
            _masterController.tabsView.frame = tmpFrame;
        }];
    }

    if (numOfScrollDirection.intValue == ScrollingDirectionUp && _masterController.tabsView.frame.origin.y == 568.0f) {
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
    
    self.sideNavigationController.state = SideNavigationStateHidden;
    
    [self.containerController navigateToPage: index];
    
    
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
    
    if (!self.containerController.inTransitioning)
    {
        [self navigateToPage: tabPressed.tag];
    }
    
}


-(void) scrollMoved: (UIScrollView *) scrollMoved{
  //  CGRect newFrame = _masterController.tabsView.frame;
   // NSLog(@"Navigation %@, ",scrollMoved);
   // NSLog (@"%@",scrollMoved);

}

@end
