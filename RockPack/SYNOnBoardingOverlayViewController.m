//
//  SYNOnBoardingOverlayViewController.m
//  dolly
//
//  Created by Cong Le on 20/02/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNOnBoardingOverlayViewController.h"
#import "SYNDeviceManager.h"
@interface SYNOnBoardingOverlayViewController ()
@property (strong, nonatomic) IBOutlet UIView *container;

@end

@implementation SYNOnBoardingOverlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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


- (void)viewWillLayoutSubviews
{
    if (IS_IPAD) {
        if (UIDeviceOrientationIsLandscape([SYNDeviceManager.sharedInstance orientation])) {
            self.container.frame = CGRectMake(204, 353, 353, 78);
            
        } else {
            
            self.container.frame = CGRectMake(211, 353, 353, 78);
        }
    }
}

@end
