//
//  SYNOnBoardingOverlayViewController.m
//  dolly
//
//  Created by Cong Le on 20/02/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNOnBoardingOverlayViewController.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"

@interface SYNOnBoardingOverlayViewController ()
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;

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
    
    if (IS_IPHONE) {
        self.textLabel.font = [UIFont lightCustomFontOfSize:15.0f];
    } else {
        self.textLabel.font = [UIFont lightCustomFontOfSize:23.0f];
    }
}


- (void)viewWillLayoutSubviews
{
    if (IS_IPAD) {
        if (UIDeviceOrientationIsLandscape([SYNDeviceManager.sharedInstance orientation])) {
            self.container.frame = CGRectMake(93, 252, 495, 246);
        } else {
            self.container.frame = CGRectMake(100, 252, 495, 246);
        }
    }
}

@end
