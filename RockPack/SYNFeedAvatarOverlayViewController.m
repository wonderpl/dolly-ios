//
//  SYNFeedAvatarOverlayViewController.m
//  dolly
//
//  Created by Cong on 02/07/2014.
//  Copyright (c) 2014 Wonder PL Ltd. All rights reserved.
//

#import "SYNFeedAvatarOverlayViewController.h"
#import "SYNDeviceManager.h"

@interface SYNFeedAvatarOverlayViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *avatar1;
@property (strong, nonatomic) IBOutlet UIImageView *avatar2;
@property (strong, nonatomic) IBOutlet UIImageView *avatar3;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation SYNFeedAvatarOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutViews];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutViews];
}

- (void)layoutViews {
    if (UIDeviceOrientationIsPortrait([[SYNDeviceManager sharedInstance] orientation])) {
        self.avatar1.frame = CGRectMake(338, 33, 44, 44);
        self.avatar2.frame = CGRectMake(175, 605, 44, 44);
        self.avatar3.frame = CGRectMake(509, 605, 44, 44);
        self.textLabel.frame = CGRectMake(193, 284, 332, 156);
    } else {
        self.avatar1.frame = CGRectMake(292, 180, 44, 44);
        self.avatar2.frame = CGRectMake(758, 90, 44, 44);
        self.avatar3.frame = CGRectMake(758, 440, 44, 44);
        self.textLabel.frame = CGRectMake(143, 341, 332, 156);
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self layoutViews];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutViews];
}

@end
