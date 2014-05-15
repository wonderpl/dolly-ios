//
//  SYNInBoardingViewController.m
//  dolly
//
//  Created by Cong Le on 20/02/2014.
//  Copyright (c) 2014 Rockpack Ltd. All rights reserved.
//

#import "SYNInBoardingViewController.h"
#import "SYNDeviceManager.h"
#import "UIFont+SYNFont.h"
@interface SYNInBoardingViewController ()

@end

@implementation SYNInBoardingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) addToViewController :(UIViewController*) vc {
//        
//        // Set frame to full screen
//        CGRect vFrame = self.view.frame;
//        vFrame.size = [[SYNDeviceManager sharedInstance] currentScreenSize];
//        self.view.frame = vFrame;
//        self.view.alpha = 0.0f;
//        
//        [vc addChildViewController:self];
//        [vc.view addSubview:self.view];
//        [UIView animateWithDuration:2.0 animations:^{
//            self.view.alpha = 1.0f;
//        }];
}

- (void)screenTapped:(UITapGestureRecognizer*)tapGesture {
    
    [UIView animateWithDuration:0.6f animations:^{
        self.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromParentViewController];
    }];

}


@end
