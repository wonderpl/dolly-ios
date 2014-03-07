//
//  SYNFeedOverlayViewController.m
//  dolly
//
//  Created by Cong Le on 07/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNFeedOverlayViewController.h"
#import "UIFont+SYNFont.h"

@interface SYNFeedOverlayViewController ()
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation SYNFeedOverlayViewController

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
            self.container.frame = CGRectMake(224, 293, 522, 410);

        } else {
            self.container.frame = CGRectMake(96, 293, 522, 410);

        
        }
    }
}

@end
