//
//  SYNFeedOverlayViewController.m
//  dolly
//
//  Created by Cong Le on 07/03/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNFeedOverlayAddingViewController.h"
#import "UIFont+SYNFont.h"

@interface SYNFeedOverlayAddingViewController ()
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation SYNFeedOverlayAddingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (IS_IPHONE) {
        self.textLabel.font = [UIFont lightCustomFontOfSize:self.textLabel.font.pointSize];
    } else {
        self.textLabel.font = [UIFont lightCustomFontOfSize:23.0f];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (IS_IPAD) {
        
        if (UIDeviceOrientationIsLandscape([SYNDeviceManager.sharedInstance orientation])) {
            self.container.frame = CGRectMake(49, 347, 522, 410);
        } else {
            self.container.frame = CGRectMake(96, 293, 522, 410);
        }
    }
}

@end
