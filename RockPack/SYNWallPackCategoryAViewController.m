//
//  SYNWallPackCategoryAViewController.m
//  RockPack
//
//  Created by Nick Banks on 14/10/2012.
//  Copyright (c) 2012 Nick Banks. All rights reserved.
//

#import "AppConstants.h"
#import "SYNWallPackCategoryAViewController.h"

@interface SYNWallPackCategoryAViewController ()

@end

@implementation SYNWallPackCategoryAViewController

- (id) initWithNibName: (NSString *) nibNameOrNil
                bundle: (NSBundle *) nibBundleOrNil
{
    self = [super initWithNibName: nibNameOrNil
                           bundle: nibBundleOrNil];
    if (self)
    {
        CGRect xibFrame = self.view.frame;
        xibFrame.origin.y += kTabTopContentOffset;
        self.view.frame = xibFrame;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
