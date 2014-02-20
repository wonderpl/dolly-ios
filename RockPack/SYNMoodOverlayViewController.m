//
//  SYNMoodOverlayViewController.m
//  dolly
//
//  Created by Cong Le on 20/02/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNMoodOverlayViewController.h"
#import "SYNPopoverable.h"
#import "SYNDeviceManager.h"

@interface SYNMoodOverlayViewController ()
@property (strong, nonatomic) IBOutlet UIView *container;

@end

@implementation SYNMoodOverlayViewController

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


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    self.view.frame = [[SYNDeviceManager sharedInstance] currentScreenRect];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (IS_IPAD) {
        
        if (UIDeviceOrientationIsLandscape([SYNDeviceManager.sharedInstance orientation])) {
            self.container.frame = CGRectMake(383, 488, 384, 126);
        } else {
            self.container.frame = CGRectMake(215, 601, 384, 126);
        }
    }
}


@end
