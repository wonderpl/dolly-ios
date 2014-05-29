//
//  SYNShopMotionOverlayViewController.m
//  dolly
//
//  Created by Cong on 29/05/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNShopMotionOverlayViewController.h"

@interface SYNShopMotionOverlayViewController ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UIImageView *tabImage;
@property (strong, nonatomic) IBOutlet UIImageView *shopMotionImage;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tabButtonHorizontal;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tabButtonHorizontalConstant;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tabButtonVerticalConstant;

@end

@implementation SYNShopMotionOverlayViewController

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
    // Do any additional setup after loading the view.
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
        
            [self.tabButtonHorizontalConstant setConstant:221];
			[self.tabButtonVerticalConstant setConstant:584];
            
        } else {
            [self.tabButtonHorizontalConstant setConstant:91];
			[self.tabButtonVerticalConstant setConstant:584];
        }
    }
}



@end
