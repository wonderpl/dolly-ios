//
//  SYNTabsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 17/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNTabsViewController.h"
#import "AppConstants.h"
#import "SYNAppDelegate.h"

@interface SYNTabsViewController ()
{
    SYNAppDelegate* appDelegate;
}

@property (nonatomic, strong) NSArray* tabsData;

@end

@implementation SYNTabsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // == Create Data == //
    
    
    self.tabsData = @[kFeedViewId, kFeedViewId, kFeedViewId, kFeedViewId];
    
    // == Populate Tabs == //
    
    appDelegate = (SYNAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
}


-(IBAction)tabButtonPressed:(UIButton*)tabButton
{
    // tags are 1 indexed
    [appDelegate.navigationManager navigateToPageByName:self.tabsData[tabButton.tag-1]];
}

-(NSArray*)tabs
{
    return self.view.subviews;
}


@end
