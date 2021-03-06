//
//  SYNCollectectionDetailsOverlayViewController.m
//  dolly
//
//  Created by Cong Le on 20/02/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNCollectectionDetailsOverlayViewController.h"
#import "UIFont+SYNFont.h"

@interface SYNCollectectionDetailsOverlayViewController ()
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation SYNCollectectionDetailsOverlayViewController

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
            self.container.frame = CGRectMake(128, 225, 773, 41);
        } else {
            self.container.frame = CGRectMake(0, 225, 773, 41);
        }
    }
}


@end
