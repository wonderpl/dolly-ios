//
//  SYNFeedOverlayLovingViewController.m
//  dolly
//
//  Created by Cong on 21/05/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNFeedOverlayLovingViewController.h"

@interface SYNFeedOverlayLovingViewController ()
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UIImageView *heartImage;

@end

@implementation SYNFeedOverlayLovingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (IS_IPAD) {
        
        if (UIDeviceOrientationIsLandscape([SYNDeviceManager.sharedInstance orientation])) {
            self.heartImage.frame = CGRectMake(136, 404, 24, 22);
            self.textLabel.frame = CGRectMake(77, 251, 332, 129);
        } else {

            self.heartImage.frame = CGRectMake(183, 350, 24, 22);
            self.textLabel.frame = CGRectMake(123, 197, 332, 129);
        }
    }
}


@end
