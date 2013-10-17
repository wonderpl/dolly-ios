//
//  SYNTabsViewController.m
//  rockpack
//
//  Created by Michael Michailidis on 17/10/2013.
//  Copyright (c) 2013 Nick Banks. All rights reserved.
//

#import "SYNTabsViewController.h"
#import "AppConstants.h"

@interface SYNTabsViewController ()

@property (nonatomic, strong) NSArray* tabsData;

@end

@implementation SYNTabsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // == Create Data == //
    
    
    self.tabsData = @[kFeedViewId, kFeedViewId, kFeedViewId, kFeedViewId];
    
    // == Populate Tabs == //
    
    
    
    
}


-(IBAction)tabButtonPressed:(UIButton*)tabButton
{
    switch (tabButton.tag) {
        case 1:
            
            break;
        case 2:
            
            break;
        case 3:
            
            break;
        case 4:
            
            break;
        case 5:
            
            break;
        default:
            DebugLog(@"Tab with unknown tag %i clicked", tabButton.tag);
            break;
            
    }
    
}



@end
