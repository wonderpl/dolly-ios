//
//  SYNDiscoverOverlayHighlightsViewController.m
//  dolly
//
//  Created by Cong Le on 20/02/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNDiscoverOverlayHighlightsViewController.h"
#import "SYNDeviceManager.h"

@interface SYNDiscoverOverlayHighlightsViewController ()
@property (strong, nonatomic) IBOutlet UIView *container;

@end

@implementation SYNDiscoverOverlayHighlightsViewController

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
    [super viewWillLayoutSubviews];
    if (IS_IPAD) {
        
        if (UIDeviceOrientationIsLandscape([SYNDeviceManager.sharedInstance orientation])) {
            NSLog(@"%@", NSStringFromCGRect(self.container.frame));
            
            self.container.frame = CGRectMake(668, 214, 363, 122);
        } else {
            self.container.frame = CGRectMake(405, 214, 363, 122);
            NSLog(@"%@", NSStringFromCGRect(self.container.frame));

        }
    }
}


@end
